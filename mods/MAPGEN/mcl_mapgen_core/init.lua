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

-- Content IDs
local c_bedrock = minetest.get_content_id("mcl_core:bedrock")
local c_obsidian = minetest.get_content_id("mcl_core:obsidian")
local c_stone = minetest.get_content_id("mcl_core:stone")
local c_dirt = minetest.get_content_id("mcl_core:dirt")
local c_dirt_with_grass = minetest.get_content_id("mcl_core:dirt_with_grass")
local c_dirt_with_grass_snow = minetest.get_content_id("mcl_core:dirt_with_grass_snow")
local c_sand = minetest.get_content_id("mcl_core:sand")
--local c_sandstone = minetest.get_content_id("mcl_core:sandstone")
local c_void = minetest.get_content_id("mcl_core:void")
local c_lava = minetest.get_content_id("mcl_core:lava_source")
local c_water = minetest.get_content_id("mcl_core:water_source")

local c_nether = nil
if minetest.get_modpath("mcl_nether") then
	c_nether = {
		soul_sand = minetest.get_content_id("mcl_nether:soul_sand"),
		netherrack = minetest.get_content_id("mcl_nether:netherrack"),
		lava = minetest.get_content_id("mcl_nether:nether_lava_source")
	}
end

--local c_end_stone = minetest.get_content_id("mcl_end:end_stone")
local c_realm_barrier = minetest.get_content_id("mcl_core:realm_barrier")
local c_top_snow = minetest.get_content_id("mcl_core:snow")
local c_snow_block = minetest.get_content_id("mcl_core:snowblock")
local c_clay = minetest.get_content_id("mcl_core:clay")
--local c_jungletree = minetest.get_content_id("mcl_core:jungletree")
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

-- Takes an index of a biomemap table (from minetest.get_mapgen_object),
-- minp and maxp (from an on_generated callback) and returns the real world coordinates
-- as X, Z.
-- Inverse function of xz_to_biomemap
--[[local function biomemap_to_xz(index, minp, maxp)
	local xwidth = maxp.x - minp.x + 1
	local zwidth = maxp.z - minp.z + 1
	local x = ((index-1) % xwidth) + minp.x
	local z = ((index-1) / zwidth) + minp.z
	return x, z
end]]

local dragon_spawn_pos = false
local dragon_spawned, portal_generated = false, false

local function spawn_ender_dragon()
	local obj = minetest.add_entity(dragon_spawn_pos, "mobs_mc:enderdragon")
	if not obj then return false end
	local dragon_entity = obj:get_luaentity()
	dragon_entity._initial = true
	dragon_entity._portal_pos = pos
	return obj
end

local function try_to_spawn_ender_dragon()
	if spawn_ender_dragon() then
		dragon_spawned = true
		return
	end
	minetest.after(2, try_to_spawn_ender_dragon)
	minetest.log("warning", "[mcl_mapgen_core] WARNING! Ender dragon doesn't want to spawn at "..minetest.pos_to_string(dragon_spawn_pos))
end

if portal_generated and not dragon_spawned then
	minetest.after(10, try_to_spawn_ender_dragon)
end

function mcl_mapgen_core.generate_end_exit_portal(pos)
	if dragon_spawn_pos then return false end
	dragon_spawn_pos = vector.add(pos, vector.new(3, 11, 3))
	mcl_structures.call_struct(pos, "end_exit_portal", nil, nil, function()
		minetest.after(2, function()
			minetest.emerge_area(vector.subtract(dragon_spawn_pos, {x = 64, y = 12, z = 5}), vector.add(dragon_spawn_pos, {x = 3, y = 3, z = 5}), function(blockpos, action, calls_remaining, param)
				if calls_remaining > 0 then return end
				minetest.after(2, try_to_spawn_ender_dragon)
			end)
		end)
	end)
	portal_generated = true
end

