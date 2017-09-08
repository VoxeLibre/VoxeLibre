local mg_name = minetest.get_mapgen_setting("mg_name")

--
-- Register biomes
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

	--[[ OVERWORLD ]]

	-- Ice spikes
	minetest.register_biome({
		name = "ice_plains_spike",
		node_top = "mcl_core:snowblock",
		depth_top = 2,
		node_filler = "mcl_core:snowblock",
		depth_filler = 1,
		node_water_top = "mcl_core:ice",
		depth_water_top = 2,
		node_river_water = "mcl_core:ice",
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 0,
		humidity_point = 73,
	})

	-- Frozen ocean
	minetest.register_biome({
		name = "ice_plains_spike_ocean",
		node_top = "mcl_core:gravel",
		depth_top = 2,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_water_top = "mcl_core:ice",
		depth_water_top = 2,
		node_river_water = "mcl_core:ice",
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 0,
		humidity_point = 73,
	})

	-- Cold Taiga
	minetest.register_biome({
		name = "cold_taiga",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:dirt_with_grass_snow",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 2,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 0,
		humidity_point = 40,
	})

	minetest.register_biome({
		name = "cold_taiga_beach",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_water_top = "mcl_core:ice",
		depth_water_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -3,
		y_max = 1,
		heat_point = 0,
		humidity_point = 40,
	})

	minetest.register_biome({
		name = "cold_taiga_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -4,
		heat_point = 0,
		humidity_point = 40,
	})

	-- Mega taiga
	minetest.register_biome({
		name = "mega_taiga",
		node_top = "mcl_core:podzol",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 26,
		humidity_point = 72,
	})

	minetest.register_biome({
		name = "mega_taiga_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 26,
		humidity_point = 72,
	})

	-- Mega spruce taiga
	minetest.register_biome({
		name = "mega_spruce_taiga",
		node_top = "mcl_core:podzol",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 21,
		humidity_point = 72,
	})

	minetest.register_biome({
		name = "mega_spruce_taiga_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 21,
		humidity_point = 72,
	})

	-- Ice plains
	minetest.register_biome({
		name = "ice_plains",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:dirt_with_grass_snow",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_water_top = "mcl_core:ice",
		depth_water_top = 2,
		node_river_water = "mcl_core:ice",
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 13,
		humidity_point = 79,
	})

	minetest.register_biome({
		name = "ice_plains_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 13,
		humidity_point = 79,
	})

	-- Plains
	minetest.register_biome({
		name = "plains",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 26,
		humidity_point = 45,
	})

	minetest.register_biome({
		name = "plains_beach",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 3,
		y_max = 1,
		heat_point = 26,
		humidity_point = 45,
	})

	minetest.register_biome({
		name = "plains_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 26,
		humidity_point = 45,
	})

	-- TODO: Sunflower Plains
