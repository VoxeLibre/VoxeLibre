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
	_tt_help = S("+2 Hearts"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#CC0000"),
	inventory_image = potion_image("#CC0000"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 4)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#CC0000")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 4)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#CC0000")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:healing_2", {
	description = S("Healing Potion II"),
	_tt_help = S("+4 Hearts"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#DD0000"),
	inventory_image = potion_image("#DD0000"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 8)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#DD0000")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, 8)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#DD0000")
		return itemstack
	end,

})

minetest.register_craftitem("mcl_potions:harming", {
	description = S("Harming Potion"),
	_tt_help = S("-3 Hearts"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#660099"),
	inventory_image = potion_image("#660099"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -6)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#660099")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -6)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#660099")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:harming_2", {
	description = S("Harming Potion II"),
	_tt_help = S("-6 Hearts"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#330066"),
	inventory_image = potion_image("#330066"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -12)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#330066")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.healing_func(user, -12)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#330066")
		return itemstack
	end,
})


minetest.register_craftitem("mcl_potions:night_vision", {
	description = S("Night Vision Potion"),
	_tt_help = S("3:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#1010AA"),
	inventory_image = potion_image("#1010AA"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.night_vision_func(user, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#1010AA")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.night_vision_func(user, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#1010AA")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:night_vision_plus", {
	description = S("Night Vision Potion +"),
	_tt_help = S("8:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#2020BA"),
	inventory_image = potion_image("#2020BA"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.night_vision_func(user, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#2020BA")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.night_vision_func(user, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#2020BA")
		return itemstack
	end,
})


minetest.register_craftitem("mcl_potions:swiftness", {
	description = S("Swiftness Potion"),
	_tt_help = S("+20% | 3:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#009999"),
	inventory_image = potion_image("#009999"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#009999")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#009999")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:swiftness_2", {
	description = S("Swiftness Potion II"),
	_tt_help = S("+40% | 1:30"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00BBBB"),
	inventory_image = potion_image("#00BBBB"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.4, mcl_potions.DURATION_2)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00BBBB")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.4, mcl_potions.DURATION_2)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00BBBB")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:swiftness_plus", {
	description = S("Swiftness Potion +"),
	_tt_help = S("+20% | 8:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00AAAA"),
	inventory_image = potion_image("#00AAAA"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00AAAA")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 1.2, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00AAAA")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:slowness", {
	description = S("Slowness Potion"),
	_tt_help = S("-15% | 1:30"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#000080"),
	inventory_image = potion_image("#000080"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#000080")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#000080")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:slowness_plus", {
	description = S("Slowness Potion +"),
	_tt_help = S("-15% | 4:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#000066"),
	inventory_image = potion_image("#000066"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#000066")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.85, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#000066")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:slowness_2", {
	description = S("Slowness Potion IV"),
	_tt_help = S("-60% | 0:20"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#000090"),
	inventory_image = potion_image("#000090"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.40, 20)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#000090")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.swiftness_func(user, 0.40, 20)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#000090")
		return itemstack
	end,
})


minetest.register_craftitem("mcl_potions:leaping", {
	description = S("Leaping Potion"),
	_tt_help = S("+50% | 3:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00CC33"),
	inventory_image = potion_image("#00CC33"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.5, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00CC33")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.5, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00CC33")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:leaping_2", {
	description = S("Leaping Potion II"),
	_tt_help = S("+125% | 1:30"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00EE33"),
	inventory_image = potion_image("#00EE33"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 2.25, mcl_potions.DURATION_2)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00EE33")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 2.25, mcl_potions.DURATION_2)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00EE33")
		return itemstack
	end,
})

minetest.register_craftitem("mcl_potions:leaping_plus", {
	description = S("Leaping Potion +"),
	_tt_help = S("+50% | 8:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#00DD33"),
	inventory_image = potion_image("#00DD33"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.5, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00DD33")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.leaping_func(user, 1.5, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#00DD33")
		return itemstack
	end,
})


minetest.register_craftitem("mcl_potions:weakness", {
	description = S("Weakness Potion"),
	_tt_help = S("No effect | 1:30"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#6600AA"),
	inventory_image = potion_image("#6600AA"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.2, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#6600AA")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.2, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#6600AA")
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:weakness_plus", {
	description = S("Weakness Potion +"),
	_tt_help = S("No effect | 4:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#7700BB"),
	inventory_image = potion_image("#7700BB"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.4, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#7700BB")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.weakness_func(user, 1.4, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#7700BB")
		return itemstack
	end
})


minetest.register_craftitem("mcl_potions:poison", {
	description = S("Poison Potion"),
	_tt_help = S("-1/2 Heart / 2.5sec | 0:45"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#225533"),
	inventory_image = potion_image("#225533"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, mcl_potions.DURATION*mcl_potions.INV_FACTOR*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#225533")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, mcl_potions.DURATION*mcl_potions.INV_FACTOR*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#225533")
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:poison_2", {
	description = S("Poison Potion II"),
	_tt_help = S("-1/2 Heart / 1.2sec | 0:21"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#447755"),
	inventory_image = potion_image("#447755"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 1.2, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#447755")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 1.2, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#447755")
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:poison_plus", {
	description = S("Poison Potion +"),
	_tt_help = S("-1/2 Heart / 2.5sec | 1:30"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#336644"),
	inventory_image = potion_image("#336644"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#336644")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.poison_func(user, 2.5, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#336644")
		return itemstack
	end
})


minetest.register_craftitem("mcl_potions:regeneration", {
	description = S("Regeneration Potion"),
	_tt_help = S("+1/2 Heart / 2.5sec | 0:45"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#A52BB2"),
	inventory_image = potion_image("#A52BB2"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, mcl_potions.DURATION*mcl_potions.INV_FACTOR^2)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#A52BB2")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, mcl_potions.DURATION*mcl_potions.INV_FACTOR^2)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#A52BB2")
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:regeneration_2", {
	description = S("Regeneration Potion II"),
	_tt_help = S("+1/2 Heart / 1.2sec | 0:22"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#B52CC2"),
	inventory_image = potion_image("#B52CC2"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 1.2, mcl_potions.DURATION*mcl_potions.INV_FACTOR^3 + 1)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#B52CC2")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 1.2, mcl_potions.DURATION*mcl_potions.INV_FACTOR^3 + 1)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#B52CC2")
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:regeneration_plus", {
	description = S("Regeneration Potion +"),
	_tt_help = S("+1/2 Heart / 2.5sec | 1:30"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#C53DD3"),
	inventory_image = potion_image("#C53DD3"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#C53DD3")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.regeneration_func(user, 2.5, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#C53DD3")
		return itemstack
	end
})


minetest.register_craftitem("mcl_potions:invisibility", {
	description = S("Invisibility Potion"),
	_tt_help = S("3:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#B0B0B0"),
	inventory_image = potion_image("#B0B0B0"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#B0B0B0")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#B0B0B0")
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:invisibility_plus", {
	description = S("Invisibility Potion +"),
	_tt_help = S("8:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#A0A0A0"),
	inventory_image = potion_image("#A0A0A0"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#A0A0A0")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.invisiblility_func(user, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#A0A0A0")
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
	_tt_help = S("3:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#0000AA"),
	inventory_image = potion_image("#0000AA"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.water_breathing_func(user, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#0000AA")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.water_breathing_func(user, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#0000AA")
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:water_breathing_plus", {
	description = S("Water Breathing Potion +"),
	_tt_help = S("8:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#0000CC"),
	inventory_image = potion_image("#0000CC"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.water_breathing_func(user, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#0000CC")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.water_breathing_func(user, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#0000CC")
		return itemstack
	end
})


minetest.register_craftitem("mcl_potions:fire_resistance", {
	description = S("Fire Resistance Potion"),
	_tt_help = S("3:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#D0A040"),
	inventory_image = potion_image("#D0A040"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.fire_resistance_func(user, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#D0A040")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.fire_resistance_func(user, mcl_potions.DURATION)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#D0A040")
		return itemstack
	end
})

minetest.register_craftitem("mcl_potions:fire_resistance_plus", {
	description = S("Fire Resistance Potion +"),
	_tt_help = S("8:00"),
	_doc_items_longdesc = brewhelp,
	wield_image = potion_image("#E0B050"),
	inventory_image = potion_image("#E0B050"),
	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
	stack_max = 1,

	on_place = function(itemstack, user, pointed_thing)
		mcl_potions.fire_resistance_func(user, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#E0B050")
		return itemstack
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		mcl_potions.fire_resistance_func(user, mcl_potions.DURATION_PLUS)
		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		mcl_potions._use_potion(itemstack, user, "#E0B050")
		return itemstack
	end
})
