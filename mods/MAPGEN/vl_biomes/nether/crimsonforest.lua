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

vl_biomes.register_decoration({
	biomes = {"CrimsonForest"},
	decoration = "mcl_crimson:crimson_nylium",
	param2 = 0,
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_nether:magma", "mcl_blackstone:blackstone"},
	fill_ratio = 10, -- fill
	flags = "all_floors",
})

vl_biomes.register_decoration({
	biomes = {"CrimsonForest"},
	decoration = "mcl_crimson:crimson_fungus",
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 10,
	place_on = {"mcl_crimson:crimson_nylium"},
	fill_ratio = 0.02,
	flags = "all_floors",
})

--- Fix light for mushroom lights after generation
vl_biomes.register_decoration({
	name = "vl_biomes:crimson_tree1",
	biomes = {"CrimsonForest"},
	schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_1.mts", -- size = vector.new(5, 8, 5),
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 10,
	place_on = {"mcl_crimson:crimson_nylium"},
	fill_ratio = 0.008,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	name = "vl_biomes:crimson_tree2",
	biomes = {"CrimsonForest"},
	schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_2.mts", -- size = vector.new(5, 12, 5),
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 15,
	place_on = {"mcl_crimson:crimson_nylium"},
	fill_ratio = 0.006,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	name = "vl_biomes:crimson_tree3",
	biomes = {"CrimsonForest"},
	schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_3.mts", --size = vector.new(7, 13, 7),
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 20,
	place_on = {"mcl_crimson:crimson_nylium"},
	fill_ratio = 0.004,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	biomes = {"CrimsonForest"},
	decoration = "mcl_crimson:weeping_vines",
	height = 2,
	height_max = 8,
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_deco_max,
	place_on = {"mcl_crimson:warped_nylium", "mcl_crimson:weeping_vines", "mcl_nether:netherrack"},
	fill_ratio = 0.063,
	flags = "all_ceilings",
})

vl_biomes.register_decoration({
	biomes = {"CrimsonForest"},
	decoration = "mcl_crimson:crimson_roots",
	max_height = 5,
	y_min = vl_biomes.lava_nether_max + 1,
	place_on = {"mcl_crimson:crimson_nylium"},
	fill_ratio = 0.082,
	flags = "all_floors",
})
