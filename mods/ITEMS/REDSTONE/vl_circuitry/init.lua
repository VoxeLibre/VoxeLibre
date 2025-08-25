vl_circuitry = {
	mesecon = {}
}

local modpath = core.get_modpath(core.get_current_modname())
local has_mesecons = core.get_modpath("mesecons")
if has_mesecons then
	dofile(modpath..DIR_DELIM.."compat.lua")
else
	dofile(modpath..DIR_DELIM.."native.lua")
end
