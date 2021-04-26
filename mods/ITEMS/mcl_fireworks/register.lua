local S = minetest.get_translator("mcl_fireworks")

player_rocketing = {}

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
      local torso = user:get_inventory():get_stack("armor", 3)
      if torso and torso:get_name() == "mcl_armor:elytra" and player_rocketing[user] ~= true then
        player_rocketing[user] = true
        minetest.after(2.2, function()
          player_rocketing[user] = false
        end)
        itemstack:take_item()
	      --user:add_player_velocity(vector.multiply(user:get_look_dir(), 20))
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
      local torso = user:get_inventory():get_stack("armor", 3)
      if torso and torso:get_name() == "mcl_armor:elytra" and player_rocketing[user] ~= true then
        player_rocketing[user] = true
        minetest.after(4.5, function()
          player_rocketing[user] = false
        end)
        itemstack:take_item()
	      --user:add_player_velocity(vector.multiply(user:get_look_dir(), 20))
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
    on_use = function(itemstack, user, pointed_thing)
      local torso = user:get_inventory():get_stack("armor", 3)
      if torso and torso:get_name() == "mcl_armor:elytra" and player_rocketing[user] ~= true then
        player_rocketing[user] = true
        minetest.after(6, function()
          player_rocketing[user] = false
        end)
        itemstack:take_item()
	      --user:add_player_velocity(vector.multiply(user:get_look_dir(), 20))
        rocket_sound()
      end
      return itemstack
    end,
})
