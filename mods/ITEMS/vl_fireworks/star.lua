local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_craftitem("vl_fireworks:firework_star", {
	description = S("Firework Star"),
	_doc_items_longdesc = S("A firework star is the key component of a firework rocket which is responsible for the visible explosion."),
	wield_image = "vl_fireworks_star.png",
	inventory_image = "vl_fireworks_star.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

-- TODO tt snippets
-- TODO image handlers
