local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
mcl_minecarts = {}
local mod = mcl_minecarts
mcl_minecarts.modpath = modpath

-- Constants
mcl_minecarts.speed_max = 10
mcl_minecarts.check_float_time = 15
mcl_minecarts.FRICTION = 0.4

for _,filename in pairs({"storage","functions","rails","train","carts"}) do
	dofile(modpath.."/"..filename..".lua")
end
