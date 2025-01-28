local mg_name = core.get_mapgen_setting("mg_name")

-- Note: this currently has to go after all the extremehills (windswept hills) biomes in order to be able to register.
-- Alternatively, we could put a copy into each...
local stonelike = {"mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite"}

-- Emeralds
core.register_ore({
	ore_type = "scatter",
	ore = "mcl_core:stone_with_emerald",
	wherein = stonelike,
	clust_scarcity = 16384,
	clust_num_ores = 1,
	clust_size = 1,
	y_min = mcl_worlds.layer_to_y(4),
	y_max = mcl_worlds.layer_to_y(32),
	biomes = {
		"ExtremeHills", "ExtremeHills_beach", "ExtremeHills_ocean", "ExtremeHills_deep_ocean", "ExtremeHills_underground",
		"ExtremeHills+", "ExtremeHills+_ocean", "ExtremeHills+_deep_ocean", "ExtremeHills+_underground",
		"ExtremeHillsM", "ExtremeHillsM_ocean", "ExtremeHillsM_deep_ocean", "ExtremeHillsM_underground",
	},
})

-- Rarely replace stone with stone monster eggs.
-- In v6 this can happen anywhere, in other mapgens only in Extreme Hills.
local monster_egg_scarcity = (mg_name == "v6" and 28 or 26)^3
core.register_ore({
	ore_type = "scatter",
	ore = "mcl_monster_eggs:monster_egg_stone",
	wherein = "mcl_core:stone",
	clust_scarcity = monster_egg_scarcity,
	clust_num_ores = 3,
	clust_size = 2,
	y_min = vl_biomes.overworld_min,
	y_max = mcl_worlds.layer_to_y(61),
	biomes = {
		"ExtremeHills", "ExtremeHills_beach", "ExtremeHills_ocean", "ExtremeHills_deep_ocean", "ExtremeHills_underground",
		"ExtremeHills+", "ExtremeHills+_ocean", "ExtremeHills+_deep_ocean", "ExtremeHills+_underground",
		"ExtremeHillsM", "ExtremeHillsM_ocean", "ExtremeHillsM_deep_ocean", "ExtremeHillsM_underground",
	},
})
