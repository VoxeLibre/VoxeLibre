mcl_boats = {}

local S = core.get_translator("mcl_boats")
local modpath = core.get_modpath("mcl_boats")

for _, file in ipairs{"api", "register", "compat"} do
	loadfile(modpath .. DIR_DELIM .. file .. ".lua")(S)
end
