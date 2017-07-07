mcl_core = {}

-- Repair percentage for toolrepair
mcl_core.repair = 0.05

-- Load files
local modpath = minetest.get_modpath("mcl_core")
dofile(modpath.."/functions.lua")
dofile(modpath.."/nodes_base.lua") -- Simple solid cubic nodes with simple definitions
dofile(modpath.."/nodes_liquid.lua") -- Liquids
dofile(modpath.."/nodes_cactuscane.lua") -- Cactus and sugar canes
dofile(modpath.."/nodes_trees.lua") -- Tree nodes: Wood, Planks, Sapling, Leaves
dofile(modpath.."/nodes_glass.lua") -- Glass
dofile(modpath.."/nodes_climb.lua") -- Climbable nodes
dofile(modpath.."/nodes_misc.lua") -- Other and special nodes
dofile(modpath.."/craftitems.lua")
dofile(modpath.."/crafting.lua")
