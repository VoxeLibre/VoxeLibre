local init = os.clock()

dofile(minetest.get_modpath("mobs").."/api.lua")

-- Items
dofile(minetest.get_modpath("mobs").."/item.lua")

-- Mouton
dofile(minetest.get_modpath("mobs").."/sheep.lua")

-- Zombie
dofile(minetest.get_modpath("mobs").."/zombie.lua")

-- Slime
dofile(minetest.get_modpath("mobs").."/slime.lua")

-- Creeper
dofile(minetest.get_modpath("mobs").."/creeper.lua")

-- Spider
dofile(minetest.get_modpath("mobs").."/spider.lua")

-- Herobrine
dofile(minetest.get_modpath("mobs").."/herobrine.lua")


if minetest.setting_getbool("spawn_friendly_mobs") ~= false then -- “If not defined or set to true then”
	mobs:register_spawn("mobs:sheep", "Sheep", {"default:dirt_with_grass"},16, 8, 2, 250, 100)
end
if minetest.setting_getbool("spawn_hostile_mobs") ~= false then -- “If not defined or set to true then”
	mobs:register_spawn("mobs:slime", "Slime", { "default:dirt_with_grass"}, 20, 1, 11, 80, 0)
	mobs:register_spawn("mobs:herobrine", "Herobrine",     {"head:herobine"}, 20, -1, 100, 1, 0)
	mobs:register_spawn("mobs:zombie", "Zombie",     {"default:stone", "default:dirt", "default:dirt_with_grass", "default:sand"}, 1, -1, 7, 80, 0)
	mobs:register_spawn("mobs:spider", "Spider",     {"default:stone", "default:dirt", "default:dirt_with_grass", "default:sand"}, 1, -1, 7, 40, 0)
end

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))

