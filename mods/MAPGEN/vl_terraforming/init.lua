local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
vl_terraforming = {}

dofile(modpath.."/util.lua")
dofile(modpath.."/clearance.lua")
dofile(modpath.."/foundation.lua")
dofile(modpath.."/level.lua")
