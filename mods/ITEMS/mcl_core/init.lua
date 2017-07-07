mcl_core = {}

-- Repair percentage for toolrepair
mcl_core.repair = 0.05

-- Load files
dofile(minetest.get_modpath("mcl_core").."/functions.lua")
dofile(minetest.get_modpath("mcl_core").."/nodes_base.lua")
dofile(minetest.get_modpath("mcl_core").."/nodes_cactuscane.lua")
dofile(minetest.get_modpath("mcl_core").."/nodes_trees.lua")
dofile(minetest.get_modpath("mcl_core").."/nodes_glass.lua")
dofile(minetest.get_modpath("mcl_core").."/nodes_misc.lua")
dofile(minetest.get_modpath("mcl_core").."/craftitems.lua")
dofile(minetest.get_modpath("mcl_core").."/crafting.lua")
