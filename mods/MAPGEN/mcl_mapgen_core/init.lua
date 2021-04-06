mcl_mapgen_core = {}
local registered_generators = {}

local lvm, nodes, param2 = 0, 0, 0
local lvm_buffer = {}

--
-- Aliases for map generator outputs
--

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
minetest.register_alias("mapgen_junglegrass", "mcl_flowers:fern")
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

minetest.register_alias("mapgen_stair_cobble", "mcl_stairs:stair_cobble")
minetest.register_alias("mapgen_sandstonebrick", "mcl_core:sandstonesmooth")
minetest.register_alias("mapgen_stair_sandstonebrick", "mcl_stairs:stair_sandstone")
minetest.register_alias("mapgen_stair_sandstone_block", "mcl_stairs:stair_sandstone")
minetest.register_alias("mapgen_stair_desert_stone", "mcl_stairs:stair_sandstone")

local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"

local WITCH_HUT_HEIGHT = 3 -- Exact Y level to spawn witch huts at. This height refers to the height of the floor

-- End exit portal position
local END_EXIT_PORTAL_POS = vector.new(-3, -27003, -3)

-- Content IDs
local c_bedrock = minetest.get_content_id("mcl_core:bedrock")
local c_obsidian = minetest.get_content_id("mcl_core:obsidian")
local c_stone = minetest.get_content_id("mcl_core:stone")
local c_dirt = minetest.get_content_id("mcl_core:dirt")
local c_dirt_with_grass = minetest.get_content_id("mcl_core:dirt_with_grass")
local c_dirt_with_grass_snow = minetest.get_content_id("mcl_core:dirt_with_grass_snow")
local c_sand = minetest.get_content_id("mcl_core:sand")
local c_sandstone = minetest.get_content_id("mcl_core:sandstone")
local c_void = minetest.get_content_id("mcl_core:void")
local c_lava = minetest.get_content_id("mcl_core:lava_source")
local c_water = minetest.get_content_id("mcl_core:water_source")
local c_soul_sand = minetest.get_content_id("mcl_nether:soul_sand")
local c_netherrack = minetest.get_content_id("mcl_nether:netherrack")
local c_nether_lava = minetest.get_content_id("mcl_nether:nether_lava_source")
local c_end_stone = minetest.get_content_id("mcl_end:end_stone")
local c_realm_barrier = minetest.get_content_id("mcl_core:realm_barrier")
local c_top_snow = minetest.get_content_id("mcl_core:snow")
local c_snow_block = minetest.get_content_id("mcl_core:snowblock")
local c_clay = minetest.get_content_id("mcl_core:clay")
local c_leaves = minetest.get_content_id("mcl_core:leaves")
local c_jungleleaves = minetest.get_content_id("mcl_core:jungleleaves")
local c_jungletree = minetest.get_content_id("mcl_core:jungletree")
local c_cocoa_1 = minetest.get_content_id("mcl_cocoas:cocoa_1")
local c_cocoa_2 = minetest.get_content_id("mcl_cocoas:cocoa_2")
local c_cocoa_3 = minetest.get_content_id("mcl_cocoas:cocoa_3")
local c_vine = minetest.get_content_id("mcl_core:vine")
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
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_vars.mg_overworld_max,
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
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_vars.mg_overworld_max,
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
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_vars.mg_overworld_max,
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
	y_min          = mcl_vars.mg_overworld_min,
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
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(50),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 510*3,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(50),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_coal",
		wherein        = stonelike,
		clust_scarcity = 500*3,
		clust_num_ores = 12,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
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
		y_min          = mcl_vars.mg_overworld_min,
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
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(30),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_gold",
		wherein         = stonelike,
		clust_scarcity = 6560,
		clust_num_ores = 7,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
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
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(12),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 5000,
		clust_num_ores = 2,
		clust_size     = 2,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(12),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_diamond",
		wherein         = stonelike,
		clust_scarcity = 10000,
		clust_num_ores = 8,
		clust_size     = 3,
		y_min          = mcl_vars.mg_overworld_min,
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
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_worlds.layer_to_y(13),
	})
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = "mcl_core:stone_with_redstone",
		wherein         = stonelike,
		clust_scarcity = 800,
		clust_num_ores = 7,
		clust_size     = 4,
		y_min          = mcl_vars.mg_overworld_min,
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

	if mg_name == "v6" then
		-- Generate everywhere in v6, but rarely.

		-- Common spawn
		minetest.register_ore({
			ore_type       = "scatter",
			ore            = "mcl_core:stone_with_emerald",
			wherein        = stonelike,
			clust_scarcity = 14340,
			clust_num_ores = 1,
			clust_size     = 1,
			y_min          = mcl_vars.mg_overworld_min,
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
		y_max = mcl_vars.mg_overworld_max,
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
		y_max = mcl_vars.mg_overworld_max,
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
		spawn_by = { "mcl_core:jungletree", "mcl_flowers:fern" },
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
		y_max = mcl_vars.mg_overworld_max,
	})

	-- Large flowers
	local register_large_flower = function(name, seed, offset)
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
			y_max = mcl_vars.overworld_max,
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
		y_max = mcl_vars.overworld_max,
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
		spawn_by = { "mcl_core:jungletree", "mcl_flowers:fern" },
		num_spawn_by = 1,
		y_min = 1,
		y_max = 40,
		decoration = "mcl_farming:melon",
	})

	-- Tall grass
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
		y_max = mcl_vars.overworld_max,
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
		y_max = mcl_vars.overworld_max,
		decoration = "mcl_flowers:tallgrass",
	})

	-- Seagrass and kelp
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
			y_min = mcl_vars.overworld_min,
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
			y_min = mcl_vars.overworld_min,
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
			y_min = mcl_vars.overworld_min,
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
			y_min = mcl_vars.overworld_min,
			y_max = -15,
			decoration = "mcl_ocean:kelp_"..mat,
			param2 = 32,
			param2_max = 160,
		})

	end

	-- Wet Sponge
	-- TODO: Remove this when we got ocean monuments
	minetest.register_decoration({
		deco_type = "simple",
		decoration = "mcl_sponges:sponge_wet",
		spawn_by = {"group:water"},
		num_spawn_by = 1,
		place_on = {"mcl_core:dirt","mcl_core:sand"},
		sidelen = 16,
		noise_params = {
			offset = 0.00295,
			scale = 0.006,
			spread = {x = 250, y = 250, z = 250},
			seed = 999,
			octaves = 3,
			persist = 0.666
		},
		flags = "force_placement",
		y_min = mcl_vars.mg_lava_overworld_max + 5,
		y_max = -20,
	})

	-- Add a small amount of tall grass everywhere to avoid areas completely empty devoid of tall grass
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_no_snow"},
		sidelen = 8,
		fill_ratio = 0.004,
		y_min = 1,
		y_max = mcl_vars.overworld_max,
		decoration = "mcl_flowers:tallgrass",
	})

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
			y_max = mcl_vars.mg_overworld_max,
			decoration = mushrooms[m],
			spawn_by = { "mcl_core:tree", "mcl_core:sprucetree", "mcl_core:darktree", "mcl_core:birchtree", },
			num_spawn_by = 1,
		})
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
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:deadbush",
	})

	local function register_mgv6_flower(name, seed, offset, y_max)
		if offset == nil then
			offset = 0
		end
		if y_max == nil then
			y_max = mcl_vars.mg_overworld_max
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

	-- Put top snow on snowy grass blocks. The v6 mapgen does not generate the top snow on its own.
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"group:grass_block_snow"},
		sidelen = 16,
		fill_ratio = 11.0, -- complete coverage
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		decoration = "mcl_core:snow",
	})

