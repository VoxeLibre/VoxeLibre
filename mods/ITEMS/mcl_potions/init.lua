local S = minetest.get_translator("mcl_potions")
mcl_potions = {}

local modpath = minetest.get_modpath("mcl_potions")
dofile(modpath .. "/functions.lua")
dofile(modpath .. "/splash.lua")

local brewhelp = S("Put this item in an item frame for decoration. It's useless otherwise.")

minetest.register_craftitem("mcl_potions:fermented_spider_eye", {
	description = S("Fermented Spider Eye"),
	_doc_items_longdesc = brewhelp,
	wield_image = "mcl_potions_spider_eye_fermented.png",
	inventory_image = "mcl_potions_spider_eye_fermented.png",
	-- TODO: Reveal item when it's actually useful
	groups = { brewitem = 1, not_in_creative_inventory = 0, not_in_craft_guide = 0 },
	stack_max = 64,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_potions:fermented_spider_eye",
	recipe = { "mcl_mushrooms:mushroom_brown", "mcl_core:sugar", "mcl_mobitems:spider_eye" },
})

minetest.register_craftitem("mcl_potions:glass_bottle", {
	description = S("Glass Bottle"),
	_tt_help = S("Liquid container"),
	_doc_items_longdesc = S("A glass bottle is used as a container for liquids and can be used to collect water directly."),
	_doc_items_usagehelp = S("To collect water, it on a cauldron with water (which removes a level of water) or any water source (which removes no water)."),
	inventory_image = "mcl_potions_potion_bottle_empty.png",
	wield_image = "mcl_potions_potion_bottle_empty.png",
	groups = {brewitem=1},
	liquids_pointable = true,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				if def and def.on_rightclick then
					return def.on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			-- Try to fill glass bottle with water
			local get_water = false
			local from_liquid_source = false
			local river_water = false
			if not def then
				-- Unknown node: no-op
			elseif def.groups and def.groups.water and def.liquidtype == "source" then
				-- Water source
				get_water = true
				from_liquid_source = true
				river_water = node.name == "mclx_core:river_water_source"
			-- Or reduce water level of cauldron by 1
			elseif string.sub(node.name, 1, 14) == "mcl_cauldrons:" then
				local pname = placer:get_player_name()
				if minetest.is_protected(pointed_thing.under, pname) then
					minetest.record_protection_violation(pointed_thing.under, pname)
					return itemstack
				end
				if node.name == "mcl_cauldrons:cauldron_3" then
					get_water = true
					minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_2"})
				elseif node.name == "mcl_cauldrons:cauldron_2" then
					get_water = true
					minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_1"})
				elseif node.name == "mcl_cauldrons:cauldron_1" then
					get_water = true
					minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron"})
				elseif node.name == "mcl_cauldrons:cauldron_3r" then
					get_water = true
					river_water = true
					minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_2r"})
				elseif node.name == "mcl_cauldrons:cauldron_2r" then
					get_water = true
					river_water = true
					minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron_1r"})
				elseif node.name == "mcl_cauldrons:cauldron_1r" then
					get_water = true
					river_water = true
					minetest.set_node(pointed_thing.under, {name="mcl_cauldrons:cauldron"})
				end
			end
			if get_water then
				local creative = minetest.settings:get_bool("creative_mode") == true
				if from_liquid_source or creative then
					-- Replace with water bottle, if possible, otherwise
					-- place the water potion at a place where's space
					local water_bottle
					if river_water then
						water_bottle = ItemStack("mcl_potions:potion_river_water")
					else
						water_bottle = ItemStack("mcl_potions:potion_water")
					end
					local inv = placer:get_inventory()
					if creative then
						-- Don't replace empty bottle in creative for convenience reasons
						if not inv:contains_item("main", water_bottle) then
							inv:add_item("main", water_bottle)
						end
					elseif itemstack:get_count() == 1 then
						return water_bottle
					else
						if inv:room_for_item("main", water_bottle) then
							inv:add_item("main", water_bottle)
						else
							minetest.add_item(placer:get_pos(), water_bottle)
						end
						itemstack:take_item()
					end
				end
				minetest.sound_play("mcl_potions_bottle_fill", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
			end
		end
		return itemstack
	end,
})

minetest.register_craft( {
	output = "mcl_potions:glass_bottle 3",
	recipe = {
		{ "mcl_core:glass", "", "mcl_core:glass" },
		{ "", "mcl_core:glass", "" }
	}
})

-- Template function for creating images of filled potions
-- - colorstring must be a ColorString of form “#RRGGBB”, e.g. “#0000FF” for blue.
-- - opacity is optional opacity from 0-255 (default: 127)
local potion_image = function(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_potion_bottle_drinkable.png"
end



-- Cauldron fill up rules:
-- Adding any water increases the water level by 1, preserving the current water type
local cauldron_levels = {
	-- start = { add water, add river water }
	{ "",    "_1",  "_1r" },
	{ "_1",  "_2",  "_2" },
	{ "_2",  "_3",  "_3" },
	{ "_1r", "_2r",  "_2r" },
	{ "_2r", "_3r", "_3r" },
}
local fill_cauldron = function(cauldron, water_type)
	local base = "mcl_cauldrons:cauldron"
	for i=1, #cauldron_levels do
		if cauldron == base .. cauldron_levels[i][1] then
			if water_type == "mclx_core:river_water_source" then
				return base .. cauldron_levels[i][3]
			else
				return base .. cauldron_levels[i][2]
			end
		end
	end
end

-- Itemstring of potions is “mcl_potions:potion_<NBT Potion Tag>”

minetest.register_craftitem("mcl_potions:potion_water", {
	description = S("Water Bottle"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("Water bottles can be used to fill cauldrons. Drinking water has no effect."),
	_doc_items_usagehelp = S("Use the “Place” key to drink. Place this item on a cauldron to pour the water into the cauldron."),
	stack_max = 1,
	inventory_image = potion_image("#0000FF"),
	wield_image = potion_image("#0000FF"),
	groups = {brewitem=1, food=3, can_eat_when_full=1, water_bottle=1},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				if def and def.on_rightclick then
					return def.on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			local cauldron = fill_cauldron(node.name, "mcl_core:water_source")
			if cauldron then
				local pname = placer:get_player_name()
				if minetest.is_protected(pointed_thing.under, pname) then
					minetest.record_protection_violation(pointed_thing.under, pname)
					return itemstack
				end
				-- Increase water level of cauldron by 1
				minetest.set_node(pointed_thing.under, {name=cauldron})
				minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
				if minetest.settings:get_bool("creative_mode") == true then
					return itemstack
				else
					return "mcl_potions:glass_bottle"
				end
			end
		end

		-- Drink the water by default
		return minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, placer, pointed_thing)
	end,
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})

minetest.register_craftitem("mcl_potions:potion_river_water", {
	description = S("River Water Bottle"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("River water bottles can be used to fill cauldrons. Drinking it has no effect."),
	_doc_items_usagehelp = S("Use the “Place” key to drink. Place this item on a cauldron to pour the river water into the cauldron."),

	stack_max = 1,
	inventory_image = potion_image("#0044FF"),
	wield_image = potion_image("#0044FF"),
	groups = {brewitem=1, food=3, can_eat_when_full=1, water_bottle=1},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type == "node" then
			local node = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[node.name]

			-- Call on_rightclick if the pointed node defines it
			if placer and not placer:get_player_control().sneak then
				if def and def.on_rightclick then
					return def.on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
				end
			end

			local cauldron = fill_cauldron(node.name, "mclx_core:river_water_source")
			if cauldron then
				local pname = placer:get_player_name()
				if minetest.is_protected(pointed_thing.under, pname) then
					minetest.record_protection_violation(pointed_thing.under, pname)
					return itemstack
				end
				-- Increase water level of cauldron by 1
				minetest.set_node(pointed_thing.under, {name=cauldron})
				minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)
				if minetest.settings:get_bool("creative_mode") == true then
					return itemstack
				else
					return "mcl_potions:glass_bottle"
				end
			end
		end

		-- Drink the water by default
		return minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, placer, pointed_thing)
	end,
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})



local how_to_drink = S("Use the “Place” key to drink it.")

minetest.register_craftitem("mcl_potions:awkward", {
	description = S("Awkward Potion"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("This potion has an awkward taste and is used for brewing more potions. Drinking it has no effect."),
	_doc_items_usagehelp = how_to_drink,
	stack_max = 1,
	inventory_image = potion_image("#0000FF"),
	wield_image = potion_image("#0000FF"),
	-- TODO: Reveal item when it's actually useful
	groups = {brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=1},
	on_place = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})
minetest.register_craftitem("mcl_potions:mundane", {
	description = S("Mundane Potion"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("This potion has a clean taste and is used for brewing more potions. Drinking it has no effect."),
	_doc_items_usagehelp = how_to_drink,
	stack_max = 1,
	inventory_image = potion_image("#0000FF"),
	wield_image = potion_image("#0000FF"),
	-- TODO: Reveal item when it's actually useful
	groups = {brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=1 },
	on_place = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})


minetest.register_craftitem("mcl_potions:thick", {
	description = S("Thick Potion"),
	_tt_help = S("No effect"),
	_doc_items_longdesc = S("This potion has a bitter taste and is used for brewing more potions. Drinking it has no effect."),
	_doc_items_usagehelp = how_to_drink,
	stack_max = 1,
	inventory_image = potion_image("#0000FF"),
	wield_image = potion_image("#0000FF"),
	-- TODO: Reveal item when it's actually useful
	groups = {brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	on_place = minetest.item_eat(0, "mcl_potions:glass_bottle"),
	on_secondary_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
})

minetest.register_craftitem("mcl_potions:speckled_melon", {
	description = S("Glistering Melon"),
	_doc_items_longdesc = S("This shiny melon is full of tiny gold nuggets and would be nice in an item frame. It isn't edible and not useful for anything else."),
	stack_max = 64,
	groups = { brewitem = 1, not_in_creative_inventory = 0, not_in_craft_guide = 1 },
	inventory_image = "mcl_potions_melon_speckled.png",
})

minetest.register_craft({
	output = "mcl_potions:speckled_melon",
	recipe = {
		{'mcl_core:gold_nugget', 'mcl_core:gold_nugget', 'mcl_core:gold_nugget'},
		{'mcl_core:gold_nugget', 'mcl_farming:melon_item', 'mcl_core:gold_nugget'},
		{'mcl_core:gold_nugget', 'mcl_core:gold_nugget', 'mcl_core:gold_nugget'},
	}
})

minetest.register_craftitem("mcl_potions:dragon_breath", {
	description = S("Dragon's Breath"),
	_doc_items_longdesc = brewhelp,
	wield_image = "mcl_potions_dragon_breath.png",
	inventory_image = "mcl_potions_dragon_breath.png",
	groups = { brewitem = 1, not_in_creative_inventory = 0 },
	stack_max = 1,
})


minetest.register_craftitem("mcl_potions:healing", {
	description = S("Healing Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#CC0000"),
	inventory_image = potion_image("#CC0000"),
	groups = { brewitem = 1, food=3, can_eat_when_full=1 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 4)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 4)
		mcl_potions._use_potion()
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:healing_2", {
	description = S("Healing Potion II"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#DD0000"),
	inventory_image = potion_image("#DD0000"),
	groups = { brewitem = 1, food=3, can_eat_when_full=1 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 8)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 8)
		mcl_potions._use_potion()
		return itemstack
	end,

})

minetest.register_craftitem("mcl_potions:harming", {
	description = S("Harming Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#660099"),
	inventory_image = potion_image("#660099"),
	groups = { brewitem = 1, food=3, can_eat_when_full=1 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -6)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -6)
		mcl_potions._use_potion()
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:harming_2", {
	description = S("Harming Potion II"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#330066"),
	inventory_image = potion_image("#330066"),
	groups = { brewitem = 1, food=3, can_eat_when_full=1 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -12)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -12)
		mcl_potions._use_potion()
		return itemstack
	end,
})


minetest.register_craftitem("mcl_potions:night_vision", {
	description = S("Night Vision Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = "mcl_potions_night_vision.png",
	inventory_image = "mcl_potions_night_vision.png",
	groups = { brewitem = 1, food=0},
	stack_max = 1,
})


minetest.register_craftitem("mcl_potions:swiftness", {
	description = S("Swiftness Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#009999"),
	inventory_image = potion_image("#009999"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, 180)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, 180)
		mcl_potions._use_potion()
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:swiftness_2", {
	description = S("Swiftness Potion II"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00BBBB"),
	inventory_image = potion_image("#00BBBB"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.4, 90)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.4, 90)
		mcl_potions._use_potion()
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:swiftness_plus", {
	description = S("Swiftness Potion +"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00AAAA"),
	inventory_image = potion_image("#00AAAA"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, 480)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, 480)
		mcl_potions._use_potion()
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:slowness", {
	description = S("Slowness Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#000080"),
	inventory_image = potion_image("#000080"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, 90)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, 90)
		mcl_potions._use_potion()
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:slowness_plus", {
	description = S("Slowness Potion +"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#000066"),
	inventory_image = potion_image("#000066"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, 240)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, 240)
		mcl_potions._use_potion()
		return itemstack
	end,
})


minetest.register_craftitem("mcl_potions:leaping", {
	description = S("Leaping Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00CC33"),
	inventory_image = potion_image("#00CC33"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.2, 180)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.2, 180)
		mcl_potions._use_potion()
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:leaping_2", {
	description = S("Leaping Potion II"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00EE33"),
	inventory_image = potion_image("#00EE33"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.4, 90)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.4, 90)
		mcl_potions._use_potion()
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:leaping_plus", {
	description = S("Leaping Potion +"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00DD33"),
	inventory_image = potion_image("#00DD33"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.2, 480)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.2, 480)
		mcl_potions._use_potion()
		return itemstack
	end,
})


