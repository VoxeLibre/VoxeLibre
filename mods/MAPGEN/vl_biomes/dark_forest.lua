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
	_vl_biome_type = "medium",
	_vl_water_temp = "ocean",
	_vl_grass_palette = "dark_forest",
	_vl_foliage_palette = "forest",
	_vl_water_palette = "plains",
	_vl_skycolor = "#79A6FF",
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
vl_biomes.register_decoration({
	biomes = {"RoofedForest"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_dark_oak.mts",
	y_min = 4,
	place_on = {"group:grass_block_no_snow"},
	noise_params = {
		offset = 0.05,
		scale = 0.0015,
		spread = vector.new(125, 125, 125),
		seed = 223,
		octaves = 3,
		persist = 0.66
	},
	_vl_foliage_palette = "forest",
})

local ratio_mushroom = 0.0001
local ratio_mushroom_huge = ratio_mushroom * (11 / 12)
local ratio_mushroom_giant = ratio_mushroom * (1 / 12)

-- Huge Brown Mushroom
vl_biomes.register_decoration({
	biomes = {"RoofedForest"},
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_huge_brown.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = ratio_mushroom_huge,
	rotation = "0",
})

vl_biomes.register_decoration({
	biomes = {"RoofedForest"},
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_giant_brown.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = ratio_mushroom_giant,
	rotation = "0",
})

-- Huge Red Mushroom
vl_biomes.register_decoration({
	biomes = {"RoofedForest"},
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_huge_red.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = ratio_mushroom_huge,
	rotation = "0",
})

vl_biomes.register_decoration({
	biomes = {"RoofedForest"},
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_giant_red.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = ratio_mushroom_giant,
	rotation = "0",
})
