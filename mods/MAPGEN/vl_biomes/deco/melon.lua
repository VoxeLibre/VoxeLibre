-- Melon
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:grass_block_no_snow"},
	sidelen = 16,
	noise_params = {
		offset = -0.01,
		scale = 0.006,
		spread = vector.new(250, 250, 250),
		seed = 333,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	decoration = "mcl_farming:melon",
	biomes = {"Jungle", "BambooJungle"},
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:grass_block_no_snow"},
	sidelen = 16,
	noise_params = {
		offset = 0.0,
		scale = 0.006,
		spread = vector.new(250, 250, 250),
		seed = 333,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	decoration = "mcl_farming:melon",
	biomes = {"JungleM", "BambooJungleM"},
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:grass_block_no_snow"},
	sidelen = 8,
	noise_params = {
		offset = -0.005,
		scale = 0.006,
		spread = vector.new(250, 250, 250),
		seed = 333,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	decoration = "mcl_farming:melon",
	biomes = {"JungleEdge", "JungleEdgeM", "BambooJungleEdge", "BambooJungleEdgeM"},
})

-- Lots of melons in Jungle Edge M
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:grass_block_no_snow"},
	sidelen = 8,
	noise_params = {
		offset = 0.013,
		scale = 0.006,
		spread = vector.new(125, 125, 125),
		seed = 333,
		octaves = 3,
		persist = 0.6
	},
	y_min = 1,
	y_max = mcl_vars.mg_overworld_max,
	decoration = "mcl_farming:melon",
	biomes = {"JungleEdgeM"},
})