end

local mg_flags = minetest.settings:get_flags("mg_flags")

-- Inform other mods of dungeon setting for MCL2-style dungeons
mcl_vars.mg_dungeons = mg_flags.dungeons and not superflat

-- Disable builtin dungeons, we provide our own dungeons
mg_flags.dungeons = false

-- Apply mapgen-specific mapgen code
if mg_name == "v6" then
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

-- Helper function for converting a MC probability to MT, with
-- regards to MapBlocks.
-- Some MC generated structures are generated on per-chunk
-- probability.
-- The MC probability is 1/x per Minecraft chunk (16×16).

-- x: The MC probability is 1/x.
-- minp, maxp: MapBlock limits
-- returns: Probability (1/return_value) for a single MT mapblock
local function minecraft_chunk_probability(x, minp, maxp)
	-- 256 is the MC chunk height
	return x * (((maxp.x-minp.x+1)*(maxp.z-minp.z+1)) / 256)
end

-- Takes an index of a biomemap table (from minetest.get_mapgen_object),
-- minp and maxp (from an on_generated callback) and returns the real world coordinates
-- as X, Z.
-- Inverse function of xz_to_biomemap
local biomemap_to_xz = function(index, minp, maxp)
	local xwidth = maxp.x - minp.x + 1
	local zwidth = maxp.z - minp.z + 1
	local x = ((index-1) % xwidth) + minp.x
	local z = ((index-1) / zwidth) + minp.z
	return x, z
end

-- Takes x and z coordinates and minp and maxp of a generated chunk
-- (in on_generated callback) and returns a biomemap index)
-- Inverse function of biomemap_to_xz
local xz_to_biomemap_index = function(x, z, minp, maxp)
	local xwidth = maxp.x - minp.x + 1
	local zwidth = maxp.z - minp.z + 1
	local minix = x % xwidth
	local miniz = z % zwidth

	return (minix + miniz * zwidth) + 1
end

-- Perlin noise objects
local perlin_structures
local perlin_vines, perlin_vines_fine, perlin_vines_upwards, perlin_vines_length, perlin_vines_density
local perlin_clay

local function generate_clay(minp, maxp, blockseed, voxelmanip_data, voxelmanip_area, lvm_used)
	-- TODO: Make clay generation reproducible for same seed.
	if maxp.y < -5 or minp.y > 0 then
		return lvm_used
	end

	local pr = PseudoRandom(blockseed)

	perlin_clay = perlin_clay or minetest.get_perlin({
		offset = 0.5,
		scale = 0.2,
		spread = {x = 5, y = 5, z = 5},
		seed = -316,
		octaves = 1,
		persist = 0.0
	})

	for y=math.max(minp.y, 0), math.min(maxp.y, -8), -1 do
		-- Assume X and Z lengths are equal
		local divlen = 4
		local divs = (maxp.x-minp.x)/divlen+1;
		for divx=0+1,divs-2 do
		for divz=0+1,divs-2 do
			-- Get position and shift it a bit randomly so the clay do not obviously appear in a grid
			local cx = minp.x + math.floor((divx+0.5)*divlen) + pr:next(-1,1)
			local cz = minp.z + math.floor((divz+0.5)*divlen) + pr:next(-1,1)

			local water_pos = voxelmanip_area:index(cx, y+1, cz)
			local waternode = voxelmanip_data[water_pos]
			local surface_pos = voxelmanip_area:index(cx, y, cz)
			local surfacenode = voxelmanip_data[surface_pos]

			local genrnd = pr:next(1, 20)
			if genrnd == 1 and perlin_clay:get_3d({x=cx,y=y,z=cz}) > 0 and waternode == c_water and
					(surfacenode == c_dirt or minetest.get_item_group(minetest.get_name_from_content_id(surfacenode), "sand") == 1) then
				local diamondsize = pr:next(1, 3)
				for x1 = -diamondsize, diamondsize do
				for z1 = -(diamondsize - math.abs(x1)), diamondsize - math.abs(x1) do
					local ccpos = voxelmanip_area:index(cx+x1, y, cz+z1)
					local claycandidate = voxelmanip_data[ccpos]
					if voxelmanip_data[ccpos] == c_dirt or minetest.get_item_group(minetest.get_name_from_content_id(claycandidate), "sand") == 1 then
						voxelmanip_data[ccpos] = c_clay
						lvm_used = true
					end
				end
				end
			end
		end
		end
	end
	return lvm_used
