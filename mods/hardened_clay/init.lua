
local clay = {}
clay.dyes = {
	{"white",      "White",      "white"},
	{"grey",       "Grey",       "dark_grey"},
	{"silver",     "Light Gray", "grey"},
	{"black",      "Black",      "black"},
	{"red",        "Red",        "red"},
	{"yellow",     "Yellow",     "yellow"},
	{"green",      "Green",      "dark_green"},
	{"cyan",       "Cyan",       "cyan"},
	{"blue",       "Blue",       "blue"},
	{"magenta",    "Magenta",    "magenta"},
	{"orange",     "Orange",     "orange"},
	{"purple",     "Purple",     "violet"},
	{"brown",      "Brown",      "dark_orange"},
	{"pink",       "Pink",       "light_red"},
	{"lime",       "Lime",       "green"},
	{"light_blue", "Light Blue", "lightblue"},
}

minetest.register_node("hardened_clay:hardened_clay", {
	description = "Hardened Clay",
	tiles = {"hardened_clay.png"},
	stack_max = 64,
	groups = {cracky=3},
	legacy_mineral = true,
})

minetest.register_craft({
	type = "cooking",
	output = "hardened_clay:hardened_clay",
	recipe = "default:clay",
})


for _, row in ipairs(clay.dyes) do
	local name = row[1]
	local desc = row[2]
	local craft_color_group = row[3]
	-- Node Definition
		minetest.register_node("hardened_clay:"..name, {
			description = desc.." Hardened Clay",
			tiles = {"hardened_clay_stained_"..name..".png"},
			groups = {cracky=3,hardened_clay=1},
			stack_max = 64,
			sounds = default.node_sound_defaults(),
		})
	if craft_color_group then
		minetest.register_craft({
			output = 'hardened_clay:'..name..' 8',
			recipe = {
					{'hardened_clay:hardened_clay', 'hardened_clay:hardened_clay', 'hardened_clay:hardened_clay'},
					{'hardened_clay:hardened_clay', 'dye:'..craft_color_group, 'hardened_clay:hardened_clay'},
					{'hardened_clay:hardened_clay', 'hardened_clay:hardened_clay', 'hardened_clay:hardened_clay'},
			},
		})
	end
end