minetest.register_craftitem("mcl_potions:weakness", {
	description = S("Weakness Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#6600AA"),
	inventory_image = potion_image("#6600AA"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.2, 180)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.2, 180)
		mcl_potions._use_potion()
		return itemstack
	end
})


minetest.register_craftitem("mcl_potions:poison", {
	description = S("Poison Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#225533"),
	inventory_image = potion_image("#225533"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, 45)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, 45)
		mcl_potions._use_potion()
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:poison_2", {
	description = S("Poison Potion II"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#447755"),
	inventory_image = potion_image("#447755"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 1.2, 21)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 1.2, 21)
		mcl_potions._use_potion()
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:poison_plus", {
	description = S("Poison Potion +"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#336644"),
	inventory_image = potion_image("#336644"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, 90)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, 90)
		mcl_potions._use_potion()
		return itemstack
	end
})


minetest.register_craftitem("mcl_potions:regeneration", {
	description = S("Regeneration Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#A52BB2"),
	inventory_image = potion_image("#A52BB2"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, 45)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, 45)
		mcl_potions._use_potion()
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:regeneration_2", {
	description = S("Regeneration Potion II"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#B52CC2"),
	inventory_image = potion_image("#B52CC2"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 1.2, 21)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 1.2, 21)
		mcl_potions._use_potion()
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:regeneration_plus", {
	description = S("Regeneration Potion +"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#C53DD3"),
	inventory_image = potion_image("#C53DD3"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, 90)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, 90)
		mcl_potions._use_potion()
		return itemstack
	end
})


