local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_mud:mud", {
	description = S("Mud"),
	_doc_items_longdesc = S("Mud is a decorative block that generates in mangrove swamps. Mud can also be obtained by using water bottles on dirt or coarse dirt."),
	_doc_items_hidden = false,
	tiles = {"mcl_mud.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, enderman_takable=1, building_block=1},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_node("mcl_mud:packed_mud", {
	description = S("Packed Mud"),
	_doc_items_longdesc = S("Packed mud is a decorative block used to craft mud bricks."),
	_doc_items_hidden = false,
	tiles = {"mcl_mud_packed_mud.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {handy=1,shovely=1, enderman_takable=1, building_block=1},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_mud:packed_mud",
	recipe = {
		"mcl_mud:mud",
		"mcl_farming:wheat_item",
	}
})