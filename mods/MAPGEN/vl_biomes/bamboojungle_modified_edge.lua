local mod_mcl_core = core.get_modpath("mcl_core")

-- Bamboo Jungle Edge M (very rare).
-- Almost identical to Bamboo Jungle Edge. Has deeper dirt.
-- This biome occours directly between Bamboo Jungle M and Bamboo Jungle Edge but also has a small border to Bamboo Jungle.
-- This biome is very small in general.
vl_biomes.register_biome({
	name = "BambooJungleEdgeM",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 4,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	-- note: with 95/95, the biome would actually never spawn
	humidity_point = mcl_util.minimum_version(mcl_vars.map_version, {0, 90}) and 97 or 95,
	heat_point = mcl_util.minimum_version(mcl_vars.map_version, {0, 90}) and 90 or 95,
	_vl_biome_type = "medium",
	_vl_water_temp = "lukewarm",
	_vl_grass_palette = "mangroveswamp",
	_vl_foliage_palette = "jungle_edge",
	_vl_water_palette = "savanna",
	_vl_skycolor = vl_biomes.skycolor.jungle,
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 4,
		},
	}
})

vl_biomes.register_decoration({
	biomes = {"BambooJungleEdgeM"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = 0.0045,
	_vl_foliage_palette = "jungle_edge",
})

vl_biomes.register_decoration({
	biomes = {"BambooJungleEdgeM"},
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
