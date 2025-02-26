mcl_signs = {}

local modname = core.get_current_modname()

local S = core.get_translator(modname)
local modpath = core.get_modpath(modname)

-- UTF-8 library from modlib
local utf8 = dofile(modpath .. DIR_DELIM .. "utf8.lua")

-- Character map (see API.md for reference)
local charmap = {}
for line in io.lines(modpath .. DIR_DELIM .. "characters.tsv") do
	local split = line:split("\t")
	if #split == 3 then
		local char, img, _ = split[1], split[2], split[3] -- 3rd is ignored, reserved for width
		local code = utf8.codepoint(char)
		charmap[code] = img
	end
end
mcl_signs.charmap = charmap

-- Load modules and share local variables
for _, file in pairs{"api", "register", "compat"} do
	loadfile(modpath .. DIR_DELIM .. file .. ".lua")(S, charmap, utf8)
end
