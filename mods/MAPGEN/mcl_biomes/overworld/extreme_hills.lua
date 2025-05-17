local beach_skycolor = "#78A7FF" -- This is the case for all beach biomes except for the snowy ones! Those beaches will have their own colour instead of this one.
local cold_waterfogcolor = "#3D57D6"
local overworld_fogcolor = "#C0D8FF"
local ocean_skycolor = "#7BA4FF" -- This is the case for all ocean biomes except for non-deep frozen oceans! Those oceans will have their own colour instead of this one.
local OCEAN_MIN = -15

return {
	register_biomes = function()
		-- Extreme Hills
		-- Sparsely populated grasslands with little tallgras and trees.
		minetest.register_biome({
			name = "ExtremeHills",
			node_top = "mcl_core:dirt_with_grass",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 4,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = 4,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 10,
			heat_point = 45,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 6,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ExtremeHills_beach",
			node_top = "mcl_core:sand",
			depth_top = 2,
			depth_water_top = 1,
			node_filler = "mcl_core:sandstone",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = -4,
			y_max = 3,
			humidity_point = 10,
			heat_point = 45,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 6,
			_mcl_foliage_palette_index = 1,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = beach_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ExtremeHills_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 4,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = OCEAN_MIN,
			y_max = -5,
			vertical_blend = 1,
			humidity_point = 10,
			heat_point = 45,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 6,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

		-- Extreme Hills M
		-- Just gravel.
		minetest.register_biome({
			name = "ExtremeHillsM",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_riverbed = "mcl_core:gravel",
			depth_riverbed = 3,
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 0,
			heat_point = 25,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 7,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ExtremeHillsM_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 3,
			y_min = OCEAN_MIN,
			y_max = 0,
			humidity_point = 0,
			heat_point = 25,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 7,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

		-- Extreme Hills+
		-- This biome is near-identical to Extreme Hills on the surface but has snow-covered mountains with spruce/oak
		-- forests above a certain height.
		minetest.register_biome({
			name = "ExtremeHills+",
			node_top = "mcl_core:dirt_with_grass",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 4,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = 1,
			y_max = 41,
			humidity_point = 24,
			heat_point = 25,
			vertical_blend = 6,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 8,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		---- Sub-biome for Extreme Hills+ for those snow forests
		minetest.register_biome({
			name = "ExtremeHills+_snowtop",
			node_dust = "mcl_core:snow",
			node_top = "mcl_core:dirt_with_grass_snow",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 4,
			node_river_water = "mcl_core:ice",
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = 42,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 24,
			heat_point = 25,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 8,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ExtremeHills+_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 4,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = OCEAN_MIN,
			y_max = 0,
			humidity_point = 24,
			heat_point = 25,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 8,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})
	end,
}
