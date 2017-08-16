
--
-- Register biomes for mapgens other than v6
-- EXPERIMENTAL!
--

local function register_classic_superflat_biome()
	-- Classic Superflat: bedrock (not part of biome), 2 dirt, 1 grass block
	minetest.register_biome({
		name = "flat",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_stone = "mcl_core:dirt",
		y_min = mcl_vars.mg_overworld_min - 512,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 50,
		humidity_point = 50,
	})
end

-- All mapgens except mgv6, flat and singlenode
local function register_biomes()

	local upper_limit = mcl_vars.mg_overworld_max
	--[[ OVERWORLD ]]

	-- Icesheet
	minetest.register_biome({
		name = "icesheet",
		node_dust = "mcl_core:snowblock",
		node_top = "mcl_core:snowblock",
		depth_top = 1,
		node_filler = "mcl_core:snowblock",
		depth_filler = 3,
		node_stone = "mcl_core:packed_ice",
		node_water_top = "mcl_core:ice",
		depth_water_top = 10,
		node_river_water = "mcl_core:ice",
		node_riverbed = "mcl_core:gravel",
		depth_riverbed = 2,
		y_min = -8,
		y_max = upper_limit,
		heat_point = 0,
		humidity_point = 73,
	})

	minetest.register_biome({
		name = "icesheet_ocean",
		node_dust = "mcl_core:snowblock",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_water_top = "mcl_core:ice",
		depth_water_top = 10,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -9,
		heat_point = 0,
		humidity_point = 73,
	})

	-- Tundra

	minetest.register_biome({
		name = "tundra",
		node_dust = "mcl_core:snowblock",
		node_riverbed = "mcl_core:gravel",
		depth_riverbed = 2,
		y_min = 2,
		y_max = upper_limit,
		heat_point = 0,
		humidity_point = 40,
	})

	minetest.register_biome({
		name = "tundra_beach",
		node_top = "mcl_core:gravel",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 2,
		node_riverbed = "mcl_core:gravel",
		depth_riverbed = 2,
		y_min = -3,
		y_max = 1,
		heat_point = 0,
		humidity_point = 40,
	})

	minetest.register_biome({
		name = "tundra_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_riverbed = "mcl_core:gravel",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -4,
		heat_point = 0,
		humidity_point = 40,
	})

	-- Taiga
	minetest.register_biome({
		name = "taiga",
		node_top = "mcl_core:podzol",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 15,
		y_max = upper_limit,
		heat_point = 26,
		humidity_point = 72,
	})

	minetest.register_biome({
		name = "taiga_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 1,
		heat_point = 26,
		humidity_point = 72,
	})

	-- Snowy grassland

	minetest.register_biome({
		name = "snowy_grassland",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:dirt_with_grass_snow",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 5,
		y_max = upper_limit,
		heat_point = 13,
		humidity_point = 79,
	})

	minetest.register_biome({
		name = "snowy_grassland_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 4,
		heat_point = 13,
		humidity_point = 79,
	})

	-- Grassland

	minetest.register_biome({
		name = "grassland",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 6,
		y_max = upper_limit,
		heat_point = 26,
		humidity_point = 45,
	})

	minetest.register_biome({
		name = "grassland_dunes",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 5,
		y_max = 1,
		heat_point = 26,
		humidity_point = 45,
	})


	minetest.register_biome({
		name = "grassland_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 26,
		humidity_point = 45,
	})

	-- Coniferous forest

	minetest.register_biome({
		name = "coniferous_forest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 6,
		y_max = upper_limit,
		heat_point = 47,
		humidity_point = 73,  --was 70
	})

	minetest.register_biome({
		name = "coniferous_forest_dunes",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 56,
		heat_point = 47,
		humidity_point = 73,  --was 70
	})

	minetest.register_biome({
		name = "coniferous_forest_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 47,
		humidity_point = 73,  --was 70
	})

	-- Deciduous forest


	minetest.register_biome({
		name = "deciduous_forest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = upper_limit,
		heat_point = 33,
		humidity_point = 44,  --was 68
	})

	minetest.register_biome({
		name = "deciduous_forest_shore",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -1,
		y_max = 0,
		heat_point = 33,
		humidity_point = 44,  --was 68
	})

	minetest.register_biome({
		name = "deciduous_forest_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -2,
		heat_point = 33,
		humidity_point = 44,  --was 68
	})

	-- Desert

	minetest.register_biome({
		name = "desert",
		node_top = "mcl_core:redsand",
		depth_top = 1,
		node_filler = "mcl_core:redsand",
		depth_filler = 1,
		node_stone = "mcl_core:redsandstone",
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = upper_limit,
		heat_point = 64,
		humidity_point = 37,  --was 16
	})

	minetest.register_biome({
		name = "desert_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_stone = "mcl_core:stone",
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 64,
		humidity_point = 37,  --was 16
	})

	-- Sandstone desert

	minetest.register_biome({
		name = "sandstone_desert",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 1,
		node_stone = "mcl_core:sandstone",
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 0,
		y_max = upper_limit,
		heat_point = 57,
		humidity_point = 0,  --was 0
	})

	minetest.register_biome({
		name = "sandstone_desert_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_stone = "mcl_core:stone",
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 4,
		heat_point = 57,
		humidity_point = 0,  --was 0
	})

	-- Cold desert

	minetest.register_biome({
		name = "cold_desert",
		--node_dust = "",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 1,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = 5,
		y_max = upper_limit,
		heat_point = 26,
		humidity_point = 0,  --was 0
	})

	minetest.register_biome({
		name = "cold_desert_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 4,
		heat_point = 26,
		humidity_point = 0,  --was 0
	})

	-- Hot biomes
	minetest.register_biome({
		name = "mesa",
		node_top = "mcl_colorblocks:hardened_clay_orange",
		depth_top = 1,
		node_filler = "mcl_colorblocks:hardened_clay_orange",
		depth_filler = 1,
		node_stone = "mcl_colorblocks:hardened_clay_orange",
		y_min = -35,
		y_max = upper_limit,
		heat_point = 88,
		humidity_point = 20,  --was 40
	})


	-- Savanna
	minetest.register_biome({
		name = "savanna",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = upper_limit,
		heat_point = 50,
		humidity_point = 46,  --was 42
	})

	minetest.register_biome({
		name = "savanna_shore",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -1,
		y_max = 0,
		heat_point = 50,
		humidity_point = 46,  --was 42
	})

	minetest.register_biome({
		name = "savanna_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:stone",
		depth_filler = 3,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -2,
		heat_point = 50,
		humidity_point = 46,  --was 42
	})

	-- Rainforest

	minetest.register_biome({
		name = "rainforest",
		node_top = "mcl_core:podzol",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = upper_limit,
		heat_point = 90,
		humidity_point = 91,
	})

	minetest.register_biome({
		name = "rainforest_swamp",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -1,
		y_max = 0,
		heat_point = 90,
		humidity_point = 91,
	})

	minetest.register_biome({
		name = "rainforest_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -2,
		heat_point = 90,
		humidity_point =  91,
	})

	-- Mushroom biomes
	minetest.register_biome({
		name = "mushroom",
		node_top = "mcl_core:mycelium",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 20,
		heat_point = 99,
		humidity_point = 99,
	})

	minetest.register_biome({
		name = "mushroom_ocean",
		node_top = "mcl_core:stone",
		depth_top = 1,
		node_filler = "mcl_core:gravel",
		depth_filler = 3,
		node_riverbed = "mcl_core:coarse_dirt",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 99,
		humidity_point = 99,
	})


	--cold
	minetest.register_biome({
		name = "mushroom_cold",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:mycelium_snow",
		depth_top = 1,
		node_filler = "mcl_core:coarse_dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:stone",
		depth_riverbed = 2,
		y_min = 56,
		y_max = upper_limit,
		heat_point = -13,
		humidity_point = 30,
	})



	-- Underground in Overworld
	minetest.register_biome({
		name = "underground",
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_util.y_to_layer(61),
		heat_point = 50,
		humidity_point = 50,
	})


	--[[ REALMS ]]
	-- TODO: Make these work in v6, too.

	--[[ THE NETHER ]]

	minetest.register_biome({
		name = "nether",
		node_filler = "mcl_nether:netherrack",
		node_stone = "mcl_nether:netherrack",
		y_min = mcl_vars.mg_nether_min,
		-- FIXME: For some reason the Nether stops generating early if this constant is not added.
		-- Figure out why.
		y_max = mcl_vars.mg_nether_max + 80,
		heat_point = 100,
		humidity_point = 0,
	})

	--[[ THE END ]]

	minetest.register_biome({
		name = "end",
		node_filler = "mcl_end:end_stone",
		node_stone = "mcl_end:end_stone",
		y_min = mcl_vars.mg_end_min,
		-- FIXME: For some reason the Nether stops generating early if this constant is not added.
		-- Figure out why.
		y_max = mcl_vars.mg_end_max + 80,
		heat_point = 50,
		humidity_point = 50,
	})