minetest.register_craftitem("mcl_potions:invisibility", {
	description = S("Invisibility Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#B0B0B0"),
	inventory_image = potion_image("#B0B0B0"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, 180)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, 180)
		mcl_potions._use_potion()
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:invisibility_plus", {
	description = S("Invisibility Potion +"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#A0A0A0"),
	inventory_image = potion_image("#A0A0A0"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, 480)
		mcl_potions._use_potion()
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, 480)
		mcl_potions._use_potion()
		return itemstack
	end
})

-- Look into reducing attack on punch
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if puncher:get_attribute("weakness") then
		print("Weakness Active")
	end
end)



-- duration effects of redstone are a factor of 8/3
-- duration effects of glowstone are a time factor of 1/2 and effect of 14/12
-- splash potion effects are reduced by a factor of 3/4

local water_table = {
	["mcl_nether:nether_wart_item"] = "mcl_potions:awkward",
	["mcl_potions:fermented_spider_eye"] = "mcl_potions:weakness",
	["mcl_potions:speckled_melon"] = "mcl_potions:mundane",
	["mcl_core:sugar"] = "mcl_potions:mundane",
	["mcl_mobitems:magma_cream"] = "mcl_potions:mundane",
	["mcl_mobitems:blaze_powder"] = "mcl_potions:mundane",
	["mesecons:wire_00000000_off"] = "mcl_potions:mundane",
	["mcl_mobitems:ghast_tear"] = "mcl_potions:mundane",
	["mcl_mobitems:spider_eye"] = "mcl_potions:mundane",
	["mcl_mobitems:rabbit_foot"] = "mcl_potions:mundane"
}

