local cold_waterfogcolor = "#3D57D6"
local overworld_fogcolor = "#C0D8FF"
local ocean_skycolor = "#7BA4FF" -- This is the case for all ocean biomes except for non-deep frozen oceans! Those oceans will have their own colour instead of this one.
local OCEAN_MIN = -15

return {
	register_biomes = function()
		-- Stone beach
		-- Just stone.
		-- Not neccessarily a beach at all, only named so according to MC
		minetest.register_biome({
			name = "StoneBeach",
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 1,
			y_min = -7,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 0,
			heat_point = 8,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 9,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})

		minetest.register_biome({
			name = "StoneBeach_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 1,
			y_min = OCEAN_MIN,
			y_max = -8,
			vertical_blend = 2,
			humidity_point = 0,
			heat_point = 8,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 9,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

	end,
}
