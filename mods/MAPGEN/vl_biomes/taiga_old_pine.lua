local mod_mcl_structures = minetest.get_modpath("mcl_structures")

-- Mega Pine Taiga aka Old Growth Pine Taiga
vl_biomes.register_biome({
	name = "MegaTaiga",
	node_top = "mcl_core:podzol",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 76,
	heat_point = 10,
	_mcl_biome_type = "cold",
	_mcl_water_temp = "cold",
	_mcl_grass_palette_index = 4,
	_mcl_foliage_palette_index = 9,
	_mcl_water_palette_index = 4,
	_mcl_skycolor = "#7CA3FF",
	_ocean = {
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 3,
	},
})

-- Random coarse dirt floor in Mega Taiga
minetest.register_ore({
	ore_type = "sheet",
	ore = "mcl_core:coarse_dirt",
	wherein = {"mcl_core:podzol", "mcl_core:dirt"},
	clust_scarcity = 1,
	clust_num_ores = 12,
	clust_size = 10,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_threshold = 0.2,
	noise_params = {offset = 0, scale = 15, spread = vector.new(130, 130, 130), seed = 24, octaves = 3, persist = 0.70},
	biomes = {"MegaTaiga"},
})
-- Mossy cobblestone boulder (3x3)
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt"},
	sidelen = 80,
	noise_params = {
		offset = 0.00015,
		scale = 0.001,
		spread = vector.new(300, 300, 300),
		seed = 775703,
		octaves = 4,
		persist = 0.63,
	},
	biomes = {"MegaTaiga"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_structures .. "/schematics/mcl_structures_boulder.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

-- Small mossy cobblestone boulder (2x2)
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt"},
	sidelen = 80,
	noise_params = {
		offset = 0.001,
		scale = 0.001,
		spread = vector.new(300, 300, 300),
		seed = 775704,
		octaves = 4,
		persist = 0.63,
	},
	biomes = {"MegaTaiga"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_structures .. "/schematics/mcl_structures_boulder_small.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

-- Huge spruce
vl_biomes.register_spruce_decoration(3000, 0.0008, "mcl_core_spruce_huge_up_1.mts", {"MegaTaiga"})
vl_biomes.register_spruce_decoration(4000, 0.0008, "mcl_core_spruce_huge_up_2.mts", {"MegaTaiga"})
vl_biomes.register_spruce_decoration(6000, 0.0008, "mcl_core_spruce_huge_up_3.mts", {"MegaTaiga"})

-- Common spruce
vl_biomes.register_spruce_decoration(2500, 0.00325, "mcl_core_spruce_1.mts", {"MegaTaiga"})
vl_biomes.register_spruce_decoration(7000, 0.00425, "mcl_core_spruce_3.mts", {"MegaTaiga"})
vl_biomes.register_spruce_decoration(9000, 0.00325, "mcl_core_spruce_4.mts", {"MegaTaiga"})
vl_biomes.register_spruce_decoration(9500, 0.00500, "mcl_core_spruce_tall.mts", {"MegaTaiga"})
vl_biomes.register_spruce_decoration(5000, 0.00250, "mcl_core_spruce_2.mts", {"MegaTaiga"})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	rank = 1500,
	place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:dirt_with_grass", "mcl_core:coarse_dirt", "group:hardened_clay"},
	sidelen = 16,
	noise_params = {
		offset = 0.01,
		scale = 0.003,
		spread = vector.new(100, 100, 100),
		seed = 1972,
		octaves = 3,
		persist = 0.6
	},
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	biomes = {"MegaTaiga"},
	decoration = "mcl_core:deadbush",
	height = 1,
})
-- Mushrooms in Taiga
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:podzol"},
	sidelen = 80,
	fill_ratio = 0.003,
	biomes = {"MegaTaiga"},
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_mushrooms:mushroom_red",
})
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:podzol"},
	sidelen = 80,
	fill_ratio = 0.003,
	biomes = {"MegaTaiga"},
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_mushrooms:mushroom_brown",
})
