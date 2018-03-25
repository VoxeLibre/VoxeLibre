--[[ This table contains the concrete itemstrings to be used by this mod.
All mobs in this mod must use variables in this table, instead
of hardcoding the itemstring.
This way, external mods are enabled to replace the itemstrings to provide
their own items and game integration is made much simpler.

An item IDs is supposed to be overwritten by adding
mobs_mc.override.items["example:item"] in a game mod
with name "mobs_mc_gameconfig". ]]


-- Standard items

-- If true, mobs_mc adds the monster egg nodes (needs default mod).
-- Set to false in your gameconfig mod if you create your own monster egg nodes.
mobs_mc.create_monster_egg_nodes = true

mobs_mc.items = {}

mobs_mc.items = {
	-- Items defined in mobs_mc
	blaze_rod = "mobs_mc:blaze_rod",
	blaze_powder = "mobs_mc:blaze_powder",
	chicken_raw = "mobs_mc:chicken_raw",
	chicken_cooked = "mobs_mc:chicken_cooked",
	feather = "mobs_mc:feather",
	beef_raw = "mobs_mc:beef_raw",
	beef_cooked = "mobs_mc:beef_cooked",
	bowl = "mobs_mc:bowl",
	mushroom_stew = "mobs_mc:mushroom_stew",
	milk = "mobs_mc:milk_bucket",
	dragon_egg = "mobs_mc:dragon_egg",
	egg = "mobs_mc:egg",
	ender_eye  = "mobs_mc:ender_eye",
	ghast_tear = "mobs_mc:ghast_tear",
	saddle = "mobs:saddle",
	iron_horse_armor = "mobs_mc:iron_horse_armor",
	gold_horse_armor = "mobs_mc:gold_horse_armor",
	diamond_horse_armor = "mobs_mc:diamond_horse_armor",
	porkchop_raw = "mobs_mc:porkchop_raw",
	porkchop_cooked = "mobs_mc:porkchop_cooked",
	carrot_on_a_stick = "mobs_mc:carrot_on_a_stick",
	rabbit_raw = "mobs_mc:rabbit_raw",
	rabbit_cooked = "mobs_mc:rabbit_cooked",
	rabbit_hide = "mobs_mc:rabbit_hide",
	mutton_raw = "mobs_mc:mutton_raw",
	mutton_cooked = "mobs_mc:mutton_cooked",
	shulker_shell = "mobs_mc:shulker_shell",
	magma_cream = "mobs_mc:magma_cream",
	spider_eye = "mobs_mc:spider_eye",
	snowball = "mobs_mc:snowball",
	totem = "mobs_mc:totem",
	rotten_flesh = "mobs_mc:rotten_flesh",
	nether_star = "mobs_mc:nether_star",
	bone = "mobs_mc:bone",
	slimeball = "mobs_mc:slimeball",
	arrow = "mobs_mc:arrow",
	bow = "mobs_mc:bow_wood",
	head_creeper = "mobs_mc:head_creeper",
	head_zombie = "mobs_mc:head_zombie",
	head_skeleton = "mobs_mc:head_skeleton",
	head_wither_skeleton = "mobs_mc:head_wither_skeleton",

	-- External items
	-- Mobs Redo
	leather = "mobs:leather",
	shears = "mobs:shears",

	-- Minetest Game
	top_snow = "default:snow",
	snow_block = "default:snowblock",
	mushroom_red = "flowers:mushroom_red",
	bucket = "bucket:bucket_empty",
	grass_block = "default:dirt_with_grass",
	string = "farming:string",
	stick = "default:stick",
	flint = "default:flint",
	iron_ingot = "default:steel_ingot",
	iron_block = "default:steelblock",
	fire = "fire:basic_flame",
	gunpowder = "tnt:gunpowder",
	flint_and_steel = "fire:flint_and_steel",
	water_source = "default:water_source",
	river_water_source = "default:river_water_source",
	black_dye = "dye:black",
	poppy = "flowers:rose",
	dandelion = "flowers:dandelion_yellow",
	coal = "default:coal_lump",
	emerald = "default:diamond",
	iron_axe = "default:axe_steel",
	gold_sword = "default:sword_mese",
	gold_ingot = "default:gold_ingot",
	gold_nugget = "default:gold_lump",
	glowstone_dust = "default:mese_crystal_fragment",
	redstone = "default:mese_crystal_fragment",
	glass_bottle = "vessels:glass_bottle",
	sugar = "default:papyrus",
	wheat = "farming:wheat",
	hay_bale = "farming:straw",
	prismarine_shard = "default:mese_crystal_fragment",
	prismarine_crystals = "default:mese_crystal",
	apple = "default:apple",
	golden_apple = "default:apple",
	rabbit_foot = "mobs_mc:rabbit_foot",

	-- Boss items
	wet_sponge = "default:gold_block", -- only dropped by elder guardian; there is no equivalent block in Minetest Game

	-- Other
	nether_brick_block = "nether:brick",
	mycelium = "ethereal:mushroom_dirt",
	carrot = "farming:carrot",
	potato = "farming:potato",
	golden_carrot = "farming:carrot_gold",
	fishing_rod = "fishing:pole_wood",
	fish_raw = "fishing:fish_raw",
	salmon_raw = "fishing:carp_raw",
	clownfish_raw = "fishing:clownfish_raw",
	pufferfish_raw = "fishing:pike_raw",

	cookie = "farming:cookie",


	-- TODO: Add actual ender pearl
	ender_pearl = "farorb:farorb",

	nether_portal = "nether:portal",
	netherrack = "nether:rack",
	nether_brick_block = "nether:brick",

	-- Wool (Minecraft color scheme)
	wool_white = "wool:white",
	wool_light_grey = "wool:grey",
	wool_grey = "wool:dark_grey",
	wool_blue = "wool:blue",
	wool_lime = "wool:green",
	wool_green = "wool:dark_green",
	wool_purple = "wool:violet",
	wool_pink = "wool:pink",
	wool_yellow = "wool:yellow",
	wool_orange = "wool:orange",
	wool_brown = "wool:brown",
	wool_red = "wool:red",
	wool_cyan = "wool:cyan",
	wool_magenta = "wool:magenta",
	wool_black = "wool:black",
	-- Light blue intentionally missing

	-- Special items
	music_discs = {}, -- No music discs by default; used by creeper. Override this if your game has music discs.
}

