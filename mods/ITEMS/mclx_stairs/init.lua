mcl_stairs.register_stair_and_slab_simple("end_bricks", "mcl_end:end_bricks", "End Stone Brick Stairs", "End Stone Brick Slab", "Double End Stone Brick Slab")

mcl_stairs.register_stair_and_slab_simple("red_nether_brick", "mcl_nether:red_nether_brick", "Red Nether Brick Stairs", "Red Nether Brick Slab", "Double Red Nether Brick Slab")

mcl_stairs.register_stair_and_slab_simple("mossycobble", "mcl_core:mossycobble", "Moss Stone Stairs", "Moss Stone Slab", "Double Moss Stone Slab")

mcl_stairs.register_stair_and_slab_simple("tree_bark", "mcl_core:tree_bark", "Oak Bark Stairs", "Oak Bark Slab", "Double Oak Bark Slab", "woodlike")
mcl_stairs.register_stair_and_slab_simple("acaciatree_bark", "mcl_core:acaciatree_bark", "Acacia Bark Stairs", "Acacia Bark Slab", "Double Acacia Bark Slab", "woodlike")
mcl_stairs.register_stair_and_slab_simple("sprucetree_bark", "mcl_core:sprucetree_bark", "Spruce Bark Stairs", "Spruce Bark Slab", "Double Spruce Bark Slab", "woodlike")
mcl_stairs.register_stair_and_slab_simple("birchtree_bark", "mcl_core:birchtree_bark", "Birch Bark Stairs", "Birch Bark Slab", "Double Birch Bark Slab", "woodlike")
mcl_stairs.register_stair_and_slab_simple("jungletree_bark", "mcl_core:jungletree_bark", "Jungle Bark Stairs", "Jungle Bark Slab", "Double Jungle Bark Slab", "woodlike")
mcl_stairs.register_stair_and_slab_simple("darktree_bark", "mcl_core:darktree_bark", "Dark Oak Bark Stairs", "Dark Oak Bark Slab", "Double Dark Oak Bark Slab", "woodlike")

mcl_stairs.register_slab("lapisblock", "mcl_core:lapisblock", {pickaxey=3}, {"mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"}, "Lapis Lazuli Slab", nil, nil, "Double Lapis Lazuli Slab")
mcl_stairs.register_stair("lapisblock", "mcl_core:lapisblock", {pickaxey=3}, {"mcl_stairs_lapis_block_slab.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"}, "Lapis Lazuli Stairs", nil, nil, "woodlike")

mcl_stairs.register_slab("goldblock", "mcl_core:goldblock", {pickaxey=4}, {"default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"}, "Slab of Gold", nil, nil, "Double Slab of Gold")
mcl_stairs.register_stair("goldblock", "mcl_core:goldblock", {pickaxey=4}, {"mcl_stairs_gold_block_slab.png", "default_gold_block.png", "default_gold_block.png", "default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"}, "Stairs of Gold", nil, nil, "woodlike")

mcl_stairs.register_slab("ironblock", "mcl_core:ironblock", {pickaxey=2}, {"default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"}, "Slab of Iron", nil, nil, "Double Slab of Iron")
mcl_stairs.register_stair("ironblock", "mcl_core:ironblock", {pickaxey=2}, {"mcl_stairs_iron_block_slab.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"}, "Stairs of Iron", nil, nil, "woodlike")

mcl_stairs.register_slab("andesite_smooth", "mcl_core:andesite_smooth", {pickaxey=1}, {"mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_stairs_andesite_smooth_slab.png"}, "Polished Andesite Slab", nil, nil, "Double Polished Andesite Slab")
mcl_stairs.register_stair("andesite_smooth", "mcl_core:andesite_smooth", {pickaxey=1}, {"mcl_stairs_andesite_smooth_slab.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_core_andesite_smooth.png", "mcl_stairs_andesite_smooth_slab.png"}, "Polished Andesite Stairs", nil, nil, "woodlike")

mcl_stairs.register_slab("granite_smooth", "mcl_core:granite_smooth", {pickaxey=1}, {"mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_stairs_granite_smooth_slab.png"}, "Polished Granite Slab", nil, nil, "Double Polished Granite Slab")
mcl_stairs.register_stair("granite_smooth", "mcl_core:granite_smooth", {pickaxey=1}, {"mcl_stairs_granite_smooth_slab.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_core_granite_smooth.png", "mcl_stairs_granite_smooth_slab.png"}, "Polished Granite Stairs", nil, nil, "woodlike")

mcl_stairs.register_slab("diorite_smooth", "mcl_core:diorite_smooth", {pickaxey=1}, {"mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_stairs_diorite_smooth_slab.png"}, "Polished Diorite Slab", nil, nil, "Double Polished Diorite Slab")
mcl_stairs.register_stair("diorite_smooth", "mcl_core:diorite_smooth", {pickaxey=1}, {"mcl_stairs_diorite_smooth_slab.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_core_diorite_smooth.png", "mcl_stairs_diorite_smooth_slab.png"}, "Polished Diorite Stairs", nil, nil, "woodlike")

mcl_stairs.register_stair("stonebrickmossy", "mcl_core:stonebrickmossy",
		{pickaxey=1},
		{"mcl_core_stonebrick_mossy.png"},
		"Mossy Stone Brick Stairs",
		mcl_sounds.node_sound_stone_defaults(), 1.5, nil, "mcl_core:stonebrickmossy")

mcl_stairs.register_slab("stonebrickmossy", "mcl_core:stonebrickmossy",
		{pickaxey=1},
		{"mcl_core_stonebrick_mossy.png"},
		"Mossy Stone Brick Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Mossy Stone Brick Slab", "mcl_core:stonebrickmossy")

mcl_stairs.register_stair("stonebrickcracked", "mcl_core:stonebrickcracked",
		{pickaxey=1},
		{"mcl_core_stonebrick_cracked.png"},
		"Cracked Stone Brick Stairs",
		mcl_sounds.node_sound_stone_defaults(), 1.5, nil, "mcl_core:stonebrickcracked")

mcl_stairs.register_slab("stonebrickcracked", "mcl_core:stonebrickcracked",
		{pickaxey=1},
		{"mcl_core_stonebrick_cracked.png"},
		"Cracked Stone Brick Slab",
		mcl_sounds.node_sound_stone_defaults(), 2, "Double Cracked Stone Brick Slab", "mcl_core:stonebrickcracked")

local block = {}
block.dyes = {
	{"white",      "White",      "white"},
	{"grey",       "Grey",       "dark_grey"},
	{"silver",     "Light Grey", "grey"},
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

for i=1, #block.dyes do
	local c = block.dyes[i][1]
	mcl_stairs.register_stair_and_slab_simple("concrete_"..c, "mcl_colorblocks:concrete_"..c,
		block.dyes[i][2].." Concrete Stairs",
		block.dyes[i][2].." Concrete Slab",
		"Double "..block.dyes[i][2].." Concrete Slab")
end

