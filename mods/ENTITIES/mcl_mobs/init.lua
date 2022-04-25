
local path = minetest.get_modpath(minetest.get_current_modname())

-- Mob API
dofile(path .. "/api.lua")

-- Spawning Algorithm
dofile(path .. "/spawning.lua")

-- Rideable Mobs
dofile(path .. "/mount.lua")

-- Mob Items
dofile(path .. "/crafts.lua")