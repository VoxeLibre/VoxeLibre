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
	recipe = {"mcl_mobitems:blaze_powder", "mcl_ender_pearl:ender_pearl"},
})

