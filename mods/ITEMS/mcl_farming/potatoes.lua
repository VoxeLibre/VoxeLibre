-- Premature potato plants

for i=1, 7 do
	local texture, selbox
	if i < 3 then
		texture = "mcl_farming_potatoes_stage_0.png"
		selbox = { -0.5, -0.5, -0.5, 0.5, -5/16, 0.5 }
	elseif i < 5 then
		texture = "mcl_farming_potatoes_stage_1.png"
		selbox = { -0.5, -0.5, -0.5, 0.5, -2/16, 0.5 }
	else
		texture = "mcl_farming_potatoes_stage_2.png"
		selbox = { -0.5, -0.5, -0.5, 0.5, 2/16, 0.5 }
	end

	local create, name, longdesc
	if i==1 then
		create = true
		name = "Premature Potato Plant"
		longdesc = "Potato plants are plants which grow on farmland under sunlight in 8 stages, of which only 4 are actually visible. On hydrated farmland, they grow a bit faster. They can be harvested at any time but will only yield a profit when mature."
	else
		create = false
		if minetest.get_modpath("doc") then
			doc.add_entry_alias("nodes", "mcl_farming:potato_1", "nodes", "mcl_farming:potato_"..i)
		end
	end

	minetest.register_node("mcl_farming:potato_"..i, {
		description = string.format("Premature Potato Plant (Stage %d)", i),
		_doc_items_create_entry = create,
		_doc_items_entry_name = name,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		paramtype2 = "meshoptions",
		sunlight_propagates = true,
		place_param2 = 3,
		walkable = false,
		drawtype = "plantlike",
		drop = "mcl_farming:potato_item",
		tiles = { texture },
		selection_box = {
			type = "fixed",
			fixed = { selbox },
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
	})
end

-- Mature plant
minetest.register_node("mcl_farming:potato", {
	description = "Mature Potato Plant",
	_doc_items_longdesc = "Mature potato plants are ready to be harvested for potatoes. They won't grow any further.",
	paramtype = "light",
	paramtype2 = "meshoptions",
	sunlight_propagates = true,
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"mcl_farming_potatoes_stage_3.png"},
	drop = {
		items = {
			{ items = {'mcl_farming:potato_item 1'} },
			{ items = {'mcl_farming:potato_item 1'}, rarity = 2 },
			{ items = {'mcl_farming:potato_item 1'}, rarity = 2 },
			{ items = {'mcl_farming:potato_item 1'}, rarity = 2 },
			{ items = {'mcl_farming:potato_item_poison 1'}, rarity = 50 }
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{ -0.5, -0.5, -0.5, 0.5, 1/16, 0.5 }
		}
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
})

minetest.register_craftitem("mcl_farming:potato_item", {
	description = "Potato",
	_doc_items_longdesc = "Potatoes are food items which can be eaten, cooked in the furnace and planted. Eating a potato restores 1 hunger point. Pigs like potatoes.",
	_doc_items_usagehelp = "Hold it in your hand and rightclick to eat it. Place it on top of farmland to plant it. It grows in sunlight and grows faster on hydrated farmland. Rightclick an animal to feed it.",
	inventory_image = "farming_potato.png",
	groups = { food = 2, eatable = 1 },
	_mcl_saturation = 0.6,
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
	_doc_items_longdesc = "Baked potatoes are food items which can be eaten for 6 hunger points.",
	stack_max = 64,
	inventory_image = "farming_potato_baked.png",
	on_place = minetest.item_eat(6),
	on_secondary_use = minetest.item_eat(6),
	groups = { food = 2, eatable = 6 },
	_mcl_saturation = 6.0,
})

minetest.register_craftitem("mcl_farming:potato_item_poison", {
	description = "Poisonous Potato",
	_doc_items_longdesc = "This potato doesn't look too healthy. You can eat it for 2 hunger points, but there's a 60% chance it will poison you.",
	stack_max = 64,
	inventory_image = "farming_potato_poison.png",
	-- TODO: Cause status effects
	on_place = minetest.item_eat(2),
	on_secondary_use = minetest.item_eat(2),
	groups = { food = 2, eatable = 2 },
	_mcl_saturation = 1.2,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_farming:potato_item_baked",
	recipe = "mcl_farming:potato_item",
	cooktime = 10,
})

mcl_farming:add_plant("plant_potato", "mcl_farming:potato", {"mcl_farming:potato_1", "mcl_farming:potato_2", "mcl_farming:potato_3", "mcl_farming:potato_4", "mcl_farming:potato_5", "mcl_farming:potato_6", "mcl_farming:potato_7"}, 19.75, 20)


