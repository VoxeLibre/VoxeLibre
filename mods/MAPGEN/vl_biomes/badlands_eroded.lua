-- Mesa Bryce aka Eroded Badlands
-- Variant of Mesa, but with perfect strata and a much smaller red sand desert
vl_biomes.register_biome({
	name = "MesaBryce",
	node_top = "mcl_colorblocks:hardened_clay",
	depth_top = 1,
	node_filler = "mcl_colorblocks:hardened_clay",
	node_riverbed = "mcl_colorblocks:hardened_clay",
	depth_riverbed = 1,
	node_stone = "mcl_colorblocks:hardened_clay",
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	humidity_point = -5,
	heat_point = 100,
	_vl_biome_type = "hot",
	_vl_water_temp = "warm",
	_vl_grass_palette = "badlands_eroded",
	_vl_foliage_palette = "badlands",
	_vl_water_palette = "desert",
	_vl_skycolor = "#6EB1FF",
	_vl_subbiomes = {
		sandlevel = {
			node_top = "mcl_core:redsand",
			depth_top = 1,
			node_filler = "mcl_colorblocks:hardened_clay_orange",
			depth_filler = 3,
			node_riverbed = "mcl_colorblocks:hardened_clay",
			depth_riverbed = 1,
			node_stone = "mcl_colorblocks:hardened_clay_orange",
			y_min = -4,
			y_max = 3,
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
