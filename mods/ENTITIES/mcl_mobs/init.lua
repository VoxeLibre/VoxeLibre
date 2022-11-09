mcl_mobs = {}
mcl_mobs.mob_class = {}
mcl_mobs.mob_class_meta = {__index = mcl_mobs.mob_class}
local path = minetest.get_modpath(minetest.get_current_modname())

dofile(path .. "/effects.lua")
dofile(path .. "/physics.lua")

-- Mob API
dofile(path .. "/api.lua")

dofile(path .. "/breeding.lua")

-- Spawning Algorithm
dofile(path .. "/spawning.lua")

-- Rideable Mobs
dofile(path .. "/mount.lua")

-- Mob Items
dofile(path .. "/crafts.lua")

dofile(path .. "/compat.lua")
