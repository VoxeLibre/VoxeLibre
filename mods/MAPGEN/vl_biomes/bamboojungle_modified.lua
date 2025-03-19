local mod_mcl_core = core.get_modpath("mcl_core")

-- Bamboo Jungle M
-- Like Bamboo Jungle but with even more dense vegetation
vl_biomes.register_biome({
	name = "BambooJungleM",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 95,
	heat_point = 95,
	_vl_biome_type = "medium",
	_vl_water_temp = "lukewarm",
	_vl_grass_palette = "jungle_modified",
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
	biomes = {"BambooJungleM"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree_2.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.09,
})

vl_biomes.register_decoration({
	biomes = {"BambooJungleM"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_bush_oak_leaves.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	noise_params = {
		offset = 0.05,
		scale = 0.025,
		spread = vector.new(250, 250, 250),
		seed = 2930,
		octaves = 4,
		persist = 0.6,
	},
})
