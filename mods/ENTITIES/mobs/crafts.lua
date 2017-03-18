
local S = mobs.intllib

-- name tag
minetest.register_craftitem("mobs:nametag", {
	description = S("Name Tag"),
	_doc_items_longdesc = S("A name tag is an item to name most animals and monsters."),
	_doc_items_usagehelp = S("Rightclick an animal or monster while holding the name tag, then enter a name."),
	inventory_image = "mobs_nametag.png",
	wield_image = "mobs_nametag.png",
	stack_max = 64,
	groups = { tool=1 },
})

