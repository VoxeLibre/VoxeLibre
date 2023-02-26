local S = minetest.get_translator(minetest.get_current_modname())
-- Cartography Table Code. Used to create and copy maps. TODO: Needs a GUI still.

minetest.register_node("mcl_cartography_table:cartography_table", {
	description = S("Cartography Table"),
	_tt_help = S("Used to create or copy maps"),
	_doc_items_longdesc = S("Is used to create or copy maps for use.."),
	tiles = {
		"mcl_cartography_table_top.png", "mcl_cartography_table_side3.png",
		"mcl_cartography_table_side3.png", "mcl_cartography_table_side2.png",
		"mcl_cartography_table_side3.png", "mcl_cartography_table_side1.png"
	},
	paramtype2 = "facedir",
	groups = { axey = 2, handy = 1, deco_block = 1, material_wood = 1, flammable = 1 },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 2.5,
	_mcl_hardness = 2.5
	})


minetest.register_craft({
	output = "mcl_cartography_table:cartography_table",
	recipe = {
		{ "mcl_core:paper", "mcl_core:paper", "" },
		{ "group:wood", "group:wood", "" },
		{ "group:wood", "group:wood", "" },
	}
})
