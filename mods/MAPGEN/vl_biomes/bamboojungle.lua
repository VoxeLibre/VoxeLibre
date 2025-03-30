local mod_mcl_core = core.get_modpath("mcl_core")
-- Bamboo Jungle areas are like the Jungle areas, but warmer and more humid.
vl_biomes.register_biome({
	name = "BambooJungle",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 90,
	heat_point = 95,
	_vl_biome_type = "medium",
	_vl_water_temp = "lukewarm",
	_vl_grass_palette = "jungle",
	_vl_foliage_palette = "jungle",
	_vl_water_palette = "savanna",
	_vl_skycolor = vl_biomes.skycolor.jungle,
	_vl_subbiomes = {
		shore = {
			node_top = "mcl_core:dirt",
			depth_top = 1,
			y_min = -2,
			y_max = 0,
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
			y_max = -3,
			vertical_blend = 1,
		},
	}
})

vl_biomes.register_decoration({
	biomes = {"BambooJungle"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = 0.025,
})
