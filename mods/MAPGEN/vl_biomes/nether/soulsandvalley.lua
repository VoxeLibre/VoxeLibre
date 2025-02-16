-- Soulsand Valley (Nether)
local mod_mcl_blackstone = core.get_modpath("mcl_blackstone")

vl_biomes.register_biome({
	name = "SoulsandValley",
	node_filler = "mcl_nether:netherrack",
	node_stone = "mcl_nether:netherrack",
	node_top = "mcl_blackstone:soul_soil",
	node_water = "air",
	node_river_water = "air",
	node_cave_liquid = "air",
	y_min = vl_biomes.nether_min,
	y_max = vl_biomes.nether_max + 80,
	heat_point = 77,
	humidity_point = 33,
	_mcl_biome_type = "hot",
	_mcl_grass_palette_index = 17,
	_mcl_foliage_palette_index = 3,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = vl_biomes.skycolor.nether,
	_mcl_fogcolor = "#1B4745"
})

vl_biomes.register_decoration({
	biomes = {"SoulsandValley"},
	decoration = "mcl_blackstone:soul_soil",
	param2 = 0,
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_nether:magma"},
	fill_ratio = 10, -- fill
	flags = "all_floors, all_ceilings",
})

core.register_ore({
	ore_type = "blob",
	ore = "mcl_nether:soul_sand",
	wherein = {"mcl_nether:netherrack", "mcl_blackstone:soul_soil"},
	clust_scarcity = 100,
	clust_num_ores = 225,
	clust_size = 15,
	biomes = {"SoulsandValley"},
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

vl_biomes.register_decoration({
	biomes = {"SoulsandValley"},
	decoration = "mcl_blackstone:soul_fire",
	max_height = 5,
	y_min = vl_biomes.lava_nether_max + 1,
	place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soul_sand"},
	fill_ratio = 0.062,
	flags = "all_floors",
})

vl_biomes.register_decoration({
	biomes = {"SoulsandValley"},
	schematic = mod_mcl_blackstone .. "/schematics/mcl_blackstone_nether_fossil_1.mts", -- size = vector.new(5, 8, 5),
	y_min = vl_biomes.lava_nether_max + 1,
	place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soulsand"},
	fill_ratio = 0.000212,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	biomes = {"SoulsandValley"},
	schematic = mod_mcl_blackstone .. "/schematics/mcl_blackstone_nether_fossil_2.mts", -- size = vector.new(5, 8, 5),
	y_min = vl_biomes.lava_nether_max + 1,
	place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soulsand"},
	fill_ratio = 0.0002233,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	biomes = {"SoulsandValley"},
	schematic = mod_mcl_blackstone .. "/schematics/mcl_blackstone_nether_fossil_3.mts", -- size = vector.new(5, 8, 5),
	y_min = vl_biomes.lava_nether_max + 1,
	place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soulsand"},
	fill_ratio = 0.000225,
	flags = "all_floors, place_center_x, place_center_z",
})

vl_biomes.register_decoration({
	biomes = {"SoulsandValley"},
	schematic = mod_mcl_blackstone .. "/schematics/mcl_blackstone_nether_fossil_4.mts", -- size = vector.new(5, 8, 5),
	y_min = vl_biomes.lava_nether_max + 1,
	place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soulsand"},
	fill_ratio = 0.00022323,
	flags = "all_floors, place_center_x, place_center_z",
})