end

local function generate_end_exit_portal(pos)
	local dragon_entity = minetest.add_entity(vector.add(pos, vector.new(3, 11, 3)), "mobs_mc:enderdragon"):get_luaentity()
	dragon_entity._initial = true
	dragon_entity._portal_pos = pos
	mcl_structures.call_struct(pos, "end_exit_portal")
end

-- TODO: Try to use more efficient structure generating code
local function generate_structures(minp, maxp, blockseed, biomemap)
	local chunk_has_desert_well = false
	local chunk_has_desert_temple = false
	local chunk_has_igloo = false
	local struct_min, struct_max = -3, 111 --64

	if maxp.y >= struct_min and minp.y <= struct_max then
		-- Generate structures
		local pr = PcgRandom(blockseed)
		perlin_structures = perlin_structures or minetest.get_perlin(329, 3, 0.6, 100)
		-- Assume X and Z lengths are equal
		local divlen = 5
		for x0 = minp.x, maxp.x, divlen do for z0 = minp.z, maxp.z, divlen do
			-- Determine amount from perlin noise
			local amount = math.floor(perlin_structures:get_2d({x=x0, y=z0}) * 9)
			-- Find random positions based on this random
			local p, ground_y
			for i=0, amount do
				p = {x = pr:next(x0, x0+divlen-1), y = 0, z = pr:next(z0, z0+divlen-1)}
				-- Find ground level
				ground_y = nil
				local nn
				for y = struct_max, struct_min, -1 do
					p.y = y
					local checknode = minetest.get_node(p)
					if checknode then
						nn = checknode.name
						local def = minetest.registered_nodes[nn]
						if def and def.walkable then
							ground_y = y
							break
						end
					end
				end

				if ground_y then
					p.y = ground_y+1
					local nn0 = minetest.get_node(p).name
					-- Check if the node can be replaced
					if minetest.registered_nodes[nn0] and minetest.registered_nodes[nn0].buildable_to then
						-- Desert temples and desert wells
						if nn == "mcl_core:sand" or (nn == "mcl_core:sandstone") then
							if not chunk_has_desert_temple and not chunk_has_desert_well and ground_y > 3 then
								-- Spawn desert temple
								-- TODO: Check surface
								if pr:next(1,12000) == 1 then
									mcl_structures.call_struct(p, "desert_temple", nil, pr)
									chunk_has_desert_temple = true
								end
							end
							if not chunk_has_desert_temple and not chunk_has_desert_well and ground_y > 3 then
								local desert_well_prob = minecraft_chunk_probability(1000, minp, maxp)

								-- Spawn desert well
								if pr:next(1, desert_well_prob) == 1 then
									-- Check surface
									local surface = minetest.find_nodes_in_area({x=p.x,y=p.y-1,z=p.z}, {x=p.x+5, y=p.y-1, z=p.z+5}, "mcl_core:sand")
									if #surface >= 25 then
										mcl_structures.call_struct(p, "desert_well", nil, pr)
										chunk_has_desert_well = true
									end
								end
							end

						-- Igloos
						elseif not chunk_has_igloo and (nn == "mcl_core:snowblock" or nn == "mcl_core:snow" or (minetest.get_item_group(nn, "grass_block_snow") == 1)) then
							if pr:next(1, 4400) == 1 then
								-- Check surface
								local floor = {x=p.x+9, y=p.y-1, z=p.z+9}
								local surface = minetest.find_nodes_in_area({x=p.x,y=p.y-1,z=p.z}, floor, "mcl_core:snowblock")
								local surface2 = minetest.find_nodes_in_area({x=p.x,y=p.y-1,z=p.z}, floor, "mcl_core:dirt_with_grass_snow")
								if #surface + #surface2 >= 63 then
									mcl_structures.call_struct(p, "igloo", nil, pr)
									chunk_has_igloo = true
								end
							end
						end

						-- Fossil
						if nn == "mcl_core:sandstone" or nn == "mcl_core:sand" and not chunk_has_desert_temple and ground_y > 3 then
							local fossil_prob = minecraft_chunk_probability(64, minp, maxp)

							if pr:next(1, fossil_prob) == 1 then
								-- Spawn fossil below desert surface between layers 40 and 49
								local p1 = {x=p.x, y=pr:next(mcl_worlds.layer_to_y(40), mcl_worlds.layer_to_y(49)), z=p.z}
								-- Very rough check of the environment (we expect to have enough stonelike nodes).
								-- Fossils may still appear partially exposed in caves, but this is O.K.
								local p2 = vector.add(p1, 4)
								local nodes = minetest.find_nodes_in_area(p1, p2, {"mcl_core:sandstone", "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite", "mcl_core:stone_with_coal", "mcl_core:dirt", "mcl_core:gravel"})

								if #nodes >= 100 then -- >= 80%
									mcl_structures.call_struct(p1, "fossil", nil, pr)
								end
							end
						end

						-- Witch hut
						if ground_y <= 0 and nn == "mcl_core:dirt" then
						local prob = minecraft_chunk_probability(48, minp, maxp)
						if pr:next(1, prob) == 1 then

							local swampland = minetest.get_biome_id("Swampland")
							local swampland_shore = minetest.get_biome_id("Swampland_shore")

							-- Where do witches live?

							local here_be_witches = false
							if mg_name == "v6" then
								-- v6: In Normal biome
								if biomeinfo.get_v6_biome(p) == "Normal" then
									here_be_witches = true
								end
							else
								-- Other mapgens: In swampland biome
								local bi = xz_to_biomemap_index(p.x, p.z, minp, maxp)
								if biomemap[bi] == swampland or biomemap[bi] == swampland_shore then
									here_be_witches = true
								end
							end

							if here_be_witches then
								local r = tostring(pr:next(0, 3) * 90) -- "0", "90", "180" or 270"
								local p1 = {x=p.x-1, y=WITCH_HUT_HEIGHT+2, z=p.z-1}
								local size
								if r == "0" or r == "180" then
									size = {x=10, y=4, z=8}
								else
									size = {x=8, y=4, z=10}
								end
								local p2 = vector.add(p1, size)

								-- This checks free space at the “body” of the hut and a bit around.
								-- ALL nodes must be free for the placement to succeed.
								local free_nodes = minetest.find_nodes_in_area(p1, p2, {"air", "mcl_core:water_source", "mcl_flowers:waterlily"})
								if #free_nodes >= ((size.x+1)*(size.y+1)*(size.z+1)) then
									local place = {x=p.x, y=WITCH_HUT_HEIGHT-1, z=p.z}

									-- FIXME: For some mysterious reason (black magic?) this
									-- function does sometimes NOT spawn the witch hut. One can only see the
									-- oak wood nodes in the water, but no hut. :-/
									mcl_structures.call_struct(place, "witch_hut", r, pr)

									-- TODO: Spawn witch in or around hut when the mob sucks less.

									local place_tree_if_free = function(pos, prev_result)
										local nn = minetest.get_node(pos).name
										if nn == "mcl_flowers:waterlily" or nn == "mcl_core:water_source" or nn == "mcl_core:water_flowing" or nn == "air" then
											minetest.set_node(pos, {name="mcl_core:tree", param2=0})
											return prev_result
										else
											return false
										end
									end
									local offsets
									if r == "0" then
										offsets = {
											{x=1, y=0, z=1},
											{x=1, y=0, z=5},
											{x=6, y=0, z=1},
											{x=6, y=0, z=5},
										}
									elseif r == "180" then
										offsets = {
											{x=2, y=0, z=1},
											{x=2, y=0, z=5},
											{x=7, y=0, z=1},
											{x=7, y=0, z=5},
										}
									elseif r == "270" then
										offsets = {
											{x=1, y=0, z=1},
											{x=5, y=0, z=1},
											{x=1, y=0, z=6},
											{x=5, y=0, z=6},
										}
									elseif r == "90" then
										offsets = {
											{x=1, y=0, z=2},
											{x=5, y=0, z=2},
											{x=1, y=0, z=7},
											{x=5, y=0, z=7},
										}
									end
									for o=1, #offsets do
										local ok = true
										for y=place.y-1, place.y-64, -1 do
											local tpos = vector.add(place, offsets[o])
											tpos.y = y
											ok = place_tree_if_free(tpos, ok)
											if not ok then
												break
											end
										end
									end
								end
							end
						end
						end

						-- Ice spikes in v6
						-- In other mapgens, ice spikes are generated as decorations.
						if mg_name == "v6" and not chunk_has_igloo and nn == "mcl_core:snowblock" then
							local spike = pr:next(1,58000)
							if spike < 3 then
								-- Check surface
								local floor = {x=p.x+4, y=p.y-1, z=p.z+4}
								local surface = minetest.find_nodes_in_area({x=p.x+1,y=p.y-1,z=p.z+1}, floor, {"mcl_core:snowblock"})
								-- Check for collision with spruce
								local spruce_collisions = minetest.find_nodes_in_area({x=p.x+1,y=p.y+2,z=p.z+1}, {x=p.x+4, y=p.y+6, z=p.z+4}, {"mcl_core:sprucetree", "mcl_core:spruceleaves"})

								if #surface >= 9 and #spruce_collisions == 0 then
									mcl_structures.call_struct(p, "ice_spike_large", nil, pr)
								end
							elseif spike < 100 then
								-- Check surface
								local floor = {x=p.x+6, y=p.y-1, z=p.z+6}
								local surface = minetest.find_nodes_in_area({x=p.x+1,y=p.y-1,z=p.z+1}, floor, {"mcl_core:snowblock", "mcl_core:dirt_with_grass_snow"})

								-- Check for collision with spruce
								local spruce_collisions = minetest.find_nodes_in_area({x=p.x+1,y=p.y+1,z=p.z+1}, {x=p.x+6, y=p.y+6, z=p.z+6}, {"mcl_core:sprucetree", "mcl_core:spruceleaves"})

								if #surface >= 25 and #spruce_collisions == 0 then
									mcl_structures.call_struct(p, "ice_spike_small", nil, pr)
								end
							end
						end
					end
				end

			end
		end end
	-- End exit portal
	elseif	minp.y <= END_EXIT_PORTAL_POS.y and maxp.y >= END_EXIT_PORTAL_POS.y and
		minp.x <= END_EXIT_PORTAL_POS.x and maxp.x >= END_EXIT_PORTAL_POS.x and
		minp.z <= END_EXIT_PORTAL_POS.z and maxp.z >= END_EXIT_PORTAL_POS.z then
		for y=maxp.y, minp.y, -1 do
			local p = {x=END_EXIT_PORTAL_POS.x, y=y, z=END_EXIT_PORTAL_POS.z}
			if minetest.get_node(p).name == "mcl_end:end_stone" then
				generate_end_exit_portal(p)
				return
			end
		end
		generate_end_exit_portal(END_EXIT_PORTAL_POS)
	end
