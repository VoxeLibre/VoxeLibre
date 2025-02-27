
local DEFAULT_WATER_COLOR = "#3F76E4"
local mg_name = minetest.get_mapgen_setting("mg_name")

local function water_sky(player, sky_data)
	local water_color = DEFAULT_WATER_COLOR

	local checkname = mcl_playerinfo[player:get_player_name()].node_head
	if minetest.get_item_group(checkname, "water") == 0 then return end

	local pos = player:get_pos()
	local biome = nil
	if mg_name ~= "v6" and mg_name ~= "singlenode" then
		local biome_index = minetest.get_biome_data(pos).biome
		local biome_name = minetest.get_biome_name(biome_index)
		biome = minetest.registered_biomes[biome_name]
	end
	if biome then water_color = biome._mcl_waterfogcolor end
	if not biome then water_color = DEFAULT_WATER_COLOR end

	if checkname == "mclx_core:river_water_source" or checkname == "mclx_core:river_water_flowing" then water_color = "#0084FF" end

	local water_fog_color = mcl_weather.skycolor.adjust_brightness_by_daylight(water_color)

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
		clouds = true,
		fog = { fog_start = 0, fog_distance = 80, fog_color = water_fog_color }, -- TODO: make distance biome configurable?
	}
end
table.insert(mcl_weather.skycolor.filters, water_sky)

