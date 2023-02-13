
--                                          ____________________________
--_________________________________________/    Variables & Functions    \_________ 

local eat = minetest.item_eat(6, "mcl_core:bowl") --6 hunger points, player receives mcl_core:bowl after eating

local flower_effect = {
	[ "mcl_flowers:allium" ] = "fire_resistance",
	[ "mcl_flowers:lily_of_the_valley" ] = "poison",
	[ "mcl_flowers:blue_orchid" ] = "hunger",
	[ "mcl_flowers:dandelion" ] = "hunger",
	[ "mcl_flowers:cornflower" ] = "jump",
	[ "mcl_flowers:oxeye_daisy" ] = "regeneration",
	[ "mcl_flowers:poppy" ] = "night_vision"	
}

local effects = {
	[ "fire_resistance" ] = function(itemstack, placer, pointed_thing)
		mcl_potions.fire_resistance_func(placer, 1, 4)
		return eat(itemstack, placer, pointed_thing)
	end,
	[ "poison" ] = function(itemstack, placer, pointed_thing)
		mcl_potions.poison_func(placer, 1, 12)
		return eat(itemstack, placer, pointed_thing)
	end,

	[ "hunger" ] = function(itemstack, placer, pointed_thing, player)
		mcl_hunger.item_eat(6, "mcl_core:bowl", 3.5, 0, 100)
		return eat(itemstack, placer, pointed_thing)
	end,

	["jump"] = function(itemstack, placer, pointed_thing)
		mcl_potions.leaping_func(placer, 1, 6)
		return eat(itemstack, placer, pointed_thing)
	end,

	["regeneration"] = function(itemstack, placer, pointed_thing)
		mcl_potions.regeneration_func(placer, 1, 8)
		return eat(itemstack, placer, pointed_thing)
	end,

	["night_vision"] = function(itemstack, placer, pointed_thing)
		mcl_potions.night_vision_func(placer, 1, 5)
		return eat(itemstack, placer, pointed_thing)
	end,
}
local function get_random_effect()
	local keys = {}
	for k in pairs(effects) do
		table.insert(keys, k)
	end
	return effects[keys[math.random(#keys)]]
end

local function eat_stew(itemstack, placer, pointed_thing)
	local e = itemstack:get_meta():get_string("effect")
	local f = effects[e]
	if not f then
		f = get_random_effect()
	end
	if f(itemstack,placer,pointed_thing) then
		return "mcl_core:bowl"
	end
end

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() ~= "mcl_sus_stew:stew" then return end
	for f,e in pairs(flower_effect) do
		for _,it in pairs(old_craft_grid) do
			if it:get_name() == f then
				itemstack:get_meta():set_string("effect",e)
				return itemstack
			end
		end
	end
end)

--										  ________________________
--_________________________________________/	Item Regestration	\_________________
minetest.register_craftitem("mcl_sus_stew:stew",{
	description = "Suspicious Stew",
	inventory_image = "sus_stew.png",
	stack_max = 1,
	on_place = eat_stew,
	on_secondary_use = eat_stew,
	groups = { food = 2, eatable = 4, can_eat_when_full = 1, not_in_creative_inventory=1,},
	_mcl_saturation = 7.2,
})

mcl_hunger.register_food("mcl_sus_stew:stew",6, "mcl_core:bowl")

--compat with old (mcl5) sus_stew
minetest.register_alias("mcl_sus_stew:poison_stew", "mcl_sus_stew:stew")
minetest.register_alias("mcl_sus_stew:hunger_stew", "mcl_sus_stew:stew")
minetest.register_alias("mcl_sus_stew:jump_boost_stew", "mcl_sus_stew:stew")
minetest.register_alias("mcl_sus_stew:regneration_stew", "mcl_sus_stew:stew")
minetest.register_alias("mcl_sus_stew:night_vision_stew", "mcl_sus_stew:stew")

--										 ______________
--_________________________________________/	Crafts	\________________________________

minetest.register_craft({
	type = "shapeless",
	output = "mcl_sus_stew:stew",
	recipe = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown", "mcl_core:bowl", "mcl_flowers:allium"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_sus_stew:stew",
	recipe = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown", "mcl_core:bowl", "mcl_flowers:lily_of_the_valley"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_sus_stew:stew",
	recipe = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown", "mcl_core:bowl", "mcl_flowers:blue_orchid"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_sus_stew:stew",
	recipe = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown", "mcl_core:bowl", "mcl_flowers:dandelion"} ,
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_sus_stew:stew",
	recipe = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown", "mcl_core:bowl", "mcl_flowers:cornflower"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_sus_stew:stew",
	recipe = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown", "mcl_core:bowl", "mcl_flowers:oxeye_daisy"},
})

minetest.register_craft({
	type = "shapeless",
	output = "mcl_sus_stew:stew",
	recipe = {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown", "mcl_core:bowl", "mcl_flowers:poppy"},
})
