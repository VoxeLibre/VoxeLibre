local S = minetest.get_translator("mcl_potions")
local brewhelp = S("Try different combinations to create potions.")

local potion_image = function(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_potion_bottle_drinkable.png"
end

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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 4)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 8)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -6)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -12)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, 180)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.4, 90)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, 480)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, 90)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, 240)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.2, 180)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.4, 90)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.2, 480)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions.weakness_func(user, 1.2, 90)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.2, 90)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:weakness_plus", {
	description = S("Weakness Potion +"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#7700BB"),
	inventory_image = potion_image("#7700BB"),
	groups = { brewitem = 1, food=0},
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.4, 240)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.4, 240)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, 45)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 1.2, 21)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, 90)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, 45)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions.regeneration_func(user, 1.2, 22)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 1.2, 22)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, 90)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, 180)
		mcl_potions._use_potion(itemstack)
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
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, 480)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end
})

-- Look into reducing attack on punch
minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if puncher:get_attribute("weakness") then
		print("Weakness Active")
	end
end)


minetest.register_craftitem("mcl_potions:water_breathing", {
	description = S("Water Breathing Potion"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#0000AA"),
	inventory_image = potion_image("#0000AA"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.water_breathing_func(user, 180)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.water_breathing_func(user, 180)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:water_breathing_plus", {
	description = S("Water Breathing Potion +"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#0000CC"),
	inventory_image = potion_image("#0000CC"),
	groups = { brewitem = 1, food = 0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.water_breathing_func(user, 480)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.water_breathing_func(user, 480)
		mcl_potions._use_potion(itemstack)
		return itemstack
	end
})
