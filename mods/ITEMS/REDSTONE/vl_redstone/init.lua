local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_redstone = {}

dofile(modpath.."/wire.lua")
dofile(modpath.."/compat.lua")

