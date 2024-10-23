-- Sugar canes
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
	sidelen = 16,
	noise_params = {
		offset = -0.3,
		scale = 0.7,
		spread = vector.new(200, 200, 200),
		seed = 2,
		octaves = 3,
		persist = 0.7
	},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_core:reeds",
	height = 1,
	height_max = 3,
	spawn_by = {"mcl_core:water_source", "group:frosted_ice"}, -- TODO: river water source, too?
	num_spawn_by = 1,
})
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
	sidelen = 16,
	noise_params = {
		offset = 0.0,
		scale = 0.5,
		spread = vector.new(200, 200, 200),
		seed = 2,
		octaves = 3,
		persist = 0.7,
	},
	biomes = {"Swampland", "Swampland_shore"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_core:reeds",
	height = 1,
	height_max = 3,
	spawn_by = {"mcl_core:water_source", "group:frosted_ice"},
	num_spawn_by = 1,
})

