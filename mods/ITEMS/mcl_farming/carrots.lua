minetest.register_node("mcl_farming:carrot_1", {
	description = "Premature Carrot Plant (First Stage)",
	_doc_items_entry_name = "Premature Carrot Plant",
	_doc_items_longdesc = "Carrot plants are plants which grow on farmland under sunlight in 4 stages. On hydrated farmland, they grow a bit faster. They can be harvested at any time but will only yield a profit when mature.",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "meshoptions",
	place_param2 = 3,
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
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:carrot_2", {
	description = "Premature Carrot Plant (Second Stage)",
	_doc_items_create_entry = false,
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	drawtype = "plantlike",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	drop = "mcl_farming:carrot_item",
	tiles = {"farming_carrot_2.png"},
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

minetest.register_node("mcl_farming:carrot_3", {
	description = "Premature Carrot Plant (Third Stage)",
	_doc_items_create_entry = false,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "meshoptions",
	place_param2 = 3,
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
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_node("mcl_farming:carrot", {
	description = "Mature Carrot Plant",
	_doc_items_longdesc = "Mature carrot plants are ready to be harvested for carrots. They won't grow any further.",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "meshoptions",
	place_param2 = 3,
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
	groups = {dig_immediate=3, not_in_creative_inventory=1,dig_by_water=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_craftitem("mcl_farming:carrot_item", {
	description = "Carrot",
	_doc_items_longdesc = "Carrots can be eaten and planted. When eaten, a carrot restores 3 hunger points. Pigs and rabbits like carrots.",
	_doc_items_usagehelp = "Hold it in your hand and rightclick to eat it. Place it on top of farmland to plant the carrot. It grows in sunlight and grows faster on hydrated farmland. Rightclick an animal to feed it.",
	inventory_image = "farming_carrot.png",
	groups = { food = 2, eatable = 3 },
	on_secondary_use = minetest.item_eat(3),
	on_place = function(itemstack, placer, pointed_thing)
		local new = mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:carrot_1")
		if new ~= nil then
			return new
		else
			return minetest.do_item_eat(3, nil, itemstack, placer, pointed_thing)
		end
	end,
})

minetest.register_craftitem("mcl_farming:carrot_item_gold", {
	description = "Golden Carrot",
	_doc_items_longdesc = "This is a food item which can be eaten for 6 hunger points.",
	inventory_image = "farming_carrot_gold.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { brewitem = 1, food = 2, eatable = 6 },
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

if minetest.get_modpath("doc") then
	for i=2,3 do
		doc.add_entry_alias("nodes", "mcl_farming:carrot_1", "nodes", "mcl_farming:carrot_"..i)
	end
end
