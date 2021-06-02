-- Load files

mcl_portals = {
	storage = minetest.get_mod_storage(),
}

local modpath = minetest.get_modpath(minetest.get_current_modname())

-- Nether portal:
-- Obsidian frame, activated by flint and steel
dofile(modpath.."/portal_nether.lua")

-- End portal (W.I.P):
-- Red nether brick block frame, activated by an eye of ender
dofile(modpath.."/portal_end.lua")

dofile(modpath.."/portal_gateway.lua")

