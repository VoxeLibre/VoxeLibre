-- Temporary helper recipes.
-- These recipes are NOT part of Minecraft. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = "mcl_chests:trapped_chest",
	recipe = {"mcl_core:iron_ingot", "mcl_core:stick", "group:wood", "mcl_chests:chest"},
})

minetest.register_craft({
	output = "mcl_sponges:sponge",
	recipe = {
		{ "mcl_farming:hay_block", "mcl_farming:hay_block", "mcl_farming:hay_block" },
		{ "mcl_farming:hay_block", "mcl_core:goldblock", "mcl_farming:hay_block" },
		{ "mcl_farming:hay_block", "mcl_farming:hay_block", "mcl_farming:hay_block" },
	}
})

minetest.register_craft({
	output = "mcl_ocean:prismarine_shard",
	recipe = {
		{ "mcl_core:glass_cyan", },
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_ocean:prismarine_crystals",
	recipe = {
		"mcl_ocean:prismarine_shard",
		"mcl_ocean:prismarine_shard",
		"mcl_ocean:prismarine_shard",
		"mcl_core:gold_ingot",
	},
})

minetest.register_craft({
	output = "mcl_nether:quartz_smooth 4",
	recipe = {
		{ "mcl_nether:quartz_block", "mcl_nether:quartz_block" },
		{ "mcl_nether:quartz_block", "mcl_nether:quartz_block" },
	},
})

minetest.register_craft({
	output = "mcl_core:sandstonesmooth2 4",
	recipe = {
		{ "mcl_core:sandstonesmooth", "mcl_core:sandstonesmooth" },
		{ "mcl_core:sandstonesmooth", "mcl_core:sandstonesmooth" },
	},
})

minetest.register_craft({
	output = "mcl_core:redsandstonesmooth2 4",
	recipe = {
		{ "mcl_core:redsandstonesmooth", "mcl_core:redsandstonesmooth" },
		{ "mcl_core:redsandstonesmooth", "mcl_core:redsandstonesmooth" },
	},
})

minetest.register_craft({
	output = "mcl_potions:dragon_breath 3",
	recipe = {
		{"","mcl_end:chorus_flower",""},
		{"mcl_potions:glass_bottle","mcl_potions:glass_bottle","mcl_potions:glass_bottle"},
	}
})
