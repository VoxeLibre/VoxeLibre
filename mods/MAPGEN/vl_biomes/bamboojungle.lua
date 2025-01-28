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
	_mcl_biome_type = "medium",
	_mcl_water_temp = "lukewarm",
	_mcl_grass_palette_index = 24,
	_mcl_foliage_palette_index = 12,
	_mcl_water_palette_index = 2,
	_mcl_skycolor = vl_biomes.skycolor.jungle,
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

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	fill_ratio = 0.025,
	biomes = {"BambooJungle"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})
