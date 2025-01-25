mcl_signs = {}

local modname = core.get_current_modname()

local S = core.get_translator(modname)
local modpath = core.get_modpath(modname)

-- UTF-8 library from Modlib
local utf8 = dofile(modpath .. DIR_DELIM .. "utf8.lua")

-- Character map
local charmap = {}
for line in io.lines(modpath .. "/characters.tsv") do
	local split = line:split("\t")
	if #split > 0 then
		local char, img, _ = split[1], split[2], split[3] -- 3rd is ignored, reserved for width
		charmap[char] = img
	end
end
mcl_signs.charmap = charmap

local files = {
	"api",
	"register",
	"compat"
}

for _, file in pairs(files) do
	loadfile(modpath .. DIR_DELIM .. file .. ".lua")(S, charmap, utf8)
end