end

-- Buffers for LuaVoxelManip
-- local lvm_buffer = {}
-- local lvm_buffer_param2 = {}

-- Generate tree decorations in the bounding box. This adds:
-- * Cocoa at jungle trees
-- * Jungle tree vines
-- * Oak vines in swamplands
local function generate_tree_decorations(minp, maxp, seed, data, param2_data, area, biomemap, lvm_used, pr)
	if maxp.y < 0 then
		return lvm_used
	end

	local oaktree, oakleaves, jungletree, jungleleaves = {}, {}, {}, {}
	local swampland = minetest.get_biome_id("Swampland")
	local swampland_shore = minetest.get_biome_id("Swampland_shore")
	local jungle = minetest.get_biome_id("Jungle")
	local jungle_shore = minetest.get_biome_id("Jungle_shore")
	local jungle_m = minetest.get_biome_id("JungleM")
	local jungle_m_shore = minetest.get_biome_id("JungleM_shore")
	local jungle_edge = minetest.get_biome_id("JungleEdge")
	local jungle_edge_shore = minetest.get_biome_id("JungleEdge_shore")
	local jungle_edge_m = minetest.get_biome_id("JungleEdgeM")
	local jungle_edge_m_shore = minetest.get_biome_id("JungleEdgeM_shore")

	-- Modifier for Jungle M biome: More vines and cocoas
	local dense_vegetation = false

	if biomemap then
		-- Biome map available: Check if the required biome (jungle or swampland)
		-- is in this mapchunk. We are only interested in trees in the correct biome.
		-- The nodes are added if the correct biome is *anywhere* in the mapchunk.
		-- TODO: Strictly generate vines in the correct biomes only.
		local swamp_biome_found, jungle_biome_found = false, false
		for b=1, #biomemap do
			local id = biomemap[b]

			if not swamp_biome_found and (id == swampland or id == swampland_shore) then
				oaktree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:tree"})
				oakleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:leaves"})
				swamp_biome_found = true
			end
			if not jungle_biome_found and (id == jungle or id == jungle_shore or id == jungle_m or id == jungle_m_shore or id == jungle_edge or id == jungle_edge_shore or id == jungle_edge_m or id == jungle_edge_m_shore) then
				jungletree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungletree"})
				jungleleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungleleaves"})
				jungle_biome_found = true
			end
			if not dense_vegetation and (id == jungle_m or id == jungle_m_shore) then
				dense_vegetation = true
			end
			if swamp_biome_found and jungle_biome_found and dense_vegetation then
				break
			end
		end
	else
		-- If there is no biome map, we just count all jungle things we can find.
		-- Oak vines will not be generated.
		jungletree = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungletree"})
		jungleleaves = minetest.find_nodes_in_area(minp, maxp, {"mcl_core:jungleleaves"})
	end

	local pos, treepos, dir

	local cocoachance = 40
	if dense_vegetation then
		cocoachance = 32
	end

	-- Pass 1: Generate cocoas at jungle trees
	for n = 1, #jungletree do

		pos = table.copy(jungletree[n])
		treepos = table.copy(pos)

		if minetest.find_node_near(pos, 1, {"mcl_core:jungleleaves"}) then

			dir = pr:next(1, cocoachance)

			if dir == 1 then
				pos.z = pos.z + 1
			elseif dir == 2 then
				pos.z = pos.z - 1
			elseif dir == 3 then
				pos.x = pos.x + 1
			elseif dir == 4 then
				pos.x = pos.x -1
			end

			local p_pos = area:index(pos.x, pos.y, pos.z)
			local l = minetest.get_node_light(pos)

			if dir < 5
			and data[p_pos] == c_air
			and l ~= nil and l > 12 then
				local c = pr:next(1, 3)
				if c == 1 then
					data[p_pos] = c_cocoa_1
				elseif c == 2 then
					data[p_pos] = c_cocoa_2
				else
					data[p_pos] = c_cocoa_3
				end
				param2_data[p_pos] = minetest.dir_to_facedir(vector.subtract(treepos, pos))
				lvm_used = true
			end

		end
	end

	-- Pass 2: Generate vines at jungle wood, jungle leaves in jungle and oak wood, oak leaves in swampland
	perlin_vines = perlin_vines or minetest.get_perlin(555, 4, 0.6, 500)
	perlin_vines_fine = perlin_vines_fine or minetest.get_perlin(43000, 3, 0.6, 1)
	perlin_vines_length = perlin_vines_length or minetest.get_perlin(435, 4, 0.6, 75)
	perlin_vines_upwards = perlin_vines_upwards or minetest.get_perlin(436, 3, 0.6, 10)
	perlin_vines_density = perlin_vines_density or minetest.get_perlin(436, 3, 0.6, 500)

	-- Extra long vines in Jungle M
	local maxvinelength = 7
	if dense_vegetation then
		maxvinelength = 14
	end
	local treething
	for i=1, 4 do
		if i==1 then
			treething = jungletree
		elseif i == 2 then
			treething = jungleleaves
		elseif i == 3 then
			treething = oaktree
		elseif i == 4 then
			treething = oakleaves
		end

		for n = 1, #treething do
			pos = treething[n]

			treepos = table.copy(pos)

			local dirs = {
				{x=1,y=0,z=0},
				{x=-1,y=0,z=0},
				{x=0,y=0,z=1},
				{x=0,y=0,z=-1},
			}

			for d = 1, #dirs do
			local pos = vector.add(pos, dirs[d])
			local p_pos = area:index(pos.x, pos.y, pos.z)

			local vine_threshold = math.max(0.33333, perlin_vines_density:get_2d(pos))
			if dense_vegetation then
				vine_threshold = vine_threshold * (2/3)
			end

			if perlin_vines:get_2d(pos) > -1.0 and perlin_vines_fine:get_3d(pos) > vine_threshold and data[p_pos] == c_air then

				local rdir = {}
				rdir.x = -dirs[d].x
				rdir.y = dirs[d].y
				rdir.z = -dirs[d].z
				local param2 = minetest.dir_to_wallmounted(rdir)

				-- Determine growth direction
				local grow_upwards = false
				-- Only possible on the wood, not on the leaves
				if i == 1 then
					grow_upwards = perlin_vines_upwards:get_3d(pos) > 0.8
				end
				if grow_upwards then
					-- Grow vines up 1-4 nodes, even through jungleleaves.
					-- This may give climbing access all the way to the top of the tree :-)
					-- But this will be fairly rare.
					local length = math.ceil(math.abs(perlin_vines_length:get_3d(pos)) * 4)
					for l=0, length-1 do
						local t_pos = area:index(treepos.x, treepos.y, treepos.z)

						if (data[p_pos] == c_air or data[p_pos] == c_jungleleaves or data[p_pos] == c_leaves) and mcl_core.supports_vines(minetest.get_name_from_content_id(data[t_pos])) then
							data[p_pos] = c_vine
							param2_data[p_pos] = param2
							lvm_used = true

						else
							break
						end
						pos.y = pos.y + 1
						p_pos = area:index(pos.x, pos.y, pos.z)
						treepos.y = treepos.y + 1
					end
				else
					-- Grow vines down, length between 1 and maxvinelength
					local length = math.ceil(math.abs(perlin_vines_length:get_3d(pos)) * maxvinelength)
					for l=0, length-1 do
						if data[p_pos] == c_air then
							data[p_pos] = c_vine
							param2_data[p_pos] = param2
							lvm_used = true

						else
							break
						end
						pos.y = pos.y - 1
						p_pos = area:index(pos.x, pos.y, pos.z)
					end
				end
			end
			end

		end
	end
	return lvm_used
