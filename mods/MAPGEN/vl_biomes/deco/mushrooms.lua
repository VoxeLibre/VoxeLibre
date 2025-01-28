-- Small mushrooms in caves
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:material_stone"},
	sidelen = 80,
	fill_ratio = 0.009,
	noise_threshold = 2.0,
	flags = "all_floors",
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_mushrooms:mushroom_red",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:material_stone"},
	sidelen = 80,
	fill_ratio = 0.009,
	noise_threshold = 2.0,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_mushrooms:mushroom_brown",
})

-- Mushrooms next to trees
local mushrooms = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}
local mseeds = {7133, 8244}
for m = 1, #mushrooms do
	-- Mushrooms next to trees
	mcl_mapgen_core.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:mycelium", "mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.003,
			spread = vector.new(250, 250, 250),
			seed = mseeds[m],
			octaves = 3,
			persist = 0.66,
		},
		y_min = 1,
		y_max = vl_biomes.overworld_max,
		decoration = mushrooms[m],
		spawn_by = {"mcl_core:tree", "mcl_core:sprucetree", "mcl_core:darktree", "mcl_core:birchtree"},
		num_spawn_by = 1,
		rank = 1150,
	})

	-- More mushrooms in Swampland
	mcl_mapgen_core.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:mycelium", "mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite"},
		sidelen = 16,
		noise_params = {
			offset = 0.05,
			scale = 0.003,
			spread = vector.new(250, 250, 250),
			seed = mseeds[m],
			octaves = 3,
			persist = 0.6,
		},
		y_min = 1,
		y_max = vl_biomes.overworld_max,
		decoration = mushrooms[m],
		biomes = {"Swampland"},
		spawn_by = {"mcl_core:tree", "mcl_core:sprucetree", "mcl_core:darktree", "mcl_core:birchtree"},
		num_spawn_by = 1,
		rank = 1150,
	})
end
