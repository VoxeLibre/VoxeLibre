-- Minetest 0.4 mod: vessels
-- See README.txt for licensing and other information.

minetest.register_node("vessels:glass_bottle", {
	description = "Glass Bottle (empty)",
	drawtype = "plantlike",
	tiles = {"vessels_glass_bottle.png"},
	inventory_image = "vessels_glass_bottle_inv.png",
	wield_image = "vessels_glass_bottle.png",
	paramtype = "light",
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = {-0.25, -0.5, -0.25, 0.25, 0.4, 0.25}
	},
	groups = {vessel=1,dig_immediate=3,attached_node=1},
	sounds = default.node_sound_glass_defaults(),
})

minetest.register_craft( {
	output = "vessels:glass_bottle 4",
	recipe = {
		{ "default:glass", "", "default:glass" },
		{ "", "default:glass", "" }
	}
})
