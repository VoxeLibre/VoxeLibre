mcl_mapgen_core = {}

--
-- Aliases for map generator outputs
--

local mcl_mushrooms = minetest.get_modpath("mcl_mushrooms")

minetest.register_alias("mapgen_air", "air")
minetest.register_alias("mapgen_stone", "mcl_core:stone")
minetest.register_alias("mapgen_tree", "mcl_core:tree")
minetest.register_alias("mapgen_leaves", "mcl_core:leaves")
minetest.register_alias("mapgen_jungletree", "mcl_core:jungletree")
minetest.register_alias("mapgen_jungleleaves", "mcl_core:jungleleaves")
minetest.register_alias("mapgen_pine_tree", "mcl_core:sprucetree")
minetest.register_alias("mapgen_pine_needles", "mcl_core:spruceleaves")

minetest.register_alias("mapgen_apple", "mcl_core:leaves")
minetest.register_alias("mapgen_water_source", "mcl_core:water_source")
minetest.register_alias("mapgen_dirt", "mcl_core:dirt")
minetest.register_alias("mapgen_dirt_with_grass", "mcl_core:dirt_with_grass")
minetest.register_alias("mapgen_dirt_with_snow", "mcl_core:dirt_with_grass_snow")
minetest.register_alias("mapgen_sand", "mcl_core:sand")
minetest.register_alias("mapgen_gravel", "mcl_core:gravel")
minetest.register_alias("mapgen_clay", "mcl_core:clay")
minetest.register_alias("mapgen_lava_source", "air") -- Built-in lava generator is too unpredictable, we generate lava on our own
minetest.register_alias("mapgen_cobble", "mcl_core:cobble")
minetest.register_alias("mapgen_mossycobble", "mcl_core:mossycobble")
if minetest.get_modpath("mcl_flowers") then
	minetest.register_alias("mapgen_junglegrass", "mcl_flowers:fern")
end
minetest.register_alias("mapgen_stone_with_coal", "mcl_core:stone_with_coal")
minetest.register_alias("mapgen_stone_with_iron", "mcl_core:stone_with_iron")
minetest.register_alias("mapgen_desert_sand", "mcl_core:sand")
minetest.register_alias("mapgen_desert_stone", "mcl_core:sandstone")
minetest.register_alias("mapgen_sandstone", "mcl_core:sandstone")
if minetest.get_modpath("mclx_core") then
	minetest.register_alias("mapgen_river_water_source", "mclx_core:river_water_source")
else
	minetest.register_alias("mapgen_river_water_source", "mcl_core:water_source")
end
minetest.register_alias("mapgen_snow", "mcl_core:snow")
minetest.register_alias("mapgen_snowblock", "mcl_core:snowblock")
minetest.register_alias("mapgen_ice", "mcl_core:ice")

minetest.register_alias("mapgen_sandstonebrick", "mcl_core:sandstonesmooth")

if minetest.get_modpath("mcl_stairs") then
	minetest.register_alias("mapgen_stair_cobble", "mcl_stairs:stair_cobble")
	minetest.register_alias("mapgen_stair_sandstonebrick", "mcl_stairs:stair_sandstone")
	minetest.register_alias("mapgen_stair_sandstone_block", "mcl_stairs:stair_sandstone")
	minetest.register_alias("mapgen_stair_desert_stone", "mcl_stairs:stair_sandstone")
end

local mg_name = mcl_mapgen.name
local superflat = mcl_mapgen.superflat
local v6 = mcl_mapgen.v6
local singlenode = mcl_mapgen.singlenode
local flat = mcl_mapgen.flat

-- Content IDs
local c_bedrock = minetest.get_content_id("mcl_core:bedrock")
local c_void = minetest.get_content_id("mcl_core:void")
local c_lava = minetest.get_content_id("mcl_core:lava_source")

local c_nether = nil
if minetest.get_modpath("mcl_nether") then
	c_nether = {
		soul_sand = minetest.get_content_id("mcl_nether:soul_sand"),
		netherrack = minetest.get_content_id("mcl_nether:netherrack"),
		lava = minetest.get_content_id("mcl_nether:nether_lava_source")
	}
