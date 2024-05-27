-- Constants
local NIGHT_VISION_RATIO = 0.45
local MINIMUM_LIGHT_LEVEL = 0.2
local DEFAULT_WATER_COLOR = "#3F76E4"

-- Module state
local mods_loaded = false
local water_color = DEFAULT_WATER_COLOR
local mg_name = minetest.get_mapgen_setting("mg_name")

function mcl_weather.set_sky_box_clear(player, sky, fog)
	local pos = player:get_pos()
	if minetest.get_item_group(minetest.get_node(vector.new(pos.x,pos.y+1.5,pos.z)).name, "water") ~= 0 then return end
	local sc = {
			day_sky = "#7BA4FF",
			day_horizon = "#C0D8FF",
			dawn_sky = "#7BA4FF",
			dawn_horizon = "#C0D8FF",
			night_sky = "#000000",
			night_horizon = "#4A6790",
			indoors = "#C0D8FF",
			fog_sun_tint = "#ff5f33",
			fog_moon_tint = nil,
			fog_tint_type = "custom"
		}
	if sky then
		sc.day_sky = sky
		sc.dawn_sky = sky
	end
	if fog then
		sc.day_horizon = fog
		sc.dawn_horizon = fog
	end
	player:set_sky({
		type = "regular",
		sky_color = sc,
		clouds = true,
	})
end

function mcl_weather.set_sky_color(player, def)
	local pos = player:get_pos()
	if minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, 1.5, 0)).name, "water") ~= 0 then return end
	player:set_sky({
		type = def.type,
		sky_color = def.sky_color,
		clouds = def.clouds,
	})
end

-- Function to work out light modifier at different times
-- Noon is brightest, midnight is darkest, 0600 and 18000 is in the middle of this
local function get_light_modifier(time)
	-- 0.1 = 0.2
	-- 0.4 = 0.8
	-- 0.5 = 1
	-- 0.6 = 0.8
	-- 0.9 = 0.2

	local light_multiplier =  time * 2
	if time > 0.5 then
		light_multiplier = 2 * (1 - time)
	else
		light_multiplier = time / 0.5
	end
	return light_multiplier
end

local skycolor = {
	-- Should be activated before do any effect.
	active = true,

	-- To skip update interval
	force_update = true,

	-- Update interval.
	update_interval = 3,

	-- Main sky colors: starts from midnight to midnight.
	-- Please do not set directly. Use add_layer instead.
	colors = {},

	-- min value which will be used in color gradient, usualy its first user given color in 'pure' color.
	min_val = 0,

	-- number of colors while constructing gradient of user given colors
	max_val = 1000,

	-- Table for tracking layer order
	layer_names = {},

	utils = {},
}
mcl_weather.skycolor = skycolor
local skycolor_utils = skycolor.utils

-- To layer to colors table
function skycolor.add_layer(layer_name, layer_color, instant_update)
	mcl_weather.skycolor.colors[layer_name] = layer_color
	table.insert(mcl_weather.skycolor.layer_names, layer_name)
	mcl_weather.skycolor.force_update = true
end