end

-- Generate mushrooms in caves manually.
-- Minetest's API does not support decorations in caves yet. :-(
local generate_underground_mushrooms = function(minp, maxp, seed)
	local pr_shroom = PseudoRandom(seed-24359)
	-- Generate rare underground mushrooms
	-- TODO: Make them appear in groups, use Perlin noise
	local min, max = mcl_vars.mg_lava_overworld_max + 4, 0
	if minp.y > max or maxp.y < min then
		return
	end

	local bpos
	local stone = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_core:stone", "mcl_core:dirt", "mcl_core:mycelium", "mcl_core:podzol", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite", "mcl_core:stone_with_coal", "mcl_core:stone_with_iron", "mcl_core:stone_with_gold"})

	for n = 1, #stone do
		bpos = {x = stone[n].x, y = stone[n].y + 1, z = stone[n].z }

		local l = minetest.get_node_light(bpos, 0.5)
		if bpos.y >= min and bpos.y <= max and l ~= nil and l <= 12 and pr_shroom:next(1,1000) < 4 then
			if pr_shroom:next(1,2) == 1 then
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
			else
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
			end
		end
	end
end

local nether_wart_chance
if mg_name == "v6" then
	nether_wart_chance = 85
else
	nether_wart_chance = 170
end
-- Generate Nether decorations manually: Eternal fire, mushrooms, nether wart
-- Minetest's API does not support decorations in caves yet. :-(
local generate_nether_decorations = function(minp, maxp, seed)
	local pr_nether = PseudoRandom(seed+667)

	if minp.y > mcl_vars.mg_nether_max or maxp.y < mcl_vars.mg_nether_min then
		return
	end

	minetest.log("action", "[mcl_mapgen_core] Nether decorations " .. minetest.pos_to_string(minp) .. " ... " .. minetest.pos_to_string(maxp))

	-- TODO: Generate everything based on Perlin noise instead of PseudoRandom

	local bpos
	local rack = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:netherrack"})
	local magma = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:magma"})
	local ssand = minetest.find_nodes_in_area_under_air(minp, maxp, {"mcl_nether:soul_sand"})

	-- Helper function to spawn “fake” decoration
	local special_deco = function(nodes, spawn_func)
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
	special_deco(rack, function(bpos)
		local l = minetest.get_node_light(bpos, 0.5)
		if bpos.y > mcl_vars.mg_lava_nether_max + 6 and l ~= nil and l <= 12 and pr_nether:next(1,1000) <= 4 then
			-- TODO: Make mushrooms appear in groups, use Perlin noise
			if pr_nether:next(1,2) == 1 then
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_brown"})
			else
				minetest.set_node(bpos, {name = "mcl_mushrooms:mushroom_red"})
			end
		end
	end)

	-- Nether wart on soul sand
	-- TODO: Spawn in Nether fortresses
	special_deco(ssand, function(bpos)
		if pr_nether:next(1, nether_wart_chance) == 1 then
			minetest.set_node(bpos, {name = "mcl_nether:nether_wart"})
		end
	end)

