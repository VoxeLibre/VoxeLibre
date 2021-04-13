local S = minetest.get_translator("mcl_fireworks")

local help = S("Flight Duration:")
local description = S("Firework Rocket")
local rocket_sound = function()
    minetest.sound_play("mcl_fireworks_rocket")
end

minetest.register_craftitem("mcl_fireworks:rocket_1", {
    description = description,
    _tt_help = help.." 1",
    inventory_image = "mcl_fireworks_rocket.png",
    stack_max = 64,
    on_use = function(itemstack, user, pointed_thing)
    	itemstack:take_item()
        local torso = user:get_inventory():get_stack("armor", 3)
        if torso and torso:get_name() == "mcl_armor:elytra" then 
			user:add_player_velocity(vector.multiply(user:get_look_dir(), 20))
            rocket_sound()
        end
        return itemstack   
    end,
})

minetest.register_craftitem("mcl_fireworks:rocket_2", {
    description = description,
    _tt_help = help.." 2",
    inventory_image = "mcl_fireworks_rocket.png",
    stack_max = 64,
    on_use = function(itemstack, user, pointed_thing)
    	itemstack:take_item()
        local torso = user:get_inventory():get_stack("armor", 3)
        if torso and torso:get_name() == "mcl_armor:elytra" then 
			user:add_player_velocity(vector.multiply(user:get_look_dir(), 30))
            rocket_sound()
        end
        return itemstack   
    end,
})

minetest.register_craftitem("mcl_fireworks:rocket_3", {
    description = description,
    _tt_help = help.." 3",
    inventory_image = "mcl_fireworks_rocket.png",
    stack_max = 64,
    on_use = function(itemstack, user, pointed_thing, player)
    	itemstack:take_item()
        local torso = user:get_inventory():get_stack("armor", 3)
        if torso and torso:get_name() == "mcl_armor:elytra" then 
			user:add_player_velocity(vector.multiply(user:get_look_dir(), 40))
            rocket_sound()
        end
        return itemstack   
    end,
})
