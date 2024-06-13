
local DEFAULT_WATER_COLOR = "#3F76E4"

local function water_sky(player, sky_data)
	local pos = player:get_pos()
	local water_color = DEFAULT_WATER_COLOR

	local checkname = minetest.get_node(vector.new(pos.x,pos.y+1.5,pos.z)).name
	if minetest.get_item_group(checkname, "water") == 0 then return end

	local biome_index = minetest.get_biome_data(player:get_pos()).biome
	local biome_name = minetest.get_biome_name(biome_index)
	local biome = minetest.registered_biomes[biome_name]
	if biome then water_color = biome._mcl_waterfogcolor end
	if not biome then water_color = DEFAULT_WATER_COLOR end

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
table.insert(mcl_weather.skycolor.filters, water_sky)

