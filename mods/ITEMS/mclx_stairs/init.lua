local S = minetest.get_translator("mclx_stairs")

mcl_stairs.register_stair_and_slab_simple("tree_bark", "mcl_core:tree_bark", S("Oak Bark Stairs"), S("Oak Bark Slab"), S("Double Oak Bark Slab"), "woodlike")
mcl_stairs.register_stair_and_slab_simple("acaciatree_bark", "mcl_core:acaciatree_bark", S("Acacia Bark Stairs"), S("Acacia Bark Slab"), S("Double Acacia Bark Slab"), "woodlike")
mcl_stairs.register_stair_and_slab_simple("sprucetree_bark", "mcl_core:sprucetree_bark", S("Spruce Bark Stairs"), S("Spruce Bark Slab"), S("Double Spruce Bark Slab"), "woodlike")
mcl_stairs.register_stair_and_slab_simple("birchtree_bark", "mcl_core:birchtree_bark", S("Birch Bark Stairs"), S("Birch Bark Slab"), S("Double Birch Bark Slab"), "woodlike")
mcl_stairs.register_stair_and_slab_simple("jungletree_bark", "mcl_core:jungletree_bark", S("Jungle Bark Stairs"), S("Jungle Bark Slab"), S("Double Jungle Bark Slab"), "woodlike")
mcl_stairs.register_stair_and_slab_simple("darktree_bark", "mcl_core:darktree_bark", S("Dark Oak Bark Stairs"), S("Dark Oak Bark Slab"), S("Double Dark Oak Bark Slab"), "woodlike")

mcl_stairs.register_slab("lapisblock", "mcl_core:lapisblock", {pickaxey=3}, {"mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"}, S("Lapis Lazuli Slab"), nil, nil, S("Double Lapis Lazuli Slab"))
mcl_stairs.register_stair("lapisblock", "mcl_core:lapisblock", {pickaxey=3}, {"mcl_stairs_lapis_block_slab.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_core_lapis_block.png", "mcl_stairs_lapis_block_slab.png"}, S("Lapis Lazuli Stairs"), nil, nil, "woodlike")

mcl_stairs.register_slab("goldblock", "mcl_core:goldblock", {pickaxey=4}, {"default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"}, S("Slab of Gold"), nil, nil, S("Double Slab of Gold"))
mcl_stairs.register_stair("goldblock", "mcl_core:goldblock", {pickaxey=4}, {"mcl_stairs_gold_block_slab.png", "default_gold_block.png", "default_gold_block.png", "default_gold_block.png", "default_gold_block.png", "mcl_stairs_gold_block_slab.png"}, S("Stairs of Gold"), nil, nil, "woodlike")

mcl_stairs.register_slab("ironblock", "mcl_core:ironblock", {pickaxey=2}, {"default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"}, S("Slab of Iron"), nil, nil, S("Double Slab of Iron"))
mcl_stairs.register_stair("ironblock", "mcl_core:ironblock", {pickaxey=2}, {"mcl_stairs_iron_block_slab.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "default_steel_block.png", "mcl_stairs_iron_block_slab.png"}, S("Stairs of Iron"), nil, nil, "woodlike")

mcl_stairs.register_stair("stonebrickcracked", "mcl_core:stonebrickcracked",
		{pickaxey=1},
		{"mcl_core_stonebrick_cracked.png"},
		S("Cracked Stone Brick Stairs"),
		mcl_sounds.node_sound_stone_defaults(), 1.5, nil, "mcl_core:stonebrickcracked")

mcl_stairs.register_slab("stonebrickcracked", "mcl_core:stonebrickcracked",
		{pickaxey=1},
		{"mcl_core_stonebrick_cracked.png"},
		S("Cracked Stone Brick Slab"),
		mcl_sounds.node_sound_stone_defaults(), 2, S("Double Cracked Stone Brick Slab"), "mcl_core:stonebrickcracked")

local block = {}
block.dyes = {
	{"white",      S("White Concrete Stairs"),      S("White Concrete Slab"), S("Double White Concrete Slab"), "white"},
	{"grey",       S("Grey Concrete Stairs"),       S("Grey Concrete Slab"), S("Double Grey Concrete Slab"), "dark_grey"},
	{"silver",     S("Light Grey Concrete Stairs"), S("Light Grey Concrete Slab"), S("Double Light Grey Concrete Slab"), "grey"},
	{"black",      S("Black Concrete Stairs"),      S("Black Concrete Slab"), S("Double Black Concrete Slab"), "black"},
	{"red",        S("Red Concrete Stairs"),        S("Red Concrete Slab"), S("Double Red Concrete Slab"), "red"},
	{"yellow",     S("Yellow Concrete Stairs"),     S("Yellow Concrete Slab"), S("Double Yellow Concrete Slab"), "yellow"},
	{"green",      S("Green Concrete Stairs"),      S("Green Concrete Slab"), S("Double Green Concrete Slab"), "dark_green"},
	{"cyan",       S("Cyan Concrete Stairs"),       S("Cyan Concrete Slab"), S("Double Cyan Concrete Slab"), "cyan"},
	{"blue",       S("Blue Concrete Stairs"),       S("Blue Concrete Slab"), S("Double Blue Concrete Slab"), "blue"},
	{"magenta",    S("Magenta Concrete Stairs"),    S("Magenta Concrete Slab"), S("Double Magenta Concrete Slab"), "magenta"},
	{"orange",     S("Orange Concrete Stairs"),     S("Orange Concrete Slab"), S("Double Orange Concrete Slab"), "orange"},
	{"purple",     S("Purple Concrete Stairs"),     S("Purple Concrete Slab"), S("Double Purple Concrete Slab"), "violet"},
	{"brown",      S("Brown Concrete Stairs"),      S("Brown Concrete Slab"), S("Double Brown Concrete Slab"), "brown"},
	{"pink",       S("Pink Concrete Stairs"),       S("Pink Concrete Slab"), S("Double Pink Concrete Slab"), "pink"},
	{"lime",       S("Lime Concrete Stairs"),       S("Lime Concrete Slab"), S("Double Lime Concrete Slab"), "green"},
	{"light_blue", S("Light Blue Concrete Stairs"), S("Light Blue Concrete Slab"), S("Double Light Blue Concrete Slab"), "lightblue"},
}

for i=1, #block.dyes do
	local c = block.dyes[i][1]
	mcl_stairs.register_stair_and_slab_simple("concrete_"..c, "mcl_colorblocks:concrete_"..c,
		block.dyes[i][2],
		block.dyes[i][3],
		block.dyes[i][4])
end

