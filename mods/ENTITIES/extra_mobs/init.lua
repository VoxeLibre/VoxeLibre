--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local path = minetest.get_modpath("extra_mobs")

if not minetest.get_modpath("mobs_mc_gameconfig") then
	mobs_mc = {}
end

--Monsters
dofile(path .. "/herobrine.lua")
dofile(path .. "/hoglin+zoglin.lua")
dofile(path .. "/piglin.lua")

--Animals
dofile(path .. "/strider.lua")
dofile(path .. "/fox.lua")
dofile(path .. "/cod.lua")
dofile(path .. "/salmon.lua")
dofile(path .. "/dolphin.lua")
dofile(path .. "/glow_squid.lua")

--Items
dofile(path .. "/glow_squid_items.lua")


