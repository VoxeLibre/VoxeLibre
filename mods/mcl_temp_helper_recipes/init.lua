-- Temporary helper recipes.
-- These recipes are NOT part of Minecraft. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:gunpowder",
	recipe = {
		'group:sand',
		'mcl_core:gravel',
	}
})

minetest.register_craft({
	output = "mcl_core:sponge",
	recipe = {
		{ "mcl_core:haybale", "mcl_core:haybale", "mcl_core:haybale" },
		{ "mcl_core:haybale", "mcl_core:emerald", "mcl_core:haybale" },
		{ "mcl_core:haybale", "mcl_core:haybale", "mcl_core:haybale" },
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
	output = "mcl_core:prismarine_shard",
	recipe = {
		{ "mcl_core:glass_cyan", },
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:prismarine_crystals",
	recipe = { "mcl_core:prismarine_shard", "mcl_core:prismarine_shard", "mcl_core:prismarine_shard", "mcl_core:emerald" },
})

minetest.register_craft({
	output = "mcl_dye:black 2",
	recipe = {{"mcl_core:coal_lump"}},
})
minetest.register_craft({
	output = "mcl_dye:brown",
	recipe = {
		{"mcl_core:jungletree"},
		{"mcl_core:jungletree"}
	},
})
minetest.register_craft({
	output = "mcl_dye:white",
	recipe = {
		{"mcl_core:dirt", "mcl_core:dirt", "mcl_core:dirt"},
		{"mcl_core:dirt", "mcl_core:iron_nugget", "mcl_core:dirt"},
		{"mcl_core:dirt", "mcl_core:dirt", "mcl_core:dirt"},
	},
})

minetest.register_craft({
	output = "mcl_end:chorus_fruit",
	recipe = {
		{ "mcl_flowers:allium", "mcl_flowers:allium", "mcl_flowers:allium" },
		{ "mcl_flowers:allium", "mcl_flowers:allium", "mcl_flowers:allium" },
		{ "mcl_flowers:allium", "mcl_flowers:allium", "mcl_flowers:allium" },
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
	type = "shapeless",
	output = "mcl_throwing:ender_pearl",
	recipe = { "mcl_core:emeraldblock", "mcl_core:diamondblock", "mcl_core:goldblock", }
})

minetest.register_craft({
	output = "mcl_mobitems:string",
	recipe = {
		{ "mcl_core:reeds"},
		{ "mcl_core:reeds"}
	},
})
minetest.register_craft({
	type = "shapeless",
	output = "mcl_mobitems:leather",
	recipe = { "mcl_core:paper", "mcl_core:paper" },
})
minetest.register_craft({
	output = "mcl_mobitems:feather 3",
	recipe = {
		{ "mcl_flowers:oxeye_daisy" },
		{ "mcl_flowers:oxeye_daisy" },
	}
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
	output = 'mesecons_materials:slimeball',
	type = "cooking",
	recipe = "mcl_core:sapling",
	cooktime = 10,
})

minetest.register_craft({
	output = "mcl_core:quartz_crystal",
	recipe = {
		{"group:sand", "group:sand", "group:sand"},
		{"group:sand", "group:sand", "group:sand"},
		{"group:sand", "group:sand", "group:sand"},
	}
})
