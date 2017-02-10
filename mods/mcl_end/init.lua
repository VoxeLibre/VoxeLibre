-- Nodes
minetest.register_node("mcl_end:end_stone", {
	description = "End Stone",
	tiles = {"mcl_end_end_stone.png"},
	stack_max = 64,
	groups = {cracky=2,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_end:end_bricks", {
	description = "End Stone Bricks",
	tiles = {"mcl_end_end_bricks.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=3,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_end:purpur_block", {
	description = "Purpur Block",
	tiles = {"mcl_end_purpur_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {cracky=3,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_node("mcl_end:purpur_pillar", {
	description = "Purpur Pillar",
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = false,
	tiles = {"mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar.png"},
	groups = {cracky=3,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

local rod_box = {
	type = "wallmounted",
	wall_top = {-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
	wall_side = {-0.5, -0.125, -0.125, 0.5, 0.125, 0.125},
	wall_bottom = {-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
}
minetest.register_node("mcl_end:end_rod", {
	description = "End Rod",
	tiles = {
		"mcl_end_end_rod_top.png",
		"mcl_end_end_rod_bottom.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
		"mcl_end_end_rod_side.png",
	},
	drawtype = "nodebox",
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "wallmounted",
	light_source = 14,
	sunlight_propagates = true,
	groups = { dig_immediate=3, deco_block=1 },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, -0.4375, 0.125}, -- Base
			{-0.0625, -0.4375, -0.0625, 0.0625, 0.5, 0.0625}, -- Rod
		},
	},
	selection_box = rod_box,
	-- FIXME: Collision box does not seem to rotate correctly
	collision_box = rod_box,
	sounds = mcl_core.node_sound_glass_defaults(),
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
	is_ground_content = false,
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
	selection_box = {
		type = "regular",
	},
	groups = { oddly_breakable_by_hand = 3, falling_node = 1, deco_block = 1, not_in_creative_inventory = 1 },
	sounds = mcl_core.node_sound_stone_defaults(),
	-- TODO: Make dragon egg teleport on punching
})

local chorus_flower_box = {
	type = "fixed",
	fixed = {
		{-0.5, -0.375, -0.375, 0.5, 0.375, 0.375},
		{-0.375, -0.375, 0.375, 0.375, 0.375, 0.5},
		{-0.375, -0.375, -0.5, 0.375, 0.375, -0.375},
		{-0.375, 0.375, -0.375, 0.375, 0.5, 0.375},
		{-0.375, -0.5, -0.375, 0.375, -0.375, 0.375},
	}
}

minetest.register_node("mcl_end:chorus_flower", {
	description = "Chorus Flower",
	tiles = {
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
		"mcl_end_chorus_flower.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = chorus_flower_box,
	sounds = mcl_core.node_sound_wood_defaults(),
	groups = { oddly_breakable_by_hand = 3, choppy = 3, deco_block = 1 },
})

minetest.register_node("mcl_end:chorus_flower_dead", {
	description = "Dead Chorus Flower",
	tiles = {
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
		"mcl_end_chorus_flower_dead.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	node_box = chorus_flower_box,
	sounds = mcl_core.node_sound_wood_defaults(),
	drop = "mcl_end:chorus_flower",
	groups = { oddly_breakable_by_hand = 3, choppy = 3, deco_block = 1},
})

minetest.register_node("mcl_end:chorus_plant", {
	description = "Chorus Plant",
	tiles = {
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
		"mcl_end_chorus_plant.png",
	},
	drawtype = "nodebox",
	paramtype = "light",
	-- TODO: Maybe improve nodebox a bit to look more “natural”
	node_box = {
		type = "connected",
		fixed = { -0.25, -0.25, -0.25, 0.25, 0.25, 0.25 }, -- Core
		connect_top = { -0.1875, 0.25, -0.1875, 0.1875, 0.5, 0.1875 },
		connect_left = { -0.5, -0.1875, -0.1875, -0.25, 0.1875, 0.1875 },
		connect_right = { 0.25, -0.1875, -0.1875, 0.5, 0.1875, 0.1875 },
		connect_bottom = { -0.1875, -0.5, -0.25, 0.1875, -0.25, 0.25 },
		connect_front = { -0.1875, -0.1875, -0.5, 0.1875, 0.1875, -0.25 },
		connect_back = { -0.1875, -0.1875, 0.25, 0.1875, 0.1875, 0.5 },
	},
	connect_sides = { "top", "bottom", "front", "back", "left", "right" },
	connects_to = {"mcl_end:chorus_plant", "mcl_end:chorus_flower", "mcl_end:chorus_flower_dead", "mcl_end:end_stone"},
	sounds = mcl_core.node_sound_wood_defaults(),
	-- TODO: Check drop probability
	drop = { items = { {items = { "mcl_end:chorus_fruit", rarity = 4 } } } },
	groups = { oddly_breakable_by_hand = 3, choppy = 3, not_in_creative_inventory = 1,},
})

-- Craftitems
minetest.register_craftitem("mcl_end:chorus_fruit", {
	description = "Chorus Fruit",
	wield_image = "mcl_end_chorus_fruit.png",
	inventory_image = "mcl_end_chorus_fruit.png",
	-- TODO: Teleport player
	on_use = minetest.item_eat(4),
	groups = { food = 2, eatable = 4 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_end:chorus_fruit_popped", {
	description = "Popped Chorus Fruit",
	wield_image = "mcl_end_chorus_fruit_popped.png",
	inventory_image = "mcl_end_chorus_fruit_popped.png",
	groups = { craftitem = 1 },
	stack_max = 64,
})

minetest.register_craftitem("mcl_end:ender_eye", {
	description = "Eye of Ender",
	wield_image = "mcl_end_ender_eye.png",
	inventory_image = "mcl_end_ender_eye.png",
	stack_max = 64,
})


-- Crafting recipes
minetest.register_craft({
	output = "mcl_end:end_bricks 4",
	recipe = {
		{"mcl_end:end_stone", "mcl_end:end_stone"},
		{"mcl_end:end_stone", "mcl_end:end_stone"},
	}
})

minetest.register_craft({
	output = "mcl_end:purpur_block 4",
	recipe = {
		{"mcl_end:chorus_fruit_popped", "mcl_end:chorus_fruit_popped",},
		{"mcl_end:chorus_fruit_popped", "mcl_end:chorus_fruit_popped",},
	}
})

minetest.register_craft({
	output = "mcl_end:end_rod 4",
	recipe = {
		{"mcl_mobitems:blaze_rod"},
		{"mcl_end:chorus_fruit_popped"},
	},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_end:ender_eye",
	recipe = {"mcl_mobitems:blaze_powder", "mcl_throwing:ender_pearl"},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_end:chorus_fruit_popped",
	recipe = "mcl_end:chorus_fruit",
	cooktime = 10,
})