end

-- Register “fake” ores directly related to the biomes
local function register_biomelike_ores()

	-- Fake moss stone boulder
	-- TODO: Remove when real boulders are added
	minetest.register_ore({
		ore_type       = "blob",
		ore            = "mcl_core:mossycobble",
		wherein        = "mcl_core:podzol",
		biomes         = {"taiga"},
		clust_scarcity  = 16 * 16 * 16,
		clust_size      = 3,
		y_min           = 25,
		y_max           = 31000,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 3, y = 3, z = 3},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

	--mcl_core STRATA
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:stone",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_scarcity = 1,
		clust_num_ores = 3,
		clust_size     = 4,
		y_min     = 50,
		y_max     = 90,
		noise_threshold = 0.4,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70}
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:clay",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_scarcity = 1,
		clust_num_ores = 12,
		clust_size     = 8,
		y_min     = 24,
		y_max     = 50,
		noise_threshold = 0.4,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70}
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:sandstone",
		wherein        ={"mcl_colorblocks:hardened_clay_orange"},
		clust_scarcity = 1,
		clust_num_ores = 12,
		clust_size     = 10,
		y_min     = 10,
		y_max     = 30,
		noise_threshold = 0.2,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70}
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:dirt",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_scarcity = 1,
		clust_num_ores = 12,
		clust_size     = 4,
		y_min     = -12,
		y_max     = 7,
		noise_threshold = 0.4,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70}
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:redsand",
		wherein        = { "mcl_colorblocks:hardened_clay_orange"},
		clust_scarcity = 1,
		clust_num_ores = 12,
		clust_size     = 10,
		y_min     = 44,
		y_max     = 70,
		noise_threshold = 0.7,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70}
	})


	-- MESA STRATA
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:redsand",
		wherein        = {"mcl_core:redsandstone", "mcl_colorblocks:hardened_clay_orange"},
		clust_scarcity = 1,
		clust_num_ores = 8,
		clust_size     = 4,
		y_min     = 4,
		y_max     = 70,
		noise_threshold = 0.4,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70}
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_white",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 1,
		y_min     = 5,
		y_max     = 14,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_black",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 1,
		y_min     = 15,
		y_max     = 17,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70},
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_brown",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 6,
		y_min     = 20,
		y_max     = 29,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_red",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 2,
		y_min     = 34,
		y_max     = 37,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_yellow",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 1,
		y_min     = 42,
		y_max     = 43,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_blue",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 1,
		y_min = 43,
		y_max = 44,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_yellow",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 1,
		y_min = 44,
		y_max = 45,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_yellow",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 1,
		y_min     = 45,
		y_max     = 47,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_light_blue",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 1,
		y_min     = 49,
		y_max     = 52,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_yellow",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size = 4,
		y_min = 53,
		y_max = 59,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_white",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 8,
		y_min = 61,
		y_max = 70,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_purple",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},
		clust_size     = 8,
		y_min     = 66,
		y_max     = 75,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:obsidian",
		wherein        = {"mcl_colorblocks:hardened_clay_orange"},

		clust_size     = 8,
		y_min     = 161,
		y_max     = 170,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread= {x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})


	--[[ NETHER GENERATION ]]

	-- Soul sand
	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_nether:soul_sand",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity  = 13 * 13 * 13,
		clust_size      = 5,
		y_min           = mcl_vars.mg_nether_min,
		y_max           = mcl_util.layer_to_y(64, "nether"),
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.1,
			spread = {x = 5, y = 5, z = 5},
			seed = 2316,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Magma blocks
	minetest.register_ore({
		ore_type       = "blob",
		ore            = "mcl_nether:magma",
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 15*15*15,
		clust_num_ores = 33,
		clust_size     = 5,
		y_min          = mcl_util.layer_to_y(23, "nether"),
		y_max          = mcl_util.layer_to_y(37, "nether"),
	})

	-- Glowstone
	minetest.register_ore({
		ore_type        = "blob",
		ore             = "mcl_nether:glowstone",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity  = 26 * 26 * 26,
		clust_size      = 5,
		y_min           = mcl_vars.mg_lava_nether_max + 10,
		y_max           = mcl_vars.mg_nether_max,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.1,
			spread = {x = 5, y = 5, z = 5},
			seed = 17676,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Nether quartz
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:quartz_ore",
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 850,
		clust_num_ores = 4, -- MC cluster amount: 4-10
		clust_size     = 3,
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:quartz_ore",
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 1650,
		clust_num_ores = 8, -- MC cluster amount: 4-10
		clust_size     = 4,
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_max,
	})

	-- Gravel (Nether)
	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_core:gravel",
		wherein         = {"mcl_nether:netherrack"},
		clust_scarcity  = 16 * 16 * 16,
		clust_size      = 5,
		y_min           = mcl_util.layer_to_y(63, "nether"),
		y_max           = mcl_util.layer_to_y(65, "nether"),
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.2,
			spread = {x = 5, y = 1, z = 5},
			seed = 766,
			octaves = 1,
			persist = 0.0
		},
	})

	-- Lava in the Nether
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 12 *12 * 12,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min           = mcl_vars.mg_nether_min,
		y_max           = mcl_vars.mg_nether_min + 15,
	})


	-- Fire in the Nether
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_fire:eternal_fire",
		wherein        = "mcl_nether:netherrack",
		clust_scarcity =12 *22 * 12,
		clust_num_ores = 5,
		clust_size     = 5,
		y_min           = mcl_vars.mg_nether_min,
		y_max           = mcl_vars.mg_nether_max,
	})

	-- Generate holes in Nether
	-- TODO: Is this a good idea?
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "air",
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 1,
		clust_num_ores = 32,
		clust_size     = 10,
		y_min           = mcl_vars.mg_nether_min,
		y_max           = mcl_vars.mg_nether_max,
		noise_threshold = 0.2,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70}
	})


	--[[ THE END ]]

	-- Generate fake End
	-- TODO: Remove both "ores" when there's a better End

	minetest.register_ore({
		ore_type        = "blob",
		ore             = "mcl_end:end_stone",
		wherein         = {"air", "mcl_core:stone"},
		clust_scarcity  = 30 * 30 * 30,
		clust_size      = 17,
		y_min           = mcl_vars.mg_end_min,
		y_max           = mcl_vars.mg_end_max,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.1,
			spread = {x = 5, y = 5, z = 5},
			seed = 16,
			octaves = 1,
			persist = 0.0
		},
	})

	minetest.register_ore({
		ore_type        = "scatter",
		ore             = "mcl_end:end_stone",
		wherein         = {"air", "mcl_core:stone"},
		clust_scarcity  = 30 * 30 * 30,
		clust_size      = 34,
		y_min           = mcl_vars.mg_end_min,
		y_max           = mcl_vars.mg_end_max,
		noise_threshold = 0.0,
		noise_params    = {
			offset = 0.5,
			scale = 0.1,
			spread = {x = 70, y = 15, z = 70},
			seed = 16,
			octaves = 1,
			persist = 0.0
		},
	})

