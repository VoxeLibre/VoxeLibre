local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/nodes.lua")
dofile(modpath.."/recipes.lua")