local awkward_table = {
	["mcl_potions:speckled_melon"] = "mcl_potions:healing",
	["mcl_farming:carrot_item_gold"] = "mcl_potions:night_vision",
	["mcl_core:sugar"] = "mcl_potions:swiftness",
	["mcl_mobitems:magma_cream"] = "mcl_potions:fire_resistance", --add craft
	["mcl_mobitems:blaze_powder"] = "mcl_potions:strength", --add craft
	["mcl_fishing:pufferfish_raw"] = "mcl_potions:water_breathing", --add craft
	["mcl_mobitems:ghast_tear"] = "mcl_potions:regeneration", --add craft
	["mcl_mobitems:spider_eye"] = "mcl_potions:poison", --add craft
	["mcl_mobitems:rabbit_foot"] = "mcl_potions:leaping", --add craft
}

local output_table = {
	["mcl_potions:potion_river_water"] = water_table,
	["mcl_potions:potion_water"] = water_table,
	["mcl_potions:awkward"] = awkward_table,
}


local enhancement_table = {}
local extension_table = {}
local potions = {"awkward", "mundane", "thick"}
for i, potion in ipairs({"healing","harming","swiftness","leaping","poison","regeneration","invisibility"}) do
		if potion ~= "invisibility" and potion ~= "night_vision" then
			enhancement_table["mcl_potions:"..potion] = "mcl_potions:"..potion.."_2"
			enhancement_table["mcl_potions:"..potion.."_splash"] = "mcl_potions:"..potion.."_2_splash"
			table.insert(potions, potion)
			table.insert(potions, potion.."_2")
		end
		if potion ~= "healing" and potion ~= "harming" then
			extension_table["mcl_potions:"..potion.."_splash"] = "mcl_potions:"..potion.."_plus_splash"
			table.insert(potions, potion.."_plus")
		end
