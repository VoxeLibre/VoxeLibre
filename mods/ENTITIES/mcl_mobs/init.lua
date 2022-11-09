mcl_mobs = {}
mcl_mobs.mob_class = {}
mcl_mobs.mob_class_meta = {__index = mcl_mobs.mob_class}

local path = minetest.get_modpath(minetest.get_current_modname())

--api and helpers
dofile(path .. "/effects.lua")
dofile(path .. "/physics.lua")
dofile(path .. "/items.lua")
dofile(path .. "/pathfinding.lua")
dofile(path .. "/api.lua")

--utility functions
dofile(path .. "/breeding.lua")
dofile(path .. "/spawning.lua")
dofile(path .. "/mount.lua")
dofile(path .. "/crafts.lua")
dofile(path .. "/compat.lua")
