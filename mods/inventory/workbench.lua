minetest.register_node("inventory:crafting_table", {
	description = "Crafting Table",
	tiles = {"inventory_crafting_table_top.png", "default_wood.png", "inventory_crafting_table_side.png",
		"inventory_crafting_table_side.png", "inventory_crafting_table_front.png", "inventory_crafting_table_front.png"},
	paramtype2 = "facedir",
	paramtype = "light",
	groups = {choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		clicker:get_inventory():set_width("craft", 3)
		clicker:get_inventory():set_size("craft", 9)
		clicker:get_inventory():set_width("main", 9)
		clicker:get_inventory():set_size("main", 36)
		minetest.show_formspec(clicker:get_player_name(), "inventory:craftin_table", CRAFTING_FORMSPEC)
	end,
})

minetest.register_craft({
	output = "inventory:crafting_table",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
	},
})