end

minetest.register_on_generated(function(minp, maxp, blockseed)
	minetest.log("action", "[mcl_mapgen_core] Generating chunk " .. minetest.pos_to_string(minp) .. " ... " .. minetest.pos_to_string(maxp))
	local p1, p2 = {x=minp.x, y=minp.y, z=minp.z}, {x=maxp.x, y=maxp.y, z=maxp.z}
	if lvm > 0 then
		local lvm_used, shadow = false, false
		local lb2 = {} -- param2
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local e1, e2 = {x=emin.x, y=emin.y, z=emin.z}, {x=emax.x, y=emax.y, z=emax.z}
		local data2
		local data = vm:get_data(lvm_buffer)
		if param2 > 0 then
			data2 = vm:get_param2_data(lb2)
		end
		local area = VoxelArea:new({MinEdge=e1, MaxEdge=e2})

		for _, rec in pairs(registered_generators) do
			if rec.vf then
				local lvm_used0, shadow0 = rec.vf(vm, data, data2, e1, e2, area, p1, p2, blockseed)
				if lvm_used0 then
					lvm_used = true
				end
				if shadow0 then
					shadow = true
				end
			end
		end

		if lvm_used then
			-- Write stuff
			vm:set_data(data)
			if param2 > 0 then
				vm:set_param2_data(data2)
			end
			vm:calc_lighting(p1, p2, shadow)
			vm:write_to_map()
			vm:update_liquids()
		end
	end

	if nodes > 0 then
		for _, rec in pairs(registered_generators) do
			if rec.nf then
				rec.nf(p1, p2, blockseed)
			end
		end
	end

	mcl_vars.add_chunk(minp)
end)

