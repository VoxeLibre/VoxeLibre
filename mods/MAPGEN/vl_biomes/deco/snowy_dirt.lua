--Snow layer on snowy dirt
vl_biomes.register_decoration({
	decoration = "mcl_core:snow",
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	place_on = {"mcl_core:dirt_with_grass_snow"},
	fill_ratio = 10, -- fill
	flags = "all_floors",
})
