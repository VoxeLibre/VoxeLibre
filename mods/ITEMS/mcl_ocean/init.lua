mcl_ocean = {
	mapgen = {}
}
local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Prismarine (includes sea lantern)
dofile(modpath.."/prismarine.lua")

-- Corals
dofile(modpath.."/corals.lua")

-- Seagrass
dofile(modpath.."/seagrass.lua")

-- Kelp
dofile(modpath.."/kelp.lua")

-- Sea Pickle
dofile(modpath.."/sea_pickle.lua")

