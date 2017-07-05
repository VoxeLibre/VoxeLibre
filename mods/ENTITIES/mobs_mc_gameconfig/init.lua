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
	snowblock = "mcl_core:snowblock",

	arrow = "mcl_throwing:arrow",
	bow = "mcl_throwing:bow",

	leather = "mcl_mobitems:leather",
	shears = "mcl_tools:shears",

	mushroom_red = "mcl_mushrooms:mushroom_red",
	bucket = "bucket:bucket_empty",
	grass_block = "mcl_core:dirt_with_grass",
	string = "mcl_mobitems:string",
	stick = "mcl_core:stick",
	flint = "mcl_core:flint",
	iron_ingot = "mcl_core:iron_ingot",
	fire = "mcl_fire:fire",
	gunpowder = "mcl_mobitems:gunpowder",
	flint_and_steel = "mcl_fire:flint_and_steel",
	water_source = "mcl_core:water_source",
	black_dye = "mcl_dye:black",
	poppy = "mcl_flowers:poppy",
	dandelion = "mcl_flowers:dandelion",
	coal = "mcl_core:coal_lump",
	emerald = "mcl_core:emerald",
	iron_axe = "mcl_tools:axe_iron",
	gold_sword = "mcl_tools:sword_gold",
	gold_nugget = "mcl_core:gold_nugget",
	glowstone_dust = "mcl_nether:glowstone_dust",
	redstone = "mesecons:redstone",
	glass_bottle = "mcl_potions:glass_bottle",
	sugar = "mcl_core:sugar",
	wheat = "mcl_farming:wheat_item",
	potato = "mcl_farming:potato_item",
	hay_bale = "mcl_farming:hay_bale",
	prismarine_shard = "mcl_ocean:prismarine_shard",
	prismarine_crystals = "mcl_ocean:prismarine_crystals",
	apple = "mcl_core:apple",
	golden_apple = "mcl_core:apple_gold",
	rabbit_foot = "mcl_mobitems:rabbit_foot",

	-- Other
	nether_brick_block = "mcl_nether:nether_brick",
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

mobs_mc.override.follow = {
	chicken = { "mcl_farming:wheat_seeds", "mcl_farming:melon_seeds", "mcl_farming:pumpkin_seeds", "mcl_farming:beetroot_seeds", },
	parrot = { "mcl_farming:seed_wheat", "mcl_farming:seed_beetroot", "mcl_farming:seed_pumpkin", "mcl_farming:seed_melon" }, -- seeds in general
	pig = { mobs_mc.override.items.potato, mobs_mc.override.items.carrot, "mcl_farming:beetroot_item", mobs_mc.override.items.carrot_on_a_stick},
	ocelot = { mobs_mc.override.items.fish_raw, mobs_mc.override.items.salmon_raw, mobs_mc.override.items.clownfish_raw, mobs_mc.override.items.pufferfish_raw, },
}

-- List of nodes which endermen can take
mobs_mc.override.enderman_takable = {
	-- Generic handling, useful for entensions
	"group:enderman_takable",
}

-- List of nodes on which mobs can spawn
mobs_mc.override.spawn = {
	solid = { "group:solid", }, -- spawn on "solid" nodes
	grassland = { mobs_mc.override.items.grass_block },
	savanna = { "group:sand", "mcl_core:sandstone", "mcl_core:redsandstone" },
	grassland_savanna = { mobs_mc.override.items.grass_block, "group:sand", "mcl_core:sandstone", "mcl_core:redsandstone" },
	desert = { "group:sand" },
	jungle = { mobs_mc.override.items.grass_block, "mcl_core:podzol", "mcl_core:jungletree", "mcl_core:jungleleaves" },
	snow = { "mcl_core:snow", "mcl_core:snowblock", "mcl_core:dirt_with_grass_snow" },
	end_city = { "mcl_end:purpur_block" },
	wolf = { mobs_mc.override.items.grass_block, "mcl_core:dirt", "mcl_core:dirt_with_grass_snow", "mcl_core:snow", "mcl_core:snowblock", "mcl_core:podzol" },
}

