mobs_mc.create_monster_egg_nodes = true

-- Tables for attracting, feeding and breeding mobs
mobs_mc.follow = {
	sheep = { mobs_mc.items.wheat },
	cow = { mobs_mc.items.wheat },
	chicken = { "farming:seed_wheat", "farming:seed_cotton" }, -- seeds in general
	parrot = { "farming:seed_wheat", "farming:seed_cotton" }, -- seeds in general
	horse = { mobs_mc.items.apple, mobs_mc.items.sugar, mobs_mc.items.wheat, mobs_mc.items.hay_bale, mobs_mc.items.golden_apple, mobs_mc.items.golden_carrot },
	llama = { mobs_mc.items.wheat, mobs_mc.items.hay_bale, },
	pig = { mobs_mc.items.potato, mobs_mc.items.carrot, mobs_mc.items.carrot_on_a_stick,
		mobs_mc.items.apple, -- Minetest Game extra
	},
	rabbit = { mobs_mc.items.dandelion, mobs_mc.items.carrot, mobs_mc.items.golden_carrot, "farming_plus:carrot_item", },
	ocelot = { mobs_mc.items.fish_raw, mobs_mc.items.salmon_raw, mobs_mc.items.clownfish_raw, mobs_mc.items.pufferfish_raw,
		mobs_mc.items.chicken_raw, -- Minetest Game extra
	},
	wolf = { mobs_mc.items.bone },
	dog = { mobs_mc.items.rabbit_raw, mobs_mc.items.rabbit_cooked, mobs_mc.items.mutton_raw, mobs_mc.items.mutton_cooked, mobs_mc.items.beef_raw, mobs_mc.items.beef_cooked, mobs_mc.items.chicken_raw, mobs_mc.items.chicken_cooked, mobs_mc.items.rotten_flesh,
	-- Mobs Redo items
	"mobs:meat", "mobs:meat_raw" },
}

-- Contents for replace_what
mobs_mc.replace = {
	-- Rabbits reduce carrot growth stage by 1
	rabbit = {
		-- Farming Redo carrots
		{"farming:carrot_8", "farming:carrot_7", 0},
		{"farming:carrot_7", "farming:carrot_6", 0},
		{"farming:carrot_6", "farming:carrot_5", 0},
		{"farming:carrot_5", "farming:carrot_4", 0},
		{"farming:carrot_4", "farming:carrot_3", 0},
		{"farming:carrot_3", "farming:carrot_2", 0},
		{"farming:carrot_2", "farming:carrot_1", 0},
		{"farming:carrot_1", "air", 0},
		-- Farming Plus carrots
		{"farming_plus:carrot", "farming_plus:carrot_7", 0},
		{"farming_plus:carrot_6", "farming_plus:carrot_5", 0},
		{"farming_plus:carrot_5", "farming_plus:carrot_4", 0},
		{"farming_plus:carrot_4", "farming_plus:carrot_3", 0},
		{"farming_plus:carrot_3", "farming_plus:carrot_2", 0},
		{"farming_plus:carrot_2", "farming_plus:carrot_1", 0},
		{"farming_plus:carrot_1", "air", 0},
	},
	-- Sheep eat grass
	sheep = {
		-- Grass Block
		{ "default:dirt_with_grass", "default:dirt", -1 },
		-- “Tall Grass”
		{ "default:grass_5", "air", 0 },
		{ "default:grass_4", "air", 0 },
		{ "default:grass_3", "air", 0 },
		{ "default:grass_2", "air", 0 },
		{ "default:grass_1", "air", 0 },
	},
	-- Silverfish populate stone, etc. with monster eggs
	silverfish = {
		{"default:stone", "mobs_mc:monster_egg_stone", -1},
		{"default:cobble", "mobs_mc:monster_egg_cobble", -1},
		{"default:mossycobble", "mobs_mc:monster_egg_mossycobble", -1},
		{"default:stonebrick", "mobs_mc:monster_egg_stonebrick", -1},
		{"default:stone_block", "mobs_mc:monster_egg_stone_block", -1},
	},
}

-- List of nodes which endermen can take
mobs_mc.enderman_takable = {
	-- Generic handling, useful for entensions
	"group:enderman_takable",

	-- Generic nodes
	"group:sand",
	"group:flower",

	-- Minetest Game
	"default:dirt",
	"default:dirt_with_grass",
	"default:dirt_with_dry_grass",
	"default:dirt_with_snow",
	"default:dirt_with_rainforest_litter",
	"default:dirt_with_grass_footsteps",
-- FIXME: For some reason, Minetest has a Lua error when an enderman tries to place a Minetest Game cactus.
-- Maybe this is because default:cactus has rotate_and_place?
--	"default:cactus", -- TODO: Re-enable cactus when it works again
	"default:gravel",
	"default:clay",
	"flowers:mushroom_red",
	"flowers:mushroom_brown",
	"tnt:tnt",

	-- Nether mod
	"nether:rack",
}

