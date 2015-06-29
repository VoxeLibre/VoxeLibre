minetest.register_craftitem("farming:wheat_seed", {
	description = "Wheat Seeds",
	inventory_image = "farming_wheat_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		return farming:place_seed(itemstack, placer, pointed_thing, "farming:wheat_1")
	end
})

minetest.register_node("farming:wheat_1", {
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	drop = "farming:wheat_seed",
	tiles = {"farming_wheat_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,dig_by_water=1},
})

minetest.register_node("farming:wheat_2", {
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "farming:wheat_seed",
	tiles = {"farming_wheat_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,dig_by_water=1},
})

minetest.register_node("farming:wheat_3", {
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "farming:wheat_seed",
	tiles = {"farming_wheat_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.25, 0.5}
		},
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,dig_by_water=1},
})

minetest.register_node("farming:wheat", {
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_wheat.png"},
	drop = {
		max_items = 4,
		items = {
			{ items = {'farming:wheat_seed'} },
			{ items = {'farming:wheat_seed'}, rarity = 2},
			{ items = {'farming:wheat_seed'}, rarity = 5},
			{ items = {'farming:wheat_harvested'} }
		}
	},
	groups = {snappy=3, flammable=2, not_in_creative_inventory=1,dig_by_water=1},
})

farming:add_plant("farming:wheat", {"farming:wheat_1", "farming:wheat_2", "farming:wheat_3"}, 50, 20)

minetest.register_craftitem("farming:wheat_harvested", {
	description = "Harvested Wheat",
	inventory_image = "farming_wheat_harvested.png",
})

minetest.register_craft({
	output = "farming:bread",
	recipe = {
		{'farming:wheat_harvested', 'farming:wheat_harvested', 'farming:wheat_harvested'},
	}
})

minetest.register_craft({
	output = "farming:cookie",
	recipe = {
		{'farming:wheat_harvested', 'dye:brown', 'farming:wheat_harvested'},
	}
})

minetest.register_craftitem("farming:cookie", {
	description = "Cookie",
	inventory_image = "farming_cookie.png",
	groups = {food=2},
	on_use = minetest.item_eat(2)
})


minetest.register_craftitem("farming:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	groups = {food=2},
	on_use = minetest.item_eat(5)
})

-- ========= FUEL =========
minetest.register_craft({
	type = "fuel",
	recipe = "farming:wheat_seed",
	burntime = 1
})

minetest.register_craft({
	type = "fuel",
	recipe = "farming:wheat_harvested",
	burntime = 2
})
