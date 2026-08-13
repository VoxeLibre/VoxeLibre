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