--[[ Table of nodes to replace when an enderman takes it.
If the enderman takes an indexed node, it the enderman will get the item in the value.
Table indexes: Original node, taken by enderman.
Table values: The item which the enderman *actually* gets
Example:
	mobs_mc.enderman_node_replace = {
		["default:dirt_with_dry_grass"] = "default_dirt_with_grass",
	}
-- This means, if the enderman takes a dirt with dry grass, he will get a dirt with grass
-- on his hand instead.
]]
mobs_mc.enderman_replace_on_take = {} -- no replacements by default

-- A table which can be used to override block textures of blocks carried by endermen.
-- Only works for cube-shaped nodes and nodeboxes.
-- Key: itemstrings of the blocks to replace
-- Value: A table with the texture overrides (6 textures)
mobs_mc.enderman_block_texture_overrides = {
}

-- List of nodes on which mobs can spawn
mobs_mc.spawn = {
	solid = { "group:cracky", "group:crumbly", "group:shovely", "group:pickaxey" }, -- spawn on "solid" nodes (this is mostly just guessing)

	grassland = { mobs_mc.items.grass_block, "ethereal:prairie_dirt" },
	savanna = { "default:dirt_with_dry_grass" },
	grassland_savanna = { mobs_mc.items.grass_block, "default:dirt_with_dry_grass" },
	desert = { "default:desert_sand", "group:sand" },
	jungle = { "default:dirt_with_rainforest_litter", "default:jungleleaves", "default:junglewood", "mcl_core:jungleleaves", "mcl_core:junglewood" },
	snow = { "default:snow", "default:snowblock", "default:dirt_with_snow" },
	end_city = { "default:sandstonebrick", "mcl_end:purpur_block", "mcl_end:end_stone" },
	wolf = { mobs_mc.items.grass_block, "default:dirt_with_rainforest_litter", "default:dirt", "default:dirt_with_snow", "default:snow", "default:snowblock" },
	village = { "mg_villages:road" },

	-- These probably don't need overrides
	mushroom_island = { mobs_mc.items.mycelium, "mcl_core:mycelium" },
	nether_fortress = { mobs_mc.items.nether_brick_block, "mcl_nether:nether_brick", },
	nether = { mobs_mc.items.netherrack, "mcl_nether:netherrack", },
	nether_portal = { mobs_mc.items.nether_portal, "mcl_portals:portal" },
	water = { mobs_mc.items.water_source, "mcl_core:water_source", "default:water_source" },
}

-- This table contains important spawn height references for the mob spawn height.
-- Please base your mob spawn height on these numbers to keep things clean.
mobs_mc.spawn_height = {
	water = tonumber(minetest.settings:get("water_level")) or 0, -- Water level in the Overworld

	-- Overworld boundaries (inclusive) --I adjusted this to be more reasonable
	overworld_min = -64,-- -2999,
	overworld_max = 31000,

	-- Nether boundaries (inclusive)
	nether_min = -29067,-- -3369,
	nether_max = -28939,-- -3000,

	-- End boundaries (inclusive)
	end_min = -6200,
	end_max = -6000,
}

mobs_mc.misc = {
	shears_wear = 276, -- Wear to add per shears usage (238 uses)
	totem_fail_nodes = {} -- List of nodes in which the totem of undying fails
}

-- Item name overrides from mobs_mc_gameconfig (if present)
if minetest.get_modpath("mobs_mc_gameconfig") and mobs_mc.override then
	local tables = {"items", "follow", "replace", "spawn", "spawn_height", "misc"}
	for t=1, #tables do
		local tbl = tables[t]
		if mobs_mc.override[tbl] then
			for k, v in pairs(mobs_mc.override[tbl]) do
				mobs_mc[tbl][k] = v
			end
		end
	end

	if mobs_mc.override.enderman_takable then
		mobs_mc.enderman_takable = mobs_mc.override.enderman_takable
	end
	if mobs_mc.override.enderman_replace_on_take then
		mobs_mc.enderman_replace_on_take = mobs_mc.override.enderman_replace_on_take
	end
	if mobs_mc.enderman_block_texture_overrides then
		mobs_mc.enderman_block_texture_overrides = mobs_mc.override.enderman_block_texture_overrides
	end