-- Generate mushrooms in caves manually.
-- Minetest's API does not support decorations in caves yet. :-(
local function generate_underground_mushrooms(minp, maxp, seed)
	if not mcl_mushrooms then return end

	local pr_shroom = PseudoRandom(seed-24359)
	-- Generate rare underground mushrooms
	-- TODO: Make them appear in groups, use Perlin noise
	local min, max = mcl_mapgen.overworld.lava_max + 4, 0
	if minp.y > max or maxp.y < min then
		return
	end

	local bpos
	local stone = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_core:stone", "mcl_core:dirt", "mcl_core:mycelium", "mcl_core:podzol", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite", "mcl_core:stone_with_coal", "mcl_core:stone_with_iron", "mcl_core:stone_with_gold"})

	for n = 1, #stone do
		bpos = {x = stone[n].x, y = stone[n].y + 1, z = stone[n].z }

		local l = minetest.get_node_light(bpos, 0.5)
		if bpos.y >= min and bpos.y <= max and l and l <= 12 and pr_shroom:next(1,1000) < 4 then
			if pr_shroom:next(1,2) == 1 then
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
			else
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
			end
		end
	end
end

local nether_wart_chance
if v6 then
	nether_wart_chance = 85
else
	nether_wart_chance = 170
end
-- Generate Nether decorations manually: Eternal fire, mushrooms, nether wart
-- Minetest's API does not support decorations in caves yet. :-(
local function generate_nether_decorations(minp, maxp, seed)
	if c_nether == nil then
		return
	end

	local pr_nether = PseudoRandom(seed+667)

	if minp.y > mcl_mapgen.nether.max or maxp.y < mcl_mapgen.nether.min then
		return
	end

	minetest.log("action", "[mcl_mapgen_core] Nether decorations " .. minetest.pos_to_string(minp) .. " ... " .. minetest.pos_to_string(maxp))

	-- TODO: Generate everything based on Perlin noise instead of PseudoRandom

	local bpos
	local rack = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:netherrack"})
	local magma = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:magma"})
	local ssand = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:soul_sand"})

	-- Helper function to spawn “fake” decoration
	local function special_deco(nodes, spawn_func)
		for n = 1, #nodes do
			bpos = {x = nodes[n].x, y = nodes[n].y + 1, z = nodes[n].z }

			spawn_func(bpos)
		end

	end

	-- Eternal fire on netherrack
	special_deco(rack, function(bpos)
		-- Eternal fire on netherrack
		if pr_nether:next(1,100) <= 3 then
			minetest.set_node(bpos, {name = "mcl_fire:eternal_fire"})
		end
	end)

	-- Eternal fire on magma cubes
	special_deco(magma, function(bpos)
		if pr_nether:next(1,150) == 1 then
			minetest.set_node(bpos, {name = "mcl_fire:eternal_fire"})
		end
	end)

	-- Mushrooms on netherrack
	-- Note: Spawned *after* the fire because of light level checks
	if mcl_mushrooms then
		special_deco(rack, function(bpos)
			local l = minetest.get_node_light(bpos, 0.5)
			if bpos.y > mcl_mapgen.nether.lava_max + 6 and l and l <= 12 and pr_nether:next(1,1000) <= 4 then
				-- TODO: Make mushrooms appear in groups, use Perlin noise
				if pr_nether:next(1,2) == 1 then
					minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
				else
					minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
				end
			end
		end)
	end

	-- Nether wart on soul sand
	-- TODO: Spawn in Nether fortresses
	special_deco(ssand, function(bpos)
		if pr_nether:next(1, nether_wart_chance) == 1 then
			minetest.set_node(bpos, {name = "mcl_nether:nether_wart"})
		end
	end)

end

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
local function set_layers(data, area, content_id, check, min, max, minp, maxp, lvm_used, pr)
	if (maxp.y >= min and minp.y <= max) then
		for y = math.max(min, minp.y), math.min(max, maxp.y) do
			for x = minp.x, maxp.x do
				for z = minp.z, maxp.z do
					local p_pos = area:index(x, y, z)
					if check then
						if type(check) == "function" and check({x=x,y=y,z=z}, data[p_pos], pr) then
							data[p_pos] = content_id
							lvm_used = true
						elseif check == data[p_pos] then
							data[p_pos] = content_id
							lvm_used = true
						end
					else
						data[p_pos] = content_id
						lvm_used = true
					end
				end
			end
		end
	end
	return lvm_used
