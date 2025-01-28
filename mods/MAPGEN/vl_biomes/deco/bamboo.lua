-- Bamboo
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt", },
	sidelen = 80,
	fill_ratio = 0.0043,
	biomes = {"Jungle", "JungleM", "JungleEdge", "JungleEdgeM"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_bamboo:bamboo",
	height = 9,
	max_height = 11,
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:podzol"},
	sidelen = 80,
	fill_ratio = 0.095,
	biomes = {"BambooJungle", "BambooJungleM", "BambooJungleEdge", "BambooJungleEdgeM"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_bamboo:bamboo",
	height = 9,
	max_height = 10,
	flags = "place_center_x, place_center_z",
	rotation = "random",
})
