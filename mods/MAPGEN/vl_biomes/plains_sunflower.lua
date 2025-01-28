-- Sunflower Plains
vl_biomes.register_biome({
	name = "SunflowerPlains",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	humidity_point = 28,
	heat_point = 45,
	_mcl_biome_type = "medium",
	_mcl_water_temp = "ocean",
	_mcl_grass_palette_index = 11,
	_mcl_foliage_palette_index = 1,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = vl_biomes.skycolor.beach,
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
			node_riverbed = "mcl_core:dirt",
			depth_riverbed = 2,
		},
	}
})
