local S = core.get_translator(core.get_current_modname())

core.register_craftitem("mcl_farming:wheat_seeds", {
	-- Original Minecraft name: “Seeds”
	description = S("Wheat Seeds"),
	_tt_help = S("Grows on farmland"),
	_doc_items_longdesc = S("Grows into a wheat plant. Chickens like wheat seeds."),
	_doc_items_usagehelp = S("Place the wheat seeds on farmland (which can be created with a hoe) to plant a wheat plant.").."\n"..
		                   S("They grow in sunlight and grow faster on hydrated farmland. Rightclick an animal to feed it wheat seeds."),
	groups = {craftitem = 1, compostability = 30},
	inventory_image = "mcl_farming_wheat_seeds.png",
	on_place = function(itemstack, placer, pointed_thing)
		return mcl_farming:place_seed(itemstack, placer, pointed_thing, "mcl_farming:wheat_1")
	end
})

local sel_heights = {
	-5/16,
	-2/16,
	0,
	3/16,
	5/16,
	6/16,
	7/16,
}

for i=1,7 do
	local create, name, longdesc
	if i == 1 then
		create = true
		name = S("Premature Wheat Plant")
		longdesc = S("Premature wheat plants grow on farmland under sunlight in 8 stages.").."\n"..
		           S("On hydrated farmland, they grow faster. They can be harvested at any time but will only yield a profit when mature.")
	else
		create = false
	end

	core.register_node("mcl_farming:wheat_"..i, {
		description = S("Premature Wheat Plant (Stage @1)", i),
		_doc_items_create_entry = create,
		_doc_items_entry_name = name,
		_doc_items_longdesc = longdesc,
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 3,
		sunlight_propagates = true,
		walkable = false,
		drawtype = "plantlike",
		drop = "mcl_farming:wheat_seeds",
		tiles = {"mcl_farming_wheat_stage_"..(i-1)..".png"},
		inventory_image = "mcl_farming_wheat_stage_"..(i-1)..".png",
		wield_image = "mcl_farming_wheat_stage_"..(i-1)..".png",
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.5, -0.5, -0.5, 0.5, sel_heights[i], 0.5}
			},
		},
		groups = {dig_immediate=3, not_in_creative_inventory=1, plant=1,attached_node=1,
			dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1},
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
		_on_bone_meal = function(itemstack, placer, pointed_thing)
			local pos = pointed_thing.under
			local n = core.get_node(pos)
			local stages = math.random(2, 5)
			return mcl_farming:grow_plant("plant_wheat", pos, n, stages, true)
		end
	})
end

core.register_node("mcl_farming:wheat", {
	description = S("Mature Wheat Plant"),
	_doc_items_longdesc = S("Mature wheat plants are ready to be harvested for wheat and wheat seeds.").."\n"..
		                  S("They won't grow any further."),
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "meshoptions",
	place_param2 = 3,
	walkable = false,
	drawtype = "plantlike",
	tiles = {"mcl_farming_wheat_stage_7.png"},
	inventory_image = "mcl_farming_wheat_stage_7.png",
	wield_image = "mcl_farming_wheat_stage_7.png",
	drop = {
		max_items = 4,
		items = {
			{ items = {"mcl_farming:wheat_seeds"} },
			{ items = {"mcl_farming:wheat_seeds"}, rarity = 2},
			{ items = {"mcl_farming:wheat_seeds"}, rarity = 5},
			{ items = {"mcl_farming:wheat_item"} }
		}
	},
	groups = {dig_immediate=3, not_in_creative_inventory=1, plant=1, attached_node=1,
		dig_by_water=1,destroy_by_lava_flow=1, dig_by_piston=1},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	_mcl_blast_resistance = 0,
	_mcl_fortune_drop = {
		discrete_uniform_distribution = true,
		items = {"mcl_farming:wheat_seeds"},
		drop_without_fortune = {"mcl_farming:wheat_item"},
		min_count = 1,
		max_count = 6,
		cap = 7
	}
})

mcl_farming:add_plant("plant_wheat", "mcl_farming:wheat", {"mcl_farming:wheat_1", "mcl_farming:wheat_2", "mcl_farming:wheat_3", "mcl_farming:wheat_4", "mcl_farming:wheat_5", "mcl_farming:wheat_6", "mcl_farming:wheat_7"}, 5.8020, 35)

core.register_craftitem("mcl_farming:wheat_item", {
	description = S("Wheat"),
	_doc_items_longdesc = S("Wheat is used in crafting. Some animals like wheat."),
	_doc_items_usagehelp = S("Use the “Place” key on an animal to try to feed it wheat."),
	inventory_image = "farming_wheat_harvested.png",
	groups = {craftitem = 1, compostability = 65},
})

core.register_craft({
	output = "mcl_farming:bread",
	recipe = {
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item"},
	}
})

core.register_craft({
	output = "mcl_farming:cookie 8",
	recipe = {
		{"mcl_farming:wheat_item", "mcl_cocoas:cocoa_beans", "mcl_farming:wheat_item"},
	}
})

core.register_craftitem("mcl_farming:cookie", {
	description = S("Cookie"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	inventory_image = "farming_cookie.png",
	groups = {food = 2, eatable = 2, compostability = 85},
	_mcl_saturation = 0.4,
	on_place = core.item_eat(2),
	on_secondary_use = core.item_eat(2),
})


core.register_craftitem("mcl_farming:bread", {
	description = S("Bread"),
	_doc_items_longdesc = S("This is a food item which can be eaten."),
	inventory_image = "farming_bread.png",
	groups = {food = 2, eatable = 5, compostability = 85},
	_mcl_saturation = 6.0,
	on_place = core.item_eat(5),
	on_secondary_use = core.item_eat(5),
})

local mod_screwdriver = core.get_modpath("screwdriver")
local on_rotate
if mod_screwdriver then
	on_rotate = screwdriver.rotate_3way
end

core.register_node("mcl_farming:hay_block", {
	description = S("Hay Bale"),
	_doc_items_longdesc = S("Hay bales are decorative blocks made from wheat."),
	tiles = {"mcl_farming_hayblock_top.png", "mcl_farming_hayblock_top.png", "mcl_farming_hayblock_side.png"},
	is_ground_content = false,
	stack_max = 64,
	paramtype2 = "facedir",
	on_place = mcl_util.rotate_axis,
	groups = {
		handy = 1, hoey = 1, building_block = 1, fall_damage_add_percent = -80,
		flammable = 2, fire_encouragement = 60, fire_flammability = 20,
		compostability = 85
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	on_rotate = on_rotate,
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
})

core.register_craft({
	output = "mcl_farming:hay_block",
	recipe = {
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item"},
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item"},
		{"mcl_farming:wheat_item", "mcl_farming:wheat_item", "mcl_farming:wheat_item"},
	}
})

core.register_craft({
	output = "mcl_farming:wheat_item 9",
	recipe = {
		{"mcl_farming:hay_block"},
	}
})

if core.get_modpath("doc") then
	for i=2,7 do
		doc.add_entry_alias("nodes", "mcl_farming:wheat_1", "nodes", "mcl_farming:wheat_"..i)
	end
end
