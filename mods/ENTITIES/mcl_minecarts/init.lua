local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
mcl_minecarts = {}
local mod = mcl_minecarts
mcl_minecarts.modpath = modpath

-- Constants
mod.SPEED_MAX = 10
mod.FRICTION = 0.4
mod.MAX_TRAIN_LENGTH = 4
mod.CART_BLOCK_SIZE = 64
mod.PASSENGER_ATTACH_POSITION = vector.new(0, -1.75, 0)

for _,filename in pairs({"storage","functions","rails","train","carts"}) do
	dofile(modpath.."/"..filename..".lua")
end
