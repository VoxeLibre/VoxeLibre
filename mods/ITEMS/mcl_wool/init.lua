-- minetest/wool/init.lua

-- Backwards compatibility with jordach's 16-color wool mod
minetest.register_alias("mcl_wool:dark_blue", "wool:blue")
minetest.register_alias("mcl_wool:gold", "wool:yellow")

local wool = {}
-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.
wool.dyes = {
	{"white",      "white",		"White",      nil,		"basecolor_white"},
	{"grey",       "dark_grey",	"Grey",       "dark_grey",	"unicolor_darkgrey"},
	{"silver",     "grey",		"Light Grey", "grey",		"basecolor_grey"},
	{"black",      "black",		"Black",      "black",		"basecolor_black"},
	{"red",        "red",		"Red",        "red",		"basecolor_red"},
	{"yellow",     "yellow",	"Yellow",     "yellow",		"basecolor_yellow"},
	{"green",      "green",		"Green",      "dark_green",	"unicolor_dark_green"},
	{"cyan",       "cyan",		"Cyan",       "cyan",		"basecolor_cyan"},
	{"blue",       "blue",		"Blue",       "blue",		"basecolor_blue"},
	{"magenta",    "magenta",	"Magenta",    "magenta",	"basecolor_magenta"},
	{"orange",     "orange",	"Orange",     "orange",		"excolor_orange"},
	{"purple",     "violet",	"Purple",     "violet",		"excolor_violet"},
	{"brown",      "brown",		"Brown",      "brown",		"unicolor_dark_orange"},
	{"pink",       "pink",		"Pink",       "pink",		"unicolor_light_red"},
	{"lime",       "lime",		"Lime",       "green",		"basecolor_green"},
	{"light_blue", "light_blue",	"Light Blue", "lightblue",	"unicolor_light_blue"},
}

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local texture = row[2]
	local desc = row[3]
	local dye = row[4]
	local color_group = row[5]
	-- Node Definition
		minetest.register_node("mcl_wool:"..name, {
			description = desc.." Wool",
			_doc_items_longdesc = "Wool is a decorational block which comes in many different colors.",
			stack_max = 64,
			is_ground_content = false,
			tiles = {"wool_"..texture..".png"},
			groups = {handy=1,shearsy_wool=1, flammable=1,wool=1,building_block=1},
			sounds = mcl_sounds.node_sound_defaults(),
			_mcl_hardness = 0.8,
			_mcl_blast_resistance = 4,
		})
		minetest.register_node("mcl_wool:"..name.."_carpet", {
			description = desc.." Carpet",
			_doc_items_longdesc = "Carpets are thin floor covers which come in many different colors.",
			walkable = true,
			is_ground_content = false,
			tiles = {"wool_"..texture..".png"},
			wield_image = "wool_"..texture..".png",
			wield_scale = { x=1, y=1, z=0.5 },
			groups = {handy=1, carpet=1,dig_by_water=1,deco_block=1},
			sounds = mcl_sounds.node_sound_defaults(),
			paramtype = "light",
			sunlight_propagates = true,
			stack_max = 64,
			drawtype = "nodebox",
			node_box = {
				type = "fixed",
				fixed = {
					{-8/16, -8/16, -8/16, 8/16, -7/16, 8/16},
				},
			},
			_mcl_hardness = 0.1,
			_mcl_blast_resistance = 0.5,
		})
	if dye then
	-- Crafting from dye and white wool
		minetest.register_craft({
			type = "shapeless",
			output = 'mcl_wool:'..name,
			recipe = {"mcl_dye:"..dye, 'mcl_wool:white'},
		})
	end
	minetest.register_craft({
		output = 'mcl_wool:'..name..'_carpet 3',
		recipe = {{'mcl_wool:'..name, 'mcl_wool:'..name}},
	})
end

minetest.register_craft({
	output = "mcl_wool:white",
	recipe = {
		{ "mcl_mobitems:string", "mcl_mobitems:string" },
		{ "mcl_mobitems:string", "mcl_mobitems:string" },
	},
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:wool",
	burntime = 5,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:carpet",
	-- Original value: 3.35
	burntime = 3,
})
