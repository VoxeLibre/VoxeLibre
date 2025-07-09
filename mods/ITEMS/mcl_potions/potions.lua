local S = minetest.get_translator(minetest.get_current_modname())

mcl_potions.registered_potions = {}
-- shorthand
local registered_potions = mcl_potions.registered_potions

local function potion_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_potion_bottle.png"
end

local how_to_drink = S("Use the “Place” key to drink it.")
local potion_intro = S("Drinking a potion gives you a particular effect or set of effects.")

local function time_string(dur)
	if not dur then
		return nil
	end
	return math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
end
local function perc_string(num)

	local rem = math.floor((num-1.0)*100 + 0.1) % 5
	local out = math.floor((num-1.0)*100 + 0.1) - rem

	if (num - 1.0) < 0 then
		return out.."%"
	else
		return "+"..out.."%"
	end
end


-- ██████╗░███████╗░██████╗░██╗░██████╗████████╗███████╗██████╗░
-- ██╔══██╗██╔════╝██╔════╝░██║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
-- ██████╔╝█████╗░░██║░░██╗░██║╚█████╗░░░░██║░░░█████╗░░██████╔╝
-- ██╔══██╗██╔══╝░░██║░░╚██╗██║░╚═══██╗░░░██║░░░██╔══╝░░██╔══██╗
-- ██║░░██║███████╗╚██████╔╝██║██████╔╝░░░██║░░░███████╗██║░░██║
-- ╚═╝░░╚═╝╚══════╝░╚═════╝░╚═╝╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
--
-- ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


local function generate_on_use(effects, color, on_use, custom_effect)
	return function(itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			if user and not user:get_player_control().sneak then
				local node = minetest.get_node(pointed_thing.under)
				if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
					return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, user, itemstack) or itemstack
				end
			end
		elseif pointed_thing.type == "object" then
			return itemstack
		end

		-- Wrapper for handling mcl_hunger delayed eating
		local player_name = user:get_player_name()
		mcl_hunger.eat_internal[player_name]._custom_itemstack = itemstack -- Used as comparison to make sure the custom wrapper executes only when the same item is eaten
		mcl_hunger.eat_internal[player_name]._custom_var = {
			user = user,
			effects = effects,
			on_use = on_use,
			custom_effect = custom_effect,
		}
		mcl_hunger.eat_internal[player_name]._custom_func = function(itemstack, user, effects, on_use, custom_effect)
			local potency = itemstack:get_meta():get_int("mcl_potions:potion_potent")
			local plus = itemstack:get_meta():get_int("mcl_potions:potion_plus")
			local ef_level
			local dur
			for name, details in pairs(effects) do
				if details.uses_level then
					ef_level = details.level + details.level_scaling * (potency)
				else
					ef_level = details.level
				end
				if details.dur_variable then
					dur = details.dur * math.pow(mcl_potions.PLUS_FACTOR, plus)
					if potency>0 and details.uses_level then
						dur = dur / math.pow(mcl_potions.POTENT_FACTOR, potency)
					end
				else
					dur = details.dur
				end
				if details.effect_stacks then
					ef_level = ef_level + mcl_potions.get_effect_level(user, name)
				end
				mcl_potions.give_effect_by_level(name, user, ef_level, dur)
			end

			if on_use then on_use(user, potency+1) end
			if custom_effect then custom_effect(user, potency+1, plus) end
		end
		mcl_hunger.eat_internal[player_name]._custom_wrapper = function(player_name)
			mcl_hunger.eat_internal[player_name]._custom_func(
				mcl_hunger.eat_internal[player_name]._custom_itemstack,
				mcl_hunger.eat_internal[player_name]._custom_var.user,
				mcl_hunger.eat_internal[player_name]._custom_var.effects,
				mcl_hunger.eat_internal[player_name]._custom_var.on_use,
				mcl_hunger.eat_internal[player_name]._custom_var.custom_effect
			)
		end

		itemstack = minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		if itemstack then mcl_potions._use_potion(user, color) end

		return itemstack
	end
