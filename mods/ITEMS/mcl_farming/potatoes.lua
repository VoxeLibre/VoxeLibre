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
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
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
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
})

minetest.register_node("mcl_farming:potato", {
	paramtype = "light",
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
})

minetest.register_craftitem("mcl_farming:potato_item", {
	description = "Potato",
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
	stack_max = 64,
	inventory_image = "farming_potato_baked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
})

minetest.register_craftitem("mcl_farming:potato_item_poison", {
	description = "Poisonous Potato",
	stack_max = 64,
	inventory_image = "farming_potato_poison.png",
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2 },
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_farming:potato_item_baked",
	recipe = "mcl_farming:potato_item",
	cooktime = 10,
})

mcl_farming:add_plant("mcl_farming:potato", {"mcl_farming:potato_1", "mcl_farming:potato_2"}, 50, 20)
