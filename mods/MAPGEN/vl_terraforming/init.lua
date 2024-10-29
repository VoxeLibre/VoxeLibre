local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
vl_terraforming = {}

dofile(modpath.."/util.lua")
dofile(modpath.."/clearance.lua")
dofile(modpath.."/clearance_vm.lua")
dofile(modpath.."/foundation.lua")
dofile(modpath.."/foundation_vm.lua")
dofile(modpath.."/level.lua")
dofile(modpath.."/level_vm.lua")
