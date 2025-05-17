local frozen_waterfogcolor = "#3938C9"
local overworld_fogcolor = "#C0D8FF"
local OCEAN_MIN = -15

return {
	register_biomes = function()
		-- Cold Taiga
		minetest.register_biome({
			name = "ColdTaiga",
			node_dust = "mcl_core:snow",
			node_top = "mcl_core:dirt_with_grass_snow",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 2,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = 3,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 58,
			heat_point = 8,
			_mcl_biome_type = "snowy",
			_mcl_grass_palette_index = 3,
			_mcl_foliage_palette_index = 2,
			_mcl_water_palette_index = 5,
			_mcl_waterfogcolor = frozen_waterfogcolor,
			_mcl_skycolor = "#839EFF",
			_mcl_fogcolor = overworld_fogcolor
		})

		-- A cold beach-like biome, implemented as low part of Cold Taiga
		minetest.register_biome({
			name = "ColdTaiga_beach",
			node_dust = "mcl_core:snow",
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_water_top = "mcl_core:ice",
			depth_water_top = 1,
			node_filler = "mcl_core:sandstone",
			depth_filler = 2,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = 1,
			y_max = 2,
			humidity_point = 58,
			heat_point = 8,
			_mcl_biome_type = "snowy",
			_mcl_grass_palette_index = 3,
			_mcl_foliage_palette_index = 16,
			_mcl_water_palette_index = 5,
			_mcl_waterfogcolor = frozen_waterfogcolor,
			_mcl_skycolor = "#7FA1FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		-- Water part of the beach. Added to prevent snow being on the ice.
		minetest.register_biome({
			name = "ColdTaiga_beach_water",
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_water_top = "mcl_core:ice",
			depth_water_top = 1,
			node_filler = "mcl_core:sandstone",
			depth_filler = 2,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = -4,
			y_max = 0,
			humidity_point = 58,
			heat_point = 8,
			_mcl_biome_type = "snowy",
			_mcl_grass_palette_index = 3,
			_mcl_foliage_palette_index = 16,
			_mcl_water_palette_index = 5,
			_mcl_waterfogcolor = frozen_waterfogcolor,
			_mcl_skycolor = "#7FA1FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ColdTaiga_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = OCEAN_MIN,
			y_max = -5,
			humidity_point = 58,
			heat_point = 8,
			vertical_blend = 1,
			_mcl_biome_type = "snowy",
			_mcl_grass_palette_index = 3,
			_mcl_foliage_palette_index = 2,
			_mcl_water_palette_index = 5,
			_mcl_waterfogcolor = frozen_waterfogcolor,
			_mcl_skycolor = "#7FA1FF",
			_mcl_fogcolor = overworld_fogcolor
		})

	end,
}
