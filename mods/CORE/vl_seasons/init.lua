local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath.."/season-cycle.lua")
dofile(modpath.."/chatcommands.lua")
dofile(modpath.."/node-overrides.lua")