end

-- API - registers a potion
-- required parameters in def:
-- name - string - potion name in code
-- optional parameters in def:
-- desc_prefix - translated string - part of visible potion name, comes before the word "Potion"
-- desc_suffix - translated string - part of visible potion name, comes after the word "Potion"
-- _tt - translated string - custom tooltip text
-- _dynamic_tt - function(level) - returns custom tooltip text dependent on potion level
-- _longdesc - translated string - text for in-game documentation
-- stack_max - int - max stack size - defaults to 1
-- image - string - name of a custom texture of the potion icon
-- color - string - colorstring for potion icon when image is not defined - defaults to #0000FF
-- groups - table - item groups definition for the regular potion, not splash or lingering -
--   - must contain _mcl_potion=1 for tooltip to include dynamic_tt and effects
--   - defaults to {brewitem=1, food=3, can_eat_when_full=1, _mcl_potion=1}
-- nocreative - bool - adds a not_in_creative_inventory=1 group - defaults to false
-- _effect_list - table - all the effects dealt by the potion in the format of tables
-- -- the name of each sub-table should be a name of a registered effect, and fields can be the following:
-- -- -- uses_level - bool - whether the level of the potion affects the level of the effect -
-- -- --   - defaults to the uses_factor field of the effect definition
-- -- -- level - int - used as the effect level if uses_level is false and for lvl1 potions - defaults to 1
-- -- -- level_scaling - int - used as the number of effect levels added per potion level - defaults to 1 -
-- -- --   - this has no effect if uses_level is false
-- -- -- dur - float - duration of the effect in seconds - defaults to mcl_potions.DURATION
-- -- -- dur_variable - bool - whether variants of the potion should have the length of this effect changed -
-- -- --   - defaults to true
-- -- --   - if at least one effect has this set to true, the potion has a "plus" variant
-- -- -- effect_stacks - bool - whether the effect stacks - defaults to false
-- uses_level - bool - whether the potion should come at different levels -
--   - defaults to true if uses_level is true for at least one effect, else false
-- drinkable - bool - defaults to true
-- has_splash - bool - defaults to true
-- has_lingering - bool - defaults to true
-- has_arrow - bool - defaults to false
-- has_potent - bool - whether there is a potent (e.g. II) variant - defaults to the value of uses_level
-- default_potent_level - int - potion level used for the default potent variant - defaults to 2
-- default_extend_level - int - extention level (amount of +) used for the default extended variant - defaults to 1
-- custom_on_use - function(user, level) - called when the potion is drunk, returns true on success
-- custom_effect - function(object, level, plus) - called when the potion effects are applied, returns true on success
-- custom_splash_effect - function(pos, level) - called when the splash potion explodes, returns true on success
-- custom_linger_effect - function(pos, radius, level) - called on the lingering potion step, returns true on success
function mcl_potions.register_potion(def)
	local modname = minetest.get_current_modname()
	local name = def.name
	if name == nil then
		error("Unable to register potion: name is nil")
	end
	if type(name) ~= "string" then
		error("Unable to register potion: name is not a string")
	end
	local pdef = {}
	if def.desc_prefix and def.desc_suffix then
		pdef.description = S("@1 Potion @2", def.desc_prefix, def.desc_suffix)
	elseif def.desc_prefix then
		pdef.description = S("@1 Potion", def.desc_prefix)
	elseif def.desc_suffix then
		pdef.description = S("Potion @1", def.desc_suffix)
	else
		pdef.description = S("Strange Potion")
	end
	pdef._tt_help = def._tt
	pdef._dynamic_tt = def._dynamic_tt
	local potion_longdesc = def._longdesc
	if def._effect_list then
		potion_longdesc = potion_intro .. "\n" .. def._longdesc
	end
	pdef._doc_items_longdesc = potion_longdesc
	if def.drinkable ~= false then pdef._doc_items_usagehelp = how_to_drink end
	pdef.stack_max = def.stack_max or 1
	local color = def.color or "#0000FF"
	pdef.inventory_image = def.image or potion_image(color)
	pdef.wield_image = pdef.inventory_image
	pdef.groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1, _mcl_potion=1}
	if def.nocreative then pdef.groups.not_in_creative_inventory = 1 end

	pdef._effect_list = {}
	local effect
	local uses_level = false
	local has_plus = false
	if def._effect_list then
		for name, details in pairs(def._effect_list) do
			effect = mcl_potions.registered_effects[name]
			if effect then
				local ulvl
				if details.uses_level ~= nil then ulvl = details.uses_level
				else ulvl = effect.uses_factor end
				if ulvl then uses_level = true end
				local durvar = true
				if details.dur_variable ~= nil then durvar = details.dur_variable end
				if durvar then has_plus = true end
				pdef._effect_list[name] = {
					uses_level = ulvl,
					level = details.level or 1,
					level_scaling = details.level_scaling or 1,
					dur = details.dur or mcl_potions.DURATION,
					dur_variable = durvar,
					effect_stacks = details.effect_stacks and true or false
				}
			else
				error("Unable to register potion: effect not registered")
			end
		end
	end
	if def.uses_level ~= nil then uses_level = def.uses_level end
	pdef.uses_level = uses_level
	if def.has_potent ~= nil then pdef.has_potent = def.has_potent
	else pdef.has_potent = uses_level end
	pdef._default_potent_level = def.default_potent_level or 2
	pdef._default_extend_level = def.default_extend_level or 1
	pdef.has_plus = has_plus
	local on_use
	if def.drinkable ~= false then
		on_use = generate_on_use(pdef._effect_list, color, def.custom_on_use, def.custom_effect)
	end
	pdef.on_place = on_use
	pdef.on_secondary_use = on_use

	local internal_def = table.copy(pdef)
	minetest.register_craftitem(modname..":"..name, pdef)

	if def.has_splash or def.has_splash == nil then
		local splash_desc
		if def.desc_prefix and def.desc_suffix then
			splash_desc = S("Splash @1 Potion @2", def.desc_prefix, def.desc_suffix)
		elseif def.desc_prefix then
			splash_desc = S("Splash @1 Potion", def.desc_prefix)
		elseif def.desc_suffix then
			splash_desc = S("Splash Potion @1", def.desc_suffix)
		else
			splash_desc = S("Splash Strange Potion")
		end
		local sdef = {}
		sdef._tt = def._tt
		sdef._dynamic_tt = def._dynamic_tt
		sdef._longdesc = def._longdesc
		sdef.nocreative = def.nocreative
		sdef.stack_max = pdef.stack_max
		sdef._effect_list = pdef._effect_list
		sdef.uses_level = uses_level
		sdef.has_potent = pdef.has_potent
		sdef.has_plus = has_plus
		sdef._default_potent_level = pdef._default_potent_level
		sdef._default_extend_level = pdef._default_extend_level
		sdef.custom_effect = def.custom_effect
		sdef.on_splash = def.custom_splash_effect
		if not def._effect_list then sdef.instant = true end
		mcl_potions.register_splash(name, splash_desc, color, sdef)
		internal_def.has_splash = true
	end

	if def.has_lingering or def.has_lingering == nil then
		local ling_desc
		if def.desc_prefix and def.desc_suffix then
			ling_desc = S("Lingering @1 Potion @2", def.desc_prefix, def.desc_suffix)
		elseif def.desc_prefix then
			ling_desc = S("Lingering @1 Potion", def.desc_prefix)
		elseif def.desc_suffix then
			ling_desc = S("Lingering Potion @1", def.desc_suffix)
		else
			ling_desc = S("Lingering Strange Potion")
		end
		local ldef = {}
		ldef._tt = def._tt
		ldef._dynamic_tt = def._dynamic_tt
		ldef._longdesc = def._longdesc
		ldef.nocreative = def.nocreative
		ldef.stack_max = pdef.stack_max
		ldef._effect_list = pdef._effect_list
		ldef.uses_level = uses_level
		ldef.has_potent = pdef.has_potent
		ldef.has_plus = has_plus
		ldef._default_potent_level = pdef._default_potent_level
		ldef._default_extend_level = pdef._default_extend_level
		ldef.custom_effect = def.custom_effect
		ldef.on_splash = def.custom_splash_effect
		ldef.while_lingering = def.custom_linger_effect
		if not def._effect_list then ldef.instant = true end
		mcl_potions.register_lingering(name, ling_desc, color, ldef)
		internal_def.has_lingering = true
	end

	if def.has_arrow then
		local arr_desc
		if def.desc_prefix and def.desc_suffix then
			arr_desc = S("@1 Arrow @2", def.desc_prefix, def.desc_suffix)
		elseif def.desc_prefix then
			arr_desc = S("@1 Arrow", def.desc_prefix)
		elseif def.desc_suffix then
			arr_desc = S("Arrow @1", def.desc_suffix)
		else
			arr_desc = S("Strange Tipped Arrow")
		end
		local adef = {}
		adef._tt = def._tt
		adef._dynamic_tt = def._dynamic_tt
		adef._longdesc = def._longdesc
		adef.nocreative = def.nocreative
		adef._effect_list = pdef._effect_list
		adef.uses_level = uses_level
		adef.has_potent = pdef.has_potent
		adef.has_plus = has_plus
		adef._default_potent_level = pdef._default_potent_level
		adef._default_extend_level = pdef._default_extend_level
		adef.custom_effect = def.custom_effect
		if not def._effect_list then adef.instant = true end
		mcl_potions.register_arrow(name, arr_desc, color, adef)
		internal_def.has_arrow = true
	end

	mcl_potions.registered_potions[modname..":"..name] = internal_def