end


local inversion_table = {
	["mcl_potions:healing"] = "mcl_potions:harming",
	["mcl_potions:healing_2"] = "mcl_potions:harming_2",
	["mcl_potions:swiftness"] = "mcl_potions:slowness",
	["mcl_potions:swiftness_plus"] = "mlc_potions:slowness_plus",
	["mcl_potions:leaping"] = "mcl_potions:slowness",
	["mcl_potions:leaping_plus"] = "mcl_potions:slowness_plus",
	["mcl_potions:night_vision"] = "mcl_potions:invisibility",
	["mcl_potions:night_vision_plus"] = "mcl_potions:invisibility_plus",
	["mcl_potions:poison"] = "mcl_potions:harming",
	["mcl_potions:poison_2"] = "mcl_potions:harming_2",
	["mcl_potions:healing_splash"] = "mcl_potions:harming_splash",
	["mcl_potions:healing_2_splash"] = "mcl_potions:harming_2_splash",
	["mcl_potions:swiftness_splash"] = "mcl_potions:slowness_splash",
	["mcl_potions:swiftness_plus_splash"] = "mlc_potions:slowness_plus_splash",
	["mcl_potions:leaping_splash"] = "mcl_potions:slowness_splash",
	["mcl_potions:leaping_plus_splash"] = "mcl_potions:slowness_plus_splash",
	["mcl_potions:night_vision_splash"] = "mcl_potions:invisibility_splash",
	["mcl_potions:night_vision_plus_splash"] = "mcl_potions:invisibility_plus_splash",
	["mcl_potions:poison_splash"] = "mcl_potions:harming_splash",
	["mcl_potions:poison_2_splash"] = "mcl_potions:harming_2_splash",
}


local splash_table = {}
local lingering_table = {}

for i, potion in ipairs(potions) do
    splash_table["mcl_potions:"..potion] = "mcl_potions:"..potion.."_splash"
		lingering_table["mcl_potions:"..potion.."_splash"] = "mcl_potions:"..potion.."_lingering"
end

local mod_table = {
	["mesecons:wire_00000000_off"] = extension_table,
	["mcl_potions:fermented_spider_eye"] = inversion_table,
	["mcl_nether:glowstone_dust"] = enhancement_table,
	["mcl_mobitems:gunpowder"] = splash_table,
	["mcl_potions:dragon_breath"] = lingering_table,
}

-- Compare two ingredients for compatable alchemy
function mcl_potions.get_alchemy(ingr, pot)

	if output_table[pot] ~= nil then
		local brew_table = output_table[pot]
		if brew_table[ingr] ~= nil then
			return brew_table[ingr]
		end

	elseif mod_table[ingr] ~= nil then
		local brew_table = mod_table[ingr]
		if brew_table[pot] ~= nil then
			return brew_table[pot]
		end

	end

	return false
end
