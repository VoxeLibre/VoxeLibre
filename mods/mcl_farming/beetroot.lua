minetest.register_craftitem("mcl_farming:beetroot_seeds", {
	description = "Beetroot Seeds",
	groups = { craftitem=1 },
	inventory_image = "mcl_farming_beetroot_seeds.png",
	wield_image = "mcl_farming_beetroot_seeds.png",
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:beetroot_0")
	end
})

minetest.register_node("mcl_farming:beetroot_0", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = "",
	tiles = {"mcl_farming_beetroot_0.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:beetroot_1", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = {
		items = {
			{ items = {"mcl_farming:beetroot_seeds"}, rarity = 5 },
		},
	},
	tiles = {"mcl_farming_beetroot_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:beetroot_2", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = {
		items = {
			{ items = {"mcl_farming:beetroot_seeds"}, rarity = 4 },
		},
	},
	tiles = {"farming_carrot_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:beetroot", {
	paramtype = "light",
	walkable = false,
	drawtype = "plantlike",
	drop = {
		max_items = 2,
		items = {
			{ items = {"mcl_farming:beetroot_item"}, rarity = 1 },
			{ items = {"mcl_farming:beetroot_seeds 3"}, rarity = 4 },
			{ items = {"mcl_farming:beetroot_seeds 2"}, rarity = 4 },
			{ items = {"mcl_farming:beetroot_seeds 1"}, rarity = 4 },
		},
	},
	tiles = {"mcl_farming_beetroot_3.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_core.node_sound_leaves_defaults(),
})

minetest.register_craftitem("mcl_farming:beetroot_item", {
	description = "Beetroot",
	inventory_image = "mcl_farming_beetroot.png",
	wield_image = "mcl_farming_beetroot.png",
	on_use = minetest.item_eat(1),
	groups = { food = 2, eatable = 1 },
})

minetest.register_craftitem("mcl_farming:beetroot_soup", {
	description = "Beetroot Soup",
	stack_max = 1,
	inventory_image = "mcl_farming_beetroot_soup.png",
	wield_image = "mcl_farming_beetroot_soup.png",
	on_use = minetest.item_eat(6, "mcl_core:bowl"),
	groups = { food = 1, eatable = 6 },
})

minetest.register_craft({
	output = "mcl_farming:beetroot_soup",
	recipe = {
		{ "mcl_farming:beetroot_item","mcl_farming:beetroot_item","mcl_farming:beetroot_item", },
		{ "mcl_farming:beetroot_item","mcl_farming:beetroot_item","mcl_farming:beetroot_item", },
		{ "", "mcl_core:bowl", "" },
	},
})

mcl_farming:add_plant("mcl_farming:beetroot", {"mcl_farming:beetroot_0", "mcl_farming:beetroot_1", "mcl_farming:beetroot_2"}, 68, 3)
