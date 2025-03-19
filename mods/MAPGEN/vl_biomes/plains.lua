-- Plains
vl_biomes.register_biome({
	name = "Plains",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 3,
	y_max = vl_biomes.overworld_max,
	humidity_point = 39,
	heat_point = 58,
	_vl_biome_type = "medium",
	_vl_water_temp = "ocean",
	_vl_grass_palette = "plains",
	_vl_foliage_palette = "plains",
	_vl_water_palette = "plains",
	_vl_skycolor = vl_biomes.skycolor.beach,
	_vl_subbiomes = {
		beach = {
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_filler = "mcl_core:sandstone",
			depth_filler = 2,
			y_min = 0,
			y_max = 2,
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
			y_max = -1,
		},
	}
})
