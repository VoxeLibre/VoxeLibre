mcl_signs = {}

local modname = core.get_current_modname()

local S = core.get_translator(modname)
local modpath = core.get_modpath(modname)

-- Character map
local chars_file = io.open(modpath .. "/characters.txt", "r")
assert(chars_file, "mcl_signs/characters.txt not found")

local charmap = {}
while true do
	local char = chars_file:read("*l")
	if char == nil then break end
	local img = chars_file:read("*l")
	local _ = chars_file:read("*l")
	charmap[char] = img
end
mcl_signs.charmap = charmap

local files = {
	"api",
	"register",
	"compat"
}

for _, file in ipairs(files) do
	loadfile(modpath .. DIR_DELIM .. file .. ".lua")(S, charmap)
end
