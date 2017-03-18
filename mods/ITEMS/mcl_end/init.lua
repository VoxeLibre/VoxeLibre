-- Nodes
minetest.register_node("mcl_end:end_stone", {
	description = "End Stone",
	tiles = {"mcl_end_end_stone.png"},
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 45,
	_mcl_hardness = 3,
})

minetest.register_node("mcl_end:end_bricks", {
	description = "End Stone Bricks",
	tiles = {"mcl_end_end_bricks.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4,
	_mcl_hardness = 0.8,
})

minetest.register_node("mcl_end:purpur_block", {
	description = "Purpur Block",
	tiles = {"mcl_end_purpur_block.png"},
	is_ground_content = false,
	stack_max = 64,
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_end:purpur_pillar", {
	description = "Purpur Pillar",
	stack_max = 64,
	paramtype2 = "facedir",
	is_ground_content = false,
	on_place = mcl_util.rotate_axis,
	tiles = {"mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar_top.png", "mcl_end_purpur_pillar.png"},
	groups = {pickaxey=1, building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 30,
	_mcl_hardness = 1.5,
})

minetest.register_node("mcl_end:end_rod", {
	description = "End Rod",
	_doc_items_longdesc = "End rods are decorational light sources.",
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
	paramtype2 = "facedir",
	light_source = 14,
	sunlight_propagates = true,
	groups = { dig_immediate=3, deco_block=1, },
	node_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, -0.4375, 0.125}, -- Base
			{-0.0625, -0.4375, -0.0625, 0.0625, 0.5, 0.0625}, -- Rod
		},
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125}, -- Base
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:getpos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = minetest.dir_to_facedir(dir)
		end

		if p0.y - 1 == p1.y then
			param2 = 20
		elseif p0.x - 1 == p1.x then
			param2 = 16
		elseif p0.x + 1 == p1.x then
			param2 = 12
		elseif p0.z - 1 == p1.z then
			param2 = 8
		elseif p0.z + 1 == p1.z then
			param2 = 4
		end

		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,

	sounds = mcl_sounds.node_sound_glass_defaults(),
	_mcl_blast_resistance = 0,
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
	groups = {handy=1, falling_node = 1, deco_block = 1, not_in_creative_inventory = 1, },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 45,
	_mcl_hardness = 3,
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
	selection_box = { type = "regular" },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	groups = {handy=1,axey=1, deco_block = 1, },
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
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
	selection_box = { type = "regular" },
	sounds = mcl_sounds.node_sound_wood_defaults(),
	drop = "mcl_end:chorus_flower",
	groups = {handy=1,axey=1, deco_block = 1, },
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
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
	sounds = mcl_sounds.node_sound_wood_defaults(),
	-- TODO: Check drop probability
	drop = { items = { {items = { "mcl_end:chorus_fruit", rarity = 4 } } } },
	groups = {handy=1,axey=1, not_in_creative_inventory = 1, },
	_mcl_blast_resistance = 2,
	_mcl_hardness = 0.4,
})

-- Craftitems
minetest.register_craftitem("mcl_end:chorus_fruit", {
	description = "Chorus Fruit",
	_doc_items_longdesc = "Chorus fruits can be eaten to restore 4 hunger points.",
	wield_image = "mcl_end_chorus_fruit.png",
	inventory_image = "mcl_end_chorus_fruit.png",
	-- TODO: Teleport player
	on_place = minetest.item_eat(4),
	on_secondary_use = minetest.item_eat(4),
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

