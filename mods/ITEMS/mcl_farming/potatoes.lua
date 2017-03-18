minetest.register_node("mcl_farming:potato_1", {
	description = "Premature Potato Plant (First Stage)",
	_doc_items_entry_name = "Premature Potato Plant",
	_doc_items_longdesc = "Potato plants are plants which grow on farmland under sunlight in 3 stages. On hydrated farmland, they grow a bit faster. They can be harvested at any time but will only yield a profit when mature.",
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
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
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:potato_2", {
	description = "Premature Potato Plant (Second Stage)",
	_doc_items_create_entry = false,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
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
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:potato", {
	description = "Mature Potato Plant",
	_doc_items_longdesc = "Mature potato plants are ready to be harvested for potatoes. They won't grow any further.",
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"farming_potato_3.png"},
	drop = {
		items = {
			{ items = {'mcl_farming:potato_item 1'} },
			{ items = {'mcl_farming:potato_item 1'}, rarity = 2 },
			{ items = {'mcl_farming:potato_item 1'}, rarity = 2 },
			{ items = {'mcl_farming:potato_item 1'}, rarity = 2 },
			{ items = {'mcl_farming:potato_item_poison 1'}, rarity = 50 }
		}
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_craftitem("mcl_farming:potato_item", {
	description = "Potato",
	_doc_items_longdesc = "Potatoes are food items which can be eaten, cooked in the furnace and planted. Eating a potato restores 1 hunger point. Pigs like potatoes.",
	_doc_items_usagehelp = "Hold it in your hand and rightclick to eat it. Place it on top of farmland to plant it. It grows in sunlight and grows faster on hydrated farmland. Rightclick an animal to feed it.",
	inventory_image = "farming_potato.png",
	groups = { food = 2, eatable = 1 },
	stack_max = 64,
	on_secondary_use = minetest.item_eat(1),
	on_place = function(itemstack, placer, pointed_thing)
		local new = mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:potato_1")
		if new ~= nil then
			return new
		else
			return minetest.do_item_eat(1, nil, itemstack, placer, pointed_thing)
		end
	end,
})

minetest.register_craftitem("mcl_farming:potato_item_baked", {
	description = "Baked Potato",
	_doc_items_longdesc = "Baked potatoes are foot items which can be eaten for 6 hunger points.",
	stack_max = 64,
	inventory_image = "farming_potato_baked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
})

minetest.register_craftitem("mcl_farming:potato_item_poison", {
	description = "Poisonous Potato",
	_doc_items_longdesc = "This potato doesn't look healthy. Eating it will only poison you.",
	stack_max = 64,
	inventory_image = "farming_potato_poison.png",
	-- TODO: Cause status effects
	-- TODO: Raise to 2
	on_place = minetest.item_eat(0),
	on_secondary_use = minetest.item_eat(0),
	groups = { food = 2, eatable = 0 },
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_farming:potato_item_baked",
	recipe = "mcl_farming:potato_item",
	cooktime = 10,
})

mcl_farming:add_plant("mcl_farming:potato", {"mcl_farming:potato_1", "mcl_farming:potato_2"}, 50, 20)
