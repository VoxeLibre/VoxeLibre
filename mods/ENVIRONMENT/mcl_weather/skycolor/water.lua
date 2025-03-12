
local DEFAULT_WATER_COLOR = "#3F76E4"
local mg_name = minetest.get_mapgen_setting("mg_name")

local function water_sky(player, sky_data)
	local head_in = mcl_playerinfo[player:get_player_name()].head_in
	if (head_in.groups.water or 0) ~= 0 then return end
	local water_color = DEFAULT_WATER_COLOR
	local pos = player:get_pos()
	local biome = nil
	if mg_name ~= "v6" and mg_name ~= "singlenode" then
		local biome_index = minetest.get_biome_data(pos).biome
		local biome_name = minetest.get_biome_name(biome_index)
		biome = minetest.registered_biomes[biome_name]
	end
	if biome then water_color = biome._mcl_waterfogcolor end
	if not biome then water_color = DEFAULT_WATER_COLOR end

	if head_in.name == "mclx_core:river_water_source" or head_in.name == "mclx_core:river_water_flowing" then water_color = "#0084FF" end

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
	}
end
table.insert(mcl_weather.skycolor.filters, water_sky)

