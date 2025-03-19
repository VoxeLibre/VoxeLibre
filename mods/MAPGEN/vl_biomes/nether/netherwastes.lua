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
	_vl_biome_type = "hot",
	_vl_grass_palette = "desert",
	_vl_foliage_palette = "savanna",
	_vl_water_palette = "plains",
	_vl_skycolor = vl_biomes.skycolor.nether,
	_mcl_fogcolor = "#330808"
})

vl_biomes.register_decoration({
	biomes = {"Nether"},
	decoration = "mcl_nether:netherrack",
	param2 = 0,
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_nether:glowstone", "mcl_nether:magma"},
	fill_ratio = 10, -- fill
	flags = "all_floors",
})

vl_biomes.register_decoration({
	biomes = {"Nether"},
	decoration = "mcl_fire:eternal_fire",
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 1,
	place_on = {"mcl_nether:netherrack", "mcl_nether:magma"},
	fill_ratio = 0.04,
	flags = "all_floors",
})

vl_biomes.register_decoration({
	biomes = {"Nether"},
	decoration = "mcl_mushrooms:mushroom_brown",
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 1,
	place_on = {"mcl_nether:netherrack"},
	fill_ratio = 0.013,
	flags = "all_floors",
})

vl_biomes.register_decoration({
	biomes = {"Nether"},
	decoration = "mcl_mushrooms:mushroom_red",
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 1,
	place_on = {"mcl_nether:netherrack"},
	fill_ratio = 0.012,
	flags = "all_floors",
})
