-- Temporary helper recipes.
-- These recipes are NOT part of Minecraft. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = 'mcl_chests:trapped_chest',
	recipe = {"mcl_core:iron_ingot", "mcl_core:stick", "group:wood", "mcl_chests:chest"},
})

minetest.register_craft({
	output = "mcl_sponges:sponge",
	recipe = {
		{ "mcl_farming:hay_block", "mcl_farming:hay_block", "mcl_farming:hay_block" },
		{ "mcl_farming:hay_block", "mcl_core:emerald", "mcl_farming:hay_block" },
		{ "mcl_farming:hay_block", "mcl_farming:hay_block", "mcl_farming:hay_block" },
	}
})

minetest.register_craft({
	output = "mcl_core:redsand 8",
	recipe = {
		{ "mcl_core:sand", "mcl_core:sand", "mcl_core:sand" },
		{ "mcl_core:sand", "mcl_dye:red", "mcl_core:sand" },
		{ "mcl_core:sand", "mcl_core:sand", "mcl_core:sand" },
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
	recipe = { "mcl_ocean:prismarine_shard", "mcl_ocean:prismarine_shard", "mcl_ocean:prismarine_shard", "mcl_core:emerald" },
})

minetest.register_craft({
	output = "mcl_end:chorus_fruit",
	recipe = {
		{ "mcl_flowers:allium", "mcl_end:end_stone", "mcl_flowers:allium" },
		{ "mcl_end:end_stone", "mcl_end:end_stone", "mcl_end:end_stone" },
		{ "mcl_flowers:allium", "mcl_end:end_stone", "mcl_flowers:allium" },
	},
})

minetest.register_craft({
	output = "mcl_end:end_stone",
	recipe = {
		{ "mcl_core:sandstone", "mcl_core:stone", "mcl_core:sandstone" },
		{ "mcl_core:stone", "mcl_core:sandstone", "mcl_core:stone" },
		{ "mcl_core:sandstone", "mcl_core:stone", "mcl_core:sandstone" },
	},
})

minetest.register_craft({
	output = "mcl_mobitems:blaze_rod",
	recipe = {
		 { "mcl_fire:flint_and_steel", "mcl_fire:flint_and_steel", "mcl_fire:flint_and_steel"},
		 { "mcl_fire:flint_and_steel", "mcl_core:stick", "mcl_fire:flint_and_steel" },
		 { "mcl_fire:flint_and_steel", "mcl_fire:flint_and_steel", "mcl_fire:flint_and_steel"},
	}
})
minetest.register_craft({
	output = "mcl_mobitems:shulker_shell",
	recipe = {
		 { "mcl_end:purpur_block", "mcl_end:purpur_block", "mcl_end:purpur_block", },
		 { "mcl_end:purpur_block", "mcl_core:emerald", "mcl_end:purpur_block", },
		 { "mcl_end:purpur_block", "", "mcl_end:purpur_block", },
	}
})

minetest.register_craft({
	output = "mcl_nether:quartz",
	recipe = {
		{"group:sand", "group:sand", "group:sand"},
		{"group:sand", "group:sand", "group:sand"},
		{"group:sand", "group:sand", "group:sand"},
	}
})

minetest.register_craft({
	output = "mcl_nether:nether_wart_item",
	recipe = {
		{"mcl_nether:soul_sand", "mcl_core:obsidian", "mcl_nether:soul_sand"},
		{"mcl_core:obsidian", "mcl_core:goldblock", "mcl_core:obsidian"},
		{"mcl_nether:soul_sand", "mcl_core:obsidian", "mcl_nether:soul_sand"},
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_nether:netherrack",
	recipe = {"mcl_core:stone", "group:redsandstone"},
})

minetest.register_craft({
	output = "mcl_nether:glowstone_dust",
	recipe = {
		{"mcl_torches:torch", "mcl_torches:torch", "mcl_torches:torch",},
		{"mcl_torches:torch", "mcl_core:coalblock", "mcl_torches:torch",},
		{"mcl_torches:torch", "mcl_torches:torch", "mcl_torches:torch",},
	},
})

minetest.register_craft({
	output = "mcl_nether:soul_sand",
	recipe = {
		{"mcl_core:redsand","mcl_nether:netherrack","mcl_core:redsand"},
		{"mcl_nether:netherrack","mcl_core:redsand","mcl_nether:netherrack"},
		{"mcl_core:redsand","mcl_nether:netherrack","mcl_core:redsand"},
	},
})

minetest.register_craft({
	output = "mcl_farming:beetroot_seeds",
	recipe = {
		{"mcl_farming:hay_block","mcl_farming:wheat_seeds"},
		{"mcl_farming:wheat_seeds","mcl_farming:hay_block"},
	},
})
minetest.register_craft({
	output = "mcl_farming:beetroot_seeds",
	recipe = {
		{"mcl_farming:wheat_seeds","mcl_farming:hay_block"},
		{"mcl_farming:hay_block","mcl_farming:wheat_seeds"},
	},
})

minetest.register_craft({
	output = "3d_armor:helmet_chain",
	recipe = {
		{ "xpanes:bar_flat", "mcl_core:iron_ingot", "xpanes:bar_flat" },
		{ "xpanes:bar_flat", "", "xpanes:bar_flat" },
	}
})

minetest.register_craft({
	output = "3d_armor:leggings_chain",
	recipe = {
		{ "xpanes:bar_flat", "mcl_core:iron_ingot", "xpanes:bar_flat" },
		{ "xpanes:bar_flat", "", "xpanes:bar_flat" },
		{ "xpanes:bar_flat", "", "xpanes:bar_flat" },
	}
})

minetest.register_craft({
	output = "3d_armor:boots_chain",
	recipe = {
		{ "xpanes:bar_flat", "", "xpanes:bar_flat" },
		{ "xpanes:bar_flat", "", "xpanes:bar_flat" },
	}
})

minetest.register_craft({
	output = "3d_armor:chestplate_chain",
	recipe = {
		{ "xpanes:bar_flat", "", "xpanes:bar_flat" },
		{ "xpanes:bar_flat", "mcl_core:iron_ingot", "xpanes:bar_flat" },
		{ "xpanes:bar_flat", "xpanes:bar_flat", "xpanes:bar_flat" },
	}
})

minetest.register_craft({
	output = "mcl_jukebox:record_1",
	recipe = {
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_ocean:sea_lantern", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
	}
})
minetest.register_craft({
	output = "mcl_jukebox:record_2",
	recipe = {
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_fire:fire_charge", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
	}
})
minetest.register_craft({
	output = "mcl_jukebox:record_3",
	recipe = {
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_core:emerald", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
	}
})
minetest.register_craft({
	output = "mcl_jukebox:record_4",
	recipe = {
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_end:ender_eye", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
	}
})
minetest.register_craft({
	output = "mcl_jukebox:record_5",
	recipe = {
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_nether:nether_wart_block", "mcl_core:glass_black", },
		{ "mcl_core:glass_black", "mcl_core:glass_black", "mcl_core:glass_black", },
	}
})

-- 2 discs are dropped by creeper
-- 1 disc is droppd by zombie
-- TODO: Remove/fix these drops when creeper drops music discs properly
