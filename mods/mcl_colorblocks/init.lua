local init = os.clock()

local block = {}
block.dyes = {
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

minetest.register_node("mcl_colorblocks:hardened_clay", {
	description = "Hardened Clay",
	tiles = {"hardened_clay.png"},
	stack_max = 64,
	groups = {cracky=3,hardened_clay=1,building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_colorblocks:hardened_clay",
	recipe = "mcl_core:clay",
	cooktime = 10,
})


for _, row in ipairs(block.dyes) do
	local name = row[1]
	local desc = row[2]
	local craft_color_group = row[3]
	-- Node Definition
	minetest.register_node("mcl_colorblocks:hardened_clay_"..name, {
		description = desc.." Hardened Clay",
		tiles = {"hardened_clay_stained_"..name..".png"},
		groups = {cracky=3,hardened_clay=1,building_block=1},
		stack_max = 64,
		sounds = mcl_sounds.node_sound_stone_defaults(),
	})

	minetest.register_node("mcl_colorblocks:concrete_powder_"..name, {
		description = desc.." Concrete Powder",
		tiles = {"mcl_colorblocks_concrete_powder_"..name..".png"},
		groups = {crumbly=3,concrete_powder=1,building_block=1,falling_node=1},
		stack_max = 64,
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_sand_defaults(),
	})

	minetest.register_node("mcl_colorblocks:concrete_"..name, {
		description = desc.." Concrete",
		tiles = {"mcl_colorblocks_concrete_"..name..".png"},
		groups = {cracky=3,conrete=1,building_block=1},
		stack_max = 64,
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
	})

	-- Crafting recipes
	if craft_color_group then
		minetest.register_craft({
			output = 'mcl_colorblocks:hardened_clay_'..name..' 8',
			recipe = {
					{'mcl_colorblocks:hardened_clay', 'mcl_colorblocks:hardened_clay', 'mcl_colorblocks:hardened_clay'},
					{'mcl_colorblocks:hardened_clay', 'mcl_dye:'..craft_color_group, 'mcl_colorblocks:hardened_clay'},
					{'mcl_colorblocks:hardened_clay', 'mcl_colorblocks:hardened_clay', 'mcl_colorblocks:hardened_clay'},
			},
		})
		minetest.register_craft({
			output = 'mcl_colorblocks:concrete_powder_'..name..' 8',
			recipe = {
					{'mcl_core:sand', 'mcl_core:gravel', 'mcl_core:sand'},
					{'mcl_core:gravel', 'mcl_dye:'..craft_color_group, 'mcl_core:gravel'},
					{'mcl_core:sand', 'mcl_core:gravel', 'mcl_core:sand'},
			},
		})
	end
end

-- TODO: ABM: Concrete Powder + Water = Concrete

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))

