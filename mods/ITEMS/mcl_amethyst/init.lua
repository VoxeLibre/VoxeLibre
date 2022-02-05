local S = minetest.get_translator(minetest.get_current_modname())
mcl_amethyst = {}

-- Amethyst block
minetest.register_node("mcl_amethyst:amethyst_block",{
	description = S("Block of Amethyst"),
	tiles = {"amethyst_block.png"},
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 1.5,
	groups = {
		pickaxey = 1,
		building_block = 1,
	},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	is_ground_content = true,
	stack_max = 64,
	_doc_items_longdesc = S("The Block of Amethyst is a decoration block crafted from amethyst shards."),
})

minetest.register_node("mcl_amethyst:budding_amethyst_block",{
	description = S("Budding Amethyst"),
	tiles = {"budding_amethyst.png"},
	drop = "",
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 1.5,
	groups = {
		pickaxey = 1,
		building_block = 1,
		dig_by_piston = 1,
	},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	is_ground_content = true,
	stack_max = 64,
	_doc_items_longdesc = S("The Budding Amethyst can grow amethyst"),
})
mcl_wip.register_wip_item("mcl_amethyst:budding_amethyst_block")

-- Amethyst Shard
minetest.register_craftitem("mcl_amethyst:amethyst_shard",{
	description = S("Amethyst Shard"),
	inventory_image = "amethyst_shard.png",
	stack_max = 64,
	groups = {
		craftitem = 1,
	},
	_doc_items_longdesc = S("An amethyst shard is a crystalline mineral."),
})

-- Calcite
minetest.register_node("mcl_amethyst:calcite",{
	description = S("Calcite"),
	tiles = {"calcite.png"},
	_mcl_hardness = 0.75,
	_mcl_blast_resistance = 0.75,
	groups = {
		pickaxey = 1,
		building_block = 1,
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	is_ground_content = true,
	stack_max = 64,
	_doc_items_longdesc = S("Calcite can be found as part of amethyst geodes."),
})

-- Tinied Glass
minetest.register_node("mcl_amethyst:tinted_glass",{
	description = S("Tinted Glass"),
	tiles = {"tinted_glass.png"},
	_mcl_hardness = 0.3,
	_mcl_blast_resistance = 0.3,
	drawtype = "glasslike",
	use_texture_alpha = "clip",
	sunlight_propagates = false,
	groups = {
		handy = 1,
		building_block = 1,
		deco_block = 1,
	},
	sounds = mcl_sounds.node_sound_glass_defaults(),
	is_ground_content = false,
	stack_max = 64,
	_doc_items_longdesc = S("Tinted Glass is a type of glass which blocks lights while it is visually transparent."),
})

-- Amethyst Cluster
local bud_def = {
	{
		size         = "small",
		description  = S("Small Amethyst Bud"),
		long_desc    = S("Small Amethyst Bud is the first growth of amethyst bud."),
		light_source = 3,
		next_stage   = "mcl_amethyst:medium_amethyst_bud",
	},
	{
		size         = "medium",
		description  = S("Medium Amethyst Bud"),
		long_desc    = S("Medium Amethyst Bud is the second growth of amethyst bud."),
		light_source = 4,
		next_stage   = "mcl_amethyst:large_amethyst_bud",
	},
	{
		size         = "large",
		description  = S("Large Amethyst Bud"),
		long_desc    = S("Large Amethyst Bud is the third growth of amethyst bud."),
		light_source = 5,
		next_stage   = "mcl_amethyst:amethyst_cluster",
	},
}
for _, def in pairs(bud_def) do
	local size = def.size
	local name = "mcl_amethyst:" .. size .. "_amethyst_bud"
	local tile = size .. "_amethyst_bud.png"
	local inventory_image = size .. "_amethyst_bud.png"
	minetest.register_node(name, {
		description = def.description,
		_mcl_hardness = 1.5,
		_mcl_blast_resistance = 1.5,
		drop = "",
		tiles = {tile},
		inventory_image = inventory_image,
		paramtype1 = "light",
		paramtype2 = "wallmounted",
		drawtype = "plantlike",
		use_texture_alpha = "clip",
		sunlight_propagates = true,
		light_source = def.light_source,
		groups = {
			dig_by_water = 1,
			destroy_by_lava_flow = 1,
			dig_by_piston = 1,
			pickaxey = 1,
			deco_block = 1,
			amethyst_buds = 1,
			attached_node = 1,
		},
		selection_box = {
			type = "fixed",
			fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
		},
		collision_box = {
			type = "fixed",
			fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
		},
		_mcl_silk_touch_drop = true,
		_mcl_amethyst_next_grade = def.next_stage,
		_doc_items_longdesc = def.longdesc,
	})
end

minetest.register_node("mcl_amethyst:amethyst_cluster",{
	description = "Amethyst Cluster",
	_mcl_hardness = 1.5,
	_mcl_blast_resistance = 1.5,
	_doc_items_longdesc = S("Amethyst Cluster is the final growth of amethyst bud."),
	drop = {
		max_items = 1,
		items = {
			{
				tools = {"~mcl_tools:pick_"},
				items = {"mcl_amethyst:amethyst_shard 4"},
			},
			{
				items = {"mcl_amethyst:amethyst_shard 2"},
			},
		}
	},
	tiles = {"amethyst_cluster.png",},
	inventory_image = "amethyst_cluster.png",
	paramtype2 = "wallmounted",
	drawtype = "plantlike",
	paramtype1 = "light",
	use_texture_alpha = "clip",
	sunlight_propagates = true,
	light_source = 7,
	groups = {
		dig_by_water = 1,
		destroy_by_lava_flow = 1,
		dig_by_piston = 1,
		pickaxey = 1,
		deco_block = 1,
		attached_node = 1,
	},
	selection_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
	},
	collision_box = {
		type = "fixed",
		fixed = { -7/16, -8/16, -7/16, 7/16, -7/16, 7/16 },
	},
	_mcl_silk_touch_drop = true,
})

-- Register Crafts
minetest.register_craft({
	output = "mcl_amethyst:amethyst_block",
	recipe = {
		{"mcl_amethyst:amethyst_shard","mcl_amethyst:amethyst_shard",},
		{"mcl_amethyst:amethyst_shard","mcl_amethyst:amethyst_shard",},
	},
})

minetest.register_craft({
	output = "mcl_amethyst:tinted_glass 2",
	recipe = {
		{"","mcl_amethyst:amethyst_shard",""},
		{"mcl_amethyst:amethyst_shard","mcl_core:glass","mcl_amethyst:amethyst_shard",},
		{"","mcl_amethyst:amethyst_shard",""},
	},
})

if minetest.get_modpath("mcl_spyglass") then
	minetest.clear_craft({output = "mcl_spyglass:spyglass",})
	local function craft_spyglass(ingot)
		minetest.register_craft({
			output = "mcl_spyglass:spyglass",
			recipe = {
				{"mcl_amethyst:amethyst_shard"},
				{ingot},
				{ingot},
			}
		})
	end
	if minetest.get_modpath("mcl_copper") then
		craft_spyglass("mcl_copper:copper_ingot")
	else
		craft_spyglass("mcl_core:iron_ingot")
	end
end

-- Amethyst Growing
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/grow.lua")
