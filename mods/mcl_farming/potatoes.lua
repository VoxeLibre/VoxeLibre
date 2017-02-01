minetest.register_node("mcl_farming:potato_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:potato_item",
	tiles = {"farming_potato_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:potato_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:potato_item",
	tiles = {"farming_potato_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:potato", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_potato_3.png"},
	drop = {
		max_items = 1,
		items = {
			{ items = {'mcl_farming:potato_item 2'} },
			{ items = {'mcl_farming:potato_item 3'}, rarity = 2 },
			{ items = {'mcl_farming:potato_item 4'}, rarity = 5 }
		}
	},
	groups = {snappy=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_craftitem("mcl_farming:potato_item", {
	description = "Potato",
	inventory_image = "farming_potato.png",
	on_use = minetest.item_eat(1),
	groups = { food = 2, eatable = 1 },
	stack_max = 64,
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:potato_1")
	end,
})

minetest.register_craftitem("mcl_farming:potato_item_baked", {
	description = "Baked Potato",
	stack_max = 64,
	inventory_image = "farming_potato_baked.png",
	on_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
})

minetest.register_craftitem("mcl_farming:potato_item_poison", {
	description = "Poisonous Potato",
	stack_max = 64,
	inventory_image = "farming_potato_poison.png",
	on_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2 },
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_farming:potato_item_baked",
	recipe = "mcl_farming:potato_item",
	cooktime = 10,
})

mcl_farming:add_plant("mcl_farming:potato", {"mcl_farming:potato_1", "mcl_farming:potato_2"}, 50, 20)
