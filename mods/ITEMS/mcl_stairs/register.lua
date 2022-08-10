-- Register all Minecraft stairs and slabs
-- Note about hardness: For some reason, the hardness of slabs and stairs don't always match nicely, so that some
-- slabs actually take slightly longer to be dug than their stair counterparts.
-- Note sure if it is a good idea to preserve this oddity.

local S = minetest.get_translator(minetest.get_current_modname())

mcl_stairs.register_stair_and_slab_simple("stone_rough", "mcl_core:stone", S("Stone Stairs"), S("Stone Slab"), S("Double Stone Slab"))

mcl_stairs.register_slab("stone", "mcl_core:stone_smooth",
		{pickaxey=1, material_stone=1},
		{"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
		S("Polished Stone Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Polished Stone Slab"))

mcl_stairs.register_stair_and_slab_simple("andesite", "mcl_core:andesite", S("Andesite Stairs"), S("Andesite Slab"), S("Double Andesite Slab"))
mcl_stairs.register_stair_and_slab_simple("granite", "mcl_core:granite", S("Granite Stairs"), S("Granite Slab"), S("Double Granite Slab"))
mcl_stairs.register_stair_and_slab_simple("diorite", "mcl_core:diorite", S("Diorite Stairs"), S("Diorite Slab"), S("Double Diorite Slab"))

mcl_stairs.register_stair_and_slab_simple("cobble", "mcl_core:cobble", S("Cobblestone Stairs"), S("Cobblestone Slab"), S("Double Cobblestone Slab"))
mcl_stairs.register_stair_and_slab_simple("mossycobble", "mcl_core:mossycobble", S("Mossy Cobblestone Stairs"), S("Mossy Cobblestone Slab"), S("Double Mossy Cobblestone Slab"))

mcl_stairs.register_stair_and_slab_simple("brick_block", "mcl_core:brick_block", S("Brick Stairs"), S("Brick Slab"), S("Double Brick Slab"))


mcl_stairs.register_stair("sandstone", "group:normal_sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
		S("Sandstone Stairs"),
		mcl_sounds.node_sound_stone_defaults(),	0.8, 0.8,
		nil, "mcl_core:sandstone")	--fixme: extra parameter from previous release
mcl_stairs.register_slab("sandstone", "group:normal_sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
		S("Sandstone Slab"),
		mcl_sounds.node_sound_stone_defaults(),	6, 2,
		S("Double Sandstone Slab"), "mcl_core:sandstone")	--fixme: extra parameter from previous release
mcl_stairs.register_stair_and_slab_simple("sandstonesmooth2", "mcl_core:sandstonesmooth2", S("Smooth Sandstone Stairs"), S("Smooth Sandstone Slab"), S("Double Smooth Sandstone Slab"))

mcl_stairs.register_stair("redsandstone", "group:red_sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
		S("Red Sandstone Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 0.8, 0.8,
		nil, "mcl_core:redsandstone")	--fixme: extra parameter from previous release
mcl_stairs.register_slab("redsandstone", "group:red_sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
		S("Red Sandstone Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Red Sandstone Slab"), "mcl_core:redsandstone")	--fixme: extra parameter from previous release
mcl_stairs.register_stair_and_slab_simple("redsandstonesmooth2", "mcl_core:redsandstonesmooth2", S("Smooth Red Sandstone Stairs"), S("Smooth Red Sandstone Slab"), S("Double Smooth Red Sandstone Slab"))

-- Intentionally not group:stonebrick because of mclx_stairs
mcl_stairs.register_stair("stonebrick", "mcl_core:stonebrick",
		{pickaxey=1, material_stone=1},
		{"default_stone_brick.png"},
		S("Stone Bricks Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 6, 1.5,
		nil, "mcl_core:stonebrick")	--fixme: extra parameter from previous release
mcl_stairs.register_slab("stonebrick", "mcl_core:stonebrick",
		{pickaxey=1, material_stone=1},
		{"default_stone_brick.png"},
		S("Stone Bricks Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Stone Bricks Slab"), "mcl_core:stonebrick")	--fixme: extra parameter from previous release

mcl_stairs.register_stair("quartzblock", "group:quartz_block",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
		S("Quartz Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 0.8, 0.8,
		nil, "mcl_nether:quartz_block")	--fixme: extra parameter from previous release
mcl_stairs.register_slab("quartzblock", "group:quartz_block",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
		S("Quartz Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Quartz Slab"), "mcl_nether:quartz_block")	--fixme: extra parameter from previous release

mcl_stairs.register_stair_and_slab_simple("quartz_smooth", "mcl_nether:quartz_smooth", S("Smooth Quartz Stairs"), S("Smooth Quartz Slab"), S("Double Smooth Quartz Slab"))

mcl_stairs.register_stair_and_slab("nether_brick", "mcl_nether:nether_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_nether_brick.png"},
		S("Nether Brick Stairs"),
		S("Nether Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Nether Brick Slab"), nil)
mcl_stairs.register_stair_and_slab("red_nether_brick", "mcl_nether:red_nether_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_red_nether_brick.png"},
		S("Red Nether Brick Stairs"),
		S("Red Nether Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Red Nether Brick Slab"), nil)

mcl_stairs.register_stair_and_slab_simple("end_bricks", "mcl_end:end_bricks", S("End Stone Brick Stairs"), S("End Stone Brick Slab"), S("Double End Stone Brick Slab"))

mcl_stairs.register_stair("purpur_block", "group:purpur_block",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		S("Purpur Stairs"),
		mcl_sounds.node_sound_stone_defaults(),	6, 1.5,
		nil)
mcl_stairs.register_slab("purpur_block", "group:purpur_block",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		S("Purpur Slab"),
		mcl_sounds.node_sound_stone_defaults(),	6, 2,
		S("Double Purpur Slab"))

mcl_stairs.register_stair_and_slab_simple("prismarine", "mcl_ocean:prismarine", S("Prismarine Stairs"), S("Prismarine Slab"), S("Double Prismarine Slab"))

mcl_stairs.register_stair_and_slab_simple("mud_brick", "mcl_mud:mud_bricks", S("Mud Brick Stair"), S("Mud Brick Slab"), S("Double Mud Brick Slab"))

mcl_stairs.register_stair_and_slab_simple("prismarine_brick", "mcl_ocean:prismarine_brick", S("Prismarine Brick Stairs"), S("Prismarine Brick Slab"), S("Double Prismarine Brick Slab"))
mcl_stairs.register_stair_and_slab_simple("prismarine_dark", "mcl_ocean:prismarine_dark", S("Dark Prismarine Stairs"), S("Dark Prismarine Slab"), S("Double Dark Prismarine Slab"))

mcl_stairs.register_slab("andesite_smooth", "mcl_core:andesite_smooth",
		{pickaxey=1},
		{"mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_stairs_andesite_smooth_slab.png"},
		S("Polished Andesite Slab"),
		nil, 6, nil,
		S("Double Polished Andesite Slab"))
mcl_stairs.register_stair("andesite_smooth", "mcl_core:andesite_smooth",
		{pickaxey=1},
		{"mcl_stairs_andesite_smooth_slab.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_stairs_andesite_smooth_slab.png"},
		S("Polished Andesite Stairs"),
		nil, 6, nil,
		"woodlike")

mcl_stairs.register_slab("granite_smooth", "mcl_core:granite_smooth",
		{pickaxey=1},
		{"mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_stairs_granite_smooth_slab.png"},
		S("Polished Granite Slab"),
		nil, 6, nil,
		S("Double Polished Granite Slab"))
mcl_stairs.register_stair("granite_smooth", "mcl_core:granite_smooth",
		{pickaxey=1},
		{"mcl_stairs_granite_smooth_slab.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_stairs_granite_smooth_slab.png"},
		S("Polished Granite Stairs"),
		nil, 6, nil,
		"woodlike")

mcl_stairs.register_slab("diorite_smooth", "mcl_core:diorite_smooth",
		{pickaxey=1},
		{"mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_stairs_diorite_smooth_slab.png"},
		S("Polished Diorite Slab"),
		nil, 6, nil,
		S("Double Polished Diorite Slab"))
mcl_stairs.register_stair("diorite_smooth", "mcl_core:diorite_smooth",
		{pickaxey=1},
		{"mcl_stairs_diorite_smooth_slab.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_stairs_diorite_smooth_slab.png"},
		S("Polished Diorite Stairs"),
		nil, 6, nil,
		"woodlike")

mcl_stairs.register_stair("stonebrickmossy", "mcl_core:stonebrickmossy",
		{pickaxey=1},
		{"mcl_core_stonebrick_mossy.png"},
		S("Mossy Stone Brick Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 6, 1.5,
		nil)

mcl_stairs.register_slab("stonebrickmossy", "mcl_core:stonebrickmossy",
		{pickaxey=1},
		{"mcl_core_stonebrick_mossy.png"},
		S("Mossy Stone Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), 6, 2,
		S("Double Mossy Stone Brick Slab"), "mcl_core:stonebrickmossy")	--fixme: extra parameter from previous release