end



---
---
--- actual gameconfig now
---
---

mobs_mc = {}

mobs_mc.override = {}

mobs_mc.override.items = {
	blaze_rod = "mcl_mobitems:blaze_rod",
	blaze_powder = "mcl_mobitems:blaze_powder",
	chicken_raw = "mcl_mobitems:chicken",
	chicken_cooked = "mcl_mobitems:cooked_chicken",
	feather = "mcl_mobitems:feather",
	beef_raw = "mcl_mobitems:beef",
	beef_cooked = "mcl_mobitems:cooked_beef",
	bowl = "mcl_core:bowl",
	mushroom_stew = "mcl_mushrooms:mushroom_stew",
	milk = "mcl_mobitems:milk_bucket",
	dragon_egg = "mcl_end:dragon_egg",
	egg = "mcl_throwing:egg",
	ender_eye  = "mcl_mobitems:ender_eye",
	ghast_tear = "mcl_mobitems:ghast_tear",
	saddle = "mcl_mobitems:saddle",
	porkchop_raw = "mcl_mobitems:porkchop",
	porkchop_cooked = "mcl_mobitems:cooked_porkchop",
	carrot_on_a_stick = "mcl_mobitems:carrot_on_a_stick",
	rabbit_raw = "mcl_mobitems:rabbit",
	rabbit_cooked = "mcl_mobitems:cooked_rabbit",
	rabbit_hide = "mcl_mobitems:rabbit_hide",
	mutton_raw = "mcl_mobitems:mutton",
	mutton_cooked = "mcl_mobitems:cooked_mutton",
	shulker_shell = "mcl_mobitems:shulker_shell",
	magma_cream = "mcl_mobitems:magma_cream",
	spider_eye = "mcl_mobitems:spider_eye",
	rotten_flesh = "mcl_mobitems:rotten_flesh",
	snowball = "mcl_throwing:snowball",
	top_snow = "mcl_core:snow",
	snow_block = "mcl_core:snowblock",
	arrow = "mcl_bows:arrow",
	bow = "mcl_bows:bow",
	head_zombie = "mcl_heads:zombie",
	head_creeper = "mcl_heads:creeper",
	head_skeleton = "mcl_heads:skeleton",
	head_wither_skeleton = "mcl_heads:wither_skeleton",

	leather = "mcl_mobitems:leather",
	shears = "mcl_tools:shears",

	mushroom_red = "mcl_mushrooms:mushroom_red",
	mushroom_brown = "mcl_mushrooms:mushroom_brown",
	bucket = "mcl_buckets:bucket_empty",
	grass_block = "mcl_core:dirt_with_grass",
	string = "mcl_mobitems:string",
	stick = "mcl_core:stick",
	flint = "mcl_core:flint",
	iron_ingot = "mcl_core:iron_ingot",
	iron_block = "mcl_core:ironblock",
	fire = "mcl_fire:fire",
	gunpowder = "mcl_mobitems:gunpowder",
	flint_and_steel = "mcl_fire:flint_and_steel",
	water_source = "mcl_core:water_source",
	river_water_source = "mclx_core:river_water_source",
	black_dye = "mcl_dye:black",
	poppy = "mcl_flowers:poppy",
	dandelion = "mcl_flowers:dandelion",
	coal = "mcl_core:coal_lump",
	emerald = "mcl_core:emerald",
	iron_axe = "mcl_tools:axe_iron",
	gold_sword = "mcl_tools:sword_gold",
	gold_ingot = "mcl_core:gold_ingot",
	gold_nugget = "mcl_core:gold_nugget",
	glowstone_dust = "mcl_nether:glowstone_dust",
	redstone = "mesecons:redstone",
	glass_bottle = "mcl_potions:glass_bottle",
	sugar = "mcl_core:sugar",
	wheat = "mcl_farming:wheat_item",
	cookie = "mcl_farming:cookie",
	potato = "mcl_farming:potato_item",
	hay_bale = "mcl_farming:hay_block",
	prismarine_shard = "mcl_ocean:prismarine_shard",
	prismarine_crystals = "mcl_ocean:prismarine_crystals",
	apple = "mcl_core:apple",
	golden_apple = "mcl_core:apple_gold",
	rabbit_foot = "mcl_mobitems:rabbit_foot",
	wet_sponge = "mcl_sponges:sponge_wet",

	-- Other
	nether_brick_block = "mcl_nether:nether_brick",
	netherrack = "mcl_nether:netherrack",
	nether_star = "mcl_mobitems:nether_star",
	nether_portal = "mcl_portals:portal",
	mycelium = "mcl_core:mycelium",
	carrot = "mcl_farming:carrot_item",
	golden_carrot = "mcl_farming:carrot_item_gold",
	fishing_rod = "mcl_fishing:fishing_rod",
	fish_raw = "mcl_fishing:fish_raw",
	salmon_raw = "mcl_fishing:salmon_raw",
	clownfish_raw = "mcl_fishing:clownfish_raw",
	pufferfish_raw = "mcl_fishing:pufferfish_raw",
	bone = "mcl_mobitems:bone",
	slimeball = "mcl_mobitems:slimeball",

	ender_pearl = "mcl_throwing:ender_pearl",

	wool_white = "mcl_wool:white",
	wool_light_grey = "mcl_wool:silver",
	wool_grey = "mcl_wool:grey",
	wool_blue = "mcl_wool:blue",
	wool_lime = "mcl_wool:lime",
	wool_green = "mcl_wool:green",
	wool_purple = "mcl_wool:purple",
	wool_pink = "mcl_wool:pink",
	wool_yellow = "mcl_wool:yellow",
	wool_orange = "mcl_wool:orange",
	wool_brown = "mcl_wool:brown",
	wool_red = "mcl_wool:red",
	wool_cyan = "mcl_wool:cyan",
	wool_magenta = "mcl_wool:magenta",
	wool_black = "mcl_wool:black",
	wool_light_blue = "mcl_wool:light_blue",

	music_discs = {
		"mcl_jukebox:record_1",
		"mcl_jukebox:record_2",
		"mcl_jukebox:record_3",
		"mcl_jukebox:record_4",
		"mcl_jukebox:record_5",
		"mcl_jukebox:record_6",
		"mcl_jukebox:record_7",
		"mcl_jukebox:record_8",
		"mcl_jukebox:record_9",
	},
}

