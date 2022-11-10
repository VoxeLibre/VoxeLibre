mcl_mobs = {}
mcl_mobs.mob_class = {}
mcl_mobs.mob_class_meta = {__index = mcl_mobs.mob_class}

local path = minetest.get_modpath(minetest.get_current_modname())

--api and helpers
-- effects: sounds and particles mostly
dofile(path .. "/effects.lua")
-- physics: involuntary mob movement - particularly falling and death
dofile(path .. "/physics.lua")
-- movement: general voluntary mob movement, walking avoiding cliffs etc.
dofile(path .. "/movement.lua")
-- items: item management for mobs
dofile(path .. "/items.lua")
-- pathfinding: pathfinding to target positions
dofile(path .. "/pathfinding.lua")
-- combat: attack logic
dofile(path .. "/combat.lua")
-- the enity functions themselves
dofile(path .. "/api.lua")


--utility functions
dofile(path .. "/breeding.lua")
dofile(path .. "/spawning.lua")
dofile(path .. "/mount.lua")
dofile(path .. "/crafts.lua")
dofile(path .. "/compat.lua")
