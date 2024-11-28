-- Luanti 0.4 mod: mcl_stairs
-- See README.txt for licensing and other information.

-- Global namespace for functions

mcl_stairs = {}

-- Load other files

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/api.lua")
dofile(modpath.."/cornerstair.lua")
dofile(modpath.."/register.lua")
dofile(modpath.."/crafting.lua")
dofile(modpath.."/alias.lua")
