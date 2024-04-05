local modname = minetest.get_current_modname()

mcl_minecarts = {}
local mod = mcl_minecarts
mcl_minecarts.modpath = minetest.get_modpath(modname)
mcl_minecarts.speed_max = 10
mcl_minecarts.check_float_time = 15

dofile(mcl_minecarts.modpath.."/functions.lua")
dofile(mcl_minecarts.modpath.."/rails.lua")
dofile(mcl_minecarts.modpath.."/carts.lua")
