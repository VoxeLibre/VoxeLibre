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
	_vl_biome_type = "medium",
	_vl_water_temp = "lukewarm",
	_vl_grass_palette = "jungle_edge",
	_vl_foliage_palette = "jungle_edge",
	_vl_water_palette = "savanna",
	_vl_skycolor = vl_biomes.skycolor.jungle,
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 2,
		},
	}
})

vl_biomes.register_decoration({
	biomes = {"JungleEdge"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = 0.0004,
	_vl_foliage_palette = "jungle_edge",
})

vl_biomes.register_decoration({
	biomes = {"JungleEdge"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = 0.0045,
	_vl_foliage_palette = "jungle_edge",
})

vl_biomes.register_decoration({
	biomes = {"JungleEdge"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_bush_oak_leaves.mts",
	y_min = 3,
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	noise_params = {
		offset = 0.0085,
		scale = 0.025,
		spread = vector.new(250, 250, 250),
		seed = 2930,
		octaves = 4,
		persist = 0.6,
	},
	_vl_foliage_palette = "jungle_edge",
})
