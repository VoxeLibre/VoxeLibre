local init = os.clock()

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
	{"brown",      "Brown",      "brown"},
	{"pink",       "Pink",       "pink"},
	{"lime",       "Lime",       "green"},
	{"light_blue", "Light Blue", "lightblue"},
}

minetest.register_node("hardened_clay:hardened_clay", {
	description = "Hardened Clay",
	tiles = {"hardened_clay.png"},
	stack_max = 64,
	groups = {cracky=3,hardened_clay=1,building_block=1},
	sounds = mcl_core.node_sound_stone_defaults(),
})

minetest.register_craft({
	type = "cooking",
	output = "hardened_clay:hardened_clay",
	recipe = "mcl_core:clay",
	cooktime = 10,
})


for _, row in ipairs(clay.dyes) do
	local name = row[1]
	local desc = row[2]
	local craft_color_group = row[3]
	-- Node Definition
		minetest.register_node("hardened_clay:"..name, {
			description = desc.." Hardened Clay",
			tiles = {"hardened_clay_stained_"..name..".png"},
			groups = {cracky=3,hardened_clay=1,building_block=1},
			stack_max = 64,
			sounds = mcl_core.node_sound_stone_defaults(),
		})
	if craft_color_group then
		minetest.register_craft({
			output = 'hardened_clay:'..name..' 8',
			recipe = {
					{'hardened_clay:hardened_clay', 'hardened_clay:hardened_clay', 'hardened_clay:hardened_clay'},
					{'hardened_clay:hardened_clay', 'mcl_dye:'..craft_color_group, 'hardened_clay:hardened_clay'},
					{'hardened_clay:hardened_clay', 'hardened_clay:hardened_clay', 'hardened_clay:hardened_clay'},
			},
		})
	end
end

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))

