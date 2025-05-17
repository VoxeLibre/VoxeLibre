local cold_waterfogcolor = "#3D57D6"
local overworld_fogcolor = "#C0D8FF"
local ocean_skycolor = "#7BA4FF" -- This is the case for all ocean biomes except for non-deep frozen oceans! Those oceans will have their own colour instead of this one.
local OCEAN_MIN = -15

return {
	register_biomes = function()
		-- Mega Pine Taiga
		minetest.register_biome({
			name = "MegaTaiga",
			node_top = "mcl_core:podzol",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 76,
			heat_point = 10,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 4,
			_mcl_foliage_palette_index = 9,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7CA3FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "MegaTaiga_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = OCEAN_MIN,
			y_max = 0,
			humidity_point = 76,
			heat_point = 10,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 4,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

		-- Mega Spruce Taiga
		minetest.register_biome({
			name = "MegaSpruceTaiga",
			node_top = "mcl_core:podzol",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 100,
			heat_point = 8,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 5,
			_mcl_foliage_palette_index = 10,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA3FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "MegaSpruceTaiga_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = OCEAN_MIN,
			y_max = 0,
			humidity_point = 100,
			heat_point = 8,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 5,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

	end,
}
