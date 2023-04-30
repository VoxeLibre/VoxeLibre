-- Crafting
minetest.register_craft({
	output = "mcl_cherry_blossom:cherrytree_bark 3",
	recipe = {
		{ "mcl_cherry_blossom:cherrytree", "mcl_cherry_blossom:cherrytree" },
		{ "mcl_cherry_blossom:cherrytree", "mcl_cherry_blossom:cherrytree" },
	}
})

minetest.register_craft({
	output = "mcl_cherry_blossom:stripped_cherrytree_bark 3",
	recipe = {
		{ "mcl_cherry_blossom:stripped_cherrytree", "mcl_cherry_blossom:stripped_cherrytree" },
		{ "mcl_cherry_blossom:stripped_cherrytree", "mcl_cherry_blossom:stripped_cherrytree" },
	}
})

minetest.register_craft({
	output = "mcl_cherry_blossom:cherrywood 4",
	recipe = {
		{"mcl_cherry_blossom:cherrytree"},
	}
})
