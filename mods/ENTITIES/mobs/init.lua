
local path = minetest.get_modpath("mobs")

-- Mob API
dofile(path .. "/api.lua")

-- Rideable Mobs
dofile(path .. "/mount.lua")

minetest.log("action", "[MOD] Mobs Redo loaded")
