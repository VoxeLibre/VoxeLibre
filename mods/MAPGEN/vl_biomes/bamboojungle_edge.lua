local mod_mcl_core = core.get_modpath("mcl_core")

-- Bamboo Jungle Edge
vl_biomes.register_biome({
	name = "BambooJungleEdge",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 92,
	heat_point = 90,
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
	biomes = {"BambooJungleEdge"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.0045,
})
