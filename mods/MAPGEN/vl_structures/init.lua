local modpath = core.get_modpath(core.get_current_modname())
vl_structures = {}

---- Customization parameters for different games
-- see vl_terraforming for documentation
vl_structures.DEFAULT_PREPARE = { tolerance = 10, foundation = -3, clear = false, clear_bottom = 0, clear_top = 4, padding = 1, corners = 1 }
vl_structures.DEFAULT_FLAGS = "place_center_x,place_center_z"

-- fallback types
vl_structures.DEFAULT_SURFACE = { name = "mcl_core:dirt_with_grass" }
vl_structures.DEFAULT_FILLER = { name = "mcl_core:dirt" }
vl_structures.DEFAULT_STONE = { name = "mcl_core:stone" }
vl_structures.DEFAULT_DUST = nil

dofile(modpath.."/util.lua")
dofile(modpath.."/emerge.lua")
dofile(modpath.."/api.lua")
dofile(modpath.."/spawning.lua")
dofile(modpath.."/commands.lua")
