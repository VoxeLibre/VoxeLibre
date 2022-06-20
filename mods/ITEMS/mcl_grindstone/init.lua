local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_grindstone:grindstone", {
	description = S("Grindstone"),
	_tt_help = S("Used to disenchant/fix tools"),
	_doc_items_longdesc = S("This is currently a decorative block which serves as the weapon smith's work station.  In minecraft this is used to disenchant/fix tools howerver this has not yet been implemented"),
	tiles = {
		"grindstone_top.png",
		"grindstone_top.png",
		"grindstone_side.png",
		"grindstone_side.png",
		"grindstone_front.png",
		"grindstone_front.png"
	},
	drawtype = "nodebox",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		-- created with nodebox editor
		fixed = {
			{-0.25, -0.25, -0.375, 0.25, 0.5, 0.375}, 
			{-0.375, -0.0625, -0.1875, -0.25, 0.3125, 0.1875},
			{0.25, -0.0625, -0.1875, 0.375, 0.3125, 0.1875},
			{0.25, -0.5, -0.125, 0.375, -0.0625, 0.125},
			{-0.375, -0.5, -0.125, -0.25, -0.0625, 0.125},
		}
	},
	groups = {pickaxey = 1, deco_block = 1},
	_mcl_blast_resistance = 6,
	_mcl_hardness = 2
})

minetest.register_craft({
	output = "mcl_grindstone:grindstone",
	recipe = {
		{ "mcl_core:stick", "mcl_stairs:slab_stone_rough", "mcl_core:stick"},
		{ "group:wood", "", "group:wood"},
	}
})