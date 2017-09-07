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
	output = "mcl_end:end_stone",
		recipe = {
		{ "mcl_core:sandstone", "mcl_core:stone", "mcl_core:sandstone" },
		{ "mcl_core:stone", "mcl_core:sandstone", "mcl_core:stone" },
		{ "mcl_core:sandstone", "mcl_core:stone", "mcl_core:sandstone" },
	},
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
	output = "mcl_mobitems:shulker_shell",
	recipe = {
		 { "mcl_end:purpur_block", "mcl_end:purpur_block", "mcl_end:purpur_block", },
		 { "mcl_end:purpur_block", "mcl_core:emerald", "mcl_end:purpur_block", },
		 { "mcl_end:purpur_block", "", "mcl_end:purpur_block", },
	}
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


