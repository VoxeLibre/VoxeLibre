-- Soul sand
minetest.register_ore({
	ore_type = "sheet",
	ore = "mcl_nether:soul_sand",
	-- Note: Stone is included only for v6 mapgen support. Netherrack is not generated naturally
	-- in v6, but instead set with the on_generated function in mcl_mapgen_core.
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity = 13 * 13 * 13,
	clust_size = 5,
	y_min = vl_biomes.nether_min,
	y_max = mcl_worlds.layer_to_y(64, "nether"),
	noise_threshold = 0.0,
	noise_params = {
		offset = 0.5,
		scale = 0.1,
		spread = vector.new(5, 5, 5),
		seed = 2316,
		octaves = 1,
		persist = 0.0
	},
})

-- Magma blocks
minetest.register_ore({
	ore_type = "blob",
	ore = "mcl_nether:magma",
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity = 8 * 8 * 8,
	clust_num_ores = 45,
	clust_size = 6,
	y_min = mcl_worlds.layer_to_y(23, "nether"),
	y_max = mcl_worlds.layer_to_y(37, "nether"),
	noise_params = {
		offset = 0,
		scale = 1,
		spread = vector.new(250, 250, 250),
		seed = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	},
})
minetest.register_ore({
	ore_type = "blob",
	ore = "mcl_nether:magma",
	wherein = {"mcl_nether:netherrack"},
	clust_scarcity = 10 * 10 * 10,
	clust_num_ores = 65,
	clust_size = 8,
	y_min = mcl_worlds.layer_to_y(23, "nether"),
	y_max = mcl_worlds.layer_to_y(37, "nether"),
	noise_params = {
		offset = 0,
		scale = 1,
		spread = vector.new(250, 250, 250),
		seed = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	},
})

-- Glowstone
minetest.register_ore({
	ore_type = "blob",
	ore = "mcl_nether:glowstone",
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity = 26 * 26 * 26,
	clust_size = 5,
	y_min = vl_biomes.lava_nether_max + 10,
	y_max = vl_biomes.nether_max - 13,
	noise_threshold = 0.0,
	noise_params = {
		offset = 0.5,
		scale = 0.1,
		spread = vector.new(5, 5, 5),
		seed = 17676,
		octaves = 1,
		persist = 0.0
	},
})

-- Gravel (Nether)
minetest.register_ore({
	ore_type = "sheet",
	ore = "mcl_core:gravel",
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	column_height_min = 1,
	column_height_max = 1,
	column_midpoint_factor = 0,
	y_min = mcl_worlds.layer_to_y(63, "nether"),
	-- This should be 65, but for some reason with this setting, the sheet ore really stops at 65. o_O
	y_max = mcl_worlds.layer_to_y(65 + 2, "nether"),
	noise_threshold = 0.2,
	noise_params = {
		offset = 0.0,
		scale = 0.5,
		spread = vector.new(20, 20, 20),
		seed = 766,
		octaves = 3,
		persist = 0.6,
	},
})

-- Nether quartz
if minetest.settings:get_bool("mcl_generate_ores", true) then
	minetest.register_ore({
		ore_type = "scatter",
		ore = "mcl_nether:quartz_ore",
		wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 850,
		clust_num_ores = 4, -- MC cluster amount: 4-10
		clust_size = 3,
		y_min = vl_biomes.nether_min,
		y_max = vl_biomes.nether_max,
	})
	minetest.register_ore({
		ore_type = "scatter",
		ore = "mcl_nether:quartz_ore",
		wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 1650,
		clust_num_ores = 8, -- MC cluster amount: 4-10
		clust_size = 4,
		y_min = vl_biomes.nether_min,
		y_max = vl_biomes.nether_max,
	})
end

-- Lava springs in the Nether
minetest.register_ore({
	ore_type = "scatter",
	ore = "mcl_nether:nether_lava_source",
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity = 13500, --rare
	clust_num_ores = 1,
	clust_size = 1,
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_max - 13,
})

local lava_biomes = {"BasaltDelta", "Nether"}
minetest.register_ore({
	ore_type = "scatter",
	ore = "mcl_nether:nether_lava_source",
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity = 500,
	clust_num_ores = 1,
	clust_size = 1,
	biomes = lava_biomes,
	y_min = vl_biomes.nether_min,
	y_max = vl_biomes.lava_nether_max + 1,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "mcl_nether:nether_lava_source",
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity = 1000,
	clust_num_ores = 1,
	clust_size = 1,
	biomes = lava_biomes,
	y_min = vl_biomes.lava_nether_max + 2,
	y_max = vl_biomes.lava_nether_max + 12,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "mcl_nether:nether_lava_source",
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size = 1,
	biomes = lava_biomes,
	y_min = vl_biomes.lava_nether_max + 13,
	y_max = vl_biomes.lava_nether_max + 48,
})
minetest.register_ore({
	ore_type = "scatter",
	ore = "mcl_nether:nether_lava_source",
	wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
	clust_scarcity = 3500,
	clust_num_ores = 1,
	clust_size = 1,
	biomes = lava_biomes,
	y_min = vl_biomes.lava_nether_max + 49,
	y_max = vl_biomes.nether_max - 13,
})

