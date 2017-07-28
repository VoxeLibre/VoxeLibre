-- Shared functions and variables

mcl_banners = {}

-- Global banner definitions
mcl_banners.colors = {
	-- Format:
	-- [ID] = { banner description, wool, unified dyes color group, overlay color, dye, color name for emblazonings }
	["unicolor_white"] =      {"white",      "White Banner",      "mcl_wool:white", "#FFFFFF", "mcl_dye:white", "White" },
	["unicolor_darkgrey"] =   {"grey",       "Grey Banner",       "mcl_wool:grey", "#303030", "mcl_dye:dark_grey", "Grey" },
	["unicolor_grey"] =       {"silver",     "Light Grey Banner", "mcl_wool:silver", "#5B5B5B", "mcl_dye:grey", "Light Grey" },
	["unicolor_black"] =      {"black",      "Black Banner",      "mcl_wool:black", "#000000", "mcl_dye:black", "Black" },
	["unicolor_red"] =        {"red",        "Red Banner",        "mcl_wool:red", "#BC0000", "mcl_dye:red", "Red" },
	["unicolor_yellow"] =     {"yellow",     "Yellow Banner",     "mcl_wool:yellow", "#BCA800", "mcl_dye:yellow", "Yellow" },
	["unicolor_dark_green"] = {"green",      "Green Banner",      "mcl_wool:green", "#006000", "mcl_dye:dark_green", "Green" },
	["unicolor_cyan"] =       {"cyan",       "Cyan Banner",       "mcl_wool:cyan", "#00ACAC", "mcl_dye:cyan", "Cyan" },
	["unicolor_blue"] =       {"blue",       "Blue Banner",       "mcl_wool:blue", "#0000AC", "mcl_dye:blue", "Blue" },
	["unicolor_red_violet"] = {"magenta",    "Magenta Banner",    "mcl_wool:magenta", "#AC007C", "mcl_dye:magenta", "Magenta"},
	["unicolor_orange"] =     {"orange",     "Orange Banner",     "mcl_wool:orange", "#BC6900", "mcl_dye:orange", "Orange" },
	["unicolor_violet"] =     {"purple",     "Purple Banner",     "mcl_wool:purple", "#6400AC", "mcl_dye:violet", "Violet" },
	["unicolor_brown"] =      {"brown",      "Brown Banner",      "mcl_wool:brown", "#402100", "mcl_dye:brown", "Brown" },
	["unicolor_pink"] =       {"pink",       "Pink Banner",       "mcl_wool:pink", "#DE557C", "mcl_dye:pink", "Pink" },
	["unicolor_lime"] =       {"lime",       "Lime Banner",       "mcl_wool:lime", "#30AC00", "mcl_dye:green", "Lime" },
	["unicolor_light_blue"] = {"light_blue", "Light Blue Banner", "mcl_wool:light_blue", "#4040CF", "mcl_dye:lightblue", "Light Blue" },
}

-- Returns a banner description containing all the layer names.
-- description: Base description (from item definition)
-- layers: Table of layers
mcl_banners.make_advanced_banner_description = function(description, layers)
	if layers == nil or #layers == 0 then
		-- No layers, revert to default
		return ""
	else
		local layerstrings = {}
		for l=1, #layers do
			-- Prevent excess length description
			if l > max_layer_lines then
				break
			end
			-- Layer text line.
			local color = mcl_banners.colors[layers[l].color][6]
			local pattern_name = patterns[layers[l].pattern].name
			-- The pattern name is a format string (e.g. “%s Base”)
			table.insert(layerstrings, string.format(pattern_name, color))
		end
		-- Warn about missing information
		if #layers == max_layer_lines + 1 then
			table.insert(layerstrings, "And one addional layer")
		elseif #layers > max_layer_lines + 1 then
			table.insert(layerstrings, string.format("And %d addional layers", #layers - max_layer_lines))
		end

		-- Final string concatenations: Just a list of strings
		local append = table.concat(layerstrings, "\n")
		description = description .. "\n" .. core.colorize("#8F8F8F", append)
		return description
	end
end


