local S = minetest.get_translator(minetest.get_current_modname())
-- Fletching Table Code. No use as of current Minecraft Updates. Basically a decor block. As of now, this is complete.
minetest.register_node("mcl_fletching_table:fletching_table", {
	description = S("Fletching Table"),
	_tt_help = S("A fletching table"),
	_doc_items_longdesc = S("This is the fletcher villager's work station. It currently has no use beyond decoration."),
	tiles = {
		"fletching_table_top.png", "fletching_table_top.png",
		"fletching_table_side.png", "fletching_table_side.png",
		"fletching_table_front.png", "fletching_table_front.png"
	},
	paramtype2 = "facedir",
	groups = {choppy=1, container=4, deco_block=1, material_wood=1, flammable=1},
	is_ground_content = false
	})
minetest.register_craft({
	output = "mcl_fletching_table:fletching_table",
	recipe = {
		{ "mcl_core:flint", "mcl_core:flint", "" },
		{ "group:wood", "group:wood", "" },
		{ "group:wood", "group:wood", "" },
	}
})