end

local c_realm_barrier = minetest.get_content_id("mcl_core:realm_barrier")
local c_air = minetest.CONTENT_AIR

--
-- Ore generation
--

-- Diorite, andesite and granite
local specialstones = { "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite" }
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_core:stone"},
		clust_scarcity = 15*15*15,
		clust_num_ores = 33,
		clust_size     = 5,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_mapgen.overworld.max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = {x=250, y=250, z=250},
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		}
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = {"mcl_core:stone"},
		clust_scarcity = 10*10*10,
		clust_num_ores = 58,
		clust_size     = 7,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_mapgen.overworld.max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = {x=250, y=250, z=250},
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		}
	})
end

local stonelike = {"mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite"}

-- Dirt
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:dirt",
	wherein        = stonelike,
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = mcl_mapgen.overworld.min,
	y_max          = mcl_mapgen.overworld.max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- Gravel
minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:gravel",
	wherein        = stonelike,
	clust_scarcity = 14*14*14,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = mcl_mapgen.overworld.min,
	y_max          = mcl_worlds.layer_to_y(111),
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = {x=250, y=250, z=250},
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

if minetest.settings:get_bool("mcl_generate_ores", true) then
	--
	-- Coal
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 525*3,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(50),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 510*3,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(50),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 12,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(50),
	})

	-- Medium-rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 550*3,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 525*3,
		clust_num_ores = 6,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(51),
		y_max          = mcl_worlds.layer_to_y(80),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 600*3,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 550*3,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein         = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(81),
		y_max          = mcl_worlds.layer_to_y(128),
	})

	--
	-- Iron
	--
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_iron",
		wherein         = stonelike,
		clust_scarcity = 830,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(39),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_iron",
		wherein         = stonelike,
		clust_scarcity = 1660,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(40),
		y_max          = mcl_worlds.layer_to_y(63),
	})

	--
	-- Gold
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 4775,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(30),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 6560,
		clust_num_ores = 7,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(30),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 13000,
		clust_num_ores = 4,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(31),
		y_max          = mcl_worlds.layer_to_y(33),
	})

	--
	-- Diamond
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(12),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 5000,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(12),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(12),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 20000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 20000,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})

	--
	-- Redstone
	--

	-- Common spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 500,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(13),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 800,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_mapgen.overworld.min,
		y_max          = mcl_worlds.layer_to_y(13),
	})

	-- Rare spawn
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 1000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 1600,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_worlds.layer_to_y(13),
		y_max          = mcl_worlds.layer_to_y(15),
	})

	--
	-- Emerald
	--

	if v6 then
		-- Generate everywhere in v6, but rarely.

		-- Common spawn
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_core:stone_with_emerald",
			wherein        = stonelike,
			clust_scarcity = 14340,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = mcl_mapgen.overworld.min,
			y_max          = mcl_worlds.layer_to_y(29),
		})
		-- Rare spawn
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_core:stone_with_emerald",
			wherein        = stonelike,
			clust_scarcity = 21510,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = mcl_worlds.layer_to_y(30),
			y_max          = mcl_worlds.layer_to_y(32),
		})
	end

	--
	-- Lapis Lazuli
	--

	-- Common spawn (in the center)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_worlds.layer_to_y(14),
		y_max          = mcl_worlds.layer_to_y(16),
	})

	-- Rare spawn (below center)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 12000,
		clust_num_ores = 6,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(10),
		y_max          = mcl_worlds.layer_to_y(13),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 14000,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(6),
		y_max          = mcl_worlds.layer_to_y(9),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 16000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(2),
		y_max          = mcl_worlds.layer_to_y(5),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 18000,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(0),
		y_max          = mcl_worlds.layer_to_y(2),
	})

	-- Rare spawn (above center)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 12000,
		clust_num_ores = 6,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(17),
		y_max          = mcl_worlds.layer_to_y(20),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 14000,
		clust_num_ores = 5,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(21),
		y_max          = mcl_worlds.layer_to_y(24),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 16000,
		clust_num_ores = 4,
		clust_size     = 3,
		y_min          = mcl_worlds.layer_to_y(25),
		y_max          = mcl_worlds.layer_to_y(28),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 18000,
		clust_num_ores = 3,
		clust_size     = 2,
		y_min          = mcl_worlds.layer_to_y(29),
		y_max          = mcl_worlds.layer_to_y(32),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_lapis",
		wherein         = stonelike,
		clust_scarcity = 32000,
		clust_num_ores = 1,
		clust_size     = 1,
		y_min          = mcl_worlds.layer_to_y(31),
		y_max          = mcl_worlds.layer_to_y(32),
	})
