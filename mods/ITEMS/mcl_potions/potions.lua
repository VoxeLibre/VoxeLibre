local S = minetest.get_translator("mcl_potions")
local brewhelp = S("Try different combinations to create potions.")

local potion_image = function(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_potion_bottle.png"
end

local how_to_drink = S("Use the “Place” key to drink it.")

local function time_string(dur)
	if not dur then return nil end
	return math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
end

local function register_potion(def)

	local dur = mcl_potions.DURATION

	if def.is_inv then
		dur = dur * mcl_potions.INV_FACTOR
	end
	if def.name == "poison" or def.name == "regeneration" then
		dur = 45
	end

	local on_use = function (itemstack, user, pointed_thing)
							def.on_use(user, def.effect, dur)
							minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
							mcl_potions._use_potion(itemstack, user, def.color)
							return itemstack
						end

	local _tt
	if def.effect and def.is_dur then
		_tt = (def.effect*100).."% | "..time_string(dur)
		if def.name == "poison" or def.name == "regeneration" then
			_tt = "1/2 Heart/"..def.effect.."sec | "..time_string(dur)
		end
	else
		_tt = def._tt or time_string(dur) or S("No effect")
	end

	minetest.register_craftitem("mcl_potions:"..def.name, {
		description = S(def.description),
		_tt_help = _tt,
		_doc_items_longdesc = def._longdesc,
		_doc_items_usagehelp = how_to_drink,
		stack_max = 1,
		inventory_image = def.image or potion_image(def.color),
		wield_image = def.image or potion_image(def.color),
		groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0},
		on_place = on_use,
		on_secondary_use = on_use,
	})

	if def.is_II then

		local desc_mod = " II"

		local effect_II
		if def.name == "healing" or def.name == "harming" then
			effect_II = def.effect*mcl_potions.II_FACTOR
		elseif def.name == "poison" or def.name == "regeneration" then
			effect_II = 1.2
		else
			effect_II = def.effect^mcl_potions.II_FACTOR
		end

		dur_2 = dur / mcl_potions.II_FACTOR
		if def.name == "poison" then dur_2 = dur_2 - 1 end

		if def.name == "slowness" then
			dur_2 = 20
			effect_II = 0.40
			desc_mod = " IV"
		end

		local _tt
		if effect_II and def.is_dur then
			_tt = (effect_II*100).."% | "..time_string(dur_2)
			if def.name == "poison" or def.name == "regeneration" then
				_tt = "1/2 Heart/"..effect_II.."sec | "..time_string(dur_2)
			end
		else
			_tt = def._tt_2 or time_string(dur_2) or S("No effect")
		end

		local on_use = function (itemstack, user, pointed_thing)
								def.on_use(user, effect_II, dur_2)
								minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
								mcl_potions._use_potion(itemstack, user, def.color)
								return itemstack
							end

		minetest.register_craftitem("mcl_potions:"..def.name.."_2", {
			description = S(def.description..desc_mod),
			_tt_help = _tt,
			_doc_items_longdesc = def._longdesc,
			_doc_items_usagehelp = how_to_drink,
			stack_max = 1,
			inventory_image = def.image or potion_image(def.color),
			wield_image = def.image or potion_image(def.color),
			groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0},
			on_place = on_use,
			on_secondary_use = on_use,
		})
	end

	if def.is_plus then

		dur_pl = dur * mcl_potions.PLUS_FACTOR
		if def.name == "poison" or def.name == "regeneration" then
			dur_pl = 90
		end

		local _tt
		if def.effect and def.is_dur then
			_tt = (def.effect*100).."% | "..time_string(dur_pl)
			if def.name == "poison" or def.name == "regeneration" then
				_tt = "1/2 Heart/"..def.effect.."sec | "..time_string(dur_pl)
			end
		else
			_tt = def._tt_plus or time_string(dur_pl) or S("No effect")
		end

		local on_use = function (itemstack, user, pointed_thing)
								def.on_use(user, def.effect, dur_pl)
								minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
								mcl_potions._use_potion(itemstack, user, def.color)
								return itemstack
							end

		minetest.register_craftitem("mcl_potions:"..def.name.."_plus", {
			description = S(def.description.." +"),
			_tt_help = _tt,
			_doc_items_longdesc = def._longdesc,
			_doc_items_usagehelp = how_to_drink,
			stack_max = 1,
			inventory_image = def.image or potion_image(def.color),
			wield_image = def.image or potion_image(def.color),
			groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0},
			on_place = on_use,
			on_secondary_use = on_use,
		})

	end

