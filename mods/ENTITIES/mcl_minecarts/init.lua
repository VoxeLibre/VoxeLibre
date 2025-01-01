local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)
mcl_minecarts = {}
local mod = mcl_minecarts
mcl_minecarts.modpath = modpath

-- Constants
mod.SPEED_MAX = 10
mod.FRICTION = 0.4
mod.OFF_RAIL_FRICTION = 1.2
mod.MAX_TRAIN_LENGTH = 4
mod.CART_BLOCK_SIZE = 64
mod.PASSENGER_ATTACH_POSITION = vector.new(0, -1.75, 0)

vl_tuning.setting("gamerule:minecartMaxSpeed", "number", {
	set = function(value) mod.SPEED_MAX = value end,
	get = function() return mod.SPEED_MAX end,
	default = 10,
	description = S("The maximum speed a minecart may reach.")
})

for _,filename in pairs({"storage","functions","rails","train","carts"}) do
	dofile(modpath.."/"..filename..".lua")
end
