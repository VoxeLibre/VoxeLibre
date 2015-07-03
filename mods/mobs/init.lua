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


---mobs:register_spawn(name, description, nodes, max_light, min_light, chance, active_object_count, max_height, spawn_func)
if minetest.setting_getbool("spawn_friendly_mobs") ~= false then -- “If not defined or set to true then”
		mobs:register_spawn("mobs:sheep", "Sheep", {"default:dirt_with_grass"},16, 8, 2, 250, 100)
end
if minetest.setting_getbool("spawn_hostile_mobs") ~= false then -- “If not defined or set to true then”
		mobs:register_spawn("mobs:slime", "Slime", { "default:dirt_with_grass"}, 20, 1, 11, 80, 0)
		mobs:register_spawn("mobs:herobrine", "Herobrine",     {"head:herobine"}, 20, -1, 100, 1, 0)
		mobs:register_spawn("mobs:zombie", "Zombie",     {"default:stone", "default:dirt", "default:dirt_with_grass", "default:sand"}, 1, -1, 7, 80, 0)
		mobs:register_spawn("mobs:spider", "Spider",     {"default:stone", "default:dirt", "default:dirt_with_grass", "default:sand"}, 1, -1, 7, 40, 0)
--		mobs:register_spawn("mobs:stone_monster", "a stone monster",   {"default:stone", "default:desert_stone"}, 1, -1, 15000, 4, 0)
--		mobs:register_spawn("mobs:sand_monster", "a sand monster",     {"default:stone", "default:desert_stone"}, 1, -1, 15000, 4, 0)
--		mobs:register_spawn("mobs:oerkki", "an oerkki",                {"default:stone", "default:desert_stone"}, 1, -1, 20000, 4, 0)
--		mobs:register_spawn("mobs:tree_monster", "a tree monster",     {"default:stone", "default:desert_stone"}, 1, -1, 25000, 2, 0)
--		mobs:register_spawn("mobs:dungeon_master", "a dungeon master", {"default:stone", "default:desert_stone"}, 1, -1, 25000, 2, -50)
--		mobs:register_spawn("mobs:rhino", "a rhino",                   {"default:stone", "default:desert_stone"}, 1, -1, 25000, 2, 0)
end


local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))

