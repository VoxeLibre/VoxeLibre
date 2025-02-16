-- Cacti
vl_biomes.register_decoration({
	biomes = {"Desert",
		"Mesa", "Mesa_sandlevel",
		"MesaPlateauF", "MesaPlateauF_sandlevel",
		"MesaPlateauFM", "MesaPlateauFM_sandlevel"},
	decoration = "mcl_core:cactus",
	height = 1,
	height_max = 3,
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	place_on = {"group:sand"},
	spawn_by = "air",
	check_offset = 1,
	num_spawn_by = 16,
	noise_params = {
		offset = -0.01,
		scale = 0.024,
		spread = vector.new(100, 100, 100),
		seed = 257,
		octaves = 3,
		persist = 0.6
	},
})