end

if not superflat then
-- Water and lava springs (single blocks of lava/water source)
-- Water appears at nearly every height, but not near the bottom
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:water_source",
	wherein         = {"mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite", "mcl_core:dirt"},
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(5),
	y_max          = mcl_worlds.layer_to_y(128),
})

-- Lava springs are rather common at -31 and below
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 2000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(1),
	y_max          = mcl_worlds.layer_to_y(10),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 9000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(11),
	y_max          = mcl_worlds.layer_to_y(31),
})

-- Lava springs will become gradually rarer with increasing height
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 32000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(32),
	y_max          = mcl_worlds.layer_to_y(47),
})

minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 72000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(48),
	y_max          = mcl_worlds.layer_to_y(61),
})

-- Lava may even appear above surface, but this is very rare
minetest.register_ore({
	ore_type       = "scatter",
	ore            = "mcl_core:lava_source",
	wherein         = stonelike,
	clust_scarcity = 96000,
	clust_num_ores = 1,
	clust_size     = 1,
	y_min          = mcl_worlds.layer_to_y(62),
	y_max          = mcl_worlds.layer_to_y(127),
})
end

local function register_mgv6_decorations()

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
		y_max = mcl_mapgen.overworld.max,
		decoration = "mcl_core:cactus",
		height = 1,
		height_max = 3,
	})

	-- Sugar canes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 100, y = 100, z = 100},
			seed = 465,
			octaves = 3,
			persist = 0.7
		},
		y_min = 1,
		y_max = mcl_mapgen.overworld.max,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
		spawn_by = { "mcl_core:water_source", "group:frosted_ice" },
		num_spawn_by = 1,
	})

	if minetest.get_modpath("mcl_flowers") then
		-- Doubletall grass
		minetest.register_decoration({
			deco_type = "schematic",
			schematic = {
				size = { x=1, y=3, z=1 },
				data = {
					{ name = "air", prob = 0 },
					{ name = "mcl_flowers:double_grass", param1 = 255, },
					{ name = "mcl_flowers:double_grass_top", param1 = 255, },
				},
			},
			place_on = {"group:grass_block_no_snow"},
			sidelen = 8,
			noise_params = {
				offset = -0.0025,
				scale = 0.03,
				spread = {x = 100, y = 100, z = 100},
				seed = 420,
				octaves = 3,
				persist = 0.0,
			},
			y_min = 1,
			y_max = mcl_mapgen.overworld.max,
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
			-- v6 hack: This makes sure large ferns only appear in jungles
			spawn_by = spawn_by_in_jungle,
			num_spawn_by = 1,
			place_on = {"group:grass_block_no_snow"},

			sidelen = 16,
			noise_params = {
				offset = 0,
				scale = 0.01,
				spread = {x = 250, y = 250, z = 250},
				seed = 333,
				octaves = 2,
				persist = 0.66,
			},
			y_min = 1,
			y_max = mcl_mapgen.overworld.max,
		})

		-- Large flowers
		local function register_large_flower(name, seed, offset)
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
				place_on = {"group:grass_block_no_snow"},

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
				y_max = mcl_mapgen.overworld.max,
				flags = "",
			})
		end

		register_large_flower("rose_bush", 9350, -0.008)
		register_large_flower("peony", 10450, -0.008)
		register_large_flower("lilac", 10600, -0.007)
		register_large_flower("sunflower", 2940, -0.005)

		-- Lily pad
		minetest.register_decoration({
			deco_type = "schematic",
			schematic = {
				size = { x=1, y=3, z=1 },
				data = {
					{ name = "mcl_core:water_source", prob = 0 },
					{ name = "mcl_core:water_source" },
					{ name = "mcl_flowers:waterlily", param1 = 255 },
				},
			},
			place_on = "mcl_core:dirt",
			sidelen = 16,
			noise_params = {
				offset = -0.12,
				scale = 0.3,
				spread = {x = 200, y = 200, z = 200},
				seed = 503,
				octaves = 6,
				persist = 0.7,
			},
			y_min = 0,
			y_max = 0,
			rotation = "random",
		})
	end

	if minetest.get_modpath("mcl_farming") then
		-- Pumpkin
		minetest.register_decoration({
			deco_type = "simple",
			decoration = "mcl_farming:pumpkin_face",
			param2 = 0,
			param2_max = 3,
			place_on = {"group:grass_block_no_snow"},
			sidelen = 16,
			noise_params = {
				offset = -0.008,
				scale = 0.00666,
				spread = {x = 250, y = 250, z = 250},
				seed = 666,
				octaves = 6,
				persist = 0.666
			},
			y_min = 1,
			y_max = mcl_mapgen.overworld.max,
		})

		-- Melon
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow"},
			sidelen = 16,
			noise_params = {
				offset = 0.002,
				scale = 0.006,
				spread = {x = 250, y = 250, z = 250},
				seed = 333,
				octaves = 3,
				persist = 0.6
			},
			-- Small trick to make sure melon spawn in jungles
			spawn_by = spawn_by_in_jungle,
			num_spawn_by = 1,
			y_min = 1,
			y_max = 40,
			decoration = "mcl_farming:melon",
		})
	end

	-- Tall grass
	if minetest.get_modpath("mcl_flowers") then
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow"},
			sidelen = 8,
			noise_params = {
				offset = 0.01,
				scale = 0.3,
				spread = {x = 100, y = 100, z = 100},
				seed = 420,
				octaves = 3,
				persist = 0.6
			},
			y_min = 1,
			y_max = mcl_mapgen.overworld.max,
			decoration = "mcl_flowers:tallgrass",
		})
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow"},
			sidelen = 8,
			noise_params = {
				offset = 0.04,
				scale = 0.03,
				spread = {x = 100, y = 100, z = 100},
				seed = 420,
				octaves = 3,
				persist = 0.6
			},
			y_min = 1,
			y_max = mcl_mapgen.overworld.max,
			decoration = "mcl_flowers:tallgrass",
		})
	end

	-- Seagrass and kelp
	if minetest.get_modpath("mcl_ocean") then
		local materials = {"dirt","sand"}
		for i=1, #materials do
			local mat = materials[i]

			minetest.register_decoration({
				deco_type = "simple",
				spawn_by = {"group:water"},
				num_spawn_by = 1,
				place_on = {"mcl_core:"..mat},
				sidelen = 8,
				noise_params = {
					offset = 0.04,
					scale = 0.3,
					spread = {x = 100, y = 100, z = 100},
					seed = 421,
					octaves = 3,
					persist = 0.6
				},
				flags = "force_placement",
				place_offset_y = -1,
				y_min = mcl_mapgen.overworld.min,
				y_max = 0,
				decoration = "mcl_ocean:seagrass_"..mat,
			})
			minetest.register_decoration({
				deco_type = "simple",
				spawn_by = {"group:water"},
				num_spawn_by = 1,
				place_on = {"mcl_core:mat"},
				sidelen = 8,
				noise_params = {
					offset = 0.08,
					scale = 0.03,
					spread = {x = 100, y = 100, z = 100},
					seed = 421,
					octaves = 3,
					persist = 0.6
				},
				flags = "force_placement",
				place_offset_y = -1,
				y_min = mcl_mapgen.overworld.min,
				y_max = -5,
				decoration = "mcl_ocean:seagrass_"..mat,
			})

			minetest.register_decoration({
				deco_type = "simple",
				spawn_by = {"group:water"},
				num_spawn_by = 1,
				place_on = {"mcl_core:"..mat},
				sidelen = 16,
				noise_params = {
					offset = 0.01,
					scale = 0.01,
					spread = {x = 300, y = 300, z = 300},
					seed = 505,
					octaves = 5,
					persist = 0.62,
				},
				flags = "force_placement",
				place_offset_y = -1,
				y_min = mcl_mapgen.overworld.min,
				y_max = -6,
				decoration = "mcl_ocean:kelp_"..mat,
				param2 = 16,
				param2_max = 96,
			})
			minetest.register_decoration({
				deco_type = "simple",
				spawn_by = {"group:water"},
				num_spawn_by = 1,
				place_on = {"mcl_core:"..mat},
				sidelen = 16,
				noise_params = {
					offset = 0.01,
					scale = 0.01,
					spread = {x = 100, y = 100, z = 100},
					seed = 506,
					octaves = 5,
					persist = 0.62,
				},
				flags = "force_placement",
				place_offset_y = -1,
				y_min = mcl_mapgen.overworld.min,
				y_max = -15,
				decoration = "mcl_ocean:kelp_"..mat,
				param2 = 32,
				param2_max = 160,
			})
		end
	end

	-- Add a small amount of tall grass everywhere to avoid areas completely empty devoid of tall grass
	if minetest.get_modpath("mcl_flowers") then
		minetest.register_decoration({
			deco_type = "simple",
			place_on = {"group:grass_block_no_snow"},
			sidelen = 8,
			fill_ratio = 0.004,
			y_min = 1,
			y_max = mcl_mapgen.overworld.max,
			decoration = "mcl_flowers:tallgrass",
		})
	end

	if mcl_mushrooms then
		local mushrooms = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}
		local mseeds = { 7133, 8244 }
		for m=1, #mushrooms do
			-- Mushrooms next to trees
			minetest.register_decoration({
				deco_type = "simple",
				place_on = {"group:grass_block_no_snow", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:mycelium", "mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite"},
				sidelen = 16,
				noise_params = {
					offset = 0.04,
					scale = 0.04,
					spread = {x = 100, y = 100, z = 100},
					seed = mseeds[m],
					octaves = 3,
					persist = 0.6
				},
				y_min = 1,
				y_max = mcl_mapgen.overworld.max,
				decoration = mushrooms[m],
				spawn_by = { "mcl_core:tree", "mcl_core:sprucetree", "mcl_core:darktree", "mcl_core:birchtree", },
				num_spawn_by = 1,
			})
		end
	end

	-- Dead bushes
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:sand", "mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt", "group:hardened_clay"},
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
		y_max = mcl_mapgen.overworld.max,
		decoration = "mcl_core:deadbush",
	})

	if minetest.get_modpath("mcl_flowers") then
		local function register_mgv6_flower(name, seed, offset, y_max)
			if offset == nil then
				offset = 0
			end
			if y_max == nil then
				y_max = mcl_mapgen.overworld.max
			end
			minetest.register_decoration({
				deco_type = "simple",
				place_on = {"group:grass_block_no_snow"},
				sidelen = 16,
				noise_params = {
					offset = offset,
					scale = 0.006,
					spread = {x = 100, y = 100, z = 100},
					seed = seed,
					octaves = 3,
					persist = 0.6
				},
				y_min = 1,
				y_max = y_max,
				decoration = "mcl_flowers:"..name,
			})
		end

		register_mgv6_flower("tulip_red",  436)
		register_mgv6_flower("tulip_orange", 536)
		register_mgv6_flower("tulip_pink", 636)
		register_mgv6_flower("tulip_white", 736)
		register_mgv6_flower("azure_bluet", 800)
		register_mgv6_flower("dandelion", 8)
		-- Allium is supposed to only appear in flower forest in MC. There are no flower forests in v6.
		-- We compensate by making it slightly rarer in v6.
		register_mgv6_flower("allium", 0, -0.001)
		--[[ Blue orchid is supposed to appear in swamplands. There are no swamplands in v6.
		We emulate swamplands by limiting the height to 5 levels above sea level,
		which should be close to the water. ]]
		register_mgv6_flower("blue_orchid", 64500, nil, mcl_worlds.layer_to_y(67))
		register_mgv6_flower("oxeye_daisy", 3490)
		register_mgv6_flower("poppy", 9439)
	end

	-- Put top snow on snowy grass blocks. The v6 mapgen does not generate the top snow on its own.
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_snow"},
		sidelen = 16,
		fill_ratio = 11.0, -- complete coverage
		y_min = 1,
		y_max = mcl_mapgen.overworld.max,
		decoration = "mcl_core:snow",
	})