--Horses, Llamas, and Wolves shouldn't follow, but leaving this alone until leads are implemented.
mobs_mc.override.follow = {
	chicken = { "mcl_farming:wheat_seeds", "mcl_farming:melon_seeds", "mcl_farming:pumpkin_seeds", "mcl_farming:beetroot_seeds", },
	parrot = { "mcl_farming:wheat_seeds", "mcl_farming:melon_seeds", "mcl_farming:pumpkin_seeds", "mcl_farming:beetroot_seeds", },
	pig = { mobs_mc.override.items.potato, mobs_mc.override.items.carrot, "mcl_farming:beetroot_item", mobs_mc.override.items.carrot_on_a_stick},
	ocelot = { mobs_mc.override.items.fish_raw, mobs_mc.override.items.salmon_raw, mobs_mc.override.items.clownfish_raw, mobs_mc.override.items.pufferfish_raw, },
	sheep = { mobs_mc.override.items.wheat },
	cow = { mobs_mc.override.items.wheat },
	horse = { mobs_mc.override.items.apple, mobs_mc.override.items.sugar, mobs_mc.override.items.wheat, mobs_mc.override.items.hay_bale, mobs_mc.override.items.golden_apple, mobs_mc.override.items.golden_carrot },
	llama = { mobs_mc.override.items.wheat, mobs_mc.override.items.hay_bale },
	rabbit = { mobs_mc.override.items.dandelion, mobs_mc.override.items.carrot, mobs_mc.override.items.golden_carrot },
	wolf = { mobs_mc.override.items.bone },
	dog = { mobs_mc.override.items.rabbit_raw, mobs_mc.override.items.rabbit_cooked, mobs_mc.override.items.mutton_raw, mobs_mc.override.items.mutton_cooked, mobs_mc.override.items.beef_raw, mobs_mc.override.items.beef_cooked, mobs_mc.override.items.chicken_raw, mobs_mc.override.items.chicken_cooked, mobs_mc.override.items.rotten_flesh, mobs_mc.override.items.porkchop_raw, mobs_mc.override.items.porkchop_cooked },
}