end



local awkward_def = {
	name = "awkward",
	description = "Awkward Potion",
	_tt = S("No effect"),
	_longdesc = S("Has an awkward taste and is used for brewing potions."),
	color = "#0000FF",
	groups = {brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0},
	on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
}

local mundane_def = {
	name = "mundane",
	description = "Mundane Potion",
	_tt = S("No effect"),
	longdesc = S("Has a clean taste and is used for brewing potions."),
	color = "#0000FF",
	on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
}

local thick_def = {
	name = "thick",
	description = "Thick Potion",
	_tt = S("No effect"),
	_longdesc = S("Has a bitter taste and is used for brewing potions."),
	color = "#0000FF",
	on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
}

local dragon_breath_def = {
	name = "dragon_breath",
	description = "Dragon's Breath",
	_tt = S("No effect"),
	_longdesc = S("Combine with Splash potions to create a Lingering effect"),
	color = nil,
	image = "mcl_potions_dragon_breath.png",
	groups = { brewitem = 1, not_in_creative_inventory = 0 },
	on_use = nil,
}

local healing_def = {
	name = "healing",
	description = "Healing Potion",
	_tt = S("+2 Hearts"),
	_tt_2 = S("+4 Hearts"),
	_longdesc = S("Drink to heal yourself"),
	color = "#CC0000",
	effect = 4,
	dur = nil,
	on_use = mcl_potions.healing_func,
	is_II = true,
	effect_sq = false,
}


local harming_def = {
	name = "harming",
	description = "Harming Potion",
	_tt = S("-3 Hearts"),
	_tt_II = S("-6 Hearts"),
	_longdesc = S("Drink to heal yourself"),
	color = "#660099",
	effect = -6,
	dur = nil,
	on_use = mcl_potions.healing_func,
	is_II = true,
}

local night_vision_def = {
	name = "night_vision",
	description = "Night Vision Potion",
	_tt = nil,
	_longdesc = S("Drink to see in the dark."),
	color = "#1010AA",
	effect = nil,
	is_dur = true,
	on_use = mcl_potions.night_vision_func,
	is_plus = true,
}

local swiftness_def = {
	name = "swiftness",
	description = "Swiftness Potion",
	_tt = nil,
	_longdesc = S("Drink to increase your speed."),
	color = "#009999",
	effect = 1.2,
	is_dur = true,
	on_use = mcl_potions.swiftness_func,
	is_II = true,
	is_plus = true,
}

local slowness_def = {
	name = "slowness",
	description = "Slowness Potion",
	_tt = nil,
	_longdesc = S("Drink to become sluggish"),
	color = "#000080",
	effect = 0.85,
	is_dur = true,
	on_use = mcl_potions.swiftness_func,
	is_II = true,
	is_plus = true,
	is_inv = true,
}

local leaping_def = {
	name = "leaping",
	description = "Leaping Potion",
	_tt = nil,
	_longdesc = S("Drink to leap tall buildings in a single bound!"),
	color = "#00CC33",
	effect = 1.5,
	is_dur = true,
	on_use = mcl_potions.leaping_func,
	is_II = true,
	is_plus = true,
}

local poison_def = {
	name = "poison",
	description = "Poison Potion",
	_tt = nil,
	_longdesc = S("Poison mobs or players with this dangerous potion."),
	color = "#447755",
	effect = 2.5,
	is_dur = true,
	on_use = mcl_potions.poison_func,
	is_II = true,
	is_plus = true,
	is_inv = true,
}

