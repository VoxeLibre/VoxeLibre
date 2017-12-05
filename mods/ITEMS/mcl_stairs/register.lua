-- Register all Minecraft stairs and slabs
-- Note about hardness: For some reason, the hardness of slabs and stairs don't always match nicely, so that some
-- slabs actually take slightly longer to be dug than their stair counterparts.
-- Note sure if it is a good idea to preserve this oddity.

mcl_stairs.register_stair("wood", "mcl_core:wood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"default_wood.png"},
		"Oak Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("wood", "mcl_core:wood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"default_wood.png"},
		"Oak Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Oak Wood Slab")

mcl_stairs.register_stair("junglewood", "mcl_core:junglewood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"default_junglewood.png"},
		"Jungle Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("junglewood", "mcl_core:junglewood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"default_junglewood.png"},
		"Jungle Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Jungle Wood Slab")

mcl_stairs.register_stair("acaciawood", "mcl_core:acaciawood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"default_acacia_wood.png"},
		"Acacia Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)

mcl_stairs.register_slab("acaciawood", "mcl_core:acaciawood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"default_acacia_wood.png"},
		"Acacia Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Acacia Wood Slab")

mcl_stairs.register_stair("sprucewood", "mcl_core:sprucewood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"mcl_core_planks_spruce.png"},
		"Spruce Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("sprucewood", "mcl_core:sprucewood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"mcl_core_planks_spruce.png"},
		"Spruce Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Spruce Wood Slab")

mcl_stairs.register_stair("birchwood", "mcl_core:birchwood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"mcl_core_planks_birch.png"},
		"Birch Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("birchwood", "mcl_core:birchwood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"mcl_core_planks_birch.png"},
		"Birch Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Birch Wood Slab")

mcl_stairs.register_stair("darkwood", "mcl_core:darkwood",
		{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
		{"mcl_core_planks_big_oak.png"},
		"Dark Oak Wood Stairs",
		mcl_sounds.node_sound_wood_defaults(),
		2)
mcl_stairs.register_slab("darkwood", "mcl_core:darkwood",
		{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
		{"mcl_core_planks_big_oak.png"},
		"Dark Oak Wood Slab",
		mcl_sounds.node_sound_wood_defaults(),
		2,
		"Double Dark Oak Wood Slab")

mcl_stairs.register_slab("stone", "mcl_core:stone",
		{pickaxey=1, material_stone=1},
		{"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
		"Stone Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Stone Slab")

mcl_stairs.register_stair_and_slab_simple("cobble", "mcl_core:cobble", "Cobblestone Stairs", "Cobblestone Slab", "Double Cobblestone Slab")

mcl_stairs.register_stair_and_slab_simple("brick_block", "mcl_core:brick_block", "Brick Stairs", "Brick Slab", "Double Brick Slab")


mcl_stairs.register_stair("sandstone", "group:sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
		"Sandstone Stairs",
		mcl_sounds.node_sound_stone_defaults(), 0.8, nil, "mcl_core:sandstone")
mcl_stairs.register_slab("sandstone", "group:sandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_sandstone_top.png", "mcl_core_sandstone_bottom.png", "mcl_core_sandstone_normal.png"},
		"Sandstone Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Sandstone Slab", "mcl_core:sandstone")

mcl_stairs.register_stair("redsandstone", "group:redsandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
		"Red Sandstone Stairs",
		mcl_sounds.node_sound_stone_defaults(), 0.8, nil, "mcl_core:redsandstone")
mcl_stairs.register_slab("redsandstone", "group:redsandstone",
		{pickaxey=1, material_stone=1},
		{"mcl_core_red_sandstone_top.png", "mcl_core_red_sandstone_bottom.png", "mcl_core_red_sandstone_normal.png"},
		"Red Sandstone Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Red Sandstone Slab", "mcl_core:redsandstone")

-- Intentionally not group:stonebrick because of mclx_stairs
mcl_stairs.register_stair("stonebrick", "mcl_core:stonebrick",
		{pickaxey=1, material_stone=1},
		{"default_stone_brick.png"},
		"Stone Bricks Stairs",
		mcl_sounds.node_sound_stone_defaults(), 1.5, nil, "mcl_core:stonebrick")
mcl_stairs.register_slab("stonebrick", "mcl_core:stonebrick",
		{pickaxey=1, material_stone=1},
		{"default_stone_brick.png"},
		"Stone Bricks Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Stone Bricks Slab", "mcl_core:stonebrick")

mcl_stairs.register_stair("quartzblock", "group:quartz_block",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
		"Quartz Stairs",
		mcl_sounds.node_sound_stone_defaults(), 0.8, nil, "mcl_nether:quartz_block")
mcl_stairs.register_slab("quartzblock", "group:quartz_block",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_quartz_block_top.png", "mcl_nether_quartz_block_bottom.png", "mcl_nether_quartz_block_side.png"},
		"Quartz Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Quarzt Slab", "mcl_nether:quartz_block")

mcl_stairs.register_stair_and_slab("nether_brick", "mcl_nether:nether_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_nether_brick.png"},
		"Nether Brick Stairs",
		"Nether Brick Slab",
		mcl_sounds.node_sound_stone_defaults(),
		2,
		"Double Nether Brick Slab")

mcl_stairs.register_stair("purpur_block", "mcl_end:purpur_block",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		"Purpur Stairs",
		mcl_sounds.node_sound_stone_defaults(),
		1.5)
mcl_stairs.register_slab("purpur_block", "mcl_end:purpur_block",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		"Purpur Slab",
		mcl_sounds.node_sound_stone_defaults(),
		2,
		"Double Purpur Slab")

