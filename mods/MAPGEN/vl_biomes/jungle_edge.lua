local mod_mcl_core = core.get_modpath("mcl_core")

-- Jungle Edge aka Sparse Jungle
vl_biomes.register_biome({
	name = "JungleEdge",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 88,
	heat_point = 76,
	_mcl_biome_type = "medium",
	_mcl_water_temp = "lukewarm",
	_mcl_grass_palette_index = 26,
	_mcl_foliage_palette_index = 13,
	_mcl_water_palette_index = 2,
	_mcl_skycolor = vl_biomes.skycolor.jungle,
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 2,
		},
	}
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	fill_ratio = 0.0004,
	biomes = {"JungleEdge"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	fill_ratio = 0.0045,
	biomes = {"JungleEdge"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	noise_params = {
		offset = 0.0085,
		scale = 0.025,
		spread = vector.new(250, 250, 250),
		seed = 2930,
		octaves = 4,
		persist = 0.6,
	},
	biomes = {"JungleEdge"},
	y_min = 3,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_bush_oak_leaves.mts",
	flags = "place_center_x, place_center_z",
})
