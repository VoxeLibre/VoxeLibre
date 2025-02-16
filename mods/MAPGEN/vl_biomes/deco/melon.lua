-- Melon
vl_biomes.register_decoration({
	biomes = {"Jungle", "BambooJungle"},
	decoration = "mcl_farming:melon",
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	place_on = {"group:grass_block_no_snow"},
	noise_params = {
		offset = -0.01,
		scale = 0.006,
		spread = vector.new(250, 250, 250),
		seed = 333,
		octaves = 3,
		persist = 0.6
	},
})

vl_biomes.register_decoration({
	biomes = {"JungleM", "BambooJungleM"},
	decoration = "mcl_farming:melon",
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	place_on = {"group:grass_block_no_snow"},
	noise_params = {
		offset = 0.0,
		scale = 0.006,
		spread = vector.new(250, 250, 250),
		seed = 333,
		octaves = 3,
		persist = 0.6
	},
})

vl_biomes.register_decoration({
	biomes = {"JungleEdge", "JungleEdgeM", "BambooJungleEdge", "BambooJungleEdgeM"},
	decoration = "mcl_farming:melon",
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	place_on = {"group:grass_block_no_snow"},
	noise_params = {
		offset = -0.005,
		scale = 0.006,
		spread = vector.new(250, 250, 250),
		seed = 333,
		octaves = 3,
		persist = 0.6
	},
})

-- Lots of melons in Jungle Edge M
vl_biomes.register_decoration({
	biomes = {"JungleEdgeM"},
	decoration = "mcl_farming:melon",
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	place_on = {"group:grass_block_no_snow"},
	noise_params = {
		offset = 0.013,
		scale = 0.006,
		spread = vector.new(125, 125, 125),
		seed = 333,
		octaves = 3,
		persist = 0.6
	},
})
