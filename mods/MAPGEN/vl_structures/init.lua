local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

vl_structures = {}

-- see vl_terraforming for documentation
vl_structures.DEFAULT_PREPARE = { tolerance = 10, foundation = -3, clear = false, clear_bottom = 0, clear_top = 4, padding = 1, corners = 1 }
vl_structures.DEFAULT_FLAGS = "place_center_x,place_center_z"

dofile(modpath.."/util.lua")
dofile(modpath.."/emerge.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/spawning.lua")
dofile(modpath.."/commands.lua")
