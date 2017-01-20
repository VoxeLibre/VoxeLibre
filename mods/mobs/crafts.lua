
local S = mobs.intllib

-- name tag
minetest.register_craftitem("mobs:nametag", {
	description = S("Name Tag"),
	inventory_image = "mobs_nametag.png",
	wield_image = "mobs_nametag.png",
	stack_max = 64,
	groups = { tool=1 },
})