end

mcl_potions.register_potion({
	name = "trolling",
	desc_prefix = S("Mighty"),
	desc_suffix = S("of Trolling"),
	_tt = "trololo",
	_dynamic_tt = function(level)
		return "trolololoooololo"
	end,
	_longdesc = "Trolololololo",
	stack_max = 2,
	color = "#00AA00",
	nocreative = true,
	_effect_list = {
		night_vision = {},
		strength = {},
		swiftness = {
			uses_level = false,
			level = 2,
		},
		poison = {
			dur = 10,
		},
	},
	default_potent_level = 5,
	default_extend_level = 3,
	custom_splash_effect = mcl_potions._extinguish_nearby_fire,
	has_arrow = true,
})



-- ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
-- ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║
-- ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║
-- ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
-- ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝
--
-- ██████╗░███████╗███████╗██╗███╗░░██╗██╗████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔══██╗██╔════╝██╔════╝██║████╗░██║██║╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- ██║░░██║█████╗░░█████╗░░██║██╔██╗██║██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██║░░██║██╔══╝░░██╔══╝░░██║██║╚████║██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██████╔╝███████╗██║░░░░░██║██║░╚███║██║░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═════╝░╚══════╝╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


minetest.register_craftitem("mcl_potions:dragon_breath", {
	description = S("Dragon's Breath"),
	_longdesc = S("This item is used in brewing and can be combined with splash potions to create lingering potions."),
	image = "mcl_potions_dragon_breath.png",
	groups = { brewitem = 1, bottle = 1 },
	stack_max = 64,
})