end

-- Below the bedrock, generate air/void
local function basic_safe(vm_context)
	local vm, data, emin, emax, area, minp, maxp, chunkseed, blockseed = vm_context.vm, vm_context.data, vm_context.emin, vm_context.emax, vm_context.area, vm_context.minp, vm_context.maxp, vm_context.chunkseed, vm_context.blockseed
	vm_context.param2_data = vm_context.param2_data or vm:get_param2_data(vm_context.lvm_param2_buffer)
	local param2_data = vm_context.param2_data

	local lvm_used = false
	local pr = PseudoRandom(blockseed)

	-- The Void below the Nether:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_mapgen.EDGE_MIN	                     , mcl_mapgen.nether.min                     -1, minp, maxp, lvm_used, pr)

	-- [[ THE NETHER:					mcl_mapgen.nether.min			       mcl_mapgen.nether.max							]]

	-- The Air on the Nether roof, https://git.minetest.land/MineClone2/MineClone2/issues/1186
	lvm_used = set_layers(data, area, c_air		 , nil, mcl_mapgen.nether.max			   +1, mcl_mapgen.nether.max + 128                 , minp, maxp, lvm_used, pr)
	-- The Void above the Nether below the End:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_mapgen.nether.max + 128               +1, mcl_mapgen.end_.min                        -1, minp, maxp, lvm_used, pr)

	-- [[ THE END:						mcl_mapgen.end_.min			       mcl_mapgen.end_.max							]]

	-- The Void above the End below the Realm barrier:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_mapgen.end_.max                        +1, mcl_mapgen.realm_barrier_overworld_end_min-1, minp, maxp, lvm_used, pr)
	-- Realm barrier between the Overworld void and the End
	lvm_used = set_layers(data, area, c_realm_barrier, nil, mcl_mapgen.realm_barrier_overworld_end_min  , mcl_mapgen.realm_barrier_overworld_end_max  , minp, maxp, lvm_used, pr)
	-- The Void above Realm barrier below the Overworld:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_mapgen.realm_barrier_overworld_end_max+1, mcl_mapgen.overworld.min                  -1, minp, maxp, lvm_used, pr)


	if not singlenode then
		-- Bedrock
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_mapgen.overworld.bedrock_min, mcl_mapgen.overworld.bedrock_max, minp, maxp, lvm_used, pr)
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_mapgen.nether.bedrock_bottom_min, mcl_mapgen.nether.bedrock_bottom_max, minp, maxp, lvm_used, pr)
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_mapgen.nether.bedrock_top_min, mcl_mapgen.nether.bedrock_top_max, minp, maxp, lvm_used, pr)

		-- Flat Nether
		if mg_name == "flat" then
			lvm_used = set_layers(data, area, c_air, nil, mcl_mapgen.nether.flat_floor, mcl_mapgen.nether.flat_ceiling, minp, maxp, lvm_used, pr)
		end

		-- Big lava seas by replacing air below a certain height
		if mcl_mapgen.lava then
			lvm_used = set_layers(data, area, c_lava, c_air, mcl_mapgen.overworld.min, mcl_mapgen.overworld.lava_max, minp, maxp, lvm_used, pr)
			if c_nether then
				lvm_used = set_layers(data, area, c_nether.lava, c_air, mcl_mapgen.nether.min, mcl_mapgen.nether.lava_max, minp, maxp, lvm_used, pr)
			end
		end

		vm_context.biomemap = vm_context.biomemap or minetest.get_mapgen_object("biomemap")
		local biomemap = vm_context.biomemap

		----- Interactive block fixing section -----
		----- The section to perform basic block overrides of the core mapgen generated world. -----

		-- Snow and sand fixes. This code implements snow consistency
		-- and fixes floating sand and cut plants.
		-- A snowy grass block must be below a top snow or snow block at all times.
		if minp.y <= mcl_mapgen.overworld.max and maxp.y >= mcl_mapgen.overworld.min then
			-- v6 mapgen:
			if v6 then

				--[[ Remove broken double plants caused by v6 weirdness.
				v6 might break the bottom part of double plants because of how it works.
				There are 3 possibilities:
				1) Jungle: Top part is placed on top of a jungle tree or fern (=v6 jungle grass).
					This is because the schematic might be placed even if some nodes of it
					could not be placed because the destination was already occupied.
					TODO: A better fix for this would be if schematics could abort placement
					altogether if ANY of their nodes could not be placed.
				2) Cavegen: Removes the bottom part, the upper part floats
				3) Mudflow: Same as 2) ]]
				local plants = minetest.find_nodes_in_area(minp, maxp, "group:double_plant")
				for n = 1, #plants do
					local node = vm:get_node_at(plants[n])
					local is_top = minetest.get_item_group(node.name, "double_plant") == 2
					if is_top then
						local p_pos = area:index(plants[n].x, plants[n].y-1, plants[n].z)
						if p_pos then
							node = vm:get_node_at({x=plants[n].x, y=plants[n].y-1, z=plants[n].z})
							local is_bottom = minetest.get_item_group(node.name, "double_plant") == 1
							if not is_bottom then
								p_pos = area:index(plants[n].x, plants[n].y, plants[n].z)
								data[p_pos] = c_air
								lvm_used = true
							end
						end
					end
				end


			-- Non-v6 mapgens:
			else
				-- Set param2 (=color) of grass blocks.
				-- Clear snowy grass blocks without snow above to ensure consistency.
				local nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:dirt_with_grass", "mcl_core:dirt_with_grass_snow"})

				-- Flat area at y=0 to read biome 3 times faster than 5.3.0.get_biome_data(pos).biome: 43us vs 125us per iteration:
				local aream = VoxelArea:new({MinEdge={x=minp.x, y=0, z=minp.z}, MaxEdge={x=maxp.x, y=0, z=maxp.z}})
				for n=1, #nodes do
					local n = nodes[n]
					local p_pos = area:index(n.x, n.y, n.z)
					local p_pos_above = area:index(n.x, n.y+1, n.z)
					--local p_pos_below = area:index(n.x, n.y-1, n.z)
					local b_pos = aream:index(n.x, 0, n.z)
					local bn = minetest.get_biome_name(biomemap[b_pos])
					if bn then
						local biome = minetest.registered_biomes[bn]
						if biome and biome._mcl_biome_type then
							param2_data[p_pos] = biome._mcl_palette_index
							vm_context.write_param2 = true
						end
					end
					if data[p_pos] == c_dirt_with_grass_snow and p_pos_above and data[p_pos_above] ~= c_top_snow and data[p_pos_above] ~= c_snow_block then
						data[p_pos] = c_dirt_with_grass
						lvm_used = true
					end
				end

			end

		-- Nether block fixes:
		-- * Replace water with Nether lava.
		-- * Replace stone, sand dirt in v6 so the Nether works in v6.
		elseif minp.y <= mcl_mapgen.nether.max and maxp.y >= mcl_mapgen.nether.min then
		-- elseif emin.y <= mcl_mapgen.nether.max and emax.y >= mcl_mapgen.nether.min then
			if c_nether then
				if v6 then
					-- local nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
					local nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
					for n=1, #nodes do
						local p_pos = area:index(nodes[n].x, nodes[n].y, nodes[n].z)
						if data[p_pos] == c_water then
							data[p_pos] = c_nether.lava
							lvm_used = true
						elseif data[p_pos] == c_stone then
							data[p_pos] = c_netherrack
							lvm_used = true
						elseif data[p_pos] == c_sand or data[p_pos] == c_dirt then
							data[p_pos] = c_soul_sand
							lvm_used = true
						end
					end
				else
					-- local nodes = minetest.find_nodes_in_area(emin, emax, {"group:water"})
					local nodes = minetest.find_nodes_in_area(minp, maxp, {"group:water"})
					for _, n in pairs(nodes) do
						data[area:index(n.x, n.y, n.z)] = c_nether.lava
					end
				end
			end

		-- End block fixes:
		-- * Replace water with end stone or air (depending on height).
		-- * Remove stone, sand, dirt in v6 so our End map generator works in v6.
		-- * Generate spawn platform (End portal destination)
		elseif minp.y <= mcl_mapgen.end_.max and maxp.y >= mcl_mapgen.end_.min then
			local nodes
			if v6 then
				nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
				-- nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
			else
				nodes = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:water_source"})
				-- nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source"})
			end
			if #nodes > 0 then
				lvm_used = true
				for _,n in pairs(nodes) do
					data[area:index(n.x, n.y, n.z)] = c_air
				end
			end

			-- Obsidian spawn platform
			if minp.y <= mcl_mapgen.end_.platform_pos.y and maxp.y >= mcl_mapgen.end_.platform_pos.y and
				minp.x <= mcl_mapgen.end_.platform_pos.x and maxp.x >= mcl_mapgen.end_.platform_pos.z and
				minp.z <= mcl_mapgen.end_.platform_pos.z and maxp.z >= mcl_mapgen.end_.platform_pos.z then

				--local pos1 = {x = math.max(minp.x, mcl_mapgen.end_.platform_pos.x-2), y = math.max(minp.y, mcl_mapgen.end_.platform_pos.y),   z = math.max(minp.z, mcl_mapgen.end_.platform_pos.z-2)}
				--local pos2 = {x = math.min(maxp.x, mcl_mapgen.end_.platform_pos.x+2), y = math.min(maxp.y, mcl_mapgen.end_.platform_pos.y+2), z = math.min(maxp.z, mcl_mapgen.end_.platform_pos.z+2)}

				for x=math.max(minp.x, mcl_mapgen.end_.platform_pos.x-2), math.min(maxp.x, mcl_mapgen.end_.platform_pos.x+2) do
				for z=math.max(minp.z, mcl_mapgen.end_.platform_pos.z-2), math.min(maxp.z, mcl_mapgen.end_.platform_pos.z+2) do
				for y=math.max(minp.y, mcl_mapgen.end_.platform_pos.y), math.min(maxp.y, mcl_mapgen.end_.platform_pos.y+2) do
					local p_pos = area:index(x, y, z)
					if y == mcl_mapgen.end_.platform_pos.y then
						data[p_pos] = c_obsidian
					else
						data[p_pos] = c_air
					end
				end
				end
				end
				lvm_used = true
			end
		end
	end


	if not singlenode then
		-- Generate special decorations
		generate_underground_mushrooms(minp, maxp, blockseed)
		generate_nether_decorations(minp, maxp, blockseed)
	end

	vm_context.write = vm_context.write or lvm_used
