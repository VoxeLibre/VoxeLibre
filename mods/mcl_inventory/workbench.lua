minetest.register_node("mcl_inventory:crafting_table", {
	description = "Crafting Table",
	tiles = {"mcl_inventory_crafting_table_top.png", "default_wood.png", "mcl_inventory_crafting_table_side.png",
		"mcl_inventory_crafting_table_side.png", "mcl_inventory_crafting_table_front.png", "mcl_inventory_crafting_table_front.png"},
	paramtype2 = "facedir",
	paramtype = "light",
	is_ground_content = false,
	groups = {choppy=2,oddly_breakable_by_hand=1,flammable=2},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = function(pos, node, clicker, itemstack)
		clicker:get_inventory():set_width("craft", 3)
		clicker:get_inventory():set_size("craft", 9)
		clicker:get_inventory():set_width("main", 9)
		clicker:get_inventory():set_size("main", 36)
		minetest.show_formspec(clicker:get_player_name(), "mcl_inventory:crafting_table", CRAFTING_FORMSPEC)
	end,
})

minetest.register_craft({
	output = "mcl_inventory:crafting_table",
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
	},
})


