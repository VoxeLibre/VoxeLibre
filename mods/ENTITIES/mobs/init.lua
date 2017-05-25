
local path = minetest.get_modpath("mobs")

-- Mob API
dofile(path .. "/api.lua")

-- Mob Items
dofile(path .. "/crafts.lua")

-- Mob Spawner
-- moved into other mod (MCL2 change)

-- Lucky Blocks
dofile(path .. "/lucky_block.lua")

print ("[MOD] Mobs Redo loaded")