end

mcl_mapgen.register_mapgen_block_lvm(basic_safe, 1)

local modpath = minetest.get_modpath(minetest.get_current_modname())
dofile(modpath .. "/clay.lua")
dofile(modpath .. "/tree_decoration.lua")

-- Nether Roof Light:
mcl_mapgen.register_mapgen_block_lvm(function(vm_context)
	local minp = vm_context.minp
	local miny = minp.y
	if miny > mcl_mapgen.nether.max+127 then return end
	local maxp = vm_context.maxp
	local maxy = maxp.y
	if maxy <= mcl_mapgen.nether.max then return end
	local p1 = {x = minp.x, y = math.max(miny, mcl_mapgen.nether.max + 1), z = minp.z}
	local p2 = {x = maxp.x, y = math.min(maxy, mcl_mapgen.nether.max + 127), z = maxp.z}
	vm_context.vm:set_lighting({day=15, night=15}, p1, p2)
	vm_context.write = true
end, 999999999)

-- End Light:
mcl_mapgen.register_mapgen_block_lvm(function(vm_context)
	local minp = vm_context.minp
	local miny = minp.y
	if miny > mcl_mapgen.end_.max then return end
	local maxp = vm_context.maxp
	local maxy = maxp.y
	if maxy <= mcl_mapgen.end_.min then return end
	local p1 = {x = minp.x, y = math.max(miny, mcl_mapgen.end_.min), z = minp.z}
	local p2 = {x = maxp.x, y = math.min(maxy, mcl_mapgen.end_.max), z = maxp.z}
	vm_context.vm:set_lighting({day=15, night=15}, p1, p2)
	vm_context.write = true
end, 9999999999)
