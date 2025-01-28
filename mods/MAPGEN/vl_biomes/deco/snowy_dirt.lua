--Snow layer on snowy dirt
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:dirt_with_grass_snow"},
	sidelen = 80,
	fill_ratio = 10,
	flags = "all_floors",
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_core:snow",
})
