-- Bamboo
vl_biomes.register_decoration({
	biomes = {"Jungle", "JungleM", "JungleEdge", "JungleEdgeM"},
	decoration = "mcl_bamboo:bamboo",
	height = 9,
	max_height = 11,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.0043,
})

vl_biomes.register_decoration({
	biomes = {"BambooJungle", "BambooJungleM", "BambooJungleEdge", "BambooJungleEdgeM"},
	decoration = "mcl_bamboo:bamboo",
	height = 9,
	max_height = 10,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:podzol"},
	fill_ratio = 0.095,
})
