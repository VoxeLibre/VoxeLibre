mcl_core = {}

-- Repair percentage for toolrepair
mcl_core.repair = 0.05

-- Load files
dofile(minetest.get_modpath("mcl_core").."/functions.lua")
dofile(minetest.get_modpath("mcl_core").."/nodes.lua")
dofile(minetest.get_modpath("mcl_core").."/tools.lua")
dofile(minetest.get_modpath("mcl_core").."/craftitems.lua")
dofile(minetest.get_modpath("mcl_core").."/crafting.lua")