function skycolor.current_layer_name()
	return mcl_weather.skycolor.layer_names[#mcl_weather.skycolor.layer_names]
end

-- Retrieve layer from colors table
function skycolor.retrieve_layer()
	local last_layer = mcl_weather.skycolor.current_layer_name()
	return mcl_weather.skycolor.colors[last_layer]
end

-- Remove layer from colors table
function skycolor.remove_layer(layer_name)
	for k, name in pairs(mcl_weather.skycolor.layer_names) do
		if name == layer_name then
			table.remove(mcl_weather.skycolor.layer_names, k)
			mcl_weather.skycolor.force_update = true
			return
		end
	end
end

-- Wrapper for updating day/night ratio that respects night vision
function skycolor.override_day_night_ratio(player, ratio)
	player._skycolor_day_night_ratio = ratio
	skycolor.update_player_sky_color(player)
	player._skycolor_day_night_ratio = nil
end





function water_sky(player, sky_data)
	local pos = player:get_pos()
	local water_color = DEFAULT_WATER_COLOR

	local checkname = minetest.get_node(vector.new(pos.x,pos.y+1.5,pos.z)).name
	if minetest.get_item_group(checkname, "water") == 0 then return end

	local biome_index = minetest.get_biome_data(player:get_pos()).biome
	local biome_name = minetest.get_biome_name(biome_index)
	local biome = minetest.registered_biomes[biome_name]
	if biome then water_color = biome._mcl_waterfogcolor end
	if not biome then water_color = "#3F76E4" end

	if checkname == "mclx_core:river_water_source" or checkname == "mclx_core:river_water_flowing" then water_color = "#0084FF" end

	sky_data.sky = { type = "regular",
		sky_color = {
			day_sky = water_color,
			day_horizon = water_color,
			dawn_sky = water_color,
			dawn_horizon = water_color,
			night_sky = water_color,
			night_horizon = water_color,
			indoors = water_color,
			fog_sun_tint = water_color,
			fog_moon_tint = water_color,
			fog_tint_type = "custom"
		},
		clouds = false,
	}
end





local dimension_handlers = {}
function dimension_handlers.overworld(player, sky_data)
	local pos = player:get_pos()
	local has_weather = (mcl_worlds.has_weather(pos) and (mcl_weather.state == "snow" or mcl_weather.state =="rain" or mcl_weather.state == "thunder") and mcl_weather.has_snow(pos)) or ((mcl_weather.state =="rain" or mcl_weather.state == "thunder") and mcl_weather.has_rain(pos))

	local biomesky
	local biomefog
	if mg_name ~= "v6" and mg_name ~= "singlenode" then
		local biome_index = minetest.get_biome_data(player:get_pos()).biome
		local biome_name = minetest.get_biome_name(biome_index)
		local biome = minetest.registered_biomes[biome_name]
		if biome then
			--minetest.log("action", string.format("Biome found for number: %s in biome: %s", tostring(biome_index), biome_name))
			biomesky = biome._mcl_skycolor
			biomefog = biome._mcl_fogcolor
		else
			--minetest.log("action", string.format("No biome for number: %s in biome: %s", tostring(biome_index), biome_name))
		end
	end
	if (mcl_weather.state == "none") then
		-- Clear weather
		mcl_weather.set_sky_box_clear(player,biomesky,biomefog)
		sky_data.sun = {visible = true, sunrise_visible = true}
		sky_data.moon = {visible = true}
		sky_data.stars = {visible = true}
	elseif not has_weather then
		local day_color = mcl_weather.skycolor.get_sky_layer_color(0.15)
		local dawn_color = mcl_weather.skycolor.get_sky_layer_color(0.27)
		local night_color = mcl_weather.skycolor.get_sky_layer_color(0.1)
		sky_data.sky = {
			type = "regular",
			sky_color = {
				day_sky = day_color,
				day_horizon = day_color,
				dawn_sky = dawn_color,
				dawn_horizon = dawn_color,
				night_sky = night_color,
				night_horizon = night_color,
			},
			clouds = true,
		}
		sky_data.sun = {visible = false, sunrise_visible = false}
		sky_data.moon = {visible = false}
		sky_data.stars = {visible = false}
	elseif has_weather then
		-- Weather skies
		local day_color = mcl_weather.skycolor.get_sky_layer_color(0.5)
		local dawn_color = mcl_weather.skycolor.get_sky_layer_color(0.75)
		local night_color = mcl_weather.skycolor.get_sky_layer_color(0)
		sky_data.sky = {
			type = "regular",
			sky_color = {
				day_sky = day_color,
				day_horizon = day_color,
				dawn_sky = dawn_color,
				dawn_horizon = dawn_color,
				night_sky = night_color,
				night_horizon = night_color,
			},
			clouds = true,
		}
		sky_data.sun = {visible = false, sunrise_visible = false}
		sky_data.moon = {visible = false}
		sky_data.stars = {visible = false}

		local light_factor = mcl_weather.get_current_light_factor()
		if mcl_weather.skycolor.current_layer_name() == "lightning" then
			sky_data.day_night_ratio = 1
		elseif light_factor then
			local time = minetest.get_timeofday()
			local light_multiplier = get_light_modifier(time)
			local new_light = math.max(light_factor * light_multiplier, MINIMUM_LIGHT_LEVEL)
			sky_data.day_night_ratio = new_light
		end
	end
end
dimension_handlers["end"] = function(player, sky_data)
	local biomesky = "#000000"
	local biomefog = "#A080A0"
	if mg_name ~= "v6" and mg_name ~= "singlenode" then
		local biome_index = minetest.get_biome_data(player:get_pos()).biome
		local biome_name = minetest.get_biome_name(biome_index)
		local biome = minetest.registered_biomes[biome_name]
		if biome then
			--minetest.log("action", string.format("Biome found for number: %s in biome: %s", tostring(biome_index), biome_name))
			biomesky = biome._mcl_skycolor
			biomefog = biome._mcl_fogcolor -- The End biomes seemingly don't use the fog colour, despite having this value according to the wiki. The sky colour is seemingly used for both sky and fog?
		else
			--minetest.log("action", string.format("No biome for number: %s in biome: %s", tostring(biome_index), biome_name))
		end
	end
	local t = "mcl_playerplus_end_sky.png"
	sky_data.sky = { type = "skybox",
		base_color = biomesky,
		textures = {t,t,t,t,t,t},
		clouds = false,
	}
	sky_data.sun = {visible = false , sunrise_visible = false}
	sky_data.moon = {visible = false}
	sky_data.stars = {visible = false}
	sky_data.day_night_ratio = 0.5
end
function dimension_handlers.nether(player, sky_data)
	local biomesky = "#6EB1FF"
	local biomefog = "#330808"
	if mg_name ~= "v6" and mg_name ~= "singlenode" then
		local biome_index = minetest.get_biome_data(player:get_pos()).biome
		local biome_name = minetest.get_biome_name(biome_index)
		local biome = minetest.registered_biomes[biome_name]
		if biome then
			--minetest.log("action", string.format("Biome found for number: %s in biome: %s", tostring(biome_index), biome_name))
			biomesky = biome._mcl_skycolor -- The Nether biomes seemingly don't use the sky colour, despite having this value according to the wiki. The fog colour is used for both sky and fog.
			biomefog = biome._mcl_fogcolor
		else
			--minetest.log("action", string.format("No biome for number: %s in biome: %s", tostring(biome_index), biome_name))
		end
	end
	sky_data.sky = {
		type = "regular",
		sky_color = {
			day_sky = biomefog,
			day_horizon = biomefog,
			dawn_sky = biomefog,
			dawn_horizon = biomefog,
			night_sky = biomefog,
			night_horizon = biomefog,
			indoors = biomefog,
			fog_sun_tint = biomefog,
			fog_moon_tint = biomefog,
			fog_tint_type = "custom"
		},
		clouds = false,
	}
	sky_data.sun = {visible = false , sunrise_visible = false}
	sky_data.moon = {visible = false}
	sky_data.stars = {visible = false}
end
function dimension_handlers.void(player, sky_data)
	sky_data.sky = { type = "plain",
		base_color = "#000000",
		clouds = false,
	}
	sky_data.sun = {visible = false, sunrise_visible = false}
	sky_data.moon = {visible = false}
	sky_data.stars = {visible = false}
end

function dimension(player, sky_data)
	local pos = player:get_pos()
	local dim = mcl_worlds.pos_to_dimension(pos)

	local handler = dimension_handlers[dim]
	if handler then return handler(player, sky_data) end
end





local effects_handlers = {}
function effects_handlers.darkness(player, meta, effect, sky_data)
	-- No darkness effect if visited by shepherd
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
local DIM_ALLOW_NIGHT_VISION = {
	overworld = true,
	void = true,
}
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
local has_mcl_potions = false
local function effects(player, sky_data)
	if not has_mcl_potions then
		if not minetest.get_modpath("mcl_potions") then return end
		has_mcl_potions = true
	end

	local meta = player:get_meta()
	for name,effect in pairs(mcl_potions.registered_effects) do
		local effect_data = mcl_potions.get_effect(player, name)
		if effect_data then
			local hook = effect.mcl_weather_skycolor or effects_handlers[name]
			if hook then hook(player, meta, effect_data, sky_data) end
		end
	end

	-- Handle night vision for shepheard
	if meta:get_int("mcl_shepherd:special") == 1 then
		return effects_handlers.night_vision(player, meta, {}, sky_data)
	end
end




function skycolor.update_player_sky_color(player)
	local sky_data = {
		day_night_ratio = player._skycolor_day_night_ratio
	}

	water_sky(player, sky_data)
	dimension(player, sky_data)
	effects(player, sky_data)

	if sky_data.sky   then player:set_sky(sky_data.sky) end
	if sky_data.sun   then player:set_sun(sky_data.sun) end
	if sky_data.moon  then player:set_moon(sky_data.moon) end
	if sky_data.stars then player:set_stars(sky_data.stars) end
	player:override_day_night_ratio(sky_data.day_night_ratio)
end

-- Update sky color. If players not specified update sky for all players.
function skycolor.update_sky_color(players)
	-- Override day/night ratio as well
	players = mcl_weather.skycolor.utils.get_players(players)
	local update = skycolor.update_player_sky_color
	for _, player in ipairs(players) do
		update(player)
	end
end -- END function skycolor.update_sky_color(players)

-- Returns current layer color in {r, g, b} format
function skycolor.get_sky_layer_color(timeofday)
	if #mcl_weather.skycolor.layer_names == 0 then
		return nil
	end

	-- min timeofday value 0; max timeofday value 1. So sky color gradient range will be between 0 and 1 * mcl_weather.skycolor.max_val.
	local rounded_time = math.floor(timeofday * mcl_weather.skycolor.max_val)
	local color = mcl_weather.skycolor.utils.convert_to_rgb(mcl_weather.skycolor.min_val, mcl_weather.skycolor.max_val, rounded_time, mcl_weather.skycolor.retrieve_layer())
	return color
end

function skycolor_utils.convert_to_rgb(minval, maxval, current_val, colors)
	local max_index = #colors - 1
	local val = (current_val-minval) / (maxval-minval) * max_index + 1.0
	local index1 = math.floor(val)
	local index2 = math.min(math.floor(val)+1, max_index + 1)
	local f = val - index1
	local c1 = colors[index1]
	local c2 = colors[index2]
	return {r=math.floor(c1.r + f*(c2.r - c1.r)), g=math.floor(c1.g + f*(c2.g-c1.g)), b=math.floor(c1.b + f*(c2.b - c1.b))}
end

-- Simply getter. Ether returns user given players list or get all connected players if none provided
function skycolor_utils.get_players(players)
	if players == nil or #players == 0 then
		if mods_loaded then
			players = minetest.get_connected_players()
		elseif players == nil then
			players = {}
		end
	end
	return players
end

-- Returns first player sky color. I assume that all players are in same color layout.
function skycolor_utils.get_current_bg_color()
	local players = mcl_weather.skycolor.utils.get_players(nil)
	if players[1] then
		return players[1]:get_sky(true).sky_color
	end
	return nil
end

local timer = 0
minetest.register_globalstep(function(dtime)
	if mcl_weather.skycolor.active ~= true or #minetest.get_connected_players() == 0 then
		return
	end

	if mcl_weather.skycolor.force_update then
		mcl_weather.skycolor.update_sky_color()
		mcl_weather.skycolor.force_update = false
		return
	end

	-- regular updates based on iterval
	timer = timer + dtime;
	if timer >= mcl_weather.skycolor.update_interval then
		mcl_weather.skycolor.update_sky_color()
		timer = 0
	end

end)

local function initsky(player)

	if player.set_lighting then
		player:set_lighting({ shadows = { intensity = tonumber(minetest.settings:get("mcl_default_shadow_intensity") or 0.33) } })
	end

	if (mcl_weather.skycolor.active) then
		mcl_weather.skycolor.force_update = true
	end

	player:set_clouds(mcl_worlds:get_cloud_parameters() or {height=mcl_worlds.layer_to_y(127), speed={x=-2, z=0}, thickness=4, color="#FFF0FEF"})
end

minetest.register_on_joinplayer(initsky)
minetest.register_on_respawnplayer(initsky)

mcl_worlds.register_on_dimension_change(function(player)
	mcl_weather.skycolor.update_sky_color({player})
end)

minetest.register_on_mods_loaded(function()
	mods_loaded = true
end)
