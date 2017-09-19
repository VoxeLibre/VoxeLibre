-- Load files

mcl_portals = {}

-- Nether portal:
-- Obsidian frame, activated by flint and steel
dofile(minetest.get_modpath("mcl_portals").."/portal_nether.lua")

-- End portal (W.I.P):
-- Red nether brick block frame, activated by an eye of ender
dofile(minetest.get_modpath("mcl_portals").."/portal_end.lua")

