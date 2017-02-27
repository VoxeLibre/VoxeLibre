local init = os.clock()

local block = {}

block.dyes = {
	{"white",      "White",      "white"},
	{"grey",       "Grey",       "dark_grey"},
	{"silver",     "Light Grey", "grey"},
	{"black",      "Black",      "black"},
	{"red",        "Red",        "red"},
	{"yellow",     "Yellow",     "yellow", true},
	{"green",      "Green",      "dark_green"},
	{"cyan",       "Cyan",       "cyan"},
	{"blue",       "Blue",       "blue"},
	{"magenta",    "Magenta",    "magenta", true},
	{"orange",     "Orange",     "orange"},
	{"purple",     "Purple",     "violet", true},
	{"brown",      "Brown",      "brown"},
	{"pink",       "Pink",       "pink"},
	{"lime",       "Lime",       "green"},
	{"light_blue", "Light Blue", "lightblue"},
}

minetest.register_node("mcl_colorblocks:hardened_clay", {
	description = "Hardened Clay",
	tiles = {"hardened_clay.png"},
	stack_max = 64,
	groups = {pickaxey=1, hardened_clay=1,building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 21,
	_mcl_hardness = 1.25,
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
	-- TODO: Remove when all 16 terracotta textures are available
	local terracotta = row[4]
	-- Node Definition
	minetest.register_node("mcl_colorblocks:hardened_clay_"..name, {
		description = desc.." Hardened Clay",
		tiles = {"hardened_clay_stained_"..name..".png"},
		groups = {pickaxey=1, hardened_clay=1,building_block=1},
		stack_max = 64,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 21,
		_mcl_hardness = 1.25,
	})

	minetest.register_node("mcl_colorblocks:concrete_powder_"..name, {
		description = desc.." Concrete Powder",
		tiles = {"mcl_colorblocks_concrete_powder_"..name..".png"},
		groups = {handy=1,shovely=1, concrete_powder=1,building_block=1,falling_node=1},
		stack_max = 64,
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_sand_defaults(),

		-- Specify the node to which this node will convert after getting in contact with water
		_mcl_colorblocks_harden_to = "mcl_colorblocks:concrete_"..name,
		_mcl_blast_resistance = 2.5,
		_mcl_hardness = 0.5,
	})

	minetest.register_node("mcl_colorblocks:concrete_"..name, {
		description = desc.." Concrete",
		tiles = {"mcl_colorblocks_concrete_"..name..".png"},
		groups = {handy=1,pickaxey=1, concrete=1,building_block=1},
		stack_max = 64,
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 9,
		_mcl_hardness = 1.8,
	})

	if terracotta then
		local tex = "mcl_colorblocks_glazed_terracotta_"..name..".png"
		local texes = { tex, tex, tex.."^[transformR180", tex, tex.."^[transformR270", tex.."^[transformR90" }
		minetest.register_node("mcl_colorblocks:glazed_terracotta_"..name, {
			description = desc.." Glazed Terracotta",
			tiles = texes,
			groups = {handy=1,pickaxey=1, glazed_terracotta=1,building_block=1},
			paramtype2 = "facedir",
			stack_max = 64,
			is_ground_content = false,
			sounds = mcl_sounds.node_sound_stone_defaults(),
			_mcl_blast_resistance = 7,
			_mcl_hardness = 1.4,
		})
	end

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
			type = "shapeless",
			output = 'mcl_colorblocks:concrete_powder_'..name..' 8',
			recipe = {
				'mcl_core:sand', 'mcl_core:gravel', 'mcl_core:sand',
				'mcl_core:gravel', 'mcl_dye:'..craft_color_group, 'mcl_core:gravel',
				'mcl_core:sand', 'mcl_core:gravel', 'mcl_core:sand',
			}
		})

		if terracotta then
			minetest.register_craft({
				type = "cooking",
				output = "mcl_colorblocks:glazed_terracotta_"..name,
				recipe = "mcl_colorblocks:hardened_clay_"..name,
				cooktime = 10,
			})
		end
	end
end

-- When water touches concrete powder, it turns into concrete of the same color
minetest.register_abm({
	label = "Concrete powder hardening",
	interval = 1,
	chance = 1,
	nodenames = {"group:concrete_powder"},
	neighbors = {"group:water"},
	action = function(pos, node)
		local harden_to = minetest.registered_nodes[node.name]._mcl_colorblocks_harden_to
		minetest.swap_node(pos, { name = harden_to, param = node.param, param2 = node.param2 })
	end,
})

local time_to_load= os.clock() - init
print(string.format("[MOD] "..minetest.get_current_modname().." loaded in %.4f s", time_to_load))

