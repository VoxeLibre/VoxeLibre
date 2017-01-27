minetest.register_node("mcl_end:end_stone", {
	description = "End Stone",
	tiles = {"mcl_end_end_stone.png"},
	stack_max = 64,
	groups = {cracky=2,building_block=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mcl_end:end_bricks", {
	description = "End Stone Bricks",
	tiles = {"mcl_end_end_stone_brick.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=3,building_block=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mcl_end:purpur_block", {
	description = "Purpur Block",
	tiles = {"mcl_end_purpur_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=3,building_block=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mcl_end:purpur_pillar", {
	description = "Purpur Pillar",
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = false,
	tiles = {"mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar.png"},
	groups = {cracky=3,building_block=1},
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("mcl_end:dragon_egg", {
	description = "Dragon Egg",
	tiles = {
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
		"mcl_end_dragon_egg.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	light_source = 1,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.375, -0.5, -0.375, 0.375, -0.4375, 0.375},
			{-0.5, -0.4375, -0.5, 0.5, -0.1875, 0.5},
			{-0.4375, -0.1875, -0.4375, 0.4375, 0, 0.4375},
			{-0.375, 0, -0.375, 0.375, 0.125, 0.375},
			{-0.3125, 0.125, -0.3125, 0.3125, 0.25, 0.3125},
			{-0.25, 0.25, -0.25, 0.25, 0.3125, 0.25},
			{-0.1875, 0.3125, -0.1875, 0.1875, 0.375, 0.1875},
			{-0.125, 0.375, -0.125, 0.125, 0.4375, 0.125},
			{-0.0625, 0.4375, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	groups = { oddly_breakable_by_hand = 3, falling_node = 1, deco_block = 1, not_in_creative_inventory = 1 },
	-- TODO: Make dragon egg teleport on punching
})

minetest.register_craft({
	output = "mcl_end:end_bricks 4",
	recipe = {
		{"mcl_end:end_stone", "mcl_end:end_stone"},
		{"mcl_end:end_stone", "mcl_end:end_stone"},
	}
})

minetest.register_craftitem("mcl_end:ender_eye", {
	description = "Eye of Ender",
	wield_image = "mcl_end_ender_eye.png",
	inventory_image = "mcl_end_ender_eye.png",
	stack_max = 64,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_end:ender_eye",
	recipe = {"mcl_mobitems:blaze_powder", "mcl_throwing:ender_pearl"},
})