--[[
	minetest.register_biome({
		name = "sunflower_plains",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 26,
		humidity_point = 22.5,
	})

	minetest.register_biome({
		name = "sunflower_plains_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:dirt",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 26,
		humidity_point = 22.5,
	})
]]

	-- Taiga
	minetest.register_biome({
		name = "taiga",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 47,
		humidity_point = 73,  --was 70
	})

	minetest.register_biome({
		name = "taiga_beach",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 3,
		heat_point = 47,
		humidity_point = 73,  --was 70
	})

	minetest.register_biome({
		name = "taiga_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 47,
		humidity_point = 73,  --was 70
	})

	-- (Deciduous) forest
	minetest.register_biome({
		name = "forest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 33,
		humidity_point = 44,  --was 68
	})

	minetest.register_biome({
		name = "forest_beach",
		node_top = "mcl_core:sand",
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
		name = "forest_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -2,
		heat_point = 33,
		humidity_point = 44,  --was 68
	})

	-- Birch forest
	minetest.register_biome({
		name = "birch_forest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 20,
		humidity_point = 49,
	})

	minetest.register_biome({
		name = "birch_forest_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 20,
		humidity_point = 49,
	})

	-- Birch forest M
	minetest.register_biome({
		name = "birch_forest_m",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 20,
		humidity_point = 44,
	})

	minetest.register_biome({
		name = "birch_forest_m_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 20,
		humidity_point = 44,
	})

	-- Desert (Red Sand)
	minetest.register_biome({
		name = "red_desert",
		node_top = "mcl_core:redsand",
		depth_top = 1,
		node_filler = "mcl_core:redsand",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		node_stone = "mcl_core:redsandstone",
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 64,
		humidity_point = 37,  --was 16
	})

	minetest.register_biome({
		name = "red_desert_ocean",
		node_top = "mcl_core:redsand",
		depth_top = 1,
		node_filler = "mcl_core:redsand",
		depth_filler = 3,
		node_riverbed = "mcl_core:redsand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 64,
		humidity_point = 37,  --was 16
	})

	-- Desert (Sand)
	minetest.register_biome({
		name = "desert",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		node_stone = "mcl_core:sandstone",
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 57,
		humidity_point = 0,  --was 0
	})

	minetest.register_biome({
		name = "desert_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 57,
		humidity_point = 0,  --was 0
	})

	-- Roofed forest
	minetest.register_biome({
		name = "roofed_forest",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 26,
		humidity_point = 0,
	})

	minetest.register_biome({
		name = "roofed_forest_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 1,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 26,
		humidity_point = 0,
	})

	-- Mesa
	minetest.register_biome({
		name = "mesa",
		node_top = "mcl_colorblocks:hardened_clay",
		depth_top = 1,
		node_filler = "mcl_colorblocks:hardened_clay",
		depth_filler = 35,
		node_riverbed = "mcl_core:redsand",
		depth_riverbed = 2,
		node_stone = "mcl_colorblocks:hardened_clay",
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 88,
		humidity_point = 20,
	})

	minetest.register_biome({
		name = "mesa_ocean",
		node_top = "mcl_core:redsand",
		depth_top = 3,
		node_filler = "mcl_colorblocks:hardened_clay",
		depth_filler = 1,
		node_riverbed = "mcl_core:redsand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 88,
		humidity_point = 20,
	})

	-- Savanna
	minetest.register_biome({
		name = "savanna",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:coarse_dirt",
		depth_filler = 2,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 50,
		humidity_point = 46,
	})

	minetest.register_biome({
		name = "savanna_beach",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -1,
		y_max = 0,
		heat_point = 50,
		humidity_point = 46,
	})

	minetest.register_biome({
		name = "savanna_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:coarse_dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -2,
		heat_point = 50,
		humidity_point = 46,
	})

	-- Jungle
	minetest.register_biome({
		name = "jungle",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		heat_point = 90,
		humidity_point = 91,
	})

	minetest.register_biome({
		name = "jungle_shore",
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
		name = "jungle_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = -2,
		heat_point = 90,
		humidity_point =  91,
	})

	-- Swampland
	minetest.register_biome({
		name = "swampland",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 23,
		heat_point = 60,
		humidity_point = 99,
	})

	minetest.register_biome({
		name = "swampland_shore",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = -4,
		y_max = 0,
		heat_point = 60,
		humidity_point = 99,
	})

	minetest.register_biome({
		name = "swampland_ocean",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 20,
		y_max = -4,
		heat_point = 60,
		humidity_point = 99,
	})

	-- Mushroom biomes
	-- TODO: Make sure these biomes only spawn in islands
	minetest.register_biome({
		name = "mushroom_island",
		node_top = "mcl_core:mycelium",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 4,
		y_max = 20,
		heat_point = 99,
		humidity_point = 99,
	})

	minetest.register_biome({
		name = "mushroom_island_shore",
		node_top = "mcl_core:mycelium",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 3,
		heat_point = 99,
		humidity_point = 99,
	})

	minetest.register_biome({
		name = "mushroom_island_ocean",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = mcl_vars.mg_overworld_min,
		y_max = 0,
		heat_point = 99,
		humidity_point = 99,
	})

end

-- Register biomes of non-Overworld biomes
local function register_dimension_biomes()
	--[[ REALMS ]]

	--[[ THE NETHER ]]
	minetest.register_biome({
		name = "nether",
		node_filler = "mcl_nether:netherrack",
		node_stone = "mcl_nether:netherrack",
		node_water = "air",
		node_river_water = "air",
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
		node_stone = "air",
		node_filler = "air",
		node_water = "air",
		node_river_water = "air",
		-- FIXME: For some reason the End stops generating early if this constant is not added.
		-- Figure out why.
		y_min = mcl_vars.mg_end_min,
		y_max = mcl_vars.mg_end_max + 80,
		heat_point = 50,
		humidity_point = 50,
	})

end

-- Register “fake” ores directly related to the biomes
local function register_biomelike_ores()

	-- Mesa ores
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:sandstone",
		wherein        ={"mcl_colorblocks:hardened_clay"},
		clust_scarcity = 1,
		clust_num_ores = 12,
		clust_size     = 10,
		y_min     = 10,
		y_max     = 30,
		noise_threshold = 0.2,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70},
		biomes = { "mesa" },
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:dirt",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_scarcity = 1,
		clust_num_ores = 12,
		clust_size     = 4,
		y_min     = -12,
		y_max     = 7,
		noise_threshold = 0.4,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70},
		biomes = { "mesa" },
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:redsand",
		wherein        = { "mcl_colorblocks:hardened_clay"},
		clust_scarcity = 1,
		clust_num_ores = 12,
		clust_size     = 10,
		y_min     = 44,
		y_max     = 70,
		noise_threshold = 0.7,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70},
		biomes = { "mesa" },
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_core:redsand",
		wherein        = {"mcl_core:redsandstone", "mcl_colorblocks:hardened_clay"},
		clust_scarcity = 1,
		clust_num_ores = 8,
		clust_size     = 4,
		y_min     = 4,
		y_max     = 70,
		noise_threshold = 0.4,
		noise_params = {offset=0, scale=15, spread={x=130, y=130, z=130}, seed=24, octaves=3, persist=0.70},
		biomes = { "mesa" },
	})

	-- Mesa strata
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_silver",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 1,
		y_min     = 5,
		y_max     = 14,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_brown",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 1,
		y_min     = 15,
		y_max     = 17,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70},
		biomes = { "mesa" },
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_orange",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 6,
		y_min     = 20,
		y_max     = 29,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_red",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 2,
		y_min     = 34,
		y_max     = 37,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})

	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_yellow",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 1,
		y_min     = 42,
		y_max     = 43,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_orange",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 1,
		y_min = 43,
		y_max = 44,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_brown",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 1,
		y_min = 44,
		y_max = 45,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_yellow",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 1,
		y_min     = 45,
		y_max     = 47,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_white",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 1,
		y_min     = 49,
		y_max     = 52,
		noise_threshold = 0.0,
		noise_params =     {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_yellow",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size = 4,
		y_min = 53,
		y_max = 59,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_white",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 8,
		y_min = 61,
		y_max = 70,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})
	minetest.register_ore({
		ore_type       = "sheet",
		ore            = "mcl_colorblocks:hardened_clay_silver",
		wherein        = {"mcl_colorblocks:hardened_clay"},
		clust_size     = 8,
		y_min     = 66,
		y_max     = 75,
		noise_threshold = 0.0,
		noise_params = {offset=0, scale=1, spread={x=3100, y=3100, z=3100}, seed=23, octaves=3, persist=0.70} ,
		biomes = { "mesa" },
	})
