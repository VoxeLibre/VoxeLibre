mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:dirt_with_grass", "mcl_core:podzol"},
	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.012,
		spread = vector.new(100, 100, 100),
		seed = 354,
		octaves = 1,
		persist = 0.5,
		lacunarity = 1.0,
		flags = "absvalue"
	},
	biomes = {"Taiga", "ColdTaiga", "MegaTaiga", "MegaSpruceTaiga", "Forest"},
	y_max = vl_biomes.overworld_max,
	y_min = 2,
	decoration = "mcl_sweet_berry:sweet_berry_bush_3"
})
