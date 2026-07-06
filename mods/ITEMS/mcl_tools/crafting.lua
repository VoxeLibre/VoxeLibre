minetest.register_craft({
	output = "mcl_tools:sword_wood",
	recipe = {
		{"group:wood"},
		{"group:wood"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_stone",
	recipe = {
		{"group:cobble"},
		{"group:cobble"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_iron",
	recipe = {
		{"mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_gold",
	recipe = {
		{"mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:sword_diamond",
	recipe = {
		{"mcl_core:diamond"},
		{"mcl_core:diamond"},
		{"mcl_core:stick"},
	}
})

minetest.register_craft({
	output = "mcl_tools:shears",
	recipe = {
		{ "mcl_core:iron_ingot", "" },
		{ "", "mcl_core:iron_ingot", },
	}
})
minetest.register_craft({
	output = "mcl_tools:shears",
	recipe = {
		{ "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "" },
	}
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:sword_wood",
	burntime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:gold_nugget",
	recipe = "mcl_tools:sword_gold",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_core:iron_nugget",
	recipe = "mcl_tools:sword_iron",
	cooktime = 10,
})

minetest.register_craft({
	type = "fuel",
	recipe = "mcl_tools:sword_wood",
	burntime = 10,
})