mcl_potions.register_potion({
	name = "awkward",
	desc_prefix = S("Awkward"),
	_tt = S("No effect"),
	_longdesc = S("Has an awkward taste and is used for brewing potions."),
	color = "#0000FF",
})

mcl_potions.register_potion({
	name = "mundane",
	desc_prefix = S("Mundane"),
	_tt = S("No effect"),
	_longdesc = S("Has a terrible taste and is not really useful for brewing potions."),
	color = "#0000FF",
})

mcl_potions.register_potion({
	name = "thick",
	desc_prefix = S("Thick"),
	_tt = S("No effect"),
	_longdesc = S("Has a bitter taste and may be useful for brewing potions."),
	color = "#0000FF",
})

mcl_potions.register_potion({
	name = "healing",
	desc_suffix = S("of Healing"),
	_dynamic_tt = function(level)
		return S("+@1 HP", 4 * level)
	end,
	_longdesc = S("Instantly heals."),
	color = "#F82423",
	uses_level = true,
	has_arrow = true,
	custom_effect = function(object, level)
		return mcl_potions.healing_func(object, 4 * level)
	end,
})

mcl_potions.register_potion({
	name = "harming",
	desc_suffix = S("of Harming"),
	_dynamic_tt = function(level)
		return S("-@1 HP", 6 * level)
	end,
	_longdesc = S("Instantly deals damage."),
	color = "#430A09",
	uses_level = true,
	has_arrow = true,
	custom_effect = function(object, level)
		return mcl_potions.healing_func(object, -6 * level)
	end,
})

