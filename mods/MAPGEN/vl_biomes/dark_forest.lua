local mod_mcl_core = core.get_modpath("mcl_core")
local mod_mcl_mushrooms = core.get_modpath("mcl_mushrooms")

-- Roofed Forest aka Dark Forest
vl_biomes.register_biome({
	name = "RoofedForest",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 94,
	heat_point = 27,
	_mcl_biome_type = "medium",
	_mcl_water_temp = "ocean",
	_mcl_grass_palette_index = 18,
	_mcl_foliage_palette_index = 7,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = "#79A6FF",
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 2,
		},
	}
})

-- Dark Oak
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow"},
	sidelen = 16,
	noise_params = {
		offset = 0.05,
		scale = 0.0015,
		spread = vector.new(125, 125, 125),
		seed = 223,
		octaves = 3,
		persist = 0.66
	},
	biomes = {"RoofedForest"},
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_dark_oak.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

local ratio_mushroom = 0.0001
local ratio_mushroom_huge = ratio_mushroom * (11 / 12)
local ratio_mushroom_giant = ratio_mushroom * (1 / 12)

-- Huge Brown Mushroom
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	fill_ratio = ratio_mushroom_huge,
	biomes = {"RoofedForest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_huge_brown.mts",
	flags = "place_center_x, place_center_z",
	rotation = "0",
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	fill_ratio = ratio_mushroom_giant,
	biomes = {"RoofedForest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_giant_brown.mts",
	flags = "place_center_x, place_center_z",
	rotation = "0",
})

-- Huge Red Mushroom
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	fill_ratio = ratio_mushroom_huge,
	biomes = {"RoofedForest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_huge_red.mts",
	flags = "place_center_x, place_center_z",
	rotation = "0",
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	fill_ratio = ratio_mushroom_giant,
	biomes = {"RoofedForest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_giant_red.mts",
	flags = "place_center_x, place_center_z",
	rotation = "0",
})