end

-- Non-Overworld ores
local function register_dimension_ores()

	--[[ NETHER GENERATION ]]

	-- Soul sand
	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_nether:soul_sand",
		-- Note: Stone is included only for v6 mapgen support. Netherrack is not generated naturally
		-- in v6, but instead set with the on_generated function in mcl_mapgen_core.
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
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
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 8*8*8,
		clust_num_ores = 45,
		clust_size     = 6,
		y_min          = mcl_util.layer_to_y(23, "nether"),
		y_max          = mcl_util.layer_to_y(37, "nether"),
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = "mcl_nether:magma",
		wherein        = {"mcl_nether:netherrack"},
		clust_scarcity = 10*10*10,
		clust_num_ores = 65,
		clust_size     = 8,
		y_min          = mcl_util.layer_to_y(23, "nether"),
		y_max          = mcl_util.layer_to_y(37, "nether"),
	})

	-- Glowstone
	minetest.register_ore({
		ore_type        = "blob",
		ore             = "mcl_nether:glowstone",
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
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

	-- Gravel (Nether)
	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_core:gravel",
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
		column_height_min = 1,
		column_height_max = 1,
		column_midpoint_factor = 0,
		y_min           = mcl_util.layer_to_y(63, "nether"),
		-- This should be 65, but for some reason with this setting, the sheet ore really stops at 65. o_O
		y_max           = mcl_util.layer_to_y(65+2, "nether"),
		noise_threshold = 0.2,
		noise_params    = {
			offset = 0.0,
			scale = 0.5,
			spread = {x = 20, y = 20, z = 20},
			seed = 766,
			octaves = 3,
			persist = 0.6,
		},
	})

	-- Nether quartz
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:quartz_ore",
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 850,
		clust_num_ores = 4, -- MC cluster amount: 4-10
		clust_size     = 3,
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_max,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:quartz_ore",
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 1650,
		clust_num_ores = 8, -- MC cluster amount: 4-10
		clust_size     = 4,
		y_min = mcl_vars.mg_nether_min,
		y_max = mcl_vars.mg_nether_max,
	})

	-- Lava springs in the Nether
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 500,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_nether_min,
		y_max           = mcl_vars.mg_lava_nether_max + 1,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 1000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 2,
		y_max           = mcl_vars.mg_lava_nether_max + 12,
	})

	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 2000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 13,
		y_max           = mcl_vars.mg_lava_nether_max + 48,
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_nether:nether_lava_source",
		wherein         = {"mcl_nether:netherrack", "mcl_core:stone"},
		clust_scarcity = 3500,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min           = mcl_vars.mg_lava_nether_max + 49,
		y_max           = mcl_vars.mg_nether_max,
	})

	--[[ THE END ]]

	-- Generate fake End
	-- TODO: Remove both "ores" when there's a better End generator

	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_end:end_stone",
		wherein         = {"air"},
		y_min           = mcl_vars.mg_end_min+64,
		y_max           = mcl_vars.mg_end_min+80,
		column_height_min = 6,
		column_height_max = 7,
		column_midpoint_factor = 0.0,
		noise_params = {
			offset  = -2,
			scale   = 8,
			spread  = {x=100, y=100, z=100},
			seed    = 2999,
			octaves = 5,
			persist = 0.55,
		},
		noise_threshold = 0,
	})

	minetest.register_ore({
		ore_type        = "sheet",
		ore             = "mcl_end:end_stone",
		wherein         = {"air"},
		y_min           = mcl_vars.mg_end_min+64,
		y_max           = mcl_vars.mg_end_min+80,
		column_height_min = 4,
		column_height_max = 4,
		column_midpoint_factor = 0.0,
		noise_params = {
			offset  = -4,
			scale   = 3,
			spread  = {x=200, y=200, z=200},
			seed    = 5390,
			octaves = 5,
			persist = 0.6,
		},
		noise_threshold = 0,
	})

end


-- All mapgens except mgv6

