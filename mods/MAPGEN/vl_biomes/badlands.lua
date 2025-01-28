-- Mesa aka Badlands
-- Starts with a couple of sand-covered layers (the "sandlevel"),
-- followed by terracotta with colorful (but imperfect) strata
vl_biomes.register_biome({
	name = "Mesa",
	node_top = "mcl_colorblocks:hardened_clay",
	depth_top = 1,
	node_filler = "mcl_colorblocks:hardened_clay",
	node_riverbed = "mcl_core:redsand",
	depth_riverbed = 1,
	node_stone = "mcl_colorblocks:hardened_clay",
	y_min = 11,
	y_max = vl_biomes.overworld_max,
	humidity_point = 0,
	heat_point = 100,
	_mcl_biome_type = "hot",
	_mcl_water_temp = "warm",
	_mcl_grass_palette_index = 19,
	_mcl_foliage_palette_index = 4,
	_mcl_water_palette_index = 3,
	_mcl_skycolor = "#6EB1FF",
	_vl_subbiomes = {
		-- Helper biome for the red sand at the bottom of Mesas.
		sandlevel = {
			node_top = "mcl_core:redsand",
			depth_top = 1,
			node_filler = "mcl_colorblocks:hardened_clay_orange",
			depth_filler = 3,
			node_stone = "mcl_colorblocks:hardened_clay_orange",
			y_min = -4,
			y_max = 10,
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 3,
			node_filler = "mcl_core:sand",
			depth_filler = 2,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_max = -5,
			vertical_blend = 1,
		},
	}
})
