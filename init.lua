
--                                          ____________________________
--_________________________________________/    Variables & Functions    \_________ 

local eat = minetest.item_eat(6, "mcl_core:bowl") --6 hunger points, player receives mcl_core:bowl after eating



local function poison(itemstack, placer, pointed_thing)
    mcl_potions.poison_func(placer, 1, 12)
    return eat(itemstack, placer, pointed_thing)
end

local function hunger(itemstack, placer, pointed_thing, player)
    return eat(itemstack, placer, pointed_thing)
end

local function jump_boost(itemstack, placer, pointed_thing)
    mcl_potions.leaping_func(placer, 1, 6)
    return eat(itemstack, placer, pointed_thing)
end

local function regeneration(itemstack, placer, pointed_thing)
    mcl_potions.regeneration_func(placer, 1, 8)
    return eat(itemstack, placer, pointed_thing)
end

local function night_vision(itemstack, placer, pointed_thing)
    mcl_potions.night_vision_func(placer, 1, 5)
    return eat(itemstack, placer, pointed_thing)
end

--                                          ________________________
--_________________________________________/    Item Regestration    \_________________
minetest.register_craftitem("mcl_sus_stew:poison_stew",{
    description = "Suspicious Stew",
    inventory_image = "sus_stew.png",
    stack_max = 1, 
    on_place = poison,
    groups = { food = 2, eatable = 4, not_in_creative_inventory=1,},
    _mcl_saturation = 7.2,
})

minetest.register_craftitem("mcl_sus_stew:hunger_stew",{
    description = "Suspicious Stew",
    inventory_image = "sus_stew.png",
    stack_max = 1,
    on_place = hunger,
    groups = { food = 2, eatable = 4, not_in_creative_inventory=1,},
    _mcl_saturation = 7.2,
})

minetest.register_craftitem("mcl_sus_stew:jump_boost_stew",{
    description = "Suspicious Stew",
    inventory_image = "sus_stew.png", 
    stack_max = 1, 
    on_place = jump_boost,
    groups = { food = 2, eatable = 4, not_in_creative_inventory=1,},
    _mcl_saturation = 7.2,
})

minetest.register_craftitem("mcl_sus_stew:regneration_stew",{
    description = "Suspicious Stew",
    inventory_image = "sus_stew.png", 
    stack_max = 1, 
    on_place = regeneration,
    groups = { food = 2, eatable = 4, not_in_creative_inventory=1,},
    _mcl_saturation = 7.2,
})

minetest.register_craftitem("mcl_sus_stew:night_vision_stew",{
    description = "Suspicious Stew",
    inventory_image = "sus_stew.png", 
    stack_max = 1, 
    on_place = night_vision,
    groups = { food = 2, eatable = 4, not_in_creative_inventory=1,},
    _mcl_saturation = 7.2,
})

--                                      ____________________________
--______________________________________/   Using mcl_hunger API    \______________________
mcl_hunger.register_food("mcl_sus_stew:hunger_stew",6, "mcl_core:bowl", 3.5, 0, 100) -- Register it using mcl_hunger so i can use its poison feature


--                                         ______________
--_________________________________________/    Crafts    \________________________________

minetest.register_craft({
    output = "mcl_sus_stew:poison_stew",
    recipe = { {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}, {"mcl_core:bowl", "mcl_flowers:tulip_white"} },
})

minetest.register_craft({
    output = "mcl_sus_stew:hunger_stew",
    recipe = { {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}, {"mcl_core:bowl", "mcl_flowers:blue_orchid"} },
})

minetest.register_craft({
    output = "mcl_sus_stew:hunger_stew",
    recipe = { {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}, {"mcl_core:bowl", "mcl_flowers:dandelion"} },
})

minetest.register_craft({
    output = "mcl_sus_stew:jump_boost_stew",
    recipe = { {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}, {"mcl_core:bowl", "mcl_flowers:peony"} },
})

minetest.register_craft({
    output = "mcl_sus_stew:regeneration_stew",
    recipe = { {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}, {"mcl_core:bowl", "mcl_flowers:oxeye_daisy"} },
})

minetest.register_craft({
    output = "mcl_sus_stew:night_vision_stew",
    recipe = { {"mcl_mushrooms:mushroom_red", "mcl_mushrooms:mushroom_brown"}, {"mcl_core:bowl", "mcl_flowers:poppy"} },
})
