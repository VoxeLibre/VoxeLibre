mcl_signs = {}

local modname = core.get_current_modname()

local S = core.get_translator(modname)
local modpath = core.get_modpath(modname)

-- Character map
local charmap = {}
for line in io.lines(modpath .. "/characters.tsv") do
	local split = line:split("\t")
	if #split > 0 then
		local char, img, _ = split[1], split[2], split[3]
		charmap[char] = img
	end
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