end

local mg_flags = minetest.settings:get_flags("mg_flags")

-- Inform other mods of dungeon setting for MCL2-style dungeons
mcl_vars.mg_dungeons = mcl_mapgen.dungeons

-- Disable builtin dungeons, we provide our own dungeons
mg_flags.dungeons = false

-- Apply mapgen-specific mapgen code
if v6 then
	register_mgv6_decorations()
elseif superflat then
	-- Enforce superflat-like mapgen: no caves, decor, lakes and hills
	mg_flags.caves = false
	mg_flags.decorations = false
	minetest.set_mapgen_setting("mgflat_spflags", "nolakes,nohills", true)
end

local mg_flags_str = ""
for k,v in pairs(mg_flags) do
	if v == false then
		k = "no" .. k
	end
	mg_flags_str = mg_flags_str .. k .. ","
end
if string.len(mg_flags_str) > 0 then
	mg_flags_str = string.sub(mg_flags_str, 1, string.len(mg_flags_str)-1)
end
minetest.set_mapgen_setting("mg_flags", mg_flags_str, true)

-- Generate basic layer-based nodes: void, bedrock, realm barrier, lava seas, etc.
-- Also perform some basic node replacements.

local bedrock_check
if mcl_mapgen.bedrock_is_rough then
	function bedrock_check(pos, _, pr)
		local y = pos.y
		-- Bedrock layers with increasing levels of roughness, until a perfecly flat bedrock later at the bottom layer
		-- This code assumes a bedrock height of 5 layers.

		local diff = mcl_mapgen.overworld.bedrock_max - y -- Overworld bedrock
		local ndiff1 = mcl_mapgen.nether.bedrock_bottom_max - y -- Nether bedrock, bottom
		local ndiff2 = mcl_mapgen.nether.bedrock_top_max - y -- Nether bedrock, ceiling

		local top
		if diff == 0 or ndiff1 == 0 or ndiff2 == 4 then
			-- 50% bedrock chance
			top = 2
		elseif diff == 1 or ndiff1 == 1 or ndiff2 == 3 then
			-- 66.666...%
			top = 3
		elseif diff == 2 or ndiff1 == 2 or ndiff2 == 2 then
			-- 75%
			top = 4
		elseif diff == 3 or ndiff1 == 3 or ndiff2 == 1 then
			-- 90%
			top = 10
		elseif diff == 4 or ndiff1 == 4 or ndiff2 == 0 then
			-- 100%
			return true
		else
			-- Not in bedrock layer
			return false
		end

		return pr:next(1, top) <= top-1
	end