-- Template to register a grass or fern decoration
local function register_grass_decoration(grasstype, offset, scale, biomes)
	local place_on, seed, node
	if grasstype == "fern" then
		node = "mcl_flowers:fern"
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:podzol"}
		seed = 333
	elseif grasstype == "tallgrass" then
		node = "mcl_flowers:tallgrass"
		place_on = {"mcl_core:dirt_with_grass"}
		seed = 420
	end
	local noise = {
		offset = offset,
		scale = scale,
		spread = {x = 200, y = 200, z = 200},
		seed = seed,
		octaves = 3,
		persist = 0.6
	}
	minetest.register_decoration({
		deco_type = "simple",
		place_on = place_on,
		sidelen = 16,
		noise_params = noise,
		biomes = biomes,
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = node,
	})
end

local function register_decorations()

	-- Large ice spike
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:snowblock", "mcl_core:snow", "mcl_core:dirt_with_grass_snow"},
		sidelen = 80,
		noise_params = {
			offset = 0.00040,
			scale = 0.001,
			spread = {x = 250, y = 250, z = 250},
			seed = 1133,
			octaves = 4,
			persist = 0.67,
		},
		biomes = {"ice_plains_spike"},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_ice_spike_large.mts",
		rotation = "random",
		flags = "place_center_x, place_center_z",
	})

	-- Small ice spike
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:snowblock", "mcl_core:snow", "mcl_core:dirt_with_grass_snow"},
		sidelen = 80,
		noise_params = {
			offset = 0.005,
			scale = 0.001,
			spread = {x = 250, y = 250, z = 250},
			seed = 1133,
			octaves = 4,
			persist = 0.67,
		},
		biomes = {"ice_plains_spike"},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_ice_spike_small.mts",
		rotation = "random",
		flags = "place_center_x, place_center_z",
	})

	-- Oak
	-- Large oaks
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 80,
		noise_params = {
			offset = 0.00075,
			scale = 0.0011,
			spread = {x = 250, y = 250, z = 250},
			seed = 3,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_large_1.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 80,
		noise_params = {
			offset = 0.00075,
			scale = 0.0011,
			spread = {x = 250, y = 250, z = 250},
			seed = 3,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_large_2.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	-- Small classic oak (forest and ice plains)
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.025,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:dirt_with_grass_snow"},
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = 0.0002,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"ice_plains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	-- Rare balloon oak
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.002083,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 3,
			octaves = 3,
			persist = 0.6,
		},
		biomes = {"forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_balloon.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	-- Swamp oak
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 80,
		noise_params = {
			offset = 0.0055,
			scale = 0.0011,
			spread = {x = 250, y = 250, z = 250},
			seed = 5005,
			octaves = 5,
			persist = 0.6,
		},
		biomes = {"swampland", "swampland_shore"},
		y_min = 0,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_swamp.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Jungle tree
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 80,
		fill_ratio = 0.0025,
		biomes = {"jungle"},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_jungle_tree_huge.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 80,
		fill_ratio = 0.045,
		biomes = {"jungle"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_jungle_tree.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	-- Oak in jungle
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 80,
		fill_ratio = 0.004,
		biomes = {"jungle"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_oak_classic.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Spruce
	local function quick_spruce(seed, offset, sprucename, biomes)
		minetest.register_decoration({
			deco_type = "schematic",
			place_on = {"mcl_core:dirt_with_grass_snow", "mcl_core:dirt_with_grass", "mcl_core:podzol"},
			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = 0.0006,
				spread = {x = 250, y = 250, z = 250},
				seed = seed,
				octaves = 3,
				persist = 0.66
			},
			biomes = biomes,
			y_min = 2,
			y_max = mcl_vars.mg_overworld_max,
			schematic = minetest.get_modpath("mcl_core").."/schematics/"..sprucename,
			flags = "place_center_x, place_center_z",
		})
	end

	-- Huge spruce
	quick_spruce(3000, 0.001, "mcl_core_spruce_huge_1.mts", {"mega_spruce_taiga"})
	quick_spruce(4000, 0.00112, "mcl_core_spruce_huge_2.mts", {"mega_spruce_taiga"})
	quick_spruce(6000, 0.001, "mcl_core_spruce_huge_3.mts", {"mega_spruce_taiga"})

	-- Common spruce
	quick_spruce(2500, 0.0062, "mcl_core_spruce_1.mts", {"mega_spruce_taiga", "mega_taiga", "taiga", "cold_taiga"})
	quick_spruce(5000, 0.0065, "mcl_core_spruce_2.mts", {"mega_spruce_taiga", "mega_taiga", "taiga", "cold_taiga"})
	quick_spruce(7000, 0.005, "mcl_core_spruce_3.mts", {"mega_spruce_taiga", "mega_taiga", "taiga", "cold_taiga"})

	-- Small lollipop spruce
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass_snow", "mcl_core:dirt_with_grass", "mcl_core:podzol"},
		sidelen = 16,
		noise_params = {
			offset = 0.004,
			scale = 0.0022,
			spread = {x = 250, y = 250, z = 250},
			seed = 2500,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"taiga", "cold_taiga"},
		y_min = 2,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_spruce_lollipop.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Matchstick spruce: Very few leaves, tall trunk
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass_snow", "mcl_core:dirt_with_grass", "mcl_core:podzol"},
		sidelen = 80,
		noise_params = {
			offset = -0.025,
			scale = 0.025,
			spread = {x = 250, y = 250, z = 250},
			seed = 2566,
			octaves = 5,
			persist = 0.60,
		},
		biomes = {"taiga", "cold_taiga"},
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_spruce_matchstick.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Acacia
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:coarse_dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.00075,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 26,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"savanna"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_acacia_classic_1.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:coarse_dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.00075,
			scale = 0.002,
			spread = {x = 250, y = 250, z = 250},
			seed = 25,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"savanna"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_acacia_classic_2.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Birch
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.03,
			scale = 0.0025,
			spread = {x = 250, y = 250, z = 250},
			seed = 11,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"birch_forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_birch.mts",
		flags = "place_center_x, place_center_z",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.03,
			scale = 0.0025,
			spread = {x = 250, y = 250, z = 250},
			seed = 11,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"birch_forest_m"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_birch_tall.mts",
		flags = "place_center_x, place_center_z",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.001,
			scale = -0.0015,
			spread = {x = 250, y = 250, z = 250},
			seed = 11,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_birch.mts",
		flags = "place_center_x, place_center_z",
	})
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt_with_grass_snow"},
		sidelen = 16,
		noise_params = {
			offset = -0.0005,
			scale = -0.0015,
			spread = {x = 250, y = 250, z = 250},
			seed = 11,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"ice_plains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_birch.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Dark Oak
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.05,
			scale = 0.0015,
			spread = {x = 125, y = 125, z = 125},
			seed = 223,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"roofed_forest"},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_dark_oak.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})


	-- Huge Brown Mushroom
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = { "mcl_core:dirt_with_grass", "mcl_core:dirt" },
		sidelen = 80,
		fill_ratio = 0.0001,
		-- FIXME: Should be roofed forest, but placing it there doesn't work well (leaves often go into mushroom)
		biomes = { "forest" },
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_brown.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = { "mcl_core:mycelium" },
		sidelen = 80,
		fill_ratio = 0.002,
		biomes = { "mushroom_island", "mushroom_island_shore" },
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_brown.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Huge Red Mushroom
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = { "mcl_core:dirt_with_grass", "mcl_core:dirt" },
		sidelen = 50,
		fill_ratio = 0.0001,
		-- FIXME: Should be roofed forest, but placing it there doesn't work well (leaves often go into mushroom)
		biomes = { "forest" },
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_red.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = { "mcl_core:mycelium" },
		sidelen = 50,
		fill_ratio = 0.002,
		biomes = { "mushroom_island", "mushroom_island_shore" },
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_mushrooms").."/schematics/mcl_mushrooms_huge_red.mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})

	-- Moss stone boulder (3×3)
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt"},
		sidelen = 80,
		noise_params = {
			offset = 0.00015,
			scale = 0.001,
			spread = {x = 300, y = 300, z = 300},
			seed = 775703,
			octaves = 4,
			persist = 0.63,
		},
		biomes = {"mega_taiga", "mega_spruce_taiga"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_boulder.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Small moss stone boulder (2×2)
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt"},
		sidelen = 80,
		noise_params = {
			offset = 0.001,
			scale = 0.001,
			spread = {x = 300, y = 300, z = 300},
			seed = 775703,
			octaves = 4,
			persist = 0.63,
		},
		biomes = {"mega_taiga", "mega_spruce_taiga"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_boulder_small.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Cacti
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:sand"},
		sidelen = 16,
		noise_params = {
			offset = -0.012,
			scale = 0.024,
			spread = {x = 100, y = 100, z = 100},
			seed = 257,
			octaves = 3,
			persist = 0.6
		},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:cactus",
		biomes = {"red_desert","desert"},
		height = 1,
		height_max = 3,
	})

	-- Sugar canes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "mcl_core:dirt_with_grass", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 100, y = 100, z = 100},
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"plains", "plains_beach", "taiga_beach", "ice_plains", "cold_taiga_beach", "savanna_beach", "forest_beach", "red_desert", "desert"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
		spawn_by = { "mcl_core:water_source", "group:frosted_ice" },
		num_spawn_by = 1,
	})
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "mcl_core:dirt_with_grass", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = 0.0,
			scale = 0.5,
			spread = {x = 100, y = 100, z = 100},
			seed = 2,
			octaves = 3,
			persist = 0.7,
		},
		biomes = {"swampland"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
		spawn_by = { "mcl_core:water_source", "group:frosted_ice" },
		num_spawn_by = 1,
	})

	-- Doubletall grass
	minetest.register_decoration({
		deco_type = "schematic",
		schematic = {
			size = { x=1, y=3, z=1 },
			data = {
				{ name = "air", prob = 0 },
				{ name = "mcl_flowers:double_grass", param1=255, },
				{ name = "mcl_flowers:double_grass_top", param1=255, },
			},
		},
		replacements = {
			["mcl_flowers:tallgrass"] = "mcl_flowers:double_grass"
		},
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt_with_grass_snow"},
		sidelen = 16,
		noise_params = {
			offset = -0.01,
			scale = 0.03,
			spread = {x = 300, y = 300, z = 300},
			seed = 420,
			octaves = 2,
			persist = 0.6,
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		biomes = {"plains", "sunflower_plains", "taiga", "forest", "birch_forest", "birch_forest_m", "roofed_forest", "savanna"},
	})

	-- Large ferns
	minetest.register_decoration({
		deco_type = "schematic",
		schematic = {
			size = { x=1, y=3, z=1 },
			data = {
				{ name = "air", prob = 0 },
				{ name = "mcl_flowers:double_fern", param1=255, },
				{ name = "mcl_flowers:double_fern_top", param1=255, },
			},
		},
		replacements = {
			["mcl_flowers:fern"] = "mcl_flowers:double_fern"
		},
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:podzol", "mcl_core:podzol_snow"},

		sidelen = 16,
		noise_params = {
			offset = 0.01,
			scale = 0.01,
			spread = {x = 250, y = 250, z = 250},
			seed = 333,
			octaves = 2,
			persist = 0.66,
		},
		biomes = { "jungle", "taiga", "cold_taiga", "mega_taiga", "mega_spruce_taiga" },
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
	})

	-- Large flowers
	local register_large_flower = function(name, biomes, seed, offset)
		minetest.register_decoration({
			deco_type = "schematic",
			schematic = {
				size = { x=1, y=3, z=1 },
				data = {
					{ name = "air", prob = 0 },
					{ name = "mcl_flowers:"..name, param1=255, },
					{ name = "mcl_flowers:"..name.."_top", param1=255, },
				},
			},
			place_on = {"mcl_core:dirt_with_grass"},

			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = 0.01,
				spread = {x = 300, y = 300, z = 300},
				seed = seed,
				octaves = 5,
				persist = 0.62,
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			flags = "",
			biomes = biomes,
		})
	end

	register_large_flower("rose_bush", {"forest", "birch_forest", "birch_forest_m", "taiga", "roofed_forest", "flower_forest"}, 9350, -0.008)
	register_large_flower("peony", {"forest", "birch_forest", "birch_forest_m", "taiga", "roofed_forest", "flower_forest"}, 10450, -0.008)
	register_large_flower("lilac", {"forest", "birch_forest", "birch_forest_m", "taiga", "roofed_forest", "flower_forest"}, 10600, -0.007)
	-- TODO
	register_large_flower("sunflower", {"plains", "sunflower_plains"}, 2940, 0.0) -- 0.03

	-- Jungle bush
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 80,
		noise_params = {
			offset = 0.0196,
			scale = 0.025,
			spread = {x = 250, y = 250, z = 250},
			seed = 2930,
			octaves = 4,
			persist = 0.6,
		},
		biomes = {"jungle"},
		y_min = 3,
		y_max = mcl_vars.mg_overworld_max,
		schematic = minetest.get_modpath("mcl_core").."/schematics/mcl_core_jungle_bush.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Fallen logs
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:podzol", "mcl_core:coarse_dirt"},
		sidelen = 80,
		noise_params = {
			offset = 0.00018,
			scale = 0.00011,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"mega_taiga", "mega_spruce_taiga", "taiga"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = {
			size = {x = 4, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:sprucetree", param2 = 12, prob = 127},
				{name = "mcl_core:sprucetree", param2 = 12},
				{name = "mcl_core:sprucetree", param2 = 12},
				{name = "mcl_core:sprucetree", param2 = 12, prob = 127},
				{name = "air", prob = 0},
				{name = "mcl_mushrooms:mushroom_brown", prob = 160},
				{name = "mcl_mushrooms:mushroom_red", prob = 160},
				{name = "air", prob = 0},
			},
		},
		flags = "place_center_x",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass_snow", "mcl_core:dirt_with_grass", "mcl_core:podzol", "mcl_core:podzol_snow", "mcl_core:coarse_dirt"},
		sidelen = 80,
		noise_params = {
			offset = 0.00018,
			scale = 0.00011,
			spread = {x = 250, y = 250, z = 250},
			seed = 2,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"cold_taiga"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = {
			size = {x = 4, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:sprucetree", param2 = 12, prob = 127},
				{name = "mcl_core:sprucetree", param2 = 12},
				{name = "mcl_core:sprucetree", param2 = 12},
				{name = "mcl_core:sprucetree", param2 = 12, prob = 127},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
			},
		},
		flags = "place_center_x",
		rotation = "random",
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
		biomes = {"forest", "birch_forest", "birch_forest_m",},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = {
			size = {x = 3, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:birchtree", param2 = 12},
				{name = "mcl_core:birchtree", param2 = 12},
				{name = "mcl_core:birchtree", param2 = 12, prob = 127},
				{name = "mcl_mushrooms:mushroom_red", prob = 100},
				{name = "mcl_mushrooms:mushroom_brown", prob = 10},
				{name = "air", prob = 0},
			},
		},
		flags = "place_center_x",
		rotation = "random",
	})

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
		sidelen = 80,
		fill_ratio = 0.005,
		biomes = {"jungle"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = {
			size = {x = 4, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:jungletree", param2 = 12, prob = 127},
				{name = "mcl_core:jungletree", param2 = 12},
				{name = "mcl_core:jungletree", param2 = 12},
				{name = "mcl_core:jungletree", param2 = 12, prob = 127},
				{name = "air", prob = 0},
				{name = "mcl_mushrooms:mushroom_brown", prob = 50},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
			},
		},
		flags = "place_center_x",
		rotation = "random",
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
		biomes = {"forest"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = {
			size = {x = 3, y = 3, z = 1},
			data = {
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "air", prob = 0},
				{name = "mcl_core:tree", param2 = 12, prob = 127},
				{name = "mcl_core:tree", param2 = 12},
				{name = "mcl_core:tree", param2 = 12},
				{name = "air", prob = 0},
				{name = "mcl_mushrooms:mushroom_brown", prob = 96},
				{name = "mcl_mushrooms:mushroom_red", prob = 96},
			},
		},
		flags = "place_center_x",
		rotation = "random",
	})

	-- Lily pad

	local lily_schem = {
		{ name = "mcl_core:water_source" },
		{ name = "mcl_flowers:waterlily" },
	}

	-- Spawn them in shallow water at ocean level in swamplands.
	-- Tweak lilydepth to change the maximum water depth
	local lilydepth = 2

	for d=1, lilydepth do
		local height = d + 2
		local y = 1 - d
		table.insert(lily_schem, 1, { name = "air", prob = 0 })

		minetest.register_decoration({
			deco_type = "schematic",
			schematic = {
				size = { x=1, y=height, z=1 },
				data = lily_schem,
			},
			place_on = "mcl_core:dirt",
			sidelen = 16,
			noise_params = {
				offset = 0,
				scale = 0.3,
				spread = {x = 100, y = 100, z = 100},
				seed = 503,
				octaves = 6,
				persist = 0.7,
			},
			y_min = y,
			y_max = y,
			biomes = { "swampland_shore" },
			rotation = "random",
		})
	end

	-- Melon
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = 0.003,
			scale = 0.006,
			spread = {x = 250, y = 250, z = 250},
			seed = 333,
			octaves = 3,
			persist = 0.6
		},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_farming:melon",
		biomes = { "jungle" },
	})

	-- Pumpkin
	minetest.register_decoration({
		deco_type = "schematic",
		schematic = {
			size = { x=1, y=2, z=1 },
			data = {
				{ name = "air", prob = 0 },
				{ name = "mcl_farming:pumpkin_face", param1=255, },
			},
		},
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.016,
			scale = 0.01332,
			spread = {x = 125, y = 125, z = 125},
			seed = 666,
			octaves = 6,
			persist = 0.666
		},
		biomes = {"plains"},
		y_min = 3,
		y_max = 29,
		rotation = "random",
	})

	-- Grasses and ferns
	local grass_forest = {"plains", "taiga", "forest", "birch_forest", "birch_forest_m", "roofed_forest", "flower_forest", "swampland" }
	local grass_plains = {"plains", "savanna", "sunflower_plains"}
	local grass_savanna = {"savanna"}

	register_grass_decoration("tallgrass", -0.03,  0.09, grass_forest)
	register_grass_decoration("tallgrass", -0.015, 0.075, grass_forest)
	register_grass_decoration("tallgrass", 0,      0.06, grass_forest)
	register_grass_decoration("tallgrass", 0.015,  0.045, grass_forest)
	register_grass_decoration("tallgrass", 0.03,   0.03, grass_forest)
	register_grass_decoration("tallgrass", 0.01, 0.05, grass_forest)
	register_grass_decoration("tallgrass", 0.03, 0.03, grass_plains)
	register_grass_decoration("tallgrass", 0.05, 0.01, grass_plains)
	register_grass_decoration("tallgrass", 0.07, -0.01, grass_plains)
	register_grass_decoration("tallgrass", 0.09, -0.03, grass_plains)
	register_grass_decoration("tallgrass", 0.18, -0.03, grass_savanna)

	local fern_minimal = { "jungle", "taiga", "mega_taiga", "mega_spruce_taiga", "cold_taiga" }
	local fern_low = { "jungle", "taiga", "mega_taiga", "mega_spruce_taiga" }
	local fern_full = { "jungle" }
	register_grass_decoration("fern", -0.03,  0.09, fern_minimal)
	register_grass_decoration("fern", -0.015, 0.075, fern_minimal)
	register_grass_decoration("fern", 0,      0.06, fern_minimal)
	register_grass_decoration("fern", 0.015,  0.045, fern_low)
	register_grass_decoration("fern", 0.03,   0.03, fern_low)
	register_grass_decoration("fern", 0.01, 0.05, fern_full)
	register_grass_decoration("fern", 0.03, 0.03, fern_full)
	register_grass_decoration("fern", 0.05, 0.01, fern_full)
	register_grass_decoration("fern", 0.07, -0.01, fern_full)
	register_grass_decoration("fern", 0.09, -0.03, fern_full)

	-- Tall grass in ice plains
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt_with_grass_snow"},
		sidelen = 16,
		noise_params = {
			offset = -0.08,
			scale = 0.09,
			spread = {x = 15, y = 15, z = 15},
			seed = 420,
			octaves = 3,
			persist = 0.6,
		},
		biomes = {"ice_plains"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = {
			size = { x=1, y=2, z=1 },
			data = {
				{ name = "mcl_core:dirt_with_grass", force_place=true, },
				{ name = "mcl_flowers:tallgrass", },
			},
		},
	})

	-- Dead bushes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:sand", "mcl_core:podzol", "mcl_core:podzol_snow", "mcl_core:dirt", "mcl_core:coarse_dirt", "group:hardened_clay"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.035,
			spread = {x = 100, y = 100, z = 100},
			seed = 1972,
			octaves = 3,
			persist = 0.6
		},
		y_min = 4,
		y_max = mcl_vars.mg_overworld_max,
		biomes = {"red_desert", "desert", "mesa", "taiga", "mega_taiga"},
		decoration = "mcl_core:deadbush",
		height = 1,
	})

	-- Mushrooms in mushroom biome
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:mycelium"},
		sidelen = 80,
		fill_ratio = 0.009,
		biomes = {"mushroom_island", "mushroom_island_shore"},
		noise_threshold = 2.0,
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_mushrooms:mushroom_red",
	})
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:mycelium"},
		sidelen = 80,
		fill_ratio = 0.009,
		biomes = {"mushroom_island", "mushroom_island_shore"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_mushrooms:mushroom_brown",
	})

	-- Mushrooms in taigas
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:podzol"},
		sidelen = 80,
		fill_ratio = 0.003,
		biomes = {"taiga", "mega_taiga", "mega_spruce_taiga"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_mushrooms:mushroom_red",
	})
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:podzol"},
		sidelen = 80,
		fill_ratio = 0.003,
		biomes = {"taiga", "mega_taiga", "mega_spruce_taiga"},
		y_min = mcl_vars.mg_overworld_min,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_mushrooms:mushroom_brown",
	})


	-- Mushrooms next to trees
	local mushrooms = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}
	local mseeds = { 7133, 8244 }
	for m=1, #mushrooms do
		-- Mushrooms next to trees
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:mycelium", "mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite"},
			sidelen = 16,
			noise_params = {
				offset = 0,
				scale = 0.003,
				spread = {x = 250, y = 250, z = 250},
				seed = mseeds[m],
				octaves = 3,
				persist = 0.66,
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			decoration = mushrooms[m],
			spawn_by = { "mcl_core:tree", "mcl_core:sprucetree", "mcl_core:darktree", "mcl_core:birchtree" },
			num_spawn_by = 1,
		})

		-- More mushrooms in swamplands
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:mycelium", "mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite"},
			sidelen = 16,
			noise_params = {
				offset = 0.05,
				scale = 0.003,
				spread = {x = 250, y = 250, z = 250},
				seed = mseeds[m],
				octaves = 3,
				persist = 0.6,
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			decoration = mushrooms[m],
			biomes = { "swampland "},
			spawn_by = { "mcl_core:tree", "mcl_core:sprucetree", "mcl_core:darktree", "mcl_core:birchtree" },
			num_spawn_by = 1,
		})
	end

	local function register_flower(name, biomes, seed)
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_core:dirt_with_grass", "mcl_core:podzol"},
			sidelen = 16,
			noise_params = {
				offset = 0.0008,
				scale = 0.006,
				spread = {x = 100, y = 100, z = 100},
				seed = seed,
				octaves = 3,
				persist = 0.6
			},
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			biomes = biomes,
			decoration = "mcl_flowers:"..name,
		})
	end

	local flower_biomes1 = {"plains", "sunflower_plains", "flower_forest", "roofed_forest", "forest", "birch_forest", "birch_forest_m", "taiga", "cold_taiga", "jungle", "savanna",}

	register_flower("dandelion", flower_biomes1, 8)
	register_flower("poppy", flower_biomes1, 9439)

	local flower_biomes2 = {"plains", "sunflower_plains", "flower_forest"}
	register_flower("tulip_red", flower_biomes2, 436)
	register_flower("tulip_orange", flower_biomes2, 536)
	register_flower("tulip_pink", flower_biomes2, 636)
	register_flower("tulip_white", flower_biomes2, 736)
	register_flower("azure_bluet", flower_biomes2, 800)
	register_flower("oxeye_daisy", flower_biomes2, 3490)

	-- TODO: Make exclusive to flower forest
	register_flower("allium", {"flower_forest", "roofed_forest"}, 0)
	register_flower("blue_orchid", {"swampland"}, 64500)


end

-- Decorations in non-Overworld dimensions
local function register_dimension_decorations()
	-- TODO
end

--
-- Detect mapgen to select functions
--
if mg_name ~= "singlenode" then
	minetest.clear_registered_biomes()
	minetest.clear_registered_decorations()
	minetest.clear_registered_schematics()
	if mg_name ~= "v6" and mg_name ~= "flat" then
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

	-- Non-overworld stuff is registered independently
	register_dimension_biomes()
	register_dimension_ores()
	register_dimension_decorations()

	-- Overworld decorations for v6 are handled in mcl_mapgen_core
end