mobs_mc.override.replace = {
	-- Rabbits reduce carrot growth stage by 1
	rabbit = {
		{"mcl_farming:carrot", "mcl_farming:carrot_7", 0},
		{"mcl_farming:carrot_7", "mcl_farming:carrot_6", 0},
		{"mcl_farming:carrot_6", "mcl_farming:carrot_5", 0},
		{"mcl_farming:carrot_5", "mcl_farming:carrot_4", 0},
		{"mcl_farming:carrot_4", "mcl_farming:carrot_3", 0},
		{"mcl_farming:carrot_3", "mcl_farming:carrot_2", 0},
		{"mcl_farming:carrot_2", "mcl_farming:carrot_1", 0},
		{"mcl_farming:carrot_1", "air", 0},
	},
	-- Sheep eat grass
	sheep = {
		{ "mcl_core:dirt_with_grass", "mcl_core:dirt", -1 },
		{ "mcl_flowers:tallgrass", "air", 0 },
	},
	-- Silverfish populate stone, etc. with monster eggs
	silverfish = {
		{"mcl_core:stone", "mcl_monster_eggs:monster_egg_stone", -1},
		{"mcl_core:cobble", "mcl_monster_eggs:monster_egg_cobble", -1},
		{"mcl_core:stonebrick", "mcl_monster_eggs:monster_egg_stonebrick", -1},
		{"mcl_core:stonebrickmossy", "mcl_monster_eggs:monster_egg_stonebrickmossy", -1},
		{"mcl_core:stonebrickcracked", "mcl_monster_eggs:monster_egg_stonebrickcracked", -1},
		{"mcl_core:stonebrickcarved", "mcl_monster_eggs:monster_egg_stonebrickcarved", -1},
	},
}

-- List of nodes which endermen can take
mobs_mc.override.enderman_takable = {
	-- Generic handling, useful for entensions
	"group:enderman_takable",
}
mobs_mc.override.enderman_replace_on_take = {
}

-- Texuture overrides for enderman block. Required for cactus because it's original is a nodebox
-- and the textures have tranparent pixels.
local cbackground = "mobs_mc_gameconfig_enderman_cactus_background.png"
local ctiles = minetest.registered_nodes["mcl_core:cactus"].tiles

local ctable = {}
local last
for i=1, 6 do
	if ctiles[i] then
		last = ctiles[i]
	end
	table.insert(ctable, cbackground .. "^" .. last)
end

mobs_mc.override.enderman_block_texture_overrides = {
	["mcl_core:cactus"] = ctable,
	-- FIXME: replace colorize colors with colors from palette
	["mcl_core:dirt_with_grass"] =
	{
	"mcl_core_grass_block_top.png^[colorize:green:90",
	"default_dirt.png",
	"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
	"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
	"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)",
	"default_dirt.png^(mcl_core_grass_block_side_overlay.png^[colorize:green:90)"}
}

-- List of nodes on which mobs can spawn
mobs_mc.override.spawn = {
	solid = { "group:solid", }, -- spawn on "solid" nodes
	grassland = { "mcl_core:dirt_with_grass" },
	savanna = { "mcl_core:dirt_with_grass" },
	grassland_savanna = { "mcl_core:dirt_with_grass" },
	desert = { "mcl_core:sand", "mcl_core:sandstone" },
	jungle = { "mcl_core:jungletree", "mcl_core:jungleleaves", "mcl_flowers:fern", "mcl_core:vine" },
	snow = { "mcl_core:snow", "mcl_core:snowblock", "mcl_core:dirt_with_grass_snow" },
	-- End stone added for shulkers because End cities don't generate yet
	end_city = { "mcl_end:end_stone", "mcl_end:purpur_block" },
	-- Netherrack added because there are no Nether fortresses yet. TODO: Remove netherrac from list as soon they're available
	nether_fortress = { "mcl_nether:nether_brick", "mcl_nether:netherrack" },
	nether_portal = { mobs_mc.override.items.nether_portal },
	wolf = { mobs_mc.override.items.grass_block, "mcl_core:dirt", "mcl_core:dirt_with_grass_snow", "mcl_core:snow", "mcl_core:snowblock", "mcl_core:podzol" },
	village = { "mcl_villages:stonebrickcarved", "mcl_core:grass_path", "mcl_core:sandstonesmooth2" },
}

-- This table contains important spawn height references for the mob spawn height.
mobs_mc.override.spawn_height = {
	water = tonumber(minetest.settings:get("water_level")) or 0, -- Water level in the Overworld

	-- Overworld boundaries (inclusive)
	overworld_min = mcl_vars.mg_overworld_min,
	overworld_max = mcl_vars.mg_overworld_max,

	-- Nether boundaries (inclusive)
	nether_min = mcl_vars.mg_nether_min,
	nether_max = mcl_vars.mg_nether_max,

	-- End boundaries (inclusive)
	end_min = mcl_vars.mg_end_min,
	end_max = mcl_vars.mg_end_max,
}

