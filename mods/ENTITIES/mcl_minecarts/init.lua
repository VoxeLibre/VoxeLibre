local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
mcl_minecarts = {}
local mod = mcl_minecarts
mcl_minecarts.modpath = modpath

-- Constants
mod.speed_max = 10
mod.check_float_time = 15
mod.FRICTION = 0.4
mod.MAX_TRAIN_LENGTH = 4

for _,filename in pairs({"storage","functions","rails","train","carts"}) do
	dofile(modpath.."/"..filename..".lua")
end
