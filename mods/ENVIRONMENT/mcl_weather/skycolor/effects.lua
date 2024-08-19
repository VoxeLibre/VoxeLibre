local DIM_ALLOW_NIGHT_VISION = {
	overworld = true,
	void = true,
}

local NIGHT_VISION_RATIO = mcl_weather.skycolor.NIGHT_VISION_RATIO
local effects_handlers = {}
local has_mcl_potions = mcl_util.to_bool(minetest.get_modpath("mcl_potions"))

function effects_handlers.darkness(player, meta, effect, sky_data)
	-- No darkness effect if is a visited shepherd
	if meta:get_int("mcl_shepherd:special") == 1 then return end

	-- High stars
	sky_data.stars = {visible = false}

	-- Minor visibility if the player has the night vision effect
	if mcl_potions.has_effect(player, "night_vision") then
		sky_data.day_night_ratio = 0.1
	else
		sky_data.day_night_ratio = 0
	end
end

function effects_handlers.night_vision(player, meta, effect, sky_data)
	-- Apply night vision only for dark sky
	if not (minetest.get_timeofday() > 0.8 or minetest.get_timeofday() < 0.2 or mcl_weather.state ~= "none") then return end

	-- Only some dimensions allow night vision
	local pos = player:get_pos()
	local dim = mcl_worlds.pos_to_dimension(pos)
	if not DIM_ALLOW_NIGHT_VISION[dim] then return end

	-- Apply night vision
	sky_data.day_night_ratio = math.max(sky_data.day_night_ratio or 0, NIGHT_VISION_RATIO)
end

local function effects(player, sky_data)
	if not has_mcl_potions then return end

	local meta = player:get_meta()
	for name,effect in pairs(mcl_potions.registered_effects) do
		local effect_data = mcl_potions.get_effect(player, name)
		if effect_data then
			local hook = effect.mcl_weather_skycolor or effects_handlers[name]
			if hook then hook(player, meta, effect_data, sky_data) end
		end
	end

	-- Handle night vision for shepherd
	if meta:get_int("mcl_shepherd:special") == 1 then
		return effects_handlers.night_vision(player, meta, {}, sky_data)
	end
end
table.insert(mcl_weather.skycolor.filters, effects)

