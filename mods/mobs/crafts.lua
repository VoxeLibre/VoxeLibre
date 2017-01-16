
local S = mobs.intllib

-- name tag
minetest.register_craftitem("mobs:nametag", {
	description = S("Nametag"),
	inventory_image = "mobs_nametag.png",
})

core.register_craft({
	type = "shapeless",
	output = "mobs:nametag",
	recipe = {"default:paper", "dye:black", "farming:string"},
})

-- golden lasso
minetest.register_tool("mobs:magic_lasso", {
	description = S("Magic Lasso (right-click animal to put in inventory)"),
	inventory_image = "mobs_magic_lasso.png",
})

minetest.register_craft({
	output = "mobs:magic_lasso",
	recipe = {
		{"farming:string", "default:gold_lump", "farming:string"},
		{"default:gold_lump", "default:diamondblock", "default:gold_lump"},
		{"farming:string", "default:gold_lump", "farming:string"},
	}
})

-- net
minetest.register_tool("mobs:net", {
	description = S("Net (right-click animal to put in inventory)"),
	inventory_image = "mobs_net.png",
})

minetest.register_craft({
	output = "mobs:net",
	recipe = {
		{"default:stick", "", "default:stick"},
		{"default:stick", "", "default:stick"},
		{"farming:string", "default:stick", "farming:string"},
	}
})