-- Tables for attracting, feeding and breeding mobs
mobs_mc.follow = {
	sheep = { mobs_mc.items.wheat },
	cow = { mobs_mc.items.wheat },
	chicken = { "farming:seed_wheat", "farming:seed_cotton" }, -- seeds in general
	parrot = { "farming:seed_wheat", "farming:seed_cotton" }, -- seeds in general
	horse = { mobs_mc.items.apple, mobs_mc.items.sugar, mobs_mc.items.wheat, mobs_mc.items.hay_bale, mobs_mc.items.golden_apple, mobs_mc.items.golden_carrot },
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
	nether_fortress = { mobs_mc.items.nether_brick_block, "mcl_nether:nether_brick", "mcl_portals:nether_air"  },
	nether = { mobs_mc.items.netherrack, "mcl_nether:netherrack", "mcl_portals:nether_air" },
	nether_portal = { mobs_mc.items.nether_portal, "mcl_portals:portal" },
	water = { mobs_mc.items.water_source, "mcl_core:water_source", "default:water_source" },
}

-- This table contains important spawn height references for the mob spawn height.
-- Please base your mob spawn height on these numbers to keep things clean.
mobs_mc.spawn_height = {
	water = tonumber(minetest.setting_get("water_level")) or 0, -- Water level in the Overworld

	-- Overworld boundaries (inclusive)
	overworld_min = -2999,
	overworld_max = 31000,

	-- Nether boundaries (inclusive)
	nether_min = -3369,
	nether_max = -3000,

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

