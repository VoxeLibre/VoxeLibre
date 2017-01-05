minetest.register_craft({
	type = "fuel",
	recipe = "torches:torch",
	burntime = 4,
})

minetest.register_craft({
	output = 'torches:torch 4',
	recipe = {
		{'group:coal'},
		{'default:stick'},
	}
})

