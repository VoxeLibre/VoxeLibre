minetest.register_craftitem("mcl_farming:wheat_seed", {
	description = "Wheat Seeds",
	groups = { craftitem=1 },
	inventory_image = "farming_wheat_seed.png",
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:wheat_1")
	end
})

minetest.register_node("mcl_farming:wheat_1", {
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	drawtype = "nodebox",
	paramtype = "light",
	drop = "mcl_farming:wheat_seed",
	tiles = {"farming_wheat_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.5, -0.3125, 0.375, 0.5}, -- NodeBox1
			{0.3125, -0.5, -0.5, 0.3125, 0.375, 0.5}, -- NodeBox2
			{-0.5, -0.5, 0.375, 0.5, 0.375, 0.375}, -- NodeBox3
			{-0.5, -0.5, -0.25, 0.5, 0.375, -0.25}, -- NodeBox4
		}
	},
})

minetest.register_node("mcl_farming:wheat_2", {
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	drawtype = "nodebox",
	paramtype = "light",
	drop = "mcl_farming:wheat_seed",
	tiles = {"farming_wheat_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.25, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.5, -0.3125, 0.375, 0.5}, -- NodeBox1
			{0.3125, -0.5, -0.5, 0.3125, 0.375, 0.5}, -- NodeBox2
			{-0.5, -0.5, 0.375, 0.5, 0.375, 0.375}, -- NodeBox3
			{-0.5, -0.5, -0.25, 0.5, 0.375, -0.25}, -- NodeBox4
		}
	},
})

minetest.register_node("mcl_farming:wheat_3", {
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	drawtype = "nodebox",
	paramtype = "light",
	drop = "mcl_farming:wheat_seed",
	tiles = {"farming_wheat_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.25, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.5, -0.3125, 0.375, 0.5}, -- NodeBox1
			{0.3125, -0.5, -0.5, 0.3125, 0.375, 0.5}, -- NodeBox2
			{-0.5, -0.5, 0.375, 0.5, 0.375, 0.375}, -- NodeBox3
			{-0.5, -0.5, -0.25, 0.5, 0.375, -0.25}, -- NodeBox4
		}
	},
})

minetest.register_node("mcl_farming:wheat", {
	sunlight_propagates = true,
	paramtype = "light",
	walkable = false,
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"farming_wheat.png"},
	drop = {
		max_items = 4,
		items = {
			{ items = {'mcl_farming:wheat_seed'} },
			{ items = {'mcl_farming:wheat_seed'}, rarity = 2},
			{ items = {'mcl_farming:wheat_seed'}, rarity = 5},
			{ items = {'mcl_farming:wheat_harvested'} }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, 0.35, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, -0.5, -0.3125, 0.375, 0.5}, -- NodeBox1
			{0.3125, -0.5, -0.5, 0.3125, 0.375, 0.5}, -- NodeBox2
			{-0.5, -0.5, 0.375, 0.5, 0.375, 0.375}, -- NodeBox3
			{-0.5, -0.5, -0.25, 0.5, 0.375, -0.25}, -- NodeBox4
		}
	},
})

mcl_farming:add_plant("mcl_farming:wheat", {"mcl_farming:wheat_1", "mcl_farming:wheat_2", "mcl_farming:wheat_3"}, 50, 20)

minetest.register_craftitem("mcl_farming:wheat_harvested", {
	description = "Wheat",
	inventory_image = "farming_wheat_harvested.png",
	groups = { craftitem = 1 },
})

minetest.register_craft({
	output = "mcl_farming:bread",
	recipe = {
		{'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested', 'mcl_farming:wheat_harvested'},
	}
})

minetest.register_craft({
	output = "mcl_farming:cookie 8",
	recipe = {
		{'mcl_farming:wheat_harvested', 'mcl_dye:brown', 'mcl_farming:wheat_harvested'},
	}
})

minetest.register_craftitem("mcl_farming:cookie", {
	description = "Cookie",
	inventory_image = "farming_cookie.png",
	groups = {food=2, eatable=2},
	on_use = minetest.item_eat(2)
})


minetest.register_craftitem("mcl_farming:bread", {
	description = "Bread",
	inventory_image = "farming_bread.png",
	groups = {food=2, eatable=5},
	on_use = minetest.item_eat(5)
})