end


-- Helper function to set all nodes in the layers between min and max.
-- content_id: Node to set
-- check: optional.
--	If content_id, node will be set only if it is equal to check.
--	If function(pos_to_check, content_id_at_this_pos), will set node only if returns true.
-- min, max: Minimum and maximum Y levels of the layers to set
-- minp, maxp: minp, maxp of the on_generated
-- lvm_used: Set to true if any node in this on_generated has been set before.
--
-- returns true if any node was set and lvm_used otherwise
local function set_layers(vm_context, pr, min, max, content_id, check)
	local minp, maxp, data, area = vm_context.minp, vm_context.maxp, vm_context.data, vm_context.area
	if (maxp.y >= min and minp.y <= max) then
		for y = math.max(min, minp.y), math.min(max, maxp.y) do
			for x = minp.x, maxp.x do
				for z = minp.z, maxp.z do
					local p_pos = vm_context.area:index(x, y, z)
					if check then
						if type(check) == "function" and check({x=x,y=y,z=z}, data[p_pos], pr) then
							data[p_pos] = content_id
							vm_context.write = true
						elseif check == data[p_pos] then
							data[p_pos] = content_id
							vm_context.write = true
						end
					else
						vm_context.data[p_pos] = content_id
						vm_context.write = true
					end
				end
			end
		end
	end
