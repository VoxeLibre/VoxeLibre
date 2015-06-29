-- minetest/wool/init.lua

-- Backwards compatibility with jordach's 16-color wool mod
minetest.register_alias("wool:dark_blue", "wool:blue")
minetest.register_alias("wool:gold", "wool:yellow")

local wool = {}
-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.
wool.dyes = {
	{"white",      "White",      nil},
	{"grey",       "Grey",       "basecolor_grey"},
	{"black",      "Black",      "basecolor_black"},
	{"red",        "Red",        "basecolor_red"},
	{"yellow",     "Yellow",     "basecolor_yellow"},
	{"green",      "Green",      "basecolor_green"},
	{"cyan",       "Cyan",       "basecolor_cyan"},
	{"blue",       "Blue",       "basecolor_blue"},
	{"magenta",    "Magenta",    "basecolor_magenta"},
	{"orange",     "Orange",     "excolor_orange"},
	{"violet",     "Violet",     "excolor_violet"},
	{"brown",      "Brown",      "unicolor_dark_orange"},
	{"pink",       "Pink",       "unicolor_light_red"},
	{"dark_grey",  "Dark Grey",  "unicolor_darkgrey"},
	{"dark_green", "Dark Green", "unicolor_dark_green"},
}

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local desc = row[2]
	local craft_color_group = row[3]
	-- Node Definition
		minetest.register_node("wool:"..name, {
			description = desc.." Wool",
			stack_max = 64,
			tiles = {"wool_"..name..".png"},
			groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,flammable=3,wool=1},
			sounds = default.node_sound_defaults(),
		})
		minetest.register_node("wool:"..name.."_carpet", {
			description = desc.." Carpet",
			walkable = false,
			tiles = {"wool_"..name..".png"},
			wield_image = "wool_"..name..".png",
			groups = {snappy=2,choppy=2,oddly_breakable_by_hand=3,carpet=1},
			sounds = default.node_sound_defaults(),
			paramtype = "light",
			stack_max = 64,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
				},
			},
		})
	if craft_color_group then
	-- Crafting from dye and white wool
		minetest.register_craft({
			type = "shapeless",
			output = 'wool:'..name,
			recipe = {'group:dye,'..craft_color_group, 'group:wool'},
		})
		minetest.register_craft({
			type = "shapeless",
			output = 'wool:'..name..'_carpet 3',
			recipe = {'wool:'..name, 'wool:'..name},
		})
	end
end

