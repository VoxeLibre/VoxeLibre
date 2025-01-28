-- Nether Wastes
vl_biomes.register_biome({
	name = "Nether",
	node_filler = "mcl_nether:netherrack",
	node_stone = "mcl_nether:netherrack",
	node_top = "mcl_nether:netherrack",
	node_water = "air",
	node_river_water = "air",
	node_cave_liquid = "air",
	y_min = vl_biomes.nether_min,
	y_max = vl_biomes.nether_max + 80,
	heat_point = 100,
	humidity_point = 0,
	_mcl_biome_type = "hot",
	_mcl_grass_palette_index = 17,
	_mcl_foliage_palette_index = 3,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = vl_biomes.skycolor.nether,
	_mcl_fogcolor = "#330808"
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_nether:glowstone", "mcl_nether:magma"},
	sidelen = 16,
	fill_ratio = 10,
	biomes = {"Nether"},
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	decoration = "mcl_nether:netherrack",
	flags = "all_floors",
	param2 = 0,
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_nether:netherrack", "mcl_nether:magma"},
	sidelen = 16,
	fill_ratio = 0.04,
	biomes = {"Nether"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 1,
	flags = "all_floors",
	decoration = "mcl_fire:eternal_fire",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_nether:netherrack"},
	sidelen = 16,
	fill_ratio = 0.013,
	biomes = {"Nether"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 1,
	flags = "all_floors",
	decoration = "mcl_mushrooms:mushroom_brown",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_nether:netherrack"},
	sidelen = 16,
	fill_ratio = 0.012,
	biomes = {"Nether"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 1,
	flags = "all_floors",
	decoration = "mcl_mushrooms:mushroom_red",
})
