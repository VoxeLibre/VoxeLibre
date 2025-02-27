local MINIMUM_LIGHT_LEVEL = 0.2
local VALID_SNOW_WEATHER_STATES = { snow = true, rain = true, thunder = true }
local VALID_RAIN_WEATHER_STATES = { rain = true, thunder = true }
local mg_name = minetest.get_mapgen_setting("mg_name")

local dimension_handlers = {}
mcl_weather.skycolor.dimension_handlers = dimension_handlers

function dimension_handlers.overworld(player, sky_data)
	local pos = player:get_pos()

	local biomesky
	local biomefog
	if mg_name ~= "v6" and mg_name ~= "singlenode" then
		local biome_index = minetest.get_biome_data(player:get_pos()).biome
		local biome_name = minetest.get_biome_name(biome_index)
		local biome = minetest.registered_biomes[biome_name]
		if biome then
			biomesky = biome._mcl_skycolor
			biomefog = biome._mcl_fogcolor
		end
	end

	-- Use overworld defaults
	local day_color = mcl_weather.skycolor.get_sky_layer_color(0.5)
	local dawn_color = mcl_weather.skycolor.get_sky_layer_color(0.27)
	local night_color = mcl_weather.skycolor.get_sky_layer_color(0.1)
	sky_data.sky = {
		type = "regular",
		sky_color = {
			day_sky = day_color or "#7BA4FF",
			day_horizon = day_color or "#C0D8FF",
			dawn_sky = dawn_color or "7BA4FF",
			dawn_horizon = dawn_color or "#C0D8FF",
			night_sky = night_color or "000000",
			night_horizon = night_color or "4A6790",
			fog_sun_tint = "#ff5f33",
			fog_moon_tint = nil,
			fog_tint_type = "custom",
		},
		clouds = true,
		fog = { fog_start = -1, fog_distance = -1, fog_color = "#00000000" },
	}
	sky_data.sun = {visible = true, sunrise_visible = true}
	sky_data.moon = {visible = true}
	sky_data.stars = {visible = true}

	if mcl_weather.state == "none" then
		-- Clear weather
		mcl_weather.set_sky_box_clear(player,biomesky,biomefog)
		return
	end

	-- Check if we currently have weather that affects the sky color
	local has_weather = mcl_worlds.has_weather(pos) and (
		mcl_weather.has_snow(pos) and VALID_SNOW_WEATHER_STATES[mcl_weather.state] or
		mcl_weather.has_rain(pos) and VALID_RAIN_WEATHER_STATES[mcl_weather.state]
	)
	if has_weather then
		-- Weather skies
		local day_color = mcl_weather.skycolor.get_sky_layer_color(0.5)
		local dawn_color = mcl_weather.skycolor.get_sky_layer_color(0.75)
		local night_color = mcl_weather.skycolor.get_sky_layer_color(0)
		table.update(sky_data.sky.sky_color,{
			day_sky = day_color or "#7BA4FF",
			day_horizon = day_color or "#C0D8FF",
			dawn_sky = dawn_color or "7BA4FF",
			dawn_horizon = dawn_color or "#C0D8FF",
			night_sky = night_color or "000000",
			night_horizon = night_color or "4A6790",
			fog_tint_type = "default",
		})
		sky_data.sun = {visible = false, sunrise_visible = false}
		sky_data.moon = {visible = false}
		sky_data.stars = {visible = false}

		local light_factor = mcl_weather.get_current_light_factor()
		if mcl_weather.skycolor.current_layer_name() == "lightning" then
			sky_data.day_night_ratio = 1
		elseif light_factor then
			local time = minetest.get_timeofday()
			local light_multiplier = mcl_weather.skycolor.get_light_modifier(time)
			local new_light = math.max(light_factor * light_multiplier, MINIMUM_LIGHT_LEVEL)
			sky_data.day_night_ratio = new_light
		end
	end
end

-- This can't be function dimension_handlers.end() due to lua syntax
dimension_handlers["end"] = function(player, sky_data)
	local biomesky = "#0F0F0F"
	local biomefog = "#0F0F0F"
	if mg_name ~= "v6" and mg_name ~= "singlenode" then
		local biome_index = minetest.get_biome_data(player:get_pos()).biome
		local biome_name = minetest.get_biome_name(biome_index)
		local biome = minetest.registered_biomes[biome_name]
		if biome then
			biomesky = biome._mcl_skycolor
			biomefog = biome._mcl_fogcolor -- The End biomes seemingly don't use the fog colour, despite having this value according to the wiki. The sky colour is seemingly used for both sky and fog?
		end
	end
	local t = "mcl_playerplus_end_sky.png"
	sky_data.sky = { type = "skybox",
		base_color = biomesky,
		textures = {t,t,t,t,t,t},
		clouds = false,
		fog = { fog_start = 0.5, fog_distance = -1, fog_color = "#0F0F0F" }, -- average color of skybox
	}
	sky_data.sun = {visible = false , sunrise_visible = false}
	sky_data.moon = {visible = false}
	sky_data.stars = {visible = false}
	sky_data.day_night_ratio = 0.5
end

function dimension_handlers.nether(player, sky_data)
	local biomesky = "#000000"
	local biomefog = "#330808"
	if mg_name ~= "v6" and mg_name ~= "singlenode" then
		local biome_index = minetest.get_biome_data(player:get_pos()).biome
		local biome_name = minetest.get_biome_name(biome_index)
		local biome = minetest.registered_biomes[biome_name]
		if biome then
			-- The Nether biomes seemingly don't use the sky colour, despite having this value according to the wiki.
			-- The fog colour is used for both sky and fog.
			biomesky = biome._mcl_skycolor
			biomefog = biome._mcl_fogcolor
		end
	end
	sky_data.sky = {
		type = "plain",
		base_color = biomefog,
		fog = { fog_start = 0.1, fog_distance = -1, fog_color = biomefog },
		clouds = false,
	}
	sky_data.sun = {visible = false , sunrise_visible = false}
	sky_data.moon = {visible = false}
	sky_data.stars = {visible = false}
end

function dimension_handlers.void(player, sky_data)
	sky_data.sky = {
		type = "plain",
		base_color = "#000000",
		clouds = false,
	}
	sky_data.sun = {visible = false, sunrise_visible = false}
	sky_data.moon = {visible = false}
	sky_data.stars = {visible = false}
end

local function dimension(player, sky_data)
	local pos = player:get_pos()
	local dim = mcl_worlds.pos_to_dimension(pos)

	local handler = dimension_handlers[dim]
	if handler then return handler(player, sky_data) end
end
table.insert(mcl_weather.skycolor.filters, dimension)