end

---- Generate layers of air, void, etc
local air_layers = {
	{mcl_mapgen.nether.max + 1, mcl_mapgen.nether.max + 128} -- on Nether Roof
}
if flat then
	air_layers[#air_layers + 1] = {mcl_mapgen.nether.flat_floor, mcl_mapgen.nether.flat_ceiling} -- Flat Nether
end

-- Realm barrier between the Overworld void and the End
local barrier_min = mcl_mapgen.realm_barrier_overworld_end_min
local barrier_max = mcl_mapgen.realm_barrier_overworld_end_max

local void_layers = {
	{mcl_mapgen.EDGE_MIN        , mcl_mapgen.nether.min - 1   }, -- below Nether
	{mcl_mapgen.nether.max + 129, mcl_mapgen.end_.min - 1     }, -- below End (above Nether)
	{mcl_mapgen.end_.max + 1    , barrier_min - 1             }, -- below Realm Barrier, above End
	{barrier_max + 1            , mcl_mapgen.overworld.min - 1}, -- below Overworld, above Realm Barrier
}

local bedrock_layers = {}
if not singlenode then
	bedrock_layers = {
		{mcl_mapgen.overworld.bedrock_min    , mcl_mapgen.overworld.bedrock_max    },
		{mcl_mapgen.nether.bedrock_bottom_min, mcl_mapgen.nether.bedrock_bottom_max},
		{mcl_mapgen.nether.bedrock_top_min   , mcl_mapgen.nether.bedrock_top_max   },
	}
end

mcl_mapgen.register_mapgen_block_lvm(function(vm_context)
	local vm, data, area, minp, maxp, chunkseed, blockseed = vm_context.vm, vm_context.data, vm_context.area, vm_context.minp, vm_context.maxp, vm_context.chunkseed, vm_context.blockseed
	vm_context.param2_data = vm_context.param2_data or vm:get_param2_data(vm_context.lvm_param2_buffer)
	local param2_data = vm_context.param2_data
	local pr = PseudoRandom(blockseed)
	for _, layer in pairs(void_layers) do
		set_layers(vm_context, pr, layer[1], layer[2], c_void)
	end
	for _, layer in pairs(air_layers) do
		set_layers(vm_context, pr, layer[1], layer[2], c_air)
	end
	set_layers(vm_context, pr, barrier_min, barrier_max, c_realm_barrier)
	for _, layer in pairs(bedrock_layers) do
		set_layers(vm_context, pr, layer[1], layer[2], c_bedrock, bedrock_check)
	end
	if not singlenode then
		-- Big lava seas by replacing air below a certain height
		if mcl_mapgen.lava then
			set_layers(vm_context, pr, mcl_mapgen.overworld.min, mcl_mapgen.overworld.lava_max, c_lava, c_air)
			if c_nether then
				set_layers(vm_context, pr, mcl_mapgen.nether.min, mcl_mapgen.nether.lava_max, c_nether.lava, c_air)
			end
		end
	end
end, 1)

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath .. "/clay.lua")
dofile(modpath .. "/tree_decoration.lua")
dofile(modpath .. "/nether_wart.lua")
dofile(modpath .. "/light.lua")
if v6 then
	dofile(modpath .. "/v6.lua")
elseif not singlenode then
	dofile(modpath .. "/biomes.lua")
end
if not singlenode and c_nether then
	dofile(modpath .. "/nether.lua")
end
