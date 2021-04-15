
local path = minetest.get_modpath(minetest.get_current_modname())

local api_path = path.."/api"

-- Mob API
dofile(api_path .. "/api.lua")

-- Spawning Algorithm
dofile(api_path .. "/spawning.lua")

-- Rideable Mobs
dofile(api_path .. "/mount.lua")

-- Mob Items
dofile(path .. "/crafts.lua")