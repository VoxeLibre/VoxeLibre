-- Crafting
core.register_craft({
	output = "mcl_dye:pink",
	recipe = {
		{"mcl_cherry_blossom:pink_petals"}
	},
})

--mcl_signs.register_sign_craft("mcl_cherry_blossom", "mcl_cherry_blossom:cherrywood", "_cherrywood")

-- Smelting
core.register_craft({
	type = "fuel",
	recipe = "mcl_cherry_blossom:cherry_door",
	burntime = 10,
})

core.register_craft({
	type = "fuel",
	recipe = "mcl_cherry_blossom:cherry_trapdoor",
	burntime = 15,
})

core.register_craft({
	type = "fuel",
	recipe = "mcl_cherry_blossom:pressure_plate_cherrywood_off",
	burntime = 15
})

core.register_craft({
	type = "fuel",
	recipe = "mesecons_button:button_cherrywood_off",
	burntime = 5,
})
