minetest.register_node("mcl_farming:carrot_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:carrot_item",
	tiles = {"farming_carrot_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:carrot_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:carrot_item",
	tiles = {"farming_carrot_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:carrot_3", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:carrot_item",
	tiles = {"farming_carrot_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:carrot", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_carrot_4.png"},
	drop = {
		max_items = 1,
		items = {
			{ items = {'mcl_farming:carrot_item 4'}, rarity = 5 },
			{ items = {'mcl_farming:carrot_item 3'}, rarity = 2 },
			{ items = {'mcl_farming:carrot_item 2'}, rarity = 2 },
			{ items = {'mcl_farming:carrot_item 1'} },
		}
	},
	groups = {snappy=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_craftitem("mcl_farming:carrot_item", {
	description = "Carrot",
	inventory_image = "farming_carrot.png",
	on_use = minetest.item_eat(3),
	groups = { food = 2, eatable = 3 },
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:carrot_1")
	end
})

minetest.register_craftitem("mcl_farming:carrot_item_gold", {
	description = "Golden Carrot",
	inventory_image = "farming_carrot_gold.png",
	on_use = minetest.item_eat(3),
	groups = { brewitem = 1, food = 2, eatable = 3 },
})

minetest.register_craft({
	output = "mcl_farming:carrot_item_gold",
	recipe = {
		{'mcl_core:gold_nugget', 'mcl_core:gold_nugget', 'mcl_core:gold_nugget'},
		{'mcl_core:gold_nugget', 'mcl_farming:carrot_item', 'mcl_core:gold_nugget'},
		{'mcl_core:gold_nugget', 'mcl_core:gold_nugget', 'mcl_core:gold_nugget'},
	}
})

mcl_farming:add_plant("mcl_farming:carrot", {"mcl_farming:carrot_1", "mcl_farming:carrot_2", "mcl_farming:carrot_3"}, 50, 20)
