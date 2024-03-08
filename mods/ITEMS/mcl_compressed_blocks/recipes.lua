minetest.register_craft({
	output = "mcl_compressed_blocks:compressed_cobblestone",
	recipe = {
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
		{ "mcl_core:cobble", "mcl_core:cobble", "mcl_core:cobble" },
	},
})

minetest.register_craft({
	output = "mcl_core:cobble 9",
	recipe = {
		{ "mcl_compressed_blocks:compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:double_compressed_cobblestone",
	recipe = {
		{ "mcl_compressed_blocks:compressed_cobblestone", "mcl_compressed_blocks:compressed_cobblestone", "mcl_compressed_blocks:compressed_cobblestone" },
		{ "mcl_compressed_blocks:compressed_cobblestone", "mcl_compressed_blocks:compressed_cobblestone", "mcl_compressed_blocks:compressed_cobblestone" },
		{ "mcl_compressed_blocks:compressed_cobblestone", "mcl_compressed_blocks:compressed_cobblestone", "mcl_compressed_blocks:compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:compressed_cobblestone 9",
	recipe = {
		{ "mcl_compressed_blocks:double_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:triple_compressed_cobblestone",
	recipe = {
		{ "mcl_compressed_blocks:double_compressed_cobblestone", "mcl_compressed_blocks:double_compressed_cobblestone", "mcl_compressed_blocks:double_compressed_cobblestone" },
		{ "mcl_compressed_blocks:double_compressed_cobblestone", "mcl_compressed_blocks:double_compressed_cobblestone", "mcl_compressed_blocks:double_compressed_cobblestone" },
		{ "mcl_compressed_blocks:double_compressed_cobblestone", "mcl_compressed_blocks:double_compressed_cobblestone", "mcl_compressed_blocks:double_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:double_compressed_cobblestone 9",
	recipe = {
		{ "mcl_compressed_blocks:triple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:quadruple_compressed_cobblestone",
	recipe = {
		{ "mcl_compressed_blocks:triple_compressed_cobblestone", "mcl_compressed_blocks:triple_compressed_cobblestone", "mcl_compressed_blocks:triple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:triple_compressed_cobblestone", "mcl_compressed_blocks:triple_compressed_cobblestone", "mcl_compressed_blocks:triple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:triple_compressed_cobblestone", "mcl_compressed_blocks:triple_compressed_cobblestone", "mcl_compressed_blocks:triple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:triple_compressed_cobblestone 9",
	recipe = {
		{ "mcl_compressed_blocks:quadruple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:quintuple_compressed_cobblestone",
	recipe = {
		{ "mcl_compressed_blocks:quadruple_compressed_cobblestone", "mcl_compressed_blocks:quadruple_compressed_cobblestone", "mcl_compressed_blocks:quadruple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:quadruple_compressed_cobblestone", "mcl_compressed_blocks:quadruple_compressed_cobblestone", "mcl_compressed_blocks:quadruple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:quadruple_compressed_cobblestone", "mcl_compressed_blocks:quadruple_compressed_cobblestone", "mcl_compressed_blocks:quadruple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:quadruple_compressed_cobblestone 9",
	recipe = {
		{ "mcl_compressed_blocks:quintuple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:sextuple_compressed_cobblestone",
	recipe = {
		{ "mcl_compressed_blocks:quintuple_compressed_cobblestone", "mcl_compressed_blocks:quintuple_compressed_cobblestone", "mcl_compressed_blocks:quintuple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:quintuple_compressed_cobblestone", "mcl_compressed_blocks:quintuple_compressed_cobblestone", "mcl_compressed_blocks:quintuple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:quintuple_compressed_cobblestone", "mcl_compressed_blocks:quintuple_compressed_cobblestone", "mcl_compressed_blocks:quintuple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:quintuple_compressed_cobblestone 9",
	recipe = {
		{ "mcl_compressed_blocks:sextuple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:septuple_compressed_cobblestone",
	recipe = {
		{ "mcl_compressed_blocks:sextuple_compressed_cobblestone", "mcl_compressed_blocks:sextuple_compressed_cobblestone", "mcl_compressed_blocks:sextuple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:sextuple_compressed_cobblestone", "mcl_compressed_blocks:sextuple_compressed_cobblestone", "mcl_compressed_blocks:sextuple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:sextuple_compressed_cobblestone", "mcl_compressed_blocks:sextuple_compressed_cobblestone", "mcl_compressed_blocks:sextuple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:sextuple_compressed_cobblestone 9",
	recipe = {
		{ "mcl_compressed_blocks:septuple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:octuple_compressed_cobblestone",
	recipe = {
		{ "mcl_compressed_blocks:septuple_compressed_cobblestone", "mcl_compressed_blocks:septuple_compressed_cobblestone", "mcl_compressed_blocks:septuple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:septuple_compressed_cobblestone", "mcl_compressed_blocks:septuple_compressed_cobblestone", "mcl_compressed_blocks:septuple_compressed_cobblestone" },
		{ "mcl_compressed_blocks:septuple_compressed_cobblestone", "mcl_compressed_blocks:septuple_compressed_cobblestone", "mcl_compressed_blocks:septuple_compressed_cobblestone" },
	},
})

minetest.register_craft({
	output = "mcl_compressed_blocks:septuple_compressed_cobblestone 9",
	recipe = {
		{ "mcl_compressed_blocks:octuple_compressed_cobblestone" },
	},
})
