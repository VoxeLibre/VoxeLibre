minetest.register_craftitem("mcl_farming:beetroot_seeds", {
	description = "Beetroot Seeds",
	_doc_items_longdesc = "Grows into a beetroot plant. Chickens like beetroot seeds.",
	_doc_items_usagehelp = "Place the beetroot seeds on farmland (which can be created with a hoe) to plant a beetroot plant. They grow in sunlight and grow faster on hydrated farmland. Rightclick an animal to feed it beetroot seeds.",
	groups = { craftitem=1 },
	inventory_image = "mcl_farming_beetroot_seeds.png",
	wield_image = "mcl_farming_beetroot_seeds.png",
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:beetroot_0")
	end
})

minetest.register_node("mcl_farming:beetroot_0", {
	description = "Premature Beetroot Plant (First Stage)",
	_doc_items_longdesc = "Beetroot plants are plants which grow on farmland under sunlight in 4 stages. On hydrated farmland, they grow a bit faster. They can be harvested at any time but will only yield a profit when mature.",
	_doc_items_entry_name = "Premature Beetroot Plant",
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:beetroot_seeds",
	tiles = {"mcl_farming_beetroot_0.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:beetroot_1", {
	description = "Premature Beetroot Plant (Second Stage)",
	_doc_items_create_entry = false,
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:beetroot_seeds",
	tiles = {"mcl_farming_beetroot_1.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:beetroot_2", {
	description = "Premature Beetroot Plant (Third Stage)",
	_doc_items_create_entry = false,
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	drop = "mcl_farming:beetroot_seeds",
	tiles = {"farming_carrot_2.png"},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -0.125, 0.5}
		},
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:beetroot", {
	description = "Mature Beetroot Plant",
	_doc_items_longdesc = "A mature beetroot plant is a farming plant which is ready to be harvested for a beetroot and some beetroot seeds. It won't grow any further.",
	_doc_items_create_entry = true,
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
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
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_craftitem("mcl_farming:beetroot_item", {
	description = "Beetroot",
	_doc_items_longdesc = "Beetroots can be eaten for 1 hunger point. Pigs like beetroots, too.",
	_doc_items_usagehelp = "Hold it in your hand and right-click to eat it. Rightclick an animal to feed it.",
	inventory_image = "mcl_farming_beetroot.png",
	wield_image = "mcl_farming_beetroot.png",
	on_place = minetest.item_eat(1),
	on_secondary_use = minetest.item_eat(1),
	groups = { food = 2, eatable = 1 },
})

minetest.register_craftitem("mcl_farming:beetroot_soup", {
	description = "Beetroot Soup",
	_doc_items_longdesc = "Beetroot soup is a healthy soup which can be consumed for 6 hunger points.",
	stack_max = 1,
	inventory_image = "mcl_farming_beetroot_soup.png",
	wield_image = "mcl_farming_beetroot_soup.png",
	on_place = minetest.item_eat(6, "mcl_core:bowl"),
	on_secondary_use = minetest.item_eat(6, "mcl_core:bowl"),
	groups = { food = 3, eatable = 6 },
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

if minetest.get_modpath("doc") then
	for i=1,2 do
		doc.add_entry_alias("nodes", "mcl_farming:beetroot_0", "nodes", "mcl_farming:beetroot_"..i)
	end
end
