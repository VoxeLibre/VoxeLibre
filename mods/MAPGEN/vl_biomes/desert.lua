-- Desert
vl_biomes.register_biome({
	name = "Desert",
	node_top = "mcl_core:sand",
	depth_top = 1,
	node_filler = "mcl_core:sand",
	depth_filler = 2,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	node_stone = "mcl_core:sandstone",
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 26,
	heat_point = 94,
	_mcl_biome_type = "hot",
	_mcl_water_temp = "warm",
	_mcl_grass_palette_index = 17,
	_mcl_foliage_palette_index = 3,
	_mcl_water_palette_index = 3,
	_mcl_skycolor = "#6EB1FF",
	_vl_subbiomes = {
		ocean = {
			node_filler = "mcl_core:sand",
			depth_filler = 3,
		}
	}
})

vl_biomes.register_decoration({
	biomes = {"Desert"},
	decoration = "mcl_core:deadbush",
	y_min = 4,
	place_on = {"group:sand", "group:hardened_clay"},
	noise_params = {
		offset = 0.01,
		scale = 0.006,
		spread = vector.new(100, 100, 100),
		seed = 1972,
		octaves = 3,
		persist = 0.6
	},
	rank = 1500,
})
