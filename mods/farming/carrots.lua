minetest.register_node("farming:carrot_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "farming:carrot_item",
	tiles = {"farming_carrot_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,dig_by_water=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:carrot_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "farming:carrot_item",
	tiles = {"farming_carrot_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,dig_by_water=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:carrot_3", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "farming:carrot_item",
	tiles = {"farming_carrot_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,dig_by_water=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_node("farming:carrot", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_carrot_4.png"},
	drop = {
		max_items = 1,
		items = {
			{ items = {'farming:carrot_item 2'} },
			{ items = {'farming:carrot_item 3'}, rarity = 2 },
			{ items = {'farming:carrot_item 4'}, rarity = 5 }
		}
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,dig_by_water=1},
	sounds = default.node_sound_leaves_defaults(),
})

minetest.register_craftitem("farming:carrot_item", {
	description = "Carrot",
	inventory_image = "farming_carrot.png",
	on_use = minetest.item_eat(3),
	on_place = function(itemstack, placer, pointed_thing)
		return farming:place_seed(itemstack, placer, pointed_thing, "farming:carrot_1")
	end
})

minetest.register_craftitem("farming:carrot_item_gold", {
	description = "Golden Carrot",
	inventory_image = "farming_carrot_gold.png",
	on_use = minetest.item_eat(3),
})

minetest.register_craft({
	output = "farming:carrot_item_gold",
	recipe = {
		{'default:gold_lump'},
		{'farming:carrot_item'},
	}
})

farming:add_plant("farming:carrot", {"farming:carrot_1", "farming:carrot_2", "farming:carrot_3"}, 50, 20)
