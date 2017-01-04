minetest.register_craft({
	type = "fuel",
	recipe = "torches:torch",
	burntime = 4,
})

minetest.register_craft({
	output = 'torches:torch 4',
	recipe = {
		{'default:coal_lump'},
		{'default:stick'},
	}
})

minetest.register_craft({
	output = 'torches:torch 4',
	recipe = {
		{'default:charcoal_lump'},
		{'default:stick'},
	}
})
