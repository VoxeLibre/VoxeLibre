-- Register all Minecraft stairs and slabs
-- Note about hardness: For some reason, the hardness of slabs and stairs don't always match nicely, so that some
-- slabs actually take slightly longer to be dug than their stair counterparts.
-- Note sure if it is a good idea to preserve this oddity.

local woods = {
	{ "wood", "default_wood.png", "Oak Wood Stairs", "Oak Wood Slab", "Double Oak Wood Slab" },
	{ "junglewood", "default_junglewood.png", "Jungle Wood Stairs", "Jungle Wood Slab", "Double Jungle Wood Slab" },
	{ "acaciawood", "default_acacia_wood.png", "Acacia Wood Stairs", "Acacia Wood Slab", "Double Acacia Wood Slab" },
	{ "sprucewood", "mcl_core_planks_spruce.png", "Spruce Wood Stairs", "Spruce Wood Slab", "Double Spruce Wood Slab" },
	{ "birchwood", "mcl_core_planks_birch.png", "Birch Wood Stairs", "Birch Wood Slab", "Double Birch Wood Slab" },
	{ "darkwood", "mcl_core_planks_big_oak.png", "Dark Oak Wood Stairs", "Dark Oak Wood Slab", "Double Dark Oak Wood Slab" },
}

for w=1, #woods do
	local wood = woods[w]
	mcl_stairs.register_stair(wood[1], "mcl_core:"..wood[1],
			{handy=1,axey=1, flammable=3,wood_stairs=1, material_wood=1},
			{wood[2]},
			wood[3],
			mcl_sounds.node_sound_wood_defaults(),
			2,
			"woodlike")
	mcl_stairs.register_slab(wood[1], "mcl_core:"..wood[1],
			{handy=1,axey=1, flammable=3,wood_slab=1, material_wood=1},
			{wood[2]},
			wood[4],
			mcl_sounds.node_sound_wood_defaults(),
			2,
			wood[5])
end

mcl_stairs.register_stair_and_slab_simple("stone_rough", "mcl_core:stone", "Stone Stairs", "Stone Slab", "Double Stone Slab")

mcl_stairs.register_slab("stone", "mcl_core:stone_smooth",
		{pickaxey=1, material_stone=1},
		{"mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_top.png", "mcl_stairs_stone_slab_side.png"},
		"Polished Stone Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Polished Stone Slab")

mcl_stairs.register_stair_and_slab_simple("andesite", "mcl_core:andesite", "Andesite Stairs", "Andesite Slab", "Double Andesite Slab")
mcl_stairs.register_stair_and_slab_simple("granite", "mcl_core:granite", "Granite Stairs", "Granite Slab", "Double Granite Slab")
mcl_stairs.register_stair_and_slab_simple("diorite", "mcl_core:diorite", "Diorite Stairs", "Diorite Slab", "Double Diorite Slab")

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
mcl_stairs.register_stair_and_slab_simple("sandstonesmooth2", "mcl_core:sandstonesmooth2", "Smooth Sandstone Stairs", "Smooth Sandstone Slab", "Double Smooth Sandstone Slab")

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
mcl_stairs.register_stair_and_slab_simple("redsandstonesmooth2", "mcl_core:redsandstonesmooth2", "Smooth Red Sandstone Stairs", "Smooth Red Sandstone Slab", "Double Smooth Red Sandstone Slab")

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

mcl_stairs.register_stair_and_slab_simple("quartz_smooth", "mcl_nether:quartz_smooth", "Smooth Quartz Stairs", "Smooth Quartz Slab", "Double Smooth Quartz Slab")

mcl_stairs.register_stair_and_slab("nether_brick", "mcl_nether:nether_brick",
		{pickaxey=1, material_stone=1},
		{"mcl_nether_nether_brick.png"},
		"Nether Brick Stairs",
		"Nether Brick Slab",
		mcl_sounds.node_sound_stone_defaults(),
		2,
		"Double Nether Brick Slab")

mcl_stairs.register_stair("purpur_block", "group:purpur",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		"Purpur Stairs",
		mcl_sounds.node_sound_stone_defaults(),
		1.5)
mcl_stairs.register_slab("purpur_block", "group:purpur",
		{pickaxey=1, material_stone=1},
		{"mcl_end_purpur_block.png"},
		"Purpur Slab",
		mcl_sounds.node_sound_stone_defaults(),
		2,
		"Double Purpur Slab")

mcl_stairs.register_stair_and_slab_simple("prismarine", "mcl_ocean:prismarine", "Prismarine Stairs", "Prismarine Slab", "Double Prismarine Slab")

mcl_stairs.register_stair_and_slab_simple("prismarine_brick", "mcl_ocean:prismarine_brick", "Prismarine Brick Stairs", "Prismarine Brick Slab", "Double Prismarine Brick Slab")
mcl_stairs.register_stair_and_slab_simple("prismarine_dark", "mcl_ocean:prismarine_dark", "Dark Prismarine Stairs", "Dark Prismarine Slab", "Double Dark Prismarine Slab")

