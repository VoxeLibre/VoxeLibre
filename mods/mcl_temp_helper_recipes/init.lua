-- Temporary helper recipes.
-- These recipes are NOT part of Minecraft. They are added to make some currently unobtainable items accessible.
-- TODO: Remove recipes when they become accessible by regular means

minetest.register_craft({
	type = "shapeless",
	output = "mcl_core:gunpowder",
	recipe = {
		'mcl_core:sand',
		'mcl_core:gravel',
	}
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
		{"mcl_core:dirt", "mcl_core:dirt", "mcl_core:dirt"},
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
		 { "", "mcl_fire:flint_and_steel", ""},
		 { "mcl_fire:flint_and_steel", "mcl_core:stick", "mcl_fire:flint_and_steel" },
		 { "", "mcl_fire:flint_and_steel", ""},
	}
})
minetest.register_craft({
	output = "mcl_mobitems:shulker_shell",
	recipe = {
		 { "mcl_end:purpur_block", "mcl_end:purpur_block", "mcl_end:purpur_block", },
		 { "mcl_end:purpur_block", "", "mcl_end:purpur_block", },
		 { "mcl_end:purpur_block", "", "mcl_end:purpur_block", },
	}
})

minetest.register_craft({
	output = 'mesecons_materials:slimeball',
	type = "cooking",
	recipe = "mcl_core:sapling",
	cooktime = 10,
})

