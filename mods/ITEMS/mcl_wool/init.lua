-- minetest/wool/init.lua

-- Backwards compatibility with jordach's 16-color wool mod
minetest.register_alias("mcl_wool:dark_blue", "wool:blue")
minetest.register_alias("mcl_wool:gold", "wool:yellow")

local wool = {}
-- This uses a trick: you can first define the recipes using all of the base
-- colors, and then some recipes using more specific colors for a few non-base
-- colors available. When crafting, the last recipes will be checked first.
wool.dyes = {
	-- name,       texture,               wool desc.,        carpet desc.,        dye,          color_group
	{"white",      "wool_white",          "White Wool",      "White Carpet",      nil,          "basecolor_white"},
	{"grey",       "wool_dark_grey",      "Grey Wool",       "Grey Carpet",       "dark_grey",  "unicolor_darkgrey"},
	{"silver",     "wool_grey",           "Light Grey Wool", "Light Grey Carpet", "grey",       "basecolor_grey"},
	{"black",      "wool_black",          "Black Wool",      "Black Carpet",      "black",      "basecolor_black"},
	{"red",        "wool_red",            "Red Wool",        "Red Carpet",        "red",        "basecolor_red"},
	{"yellow",     "wool_yellow",         "Yellow Wool",     "Yellow Carpet",     "yellow",     "basecolor_yellow"},
	{"green",      "wool_dark_green",     "Green Wool",      "Green Carpet",      "dark_green", "unicolor_dark_green"},
	{"cyan",       "wool_cyan",           "Cyan Wool",       "Cyan Carpet",       "cyan",       "basecolor_cyan"},
	{"blue",       "wool_blue",           "Blue Wool",       "Blue Carpet",       "blue",       "basecolor_blue"},
	{"magenta",    "wool_magenta",        "Magenta Wool",    "Magenta Carpet",    "magenta",    "basecolor_magenta"},
	{"orange",     "wool_orange",         "Orange Wool",     "Orange Carpet",     "orange",     "excolor_orange"},
	{"purple",     "wool_violet",         "Purple Wool",     "Purple Carpet",     "violet",     "excolor_violet"},
	{"brown",      "wool_brown",          "Brown Wool",      "Brown Carpet",      "brown",      "unicolor_dark_orange"},
	{"pink",       "wool_pink",           "Pink Wool",       "Pink Carpet",       "pink",       "unicolor_light_red"},
	{"lime",       "mcl_wool_lime",       "Lime Wool",       "Lime Carpet",       "green",      "basecolor_green"},
	{"light_blue", "mcl_wool_light_blue", "Light Blue Wool", "Light Blue Carpet", "lightblue",  "unicolor_light_blue"},
}

for _, row in ipairs(wool.dyes) do
	local name = row[1]
	local texture = row[2]
	local desc_wool = row[3]
	local desc_carpet = row[4]
	local dye = row[5]
	local color_group = row[6]
	-- Node Definition
		minetest.register_node("mcl_wool:"..name, {
			description = desc_wool,
			_doc_items_longdesc = "Wool is a decorational block which comes in many different colors.",
			stack_max = 64,
			is_ground_content = false,
			tiles = {texture..".png"},
			groups = {handy=1,shearsy_wool=1, flammable=1,wool=1,building_block=1},
			sounds = mcl_sounds.node_sound_defaults(),
			_mcl_hardness = 0.8,
			_mcl_blast_resistance = 4,
		})
		minetest.register_node("mcl_wool:"..name.."_carpet", {
			description = desc_carpet,
			_doc_items_longdesc = "Carpets are thin floor covers which come in many different colors.",
			walkable = false, -- See <https://minecraft.gamepedia.com/Materials>
			is_ground_content = false,
			tiles = {texture..".png"},
			wield_image = texture..".png",
			wield_scale = { x=1, y=1, z=0.5 },
			groups = {handy=1, carpet=1,attached_node=1,dig_by_water=1,deco_block=1},
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
