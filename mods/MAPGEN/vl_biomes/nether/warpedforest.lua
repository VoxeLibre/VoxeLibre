-- WARPED FOREST
local mod_mcl_crimson = core.get_modpath("mcl_crimson")

vl_biomes.register_biome({
	name = "WarpedForest",
	node_filler = "mcl_nether:netherrack",
	node_stone = "mcl_nether:netherrack",
	node_top = "mcl_crimson:warped_nylium",
	node_water = "air",
	node_river_water = "air",
	node_cave_liquid = "air",
	y_min = vl_biomes.nether_min,
	y_max = vl_biomes.nether_max + 80,
	heat_point = 37,
	humidity_point = 70,
	_mcl_biome_type = "hot",
	_mcl_grass_palette_index = 17,
	_mcl_foliage_palette_index = 3,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = vl_biomes.skycolor.nether,
	_mcl_fogcolor = "#1A051A"
})

vl_biomes.register_decoration({
	biomes = {"WarpedForest"},
	decoration = "mcl_crimson:warped_nylium",
	param2 = 0,
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_nether:magma", "mcl_blackstone:blackstone"},
	fill_ratio = 10, -- fill
	flags = "all_floors",
})

vl_biomes.register_decoration({
	biomes = {"WarpedForest"},
	decoration = "mcl_crimson:warped_fungus",
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 10,
	place_on = {"mcl_crimson:warped_nylium"},
	fill_ratio = 0.02,
	flags = "all_floors",
})

vl_biomes.register_decoration({
	name = "vl_biomes:warped_tree1",
	biomes = {"WarpedForest"},
	schematic = mod_mcl_crimson .. "/schematics/warped_fungus_1.mts", -- size = vector.new(5, 11, 5),
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 15,
	place_on = {"mcl_crimson:warped_nylium"},
	fill_ratio = 0.007,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	biomes = {"WarpedForest"},
	schematic = mod_mcl_crimson .. "/schematics/warped_fungus_2.mts", -- size = vector.new(5, 6, 5),
	name = "vl_biomes:warped_tree2",
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 10,
	place_on = {"mcl_crimson:warped_nylium"},
	fill_ratio = 0.005,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	name = "vl_biomes:warped_tree3",
	biomes = {"WarpedForest"},
	schematic = mod_mcl_crimson .. "/schematics/warped_fungus_3.mts", -- size = vector.new(5, 12, 5),
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 14,
	place_on = {"mcl_crimson:warped_nylium"},
	fill_ratio = 0.003,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	biomes = {"WarpedForest"},
	decoration = "mcl_crimson:twisting_vines",
	height = 2,
	height_max = 8,
	y_min = vl_biomes.lava_nether_max + 1,
	place_on = {"mcl_crimson:warped_nylium", "mcl_crimson:twisting_vines"},
	fill_ratio = 0.032,
	flags = "all_floors",
})

vl_biomes.register_decoration({
	biomes = {"WarpedForest"},
	decoration = "mcl_crimson:warped_roots",
	max_height = 5,
	y_min = vl_biomes.lava_nether_max + 1,
	place_on = {"mcl_crimson:warped_nylium"},
	fill_ratio = 0.0812,
	flags = "all_floors",
})

vl_biomes.register_decoration({
	biomes = {"WarpedForest"},
	decoration = "mcl_crimson:nether_sprouts",
	place_on = {"mcl_crimson:crimson_nylium"},
	y_min = vl_biomes.lava_nether_max + 1,
	fill_ratio = 0.052,
	flags = "all_floors",
})