minetest.register_on_generated=function(node_function)
	mcl_mapgen_core.register_generator("mod_"..tostring(#registered_generators+1), nil, node_function)
end

function mcl_mapgen_core.register_generator(id, lvm_function, node_function, priority, needs_param2)
	if not id then return end

	local priority = priority or 5000

	if lvm_function then lvm = lvm + 1 end
	if lvm_function then nodes = nodes + 1 end
	if needs_param2 then param2 = param2 + 1 end

	local new_record = {
		i = priority,
		vf = lvm_function,
		nf = node_function,
		needs_param2 = needs_param2,
	}

	registered_generators[id] = new_record
	table.sort(
		registered_generators,
		function(a, b)
			return (a.i < b.i) or ((a.i == b.i) and (a.vf ~= nil) and (b.vf == nil))
		end)
end

function mcl_mapgen_core.unregister_generator(id)
	if not registered_generators[id] then return end
	local rec = registered_generators[id]
	registered_generators[id] = nil
	if rec.vf then lvm = lvm - 1 end
	if rev.nf then nodes = nodes - 1 end
	if rec.needs_param2 then param2 = param2 - 1 end
	if rec.needs_level0 then level0 = level0 - 1 end
end

-- Generate basic layer-based nodes: void, bedrock, realm barrier, lava seas, etc.
-- Also perform some basic node replacements.

local bedrock_check
if mcl_vars.mg_bedrock_is_rough then
	bedrock_check = function(pos, _, pr)
		local y = pos.y
		-- Bedrock layers with increasing levels of roughness, until a perfecly flat bedrock later at the bottom layer
		-- This code assumes a bedrock height of 5 layers.

		local diff = mcl_vars.mg_bedrock_overworld_max - y -- Overworld bedrock
		local ndiff1 = mcl_vars.mg_bedrock_nether_bottom_max - y -- Nether bedrock, bottom
		local ndiff2 = mcl_vars.mg_bedrock_nether_top_max - y -- Nether bedrock, ceiling

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
local function basic(vm, data, data2, emin, emax, area, minp, maxp, blockseed)
	local biomemap, ymin, ymax
	local lvm_used = false
	local pr = PseudoRandom(blockseed)

	-- The Void below the Nether:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mapgen_edge_min                     , mcl_vars.mg_nether_min                     -1, minp, maxp, lvm_used, pr)

	-- [[ THE NETHER:					mcl_vars.mg_nether_min			       mcl_vars.mg_nether_max							]]

	-- The Air on the Nether roof, https://git.minetest.land/MineClone2/MineClone2/issues/1186
	lvm_used = set_layers(data, area, c_air		 , nil, mcl_vars.mg_nether_max			   +1, mcl_vars.mg_nether_max + 128                 , minp, maxp, lvm_used, pr)
	-- The Void above the Nether below the End:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_nether_max + 128               +1, mcl_vars.mg_end_min                        -1, minp, maxp, lvm_used, pr)

	-- [[ THE END:						mcl_vars.mg_end_min			       mcl_vars.mg_end_max							]]

	-- The Void above the End below the Realm barrier:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_end_max                        +1, mcl_vars.mg_realm_barrier_overworld_end_min-1, minp, maxp, lvm_used, pr)
	-- Realm barrier between the Overworld void and the End
	lvm_used = set_layers(data, area, c_realm_barrier, nil, mcl_vars.mg_realm_barrier_overworld_end_min  , mcl_vars.mg_realm_barrier_overworld_end_max  , minp, maxp, lvm_used, pr)
	-- The Void above Realm barrier below the Overworld:
	lvm_used = set_layers(data, area, c_void         , nil, mcl_vars.mg_realm_barrier_overworld_end_max+1, mcl_vars.mg_overworld_min                  -1, minp, maxp, lvm_used, pr)


	if mg_name ~= "singlenode" then
		-- Bedrock
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_overworld_min, mcl_vars.mg_bedrock_overworld_max, minp, maxp, lvm_used, pr)
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_nether_bottom_min, mcl_vars.mg_bedrock_nether_bottom_max, minp, maxp, lvm_used, pr)
		lvm_used = set_layers(data, area, c_bedrock, bedrock_check, mcl_vars.mg_bedrock_nether_top_min, mcl_vars.mg_bedrock_nether_top_max, minp, maxp, lvm_used, pr)

		-- Flat Nether
		if mg_name == "flat" then
			lvm_used = set_layers(data, area, c_air, nil, mcl_vars.mg_flat_nether_floor, mcl_vars.mg_flat_nether_ceiling, minp, maxp, lvm_used, pr)
		end

		-- Big lava seas by replacing air below a certain height
		if mcl_vars.mg_lava then
			lvm_used = set_layers(data, area, c_lava, c_air, mcl_vars.mg_overworld_min, mcl_vars.mg_lava_overworld_max, minp, maxp, lvm_used, pr)
			lvm_used = set_layers(data, area, c_nether_lava, c_air, mcl_vars.mg_nether_min, mcl_vars.mg_lava_nether_max, minp, maxp, lvm_used, pr)
		end

		-- Clay, vines, cocoas
		lvm_used = generate_clay(minp, maxp, blockseed, data, area, lvm_used)

		biomemap = minetest.get_mapgen_object("biomemap")
		lvm_used = generate_tree_decorations(minp, maxp, blockseed, data, data2, area, biomemap, lvm_used, pr)

		----- Interactive block fixing section -----
		----- The section to perform basic block overrides of the core mapgen generated world. -----

		-- Snow and sand fixes. This code implements snow consistency
		-- and fixes floating sand and cut plants.
		-- A snowy grass block must be below a top snow or snow block at all times.
		if minp.y <= mcl_vars.mg_overworld_max and maxp.y >= mcl_vars.mg_overworld_min then
			-- v6 mapgen:
			if mg_name == "v6" then

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
					local p_pos_below = area:index(n.x, n.y-1, n.z)
					local b_pos = aream:index(n.x, 0, n.z)
					local bn = minetest.get_biome_name(biomemap[b_pos])
					if bn then
						local biome = minetest.registered_biomes[bn]
						if biome and biome._mcl_biome_type then
							data2[p_pos] = biome._mcl_palette_index
							lvm_used = true
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
		elseif emin.y <= mcl_vars.mg_nether_max and emax.y >= mcl_vars.mg_nether_min then
			if mg_name == "v6" then
				local nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
				for n=1, #nodes do
					local p_pos = area:index(nodes[n].x, nodes[n].y, nodes[n].z)
					if data[p_pos] == c_water then
						data[p_pos] = c_nether_lava
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
				local nodes = minetest.find_nodes_in_area(emin, emax, {"group:water"})
				for _, n in pairs(nodes) do
					data[area:index(n.x, n.y, n.z)] = c_nether_lava
				end
			end

		-- End block fixes:
		-- * Replace water with end stone or air (depending on height).
		-- * Remove stone, sand, dirt in v6 so our End map generator works in v6.
		-- * Generate spawn platform (End portal destination)
		elseif minp.y <= mcl_vars.mg_end_max and maxp.y >= mcl_vars.mg_end_min then
			local nodes, n
			if mg_name == "v6" then
				nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source", "mcl_core:stone", "mcl_core:sand", "mcl_core:dirt"})
			else
				nodes = minetest.find_nodes_in_area(emin, emax, {"mcl_core:water_source"})
			end
			if #nodes > 0 then
				lvm_used = true
				for _, n in pairs(nodes) do
					data[area:index(n.x, n.y, n.z)] = c_air
				end
			end

			-- Obsidian spawn platform
			if minp.y <= mcl_vars.mg_end_platform_pos.y and maxp.y >= mcl_vars.mg_end_platform_pos.y and
				minp.x <= mcl_vars.mg_end_platform_pos.x and maxp.x >= mcl_vars.mg_end_platform_pos.z and
				minp.z <= mcl_vars.mg_end_platform_pos.z and maxp.z >= mcl_vars.mg_end_platform_pos.z then

				local pos1 = {x = math.max(minp.x, mcl_vars.mg_end_platform_pos.x-2), y = math.max(minp.y, mcl_vars.mg_end_platform_pos.y),   z = math.max(minp.z, mcl_vars.mg_end_platform_pos.z-2)}
				local pos2 = {x = math.min(maxp.x, mcl_vars.mg_end_platform_pos.x+2), y = math.min(maxp.y, mcl_vars.mg_end_platform_pos.y+2), z = math.min(maxp.z, mcl_vars.mg_end_platform_pos.z+2)}

				for x=math.max(minp.x, mcl_vars.mg_end_platform_pos.x-2), math.min(maxp.x, mcl_vars.mg_end_platform_pos.x+2) do
				for z=math.max(minp.z, mcl_vars.mg_end_platform_pos.z-2), math.min(maxp.z, mcl_vars.mg_end_platform_pos.z+2) do
				for y=math.max(minp.y, mcl_vars.mg_end_platform_pos.y), math.min(maxp.y, mcl_vars.mg_end_platform_pos.y+2) do
					local p_pos = area:index(x, y, z)
					if y == mcl_vars.mg_end_platform_pos.y then
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

	-- Final hackery: Set sun light level in the End.
	-- -26912 is at a mapchunk border.
	local shadow = true
	if minp.y >= -26912 and maxp.y <= mcl_vars.mg_end_max then
		vm:set_lighting({day=15, night=15})
		lvm_used = true
	end
	if minp.y >= mcl_vars.mg_end_min and maxp.y <= -26911 then
		shadow = false
		lvm_used = true
	end

	if mg_name ~= "singlenode" then
		-- Generate special decorations
		generate_underground_mushrooms(minp, maxp, blockseed)
		generate_nether_decorations(minp, maxp, blockseed)
		generate_structures(minp, maxp, blockseed, biomemap)
	end

	return lvm_used, shadow
end

mcl_mapgen_core.register_generator("main", basic, nil, 1, true)