mcl_potions.register_potion({
	name = "night_vision",
	desc_suffix = S("of Night Vision"),
	_tt = nil,
	_longdesc = S("Increases the perceived brightness of light under a dark sky."),
	color = "#1F1FA1",
	_effect_list = {
		night_vision = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "swiftness",
	desc_suffix = S("of Swiftness"),
	_tt = nil,
	_longdesc = S("Increases walking speed."),
	color = "#7CAFC6",
	_effect_list = {
		swiftness = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "slowness",
	desc_suffix = S("of Slowness"),
	_tt = nil,
	_longdesc = S("Decreases walking speed."),
	color = "#5A6C81",
	_effect_list = {
		slowness = {dur=mcl_potions.DURATION_INV},
	},
	default_potent_level = 4,
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "leaping",
	desc_suffix = S("of Leaping"),
	_tt = nil,
	_longdesc = S("Increases jump strength."),
	color = "#22FF4C",
	_effect_list = {
		leaping = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "withering",
	desc_suffix = S("of Withering"),
	_tt = nil,
	_longdesc = S("Applies the withering effect which deals damage at a regular interval and can kill."),
	color = "#292929",
	_effect_list = {
		withering = {dur=mcl_potions.DURATION_POISON},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "poison",
	desc_suffix = S("of Poison"),
	_tt = nil,
	_longdesc = S("Applies the poison effect which deals damage at a regular interval."),
	color = "#4E9331",
	_effect_list = {
		poison = {dur=mcl_potions.DURATION_POISON},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "regeneration",
	desc_suffix = S("of Regeneration"),
	_tt = nil,
	_longdesc = S("Regenerates health over time."),
	color = "#CD5CAB",
	_effect_list = {
		regeneration = {dur=mcl_potions.DURATION_POISON},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "invisibility",
	desc_suffix = S("of Invisibility"),
	_tt = nil,
	_longdesc = S("Grants invisibility."),
	color = "#7F8392",
	_effect_list = {
		invisibility = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "water_breathing",
	desc_suffix = S("of Water Breathing"),
	_tt = nil,
	_longdesc = S("Grants limitless breath underwater."),
	color = "#2E5299",
	_effect_list = {
		water_breathing = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "fire_resistance",
	desc_suffix = S("of Fire Resistance"),
	_tt = nil,
	_longdesc = S("Grants immunity to damage from heat sources like fire."),
	color = "#E49A3A",
	_effect_list = {
		fire_resistance = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "strength",
	desc_suffix = S("of Strength"),
	_tt = nil,
	_longdesc = S("Increases attack power."),
	color = "#932423",
	_effect_list = {
		strength = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "weakness",
	desc_suffix = S("of Weakness"),
	_tt = nil,
	_longdesc = S("Decreases attack power."),
	color = "#484D48",
	_effect_list = {
		weakness = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "slow_falling",
	desc_suffix = S("of Slow Falling"),
	_tt = nil,
	_longdesc = S("Instead of falling, you descend gracefully."),
	color = "#ACCCFF",
	_effect_list = {
		slow_falling = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "levitation",
	desc_suffix = S("of Levitation"),
	_tt = nil,
	_longdesc = S("Floats body slowly upwards."),
	color = "#420E7E",
	_effect_list = {
		levitation = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "darkness",
	desc_suffix = S("of Darkness"),
	_tt = nil,
	_longdesc = S("Surrounds with darkness."),
	color = "#000000",
	_effect_list = {
		darkness = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "glowing",
	desc_suffix = S("of Glowing"),
	_tt = nil,
	_longdesc = S("Highlights for others to see."),
	color = "#FFFF77",
	_effect_list = {
		glowing = {},
	},
	has_arrow = false, -- TODO add a spectral arrow instead (in mcl_bows?)
})

mcl_potions.register_potion({
	name = "health_boost",
	desc_suffix = S("of Health Boost"),
	_tt = nil,
	_longdesc = S("Increases health."),
	color = "#BE1919",
	_effect_list = {
		health_boost = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "absorption",
	desc_suffix = S("of Absorption"),
	_tt = nil,
	_longdesc = S("Absorbs some incoming damage."),
	color = "#B59500",
	_effect_list = {
		absorption = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "resistance",
	desc_suffix = S("of Resistance"),
	_tt = nil,
	_longdesc = S("Decreases damage taken."),
	color = "#2552A5",
	_effect_list = {
		resistance = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "stone_cloak",
	desc_suffix = S("of Stone Cloak"),
	_tt = nil,
	_longdesc = S("Decreases damage taken at the cost of speed."),
	color = "#255235",
	_effect_list = {
		resistance = {
			level = 3,
			dur = 20,
		},
		slowness = {
			level = 4,
			level_scaling = 2,
			dur = 20,
		},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "luck",
	desc_suffix = S("of Luck"),
	_tt = nil,
	_longdesc = S("Increases luck."),
	color = "#7BFF42",
	_effect_list = {
		luck = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "bad_luck",
	desc_suffix = S("of Bad Luck"),
	_tt = nil,
	_longdesc = S("Decreases luck."),
	color = "#887343",
	_effect_list = {
		bad_luck = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "frost",
	desc_suffix = S("of Frost"),
	_tt = nil,
	_longdesc = S("Freezes..."),
	color = "#5B7DAA",
	_effect_list = {
		frost = {
			dur = mcl_potions.DURATION_POISON,
			effect_stacks = true,
		},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "blindness",
	desc_suffix = S("of Blindness"),
	_tt = nil,
	_longdesc = S("Impairs sight."),
	color = "#586868",
	_effect_list = {
		blindness = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "nausea",
	desc_suffix = S("of Nausea"),
	_tt = nil,
	_longdesc = S("Disintegrates senses."),
	color = "#715C7F",
	_effect_list = {
		nausea = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "food_poisoning",
	desc_suffix = S("of Food Poisoning"),
	_tt = nil,
	_longdesc = S("Moves bowels too fast."),
	color = "#83A061",
	_effect_list = {
		food_poisoning = {
			dur = mcl_potions.DURATION_POISON,
			effect_stacks = true,
		},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "saturation",
	desc_suffix = S("of Saturation"),
	_tt = nil,
	_longdesc = S("Satisfies hunger."),
	color = "#CEAE29",
	_effect_list = {
		saturation = {dur=mcl_potions.DURATION_POISON},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "haste",
	desc_suffix = S("of Haste"),
	_tt = nil,
	_longdesc = S("Increases digging and attack speed."),
	color = "#FFFF00",
	_effect_list = {
		haste = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "fatigue",
	desc_suffix = S("of Fatigue"),
	_tt = nil,
	_longdesc = S("Decreases digging and attack speed."),
	color = "#64643D",
	_effect_list = {
		fatigue = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "ominous",
	desc_prefix = S("Ominous"),
	_tt = nil,
	_longdesc = S("Attracts danger."),
	image = table.concat({
		"(mcl_potions_potion_overlay.png^[colorize:red:100)",
		"^mcl_potions_splash_overlay.png^[colorize:black:100",
		"^mcl_potions_potion_bottle.png",
	}),
	_effect_list = {
		bad_omen = {dur = 6000},
	},
	has_splash = false,
	has_lingering = false,
})




-- COMPAT CODE
local function replace_legacy_potion(itemstack)
	local name = itemstack:get_name()
	local suffix = ""
	local bare_name = name:match("^(.+)_splash$")
	if bare_name then
		suffix = "_splash"
	else
		bare_name = name:match("^(.+)_lingering$")
		if bare_name then
			suffix = "_lingering"
		else
			bare_name = name:match("^(.+)_arrow$")
			if bare_name then
				suffix = "_arrow"
			else
				bare_name = name
			end
		end
	end
	local new_name = bare_name:match("^(.+)_plus$")
	local new_stack
	if new_name then
		new_stack = ItemStack(new_name..suffix)
		new_stack:get_meta():set_int("mcl_potions:potion_plus",
			registered_potions[new_name]._default_extend_level)
		new_stack:set_count(itemstack:get_count())
		tt.reload_itemstack_description(new_stack)
	end
	new_name = bare_name:match("^(.+)_2$")
	if new_name then
		new_stack = ItemStack(new_name..suffix)
		new_stack:get_meta():set_int("mcl_potions:potion_potent",
			registered_potions[new_name]._default_potent_level-1)
		new_stack:set_count(itemstack:get_count())
		tt.reload_itemstack_description(new_stack)
	end
	return new_stack
end
local compat = "mcl_potions:compat_potion"
local compat_arrow = "mcl_potions:compat_arrow"
local compat_def = {
	description = S("Unknown Potion") .. "\n" .. minetest.colorize("#ff0", S("Right-click to identify")),
	image = "mcl_potions_potion_overlay.png^[colorize:#00F:127^mcl_potions_potion_bottle.png^vl_unknown.png",
	groups = {not_in_creative_inventory = 1},
	on_secondary_use = replace_legacy_potion,
	on_place = replace_legacy_potion,
}
local compat_arrow_def = {
	description = S("Unknown Tipped Arrow") .. "\n" .. minetest.colorize("#ff0", S("Right-click to identify")),
	image = "mcl_bows_arrow_inv.png^(mcl_potions_arrow_inv.png^[colorize:#FFF:100)^vl_unknown.png",
	groups = {not_in_creative_inventory = 1},
	on_secondary_use = replace_legacy_potion,
	on_place = replace_legacy_potion,
}
minetest.register_craftitem(compat, compat_def)
minetest.register_craftitem(compat_arrow, compat_arrow_def)

local old_potions_plus = {
	"fire_resistance", "water_breathing", "invisibility", "regeneration", "poison",
	"withering", "leaping", "slowness", "swiftness", "night_vision"
}
local old_potions_2 = {
	"healing", "harming", "swiftness", "slowness", "leaping",
	"withering", "poison", "regeneration"
}

for _, name in pairs(old_potions_2) do
	core.register_craftitem("mcl_potions:" .. name .. "_2", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_2_splash", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_2_lingering", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_2_arrow", table.copy(compat_arrow_def))
end
for _, name in pairs(old_potions_plus) do
	core.register_craftitem("mcl_potions:" .. name .. "_plus", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_plus_splash", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_plus_lingering", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_plus_arrow", table.copy(compat_arrow_def))
end