local regeneration_def = {
	name = "regeneration",
	description = "Regeneration Potion",
	_tt = nil,
	_longdesc = S("Regenerate mobs or players with this healing potion over time."),
	color = "#B52CC2",
	effect = 2.5,
	is_dur = true,
	on_use = mcl_potions.regeneration_func,
	is_II = true,
	is_plus = true,
}

local invisibility_def = {
	name = "invisibility",
	description = "Invisibility Potion",
	_tt = nil,
	_longdesc = S("Drink and become invisibile to mobs and players."),
	color = "#B0B0B0",
	is_dur = true,
	on_use = mcl_potions.invisiblility_func,
	is_plus = true,
}

local water_breathing_def = {
	name = "water_breathing",
	description = "Water Breathing Potion",
	_tt = nil,
	_longdesc = S("Drink and breath underwater."),
	color = "#0000AA",
	is_dur = true,
	on_use = mcl_potions.water_breathing_func,
	is_plus = true,
}

local fire_resistance_def = {
	name = "fire_resistance",
	description = "Fire Resistance Potion",
	_tt = nil,
	_longdesc = S("Drink and resist fire damage."),
	color = "#D0A040",
	is_dur = true,
	on_use = mcl_potions.fire_resistance_func,
	is_plus = true,
}



local defs = { awkward_def, mundane_def, thick_def, dragon_breath_def,
			   healing_def, harming_def, night_vision_def, swiftness_def,
		   	   slowness_def, leaping_def, poison_def, regeneration_def,
		   	   invisibility_def, water_breathing_def, fire_resistance_def}

for _, def in ipairs(defs) do
	register_potion(def)
end




-- minetest.register_craftitem("mcl_potions:weakness", {
-- 	description = S("Weakness Potion"),
-- 	_tt_help = S("-4 HP damage | 1:30"),
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#6600AA"),
-- 	inventory_image = potion_image("#6600AA"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, -4, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#6600AA")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, -4, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#6600AA")
-- 		return itemstack
-- 	end
-- })
--
-- minetest.register_craftitem("mcl_potions:weakness_plus", {
-- 	description = S("Weakness Potion +"),
-- 	_tt_help = S("-4 HP damage | 4:00"),
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#7700BB"),
-- 	inventory_image = potion_image("#7700BB"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, -4, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#7700BB")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, -4, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#7700BB")
-- 		return itemstack
-- 	end
-- })
--
-- minetest.register_craftitem("mcl_potions:strength", {
-- 	description = S("Strength Potion"),
-- 	_tt_help = S("+3 HP damage | 3:00"),
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#D444D4"),
-- 	inventory_image = potion_image("#D444D4"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 3, mcl_potions.DURATION)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#D444D4")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 3, mcl_potions.DURATION)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#D444D4")
-- 		return itemstack
-- 	end
-- })
--
-- minetest.register_craftitem("mcl_potions:strength_2", {
-- 	description = S("Strength Potion II"),
-- 	_tt_help = S("+6 HP damage | 1:30"),
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#D444E4"),
-- 	inventory_image = potion_image("#D444E4"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 6, mcl_potions.DURATION_2)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#D444E4")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 6, mcl_potions.DURATION_2)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#D444E4")
-- 		return itemstack
-- 	end
-- })
--
-- minetest.register_craftitem("mcl_potions:strength_plus", {
-- 	description = S("Strength Potion +"),
-- 	_tt_help = S("+3 HP damage | 8:00"),
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#D444F4"),
-- 	inventory_image = potion_image("#D444F4"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, not_in_creative_inventory=0 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 3, mcl_potions.DURATION_PLUS)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#D444F4")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 3, mcl_potions.DURATION_PLUS)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#D444F4")
-- 		return itemstack
-- 	end
-- })
