local mod_mcl_crimson = core.get_modpath("mcl_crimson")

vl_biomes.register_biome({
	name = "CrimsonForest",
	node_filler = "mcl_nether:netherrack",
	node_stone = "mcl_nether:netherrack",
	node_top = "mcl_crimson:crimson_nylium",
	node_water = "air",
	node_river_water = "air",
	node_cave_liquid = "air",
	y_min = vl_biomes.nether_min,
	y_max = vl_biomes.nether_max + 80,
	heat_point = 60,
	humidity_point = 47,
	_mcl_biome_type = "hot",
	_mcl_grass_palette_index = 17,
	_mcl_foliage_palette_index = 3,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = vl_biomes.skycolor.nether,
	_mcl_fogcolor = "#330303"
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_nether:magma", "mcl_blackstone:blackstone"},
	sidelen = 16,
	fill_ratio = 10,
	biomes = {"CrimsonForest"},
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	decoration = "mcl_crimson:crimson_nylium",
	flags = "all_floors",
	param2 = 0,
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_crimson:crimson_nylium"},
	sidelen = 16,
	fill_ratio = 0.02,
	biomes = {"CrimsonForest"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 10,
	flags = "all_floors",
	decoration = "mcl_crimson:crimson_fungus",
})

--- Fix light for mushroom lights after generation
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	name = "vl_biomes:crimson_tree1",
	place_on = {"mcl_crimson:crimson_nylium"},
	sidelen = 16,
	fill_ratio = 0.008,
	biomes = {"CrimsonForest"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 10,
	flags = "all_floors, place_center_x, place_center_z",
	schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_1.mts",
	size = vector.new(5, 8, 5),
	rotation = "random",
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	name = "vl_biomes:crimson_tree2",
	place_on = {"mcl_crimson:crimson_nylium"},
	sidelen = 16,
	fill_ratio = 0.006,
	biomes = {"CrimsonForest"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 15,
	flags = "all_floors, place_center_x, place_center_z",
	schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_2.mts",
	size = vector.new(5, 12, 5),
	rotation = "random",
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	name = "vl_biomes:crimson_tree3",
	place_on = {"mcl_crimson:crimson_nylium"},
	sidelen = 16,
	fill_ratio = 0.004,
	biomes = {"CrimsonForest"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 20,
	flags = "all_floors, place_center_x, place_center_z",
	schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_3.mts",
	size = vector.new(7, 13, 7),
	rotation = "random",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_crimson:warped_nylium", "mcl_crimson:weeping_vines", "mcl_nether:netherrack"},
	sidelen = 16,
	fill_ratio = 0.063,
	biomes = {"CrimsonForest"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_deco_max,
	flags = "all_ceilings",
	height = 2,
	height_max = 8,
	decoration = "mcl_crimson:weeping_vines",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_crimson:crimson_nylium"},
	sidelen = 16,
	fill_ratio = 0.082,
	biomes = {"CrimsonForest"},
	y_min = vl_biomes.lava_nether_max + 1,
	flags = "all_floors",
	max_height = 5,
	decoration = "mcl_crimson:crimson_roots",
})
