-- Register all Minecraft stairs and slabs

local S = minetest.get_translator(minetest.get_current_modname())

-- Cut Sandstone Stairs do not exist, and register_stair_and_slab does not allow multiple recipes
-- (e.g. using group:node) if we try to copy the properties of the node at the same parameter.
-- The missing recipes can be added separately via these:
function mcl_stairs.register_craft_stairs(subname, recipeitem)
	minetest.register_craft({
		output = "mcl_stairs:stair_" .. subname .. " 4",
		recipe = {
			{recipeitem, "", ""},
			{recipeitem, recipeitem, ""},
			{recipeitem, recipeitem, recipeitem},
		},
	})
	-- Flipped recipe
	minetest.register_craft({
		output = "mcl_stairs:stair_" .. subname .. " 4",
		recipe = {
			{"", "", recipeitem},
			{"", recipeitem, recipeitem},
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

function mcl_stairs.register_craft_slab(subname, recipeitem)
	minetest.register_craft({
		output = "mcl_stairs:slab_" .. subname .. " 6",
		recipe = {
			{recipeitem, recipeitem, recipeitem},
		},
	})
end

local woods = {
	oak = {
		_planks_stairs = S("Oak Wood Stairs"),
		_planks_slab = S("Oak Wood Slab"),
		_planks_double_slab = S("Double Oak Wood Slab"),
	},
	dark_oak = {
		_planks_stairs = S("Dark Oak Wood Stairs"),
		_planks_slab = S("Dark Oak Wood Slab"),
		_planks_double_slab = S("Double Dark Oak Wood Slab"),
	},
	jungle = {
		_planks_stairs = S("Jungle Wood Stairs"),
		_planks_slab = S("Jungle Wood Slab"),
		_planks_double_slab = S("Double Jungle Wood Slab"),
	},
	acacia = {
		_planks_stairs = S("Acacia Wood Stairs"),
		_planks_slab = S("Acacia Wood Slab"),
		_planks_double_slab = S("Double Acacia Wood Slab"),
	},
	spruce = {
		_planks_stairs = S("Spruce Wood Stairs"),
		_planks_slab = S("Spruce Wood Slab"),
		_planks_double_slab = S("Double Spruce Wood Slab"),
	},
	birch = {
		_planks_stairs = S("Birch Wood Stairs"),
		_planks_slab = S("Birch Wood Slab"),
		_planks_double_slab = S("Double Birch Wood Slab"),
	},
}

vl_trees.register_on_woods_added(function(name, def)
	local pname = def.planks
	local short = pname:gsub(".+:", "")
	local pdef = minetest.registered_nodes[pname]

	local groups = table.copy(pdef.groups)
	groups.wood = nil

	local groups_stairs = table.copy(groups)
	groups_stairs.wood_stairs = 1

	local groups_slab = table.copy(groups)
	groups_slab.wood_slab = 1

	mcl_stairs.register_stair(short, pname, groups_stairs, pdef.tiles, def._planks_stairs, pdef.sounds,
		nil, nil, "woodlike")
	mcl_stairs.register_slab(short, pname, groups_slab, pdef.tiles, def._planks_slab, pdef.sounds,
		nil, nil,
		def._planks_double_slab)
end, woods)

mcl_stairs.register_slab("stone_rough", "mcl_core:stone",
		{pickaxey=1, material_stone=1},
		{"default_stone.png"},
		S("Stone Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Stone Slab"))
mcl_stairs.register_stair("stone_rough", "mcl_core:stone",
		{pickaxey=1, material_stone=1},
		{"default_stone.png"},
		S("Stone Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 0.8, 0.8)

mcl_stairs.register_slab("stone", "mcl_core:stone_smooth",
		{pickaxey=1, material_stone=1},
		{"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
		S("Polished Stone Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Polished Stone Slab"))

mcl_stairs.register_stair("andesite", "mcl_core:andesite",
		{pickaxey=1, material_stone=1},
		{"mcl_core_andesite.png"},
		S("Andesite Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 0.8, 0.8)
mcl_stairs.register_slab("andesite", "mcl_core:andesite",
		{pickaxey=1, material_stone=1},
		{"mcl_core_andesite.png"},
		S("Andesite Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Andesite Slab"))

mcl_stairs.register_stair("granite", "mcl_core:granite",
		{pickaxey=1, material_stone=1},
		{"mcl_core_granite.png"},
		S("Granite Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 0.8, 0.8)
mcl_stairs.register_slab("granite", "mcl_core:granite",
		{pickaxey=1, material_stone=1},
		{"mcl_core_granite.png"},
		S("Granite Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Granite Slab"))

mcl_stairs.register_stair("diorite", "mcl_core:diorite",
		{pickaxey=1, material_stone=1},
		{"mcl_core_diorite.png"},
		S("Diorite Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 0.8, 0.8)
mcl_stairs.register_slab("diorite", "mcl_core:diorite",
		{pickaxey=1, material_stone=1},
		{"mcl_core_diorite.png"},
		S("Diorite Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Diorite Slab"))

mcl_stairs.register_stair_and_slab("cobble", "mcl_core:cobble",
		{pickaxey=1, material_stone=1},
		{"default_cobble.png"},
		S("Cobblestone Stairs"),
		S("Cobblestone Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Cobblestone Slab"))

mcl_stairs.register_stair_and_slab("mossycobble", "mcl_core:mossycobble",
		{pickaxey=1, material_stone=1},
		{"default_mossycobble.png"},
		S("Mossy Cobblestone Stairs"),
		S("Mossy Cobblestone Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Mossy Cobblestone Slab"))

mcl_stairs.register_stair_and_slab("brick_block", "mcl_core:brick_block",
		{pickaxey=1, material_stone=1},
		{"default_brick.png"},
		S("Brick Stairs"),
		S("Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Brick Slab"))

mcl_stairs.register_stair_and_slab("sandstone", "mcl_core:sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
		S("Sandstone Stairs"),
		S("Sandstone Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Sandstone Slab"))
mcl_stairs.register_craft_stairs("sandstone", "mcl_core:sandstonesmooth") -- Comment this line out if Cut Sandstone Stairs are implemented
mcl_stairs.register_craft_stairs("sandstone", "mcl_core:sandstonecarved")
mcl_stairs.register_craft_slab("sandstone", "mcl_core:sandstonecarved")

-- mcl_stairs.register_stair_and_slab("sandstonesmooth", "mcl_core:sandstonesmooth",
-- 		{pickaxey=1, material_stone=1},
-- 		{"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_smooth.png"},
-- 		S("Cut Sandstone Stairs"), S("Cut Sandstone Slab"),
-- 		mcl_sounds.node_sound_stone_defaults(), nil, nil,
-- 		S("Double Cut Sandstone Slab"))

mcl_stairs.register_stair_and_slab_simple("sandstonesmooth2", "mcl_core:sandstonesmooth2", S("Smooth Sandstone Stairs"), S("Smooth Sandstone Slab"), S("Double Smooth Sandstone Slab"))

mcl_stairs.register_stair_and_slab("redsandstone", "mcl_core:redsandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
		S("Red Sandstone Stairs"),
		S("Red Sandstone Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Red Sandstone Slab"))
mcl_stairs.register_craft_stairs("redsandstone", "mcl_core:redsandstonesmooth") -- Comment this line out if Cut Red Sandstone Stairs are implemented
mcl_stairs.register_craft_stairs("redsandstone", "mcl_core:redsandstonecarved")
mcl_stairs.register_craft_slab("redsandstone", "mcl_core:redsandstonecarved")

-- mcl_stairs.register_stair_and_slab("redsandstonesmooth", "mcl_core:redsandstonesmooth",
-- 		{pickaxey=1, material_stone=1},
-- 		{"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_smooth.png"},
-- 		S("Cut Red Sandstone Stairs"), S("Cut Red Sandstone Slab"),
-- 		mcl_sounds.node_sound_stone_defaults(), nil, nil,
-- 		S("Double Cut Red Sandstone Slab"))

mcl_stairs.register_stair_and_slab_simple("redsandstonesmooth2", "mcl_core:redsandstonesmooth2", S("Smooth Red Sandstone Stairs"), S("Smooth Red Sandstone Slab"), S("Double Smooth Red Sandstone Slab"))

-- Intentionally not group:stonebrick because of mclx_stairs
mcl_stairs.register_stair("stonebrick", "mcl_core:stonebrick",
		{pickaxey=1, material_stone=1},
		{"default_stone_brick.png"},
		S("Stone Bricks Stairs"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		nil)
mcl_stairs.register_slab("stonebrick", "mcl_core:stonebrick",
		{pickaxey=1, material_stone=1},
		{"default_stone_brick.png"},
		S("Stone Bricks Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Stone Bricks Slab"))

mcl_stairs.register_stair_and_slab("quartzblock", "mcl_nether:quartz_block",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
		S("Quartz Stairs"),
		S("Quartz Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Quartz Slab"))
mcl_stairs.register_craft_stairs("quartzblock", "mcl_nether:quartz_pillar")
mcl_stairs.register_craft_stairs("quartzblock", "mcl_nether:quartz_chiseled")
mcl_stairs.register_craft_slab("quartzblock", "mcl_nether:quartz_pillar")
mcl_stairs.register_craft_slab("quartzblock", "mcl_nether:quartz_chiseled")

mcl_stairs.register_stair("quartz_smooth", "mcl_nether:quartz_smooth",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_bottom.png"},
		S("Smooth Quartz Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 0.8, 0.8)
mcl_stairs.register_slab("quartz_smooth", "mcl_nether:quartz_smooth",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_bottom.png"},
		S("Smooth Quartz Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Smooth Quartz Slab"))

mcl_stairs.register_stair_and_slab("nether_brick", "mcl_nether:nether_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_nether_brick.png"},
		S("Nether Brick Stairs"),
		S("Nether Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Nether Brick Slab"), nil)
mcl_stairs.register_stair_and_slab("red_nether_brick", "mcl_nether:red_nether_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_red_nether_brick.png"},
		S("Red Nether Brick Stairs"),
		S("Red Nether Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Red Nether Brick Slab"), nil)

mcl_stairs.register_stair_and_slab("end_bricks", "mcl_end:end_bricks",
		{pickaxey=1, material_stone=1},
		{"mcl_end_end_bricks.png"},
		S("End Stone Brick Stairs"),
		S("End Stone Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double End Stone Brick Slab"), nil)

mcl_stairs.register_stair_and_slab("purpur_block", "mcl_end:purpur_block",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		S("Purpur Stairs"),
		S("Purpur Slab"),
		mcl_sounds.node_sound_stone_defaults(),	nil, nil,
		S("Double Purpur Slab"))
mcl_stairs.register_craft_stairs("purpur_block", "mcl_end:purpur_pillar")
mcl_stairs.register_craft_slab("purpur_block", "mcl_end:purpur_pillar")

mcl_stairs.register_stair("prismarine", "mcl_ocean:prismarine",
		{pickaxey=1, material_stone=1},
		{{name="mcl_ocean_prismarine_anim.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=45.0}}},
		S("Prismarine Stairs"),
		mcl_sounds.node_sound_stone_defaults(),	6, 1.5,
		nil)
mcl_stairs.register_slab("prismarine", "mcl_ocean:prismarine",
		{pickaxey=1, material_stone=1},
		{{name="mcl_ocean_prismarine_anim.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=45.0}}},
		S("Prismarine Slab"),
		mcl_sounds.node_sound_stone_defaults(),	6, 2,
		S("Double Prismarine Slab"))

mcl_stairs.register_stair("prismarine_brick", "mcl_ocean:prismarine_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_ocean_prismarine_bricks.png"},
		S("Prismarine Brick Stairs"),
		mcl_sounds.node_sound_stone_defaults(),	6, 1.5,
		nil)
mcl_stairs.register_slab("prismarine_brick", "mcl_ocean:prismarine_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_ocean_prismarine_bricks.png"},
		S("Prismarine Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(),	6, 2,
		S("Double Prismarine Brick Slab"))

mcl_stairs.register_stair("prismarine_dark", "mcl_ocean:prismarine_dark",
		{pickaxey=1, material_stone=1},
		{"mcl_ocean_prismarine_dark.png"},
		S("Prismarine Brick Stairs"),
		mcl_sounds.node_sound_stone_defaults(),	6, 1.5,
		nil)
mcl_stairs.register_slab("prismarine_dark", "mcl_ocean:prismarine_dark",
		{pickaxey=1, material_stone=1},
		{"mcl_ocean_prismarine_dark.png"},
		S("Dark Prismarine Slab"),
		mcl_sounds.node_sound_stone_defaults(),	6, 2,
		S("Double Dark Prismarine Slab"))

mcl_stairs.register_stair_and_slab("mud_brick", "mcl_mud:mud_bricks",
		{pickaxey=1, material_stone=1},
		{"mcl_mud_bricks.png"},
		S("Mud Brick Stairs"),
		S("Mud Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Mud Brick Slab"), nil)

mcl_stairs.register_slab("andesite_smooth", "mcl_core:andesite_smooth",
		{pickaxey=1},
		{"mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_stairs_andesite_smooth_slab.png"},
		S("Polished Andesite Slab"),
		nil, nil, nil,
		S("Double Polished Andesite Slab"))
mcl_stairs.register_stair("andesite_smooth", "mcl_core:andesite_smooth",
		{pickaxey=1},
		{"mcl_stairs_andesite_smooth_slab.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_stairs_andesite_smooth_slab.png"},
		S("Polished Andesite Stairs"),
		nil, nil, nil,
		"woodlike")

mcl_stairs.register_slab("granite_smooth", "mcl_core:granite_smooth",
		{pickaxey=1},
		{"mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_stairs_granite_smooth_slab.png"},
		S("Polished Granite Slab"),
		nil, nil, nil,
		S("Double Polished Granite Slab"))
mcl_stairs.register_stair("granite_smooth", "mcl_core:granite_smooth",
		{pickaxey=1},
		{"mcl_stairs_granite_smooth_slab.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_stairs_granite_smooth_slab.png"},
		S("Polished Granite Stairs"),
		nil, nil, nil,
		"woodlike")

mcl_stairs.register_slab("diorite_smooth", "mcl_core:diorite_smooth",
		{pickaxey=1},
		{"mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_stairs_diorite_smooth_slab.png"},
		S("Polished Diorite Slab"),
		nil, nil, nil,
		S("Double Polished Diorite Slab"))
mcl_stairs.register_stair("diorite_smooth", "mcl_core:diorite_smooth",
		{pickaxey=1},
		{"mcl_stairs_diorite_smooth_slab.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_stairs_diorite_smooth_slab.png"},
		S("Polished Diorite Stairs"),
		nil, nil, nil,
		"woodlike")

mcl_stairs.register_stair("stonebrickmossy", "mcl_core:stonebrickmossy",
		{pickaxey=1},
		{"mcl_core_stonebrick_mossy.png"},
		S("Mossy Stone Brick Stairs"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		nil)

mcl_stairs.register_slab("stonebrickmossy", "mcl_core:stonebrickmossy",
		{pickaxey=1},
		{"mcl_core_stonebrick_mossy.png"},
		S("Mossy Stone Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), nil, nil,
		S("Double Mossy Stone Brick Slab"))