end


-- All mapgens except mgv6

local function register_grass_decoration(offset, scale)
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = offset,
			scale = scale,
			spread = {x = 200, y = 200, z = 200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"grassland", "coniferous_forest", "deciduous_forest", "savanna"},
		y_min = 1,
		y_max = 31000,
		decoration = "mcl_flowers:tallgrass",
	})
end

local function register_decorations()

	-- Oak tree and log
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0036,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest"},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_core").."/schematics/apple_tree.mts",
		flags = "place_center_x, place_center_z",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.00018,
			scale = 0.00011,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest"},
		y_min = 1,
		y_max = 31000,
		schematic = {
			size = {x = 3, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:tree", param2 = 12, prob = 191},
				{name = "mcl_core:tree", param2 = 12},
				{name = "mcl_core:tree", param2 = 12, prob = 127},
				{name = "air", prob = 0},
				{name = "mcl_mushrooms:mushroom_brown", prob = 63},
				{name = "air", prob = 0},
			},
		},
		flags = "place_center_x",
		rotation = "random",
	})

	-- Jungle tree and log

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:podzol"},
		sidelen = 80,
		fill_ratio = 0.09,
		biomes = {"rainforest", "rainforest_swamp"},
		y_min = 0,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_core").."/schematics/jungle_tree.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:podzol"},
		sidelen = 80,
		fill_ratio = 0.01,
		biomes = {"rainforest", "rainforest_swamp"},
		y_min = 1,
		y_max = 31000,
		schematic = {
			size = {x = 3, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:jungletree", param2 = 12, prob = 191},
				{name = "mcl_core:jungletree", param2 = 12},
				{name = "mcl_core:jungletree", param2 = 12, prob = 127},
				{name = "air", prob = 0},
				{name = "mcl_mushrooms:mushroom_brown", prob = 127},
				{name = "air", prob = 0},
			},
		},
		flags = "place_center_x",
		rotation = "random",
	})

	-- Taiga and temperate coniferous forest pine tree and log

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass_snow", "mcl_core:dirt_with_grass", "mcl_core:podzol"},
		sidelen = 16,
		noise_params = {
			offset = 0.0096,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"taiga", "coniferous_forest","coniferous_forest_dunes"},
		y_min = 2,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_core").."/schematics/pine_tree.mts",
		flags = "place_center_x, place_center_z",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass_snow", "mcl_core:dirt_with_grass", "mcl_core:podzol"},
		sidelen = 80,
		noise_params = {
			offset = 0.00018,
			scale = 0.00011,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"taiga", "coniferous_forest","coniferous_forest_dunes"},
		y_min = 1,
		y_max = 31000,
		schematic = {
			size = {x = 3, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:sprucetree", param2 = 12, prob = 191},
				{name = "mcl_core:sprucetree", param2 = 12},
				{name = "mcl_core:sprucetree", param2 = 12, prob = 127},
				{name = "air", prob = 0},
				{name = "mcl_mushrooms:mushroom_red", prob = 63},
				{name = "air", prob = 0},
			},
		},
		flags = "place_center_x",
		rotation = "random",
	})

	-- Acacia tree and log

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:coarse_dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"savanna"},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_core").."/schematics/acacia_tree.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.001,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"savanna"},
		y_min = 1,
		y_max = 31000,
		schematic = {
			size = {x = 3, y = 2, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:acaciatree", param2 = 12, prob = 191},
				{name = "mcl_core:acaciatree", param2 = 12},
				{name = "mcl_core:acaciatree", param2 = 12, prob = 127},
			},
		},
		flags = "place_center_x",
		rotation = "random",
	})


	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:sand"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.0002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"savanna"},
		y_min = 7,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_core").."/schematics/acacia_tree.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})


	-- Aspen tree and log

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = -0.0015,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest"},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_core").."/schematics/aspen_tree.mts",
		flags = "place_center_x, place_center_z",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = -0.00008,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"deciduous_forest"},
		y_min = 1,
		y_max = 31000,
		schematic = {
			size = {x = 3, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:birchtree", param2 = 12},
				{name = "mcl_core:birchtree", param2 = 12},
				{name = "mcl_core:birchtree", param2 = 12, prob = 127},
				{name = "mcl_mushrooms:mushroom_red", prob = 63},
				{name = "mcl_mushrooms:mushroom_brown", prob = 63},
				{name = "air", prob = 0},
			},
		},
		flags = "place_center_x",
		rotation = "random",
	})


	--Big dark oak  W.I.P.

	--TODO  MAKE SCHEMATICS



	--Red Mushroom
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:mycelium"},
		sidelen = 80,
		fill_ratio = 0.004,
		biomes = {"mushroom"},
		y_min = -6000,
		y_max = 31000,
		decoration = "mcl_mushrooms:mushroom_red",
	})
	--Brown Mushroom
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:mycelium"},
		sidelen = 80,
		fill_ratio = 0.003,
		biomes = {"mushroom"},
		y_min = -6000,
		y_max = 31000,
		decoration = "mcl_mushrooms:mushroom_brown",
	})

	--Red Mushroom
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:mycelium", "mcl_core:mycelium_snow"},
		sidelen = 80,
		fill_ratio = 0.0002,
		biomes = {"mushroom", "mushroom_cold"},
		y_min = -6000,
		y_max = 31000,
		decoration = "mcl_mushrooms:mushroom_red",
	})

	--Huge Mushroom
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:mycelium", "mcl_core:mycelium_snow"},
		sidelen = 80,
		fill_ratio = 0.0004,
		biomes = {"mushroom", "mushroom_cold"},
		y_min = -6000,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_brown.mts",
		flags = "place_center_x",
		rotation = "random",
	})



	--Huge Brown Mushroom
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:mycelium", "mcl_core:mycelium_snow"},
		sidelen = 80,
		fill_ratio = 0.002,
		biomes = {"mushroom", "mushroom_cold"},
		y_min = -6000,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_brown.mts",
		flags = "place_center_x",
		rotation = "random",
	})

	--Huge Red Mushroom
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = { "mcl_core:dirt_with_grass"},
		sidelen = 50,
		fill_ratio = 0.0002,
		biomes = { "deciduous_forest"},
		y_min = -6000,
		y_max = 31000,
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_red.mts",
		flags = "place_center_x",
		rotation = "random",
	})


	-- Simple 1×1×1 moss stone
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:podzol"},
		sidelen = 80,
		fill_ratio = 0.004,
		biomes = {"taiga"},
		y_min = 10,
		y_max = 31000,
		decoration = "mcl_core:mossycobble",
	})
	-- Cactus

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:sand", "mcl_core:redsand"},
		sidelen = 16,
		noise_params = {
			offset = -0.0003,
			scale = 0.0009,
			spread = {x = 200, y = 200, z = 200},
			seed = 230,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert"},
		y_min = 5,
		y_max = 31000,
		decoration = "mcl_core:cactus",
		biomes = {"desert","sandstone_desert","grassland_dunes", "coniferous_forest_dunes"},
		height = 1,
		height_max = 3,
	})

	-- Sugar canes
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt", "mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 200, y = 200, z = 200},
			seed = 354,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"grassland", "savanna", "beach", "desert", "savanna_swamp"},
		y_min = 0,
		y_max = 0,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
	})

	-- Grasses

	register_grass_decoration(-0.03,  0.09)
	register_grass_decoration(-0.015, 0.075)
	register_grass_decoration(0,      0.06)
	register_grass_decoration(0.015,  0.045)
	register_grass_decoration(0.03,   0.03)
	register_grass_decoration(0.01, 0.05)
	register_grass_decoration(0.03, 0.03)
	register_grass_decoration(0.05, 0.01)
	register_grass_decoration(0.07, -0.01)
	register_grass_decoration(0.09, -0.03)

	-- Dead bushes

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:sand", "mcl_core:redsand"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.02,
			spread = {x = 200, y = 200, z = 200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert"},
		y_min = 2,
		y_max = 31000,
		decoration = "mcl_core:deadbush",
		height = 1,
	})


	--[[ NETHER decorations ]]

	-- Red Mushroom
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_nether:netherrack"},
		sidelen = 80,
		fill_ratio = 0.01,
		biomes = {"nether"},
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_max,
		decoration = "mcl_mushrooms:mushroom_red",
	})
	-- Brown Mushroom
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_nether:netherrack"},
		sidelen = 80,
		fill_ratio = 0.01,
		biomes = {"nether"},
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_max,
		decoration = "mcl_mushrooms:mushroom_brown",
	})

	-- Eternal Fire
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_nether:netherrack"},
		sidelen = 16,
		fill_ratio = 0.2,
		biomes = {"nether"},
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_max,
		decoration = "mcl_fire:eternal_fire",
	})
	-- Nether Wart
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_nether:soul_sand"},
		sidelen = 80,
		fill_ratio = 0.1,
		biomes = {"nether"},
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_max,
		decoration = "mcl_nether:nether_wart",
	})

end


--
-- Detect mapgen to select functions
--
local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name ~= "v6" and mg_name ~= "flat" then
	minetest.clear_registered_biomes()
	minetest.clear_registered_decorations()
	minetest.clear_registered_schematics()
	register_biomes()
	register_biomelike_ores()
	register_decorations()
elseif mg_name == "flat" then
	-- Implementation of Minecraft's Superflat mapgen, classic style
	minetest.clear_registered_biomes()
	minetest.clear_registered_decorations()
	minetest.clear_registered_schematics()
	register_classic_superflat_biome()
end
-- v6 decorations are handled in mcl_mapgen_core
