minetest.register_node("mcl_cauldrons:cauldron", {
	description = "Cauldron",
	wield_image = "mcl_cauldrons_cauldron.png",
	inventory_image = "mcl_cauldrons_cauldron.png",
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {pickaxey=1},
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.1875, -0.5, -0.375, 0.5, 0.5}, -- Left wall
			{0.375, -0.1875, -0.5, 0.5, 0.5, 0.5}, -- Right wall
			{-0.375, -0.1875, 0.375, 0.375, 0.5, 0.5}, -- Back wall
			{-0.375, -0.1875, -0.5, 0.375, 0.5, -0.375}, -- Front wall
			{-0.5, -0.3125, -0.5, 0.5, -0.1875, 0.5}, -- Floor
			{-0.5, -0.5, -0.5, -0.375, -0.3125, -0.25}, -- Left front foot, part 1
			{-0.375, -0.5, -0.5, -0.25, -0.3125, -0.375}, -- Left front foot, part 2
			{-0.5, -0.5, 0.25, -0.375, -0.3125, 0.5}, -- Left back foot, part 1
			{-0.375, -0.5, 0.375, -0.25, -0.3125, 0.5}, -- Left back foot, part 2
			{0.375, -0.5, 0.25, 0.5, -0.3125, 0.5}, -- Right back foot, part 1
			{0.25, -0.5, 0.375, 0.375, -0.3125, 0.5}, -- Right back foot, part 2
			{0.375, -0.5, -0.5, 0.5, -0.3125, -0.25}, -- Right front foot, part 1
			{0.25, -0.5, -0.5, 0.375, -0.3125, -0.375}, -- Right front foot, part 2
		}
	},
	selection_box = { type = "regular" },
	tiles = {
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_top.png",
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
		"mcl_cauldrons_cauldron_side.png"
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_hardness = 2,
	_mcl_blast_resistance = 10,
})

minetest.register_craft({
	output = "mcl_cauldrons:cauldron",
	recipe = {
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
	}
})
