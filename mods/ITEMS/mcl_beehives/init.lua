------------------
---- Beehives ----
------------------

-- Variables
local S = minetest.get_translator(minetest.get_current_modname())

-- Function to allow harvesting honey and honeycomb from the beehive and bee nest.
local honey_harvest = function(pos, node, player, itemstack, pointed_thing)
	local inv = player:get_inventory()
	local beehive = "mcl_beehives:beehive"

	if node.name == "mcl_beehives:beehive_5" then
		beehive = "mcl_beehives:beehive"
	elseif node.name == "mcl_beehives:bee_nest_5" then
		beehive = "mcl_beehives:bee_nest"
	end

	if player:get_wielded_item():get_name() == "mcl_potions:glass_bottle" then
		local honey = "mcl_honey:honey_bottle"
		if inv:room_for_item("main", honey) then
			node.name = beehive
			minetest.set_node(pos, node)
			inv:add_item("main", "mcl_honey:honey_bottle")
			if not minetest.is_creative_enabled(player:get_player_name()) then
				itemstack:take_item()
			end
		end
	elseif player:get_wielded_item():get_name() == "mcl_tools:shears" then
		minetest.add_item(pos, "mcl_honey:honeycomb 3")
		node.name = beehive
		minetest.set_node(pos, node)
	end
end

-- Beehive
minetest.register_node("mcl_beehives:beehive", {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, beehive = 1 },
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
})

for l = 1, 4 do
	minetest.register_node("mcl_beehives:beehive_" .. l, {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, not_in_creative_inventory = 1, beehive = 1 },
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
	drops = "mcl_beehives:beehive",
	})
end

minetest.register_node("mcl_beehives:beehive_5", {
	description = S("Beehive"),
	_doc_items_longdesc = S("Artificial bee nest."),
	tiles = {
		"mcl_beehives_beehive_end.png", "mcl_beehives_beehive_end.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_side.png",
		"mcl_beehives_beehive_side.png", "mcl_beehives_beehive_front_honey.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 5, material_wood = 1, not_in_creative_inventory = 1, beehive = 1 },
	_mcl_blast_resistance = 0.6,
	_mcl_hardness = 0.6,
	drops = "mcl_beehives:beehive",
	on_rightclick = honey_harvest,
})

-- Bee Nest
minetest.register_node("mcl_beehives:bee_nest", {
	description = S("Bee Nest"),
	_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
	tiles = {
		"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, bee_nest = 1 },
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
})

for i = 1, 4 do
	minetest.register_node("mcl_beehives:bee_nest_"..i, {
		description = S("Bee Nest"),
		_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
		tiles = {
			"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
			"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
			"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front.png",
		},
		paramtype2 = "facedir",
		groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, not_in_creative_inventory = 1, bee_nest = 1 },
		_mcl_blast_resistance = 0.3,
		_mcl_hardness = 0.3,
		drops = "mcl_beehives:bee_nest",
	})
end

minetest.register_node("mcl_beehives:bee_nest_5", {
	description = S("Bee Nest"),
	_doc_items_longdesc = S("A naturally generating block that houses bees and a tasty treat...if you can get it."),
	tiles = {
		"mcl_beehives_bee_nest_top.png", "mcl_beehives_bee_nest_bottom.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_side.png",
		"mcl_beehives_bee_nest_side.png", "mcl_beehives_bee_nest_front_honey.png",
	},
	paramtype2 = "facedir",
	groups = { axey = 1, deco_block = 1, flammable = 0, fire_flammability = 30, not_in_creative_inventory = 1, bee_nest = 1 },
	_mcl_blast_resistance = 0.3,
	_mcl_hardness = 0.3,
	drops = "mcl_beehives:bee_nest",
	on_rightclick = honey_harvest,
})

-- Crafting
minetest.register_craft({
	output = "mcl_beehives:beehive",
	recipe = {
		{ "group:wood", "group:wood", "group:wood" },
		{ "mcl_honey:honeycomb", "mcl_honey:honeycomb", "mcl_honey:honeycomb" },
		{ "group:wood", "group:wood", "group:wood" },
	},
})

-- Temporary ABM to update honey levels
minetest.register_abm({
	label = "Update Beehive Honey Levels",
	nodenames = "group:beehive",
	interval = 500,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local beehive = "mcl_beehives:beehive"
		if node.name == beehive then
			node.name = beehive.."_1"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_1" then
			node.name = beehive.."_2"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_2" then
			node.name = beehive.."_3"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_3" then
			node.name = beehive.."_4"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_4" then
			node.name = beehive.."_5"
			minetest.set_node(pos, node)
		end
	end,
})

minetest.register_abm({
	label = "Update Bee Nest Honey Levels",
	nodenames = "group:bee_nest",
	interval = 500,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local beehive = "mcl_beehives:bee_nest"
		if node.name == beehive then
			node.name = beehive.."_1"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_1" then
			node.name = beehive.."_2"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_2" then
			node.name = beehive.."_3"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_3" then
			node.name = beehive.."_4"
			minetest.set_node(pos, node)
		elseif node.name == beehive.."_4" then
			node.name = beehive.."_5"
			minetest.set_node(pos, node)
		end
	end,
})
