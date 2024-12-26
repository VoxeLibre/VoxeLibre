mcl_bows = {}
local modpath = core.get_modpath("mcl_bows")

--Bow
dofile(modpath.."/arrow.lua")
dofile(modpath.."/bow.lua")
dofile(modpath.."/rocket.lua")

--Crossbow
dofile(modpath.."/crossbow.lua")

--Compatiblility with older MineClone worlds
minetest.register_alias("mcl_throwing:bow", "mcl_bows:bow")
minetest.register_alias("mcl_throwing:arrow", "mcl_bows:arrow")
