-- Cacti
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:sand"},
	sidelen = 16,
	noise_params = {
		offset = -0.01,
		scale = 0.024,
		spread = vector.new(100, 100, 100),
		seed = 257,
		octaves = 3,
		persist = 0.6
	},
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_core:cactus",
	biomes = {"Desert",
		"Mesa", "Mesa_sandlevel",
		"MesaPlateauF", "MesaPlateauF_sandlevel",
		"MesaPlateauFM", "MesaPlateauFM_sandlevel"},
	height = 1,
	height_max = 3,
	spawn_by = "air",
	check_offset = 1,
	num_spawn_by = 16
})
