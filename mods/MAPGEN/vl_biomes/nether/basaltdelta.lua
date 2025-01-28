-- Nether Basalt Delta biome
vl_biomes.register_biome({
	name = "BasaltDelta",
	node_filler = "mcl_nether:netherrack",
	node_stone = "mcl_nether:netherrack",
	node_top = "mcl_blackstone:basalt",
	node_water = "air",
	node_river_water = "air",
	node_cave_liquid = "air",
	y_min = vl_biomes.nether_min,
	y_max = vl_biomes.nether_max + 80,
	heat_point = 27,
	humidity_point = 80,
	_mcl_biome_type = "hot",
	_mcl_grass_palette_index = 17,
	_mcl_foliage_palette_index = 3,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = vl_biomes.skycolor.nether,
	_mcl_fogcolor = "#685F70"
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_blackstone:blackstone", "mcl_nether:magma"},
	sidelen = 16,
	fill_ratio = 10,
	biomes = {"BasaltDelta"},
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	decoration = "mcl_blackstone:basalt",
	flags = "all_floors",
	param2 = 0,
})

core.register_ore({
	ore_type = "blob",
	ore = "mcl_blackstone:blackstone",
	wherein = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_core:gravel"},
	clust_scarcity = 100,
	clust_num_ores = 400,
	clust_size = 20,
	biomes = {"BasaltDelta"},
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	noise_params = {
		offset = 0,
		scale = 1,
		spread = vector.new(250, 250, 250),
		seed = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	decoration = "mcl_blackstone:basalt",
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	sidelen = 80,
	height_max = 55,
	noise_params = {
		offset = -0.0085,
		scale = 0.002,
		spread = vector.new(25, 120, 25),
		seed = 2325,
		octaves = 5,
		persist = 2,
		lacunarity = 3.5,
		flags = "absvalue"
	},
	biomes = {"BasaltDelta"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_deco_max - 50,
	flags = "all_floors, all ceilings",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	decoration = "mcl_blackstone:basalt",
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	sidelen = 80,
	height_max = 15,
	noise_params = {
		offset = -0.0085,
		scale = 0.004,
		spread = vector.new(25, 120, 25),
		seed = 235,
		octaves = 5,
		persist = 2.5,
		lacunarity = 3.5,
		flags = "absvalue"
	},
	biomes = {"BasaltDelta"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_deco_max - 15,
	flags = "all_floors, all ceilings",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	decoration = "mcl_blackstone:basalt",
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	sidelen = 80,
	height_max = 3,
	fill_ratio = 0.4,
	biomes = {"BasaltDelta"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_deco_max - 15,
	flags = "all_floors, all ceilings",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	decoration = "mcl_nether:magma",
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	sidelen = 80,
	fill_ratio = 0.082323,
	biomes = {"BasaltDelta"},
	place_offset_y = -1,
	y_min = vl_biomes.lava_nether_max + 1,
	flags = "all_floors, all ceilings",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	decoration = "mcl_nether:nether_lava_source",
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	spawn_by = {"mcl_blackstone:basalt", "mcl_blackstone:blackstone"},
	num_spawn_by = 14,
	sidelen = 80,
	fill_ratio = 4,
	biomes = {"BasaltDelta"},
	place_offset_y = -1,
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 5,
	flags = "all_floors, force_placement",
})
