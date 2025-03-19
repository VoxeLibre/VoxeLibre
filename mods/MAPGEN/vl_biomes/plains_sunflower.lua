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
	_vl_biome_type = "medium",
	_vl_water_temp = "ocean",
	_vl_grass_palette = "plains_sunflower",
	_vl_foliage_palette = "plains",
	_vl_water_palette = "plains",
	_vl_skycolor = vl_biomes.skycolor.beach,
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
