--|||||||||||||||||||||||
--||||| STONECUTTER |||||
--|||||||||||||||||||||||

-- TO-DO:
-- * Add GUI

local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_node("mcl_stonecutter:stonecutter", {
	description = S("Stone Cutter"),
	_tt_help = S("Used to cut stone like materials."),
	_doc_items_longdesc = S("Stonecutters are used to create stairs and slabs from stone like materials. It is also the jobsite for the Stone Mason Villager."),
	tiles = {
		"mcl_stonecutter_top.png",
		"mcl_stonecutter_bottom.png",
		"mcl_stonecutter_side.png",
		"mcl_stonecutter_side.png",
		{name="mcl_stonecutter_saw.png", 
		animation={
			type="vertical_frames", 
			aspect_w=16, 
			aspect_h=16, 
			length=1
		}},
		{name="mcl_stonecutter_saw.png", 
		animation={
			type="vertical_frames", 
			aspect_w=16, 
			aspect_h=16, 
			length=1
		}}
	},
	use_texture_alpha = "clip",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = { pickaxey=1, material_stone=1 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.0625, 0.5}, -- NodeBox1
			{-0.4375, 0.0625, 0, 0.4375, 0.5, 0}, -- NodeBox2
		}
	},
	_mcl_blast_resistance = 3.5,
	_mcl_hardness = 3.5,
	sounds = mcl_sounds.node_sound_stone_defaults(),
})

minetest.register_craft({
	output = "mcl_stonecutter:stonecutter",
	recipe = {
		{ "", "", "" },
		{ "", "mcl_core:iron_ingot", "" },
		{ "mcl_core:stone", "mcl_core:stone", "mcl_core:stone" },
	}
})
