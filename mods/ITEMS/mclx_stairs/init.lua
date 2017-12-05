mcl_stairs.register_stair_and_slab_simple("end_bricks", "mcl_end:end_bricks", "End Stone Brick Stairs", "End Stone Brick Slab", "Double End Stone Brick Slab")
mcstair.add("mcl_stairs:stair_end_bricks")

mcl_stairs.register_stair_and_slab_simple("red_nether_brick", "mcl_nether:red_nether_brick", "Red Nether Brick Stairs", "Red Nether Brick Slab", "Double Red Nether Brick Slab")
mcstair.add("mcl_stairs:stair_red_nether_brick")

mcl_stairs.register_stair_and_slab_simple("prismarine_dark", "mcl_ocean:prismarine_dark", "Dark Prismarine Stairs", "Dark Prismarine Slab", "Double Dark Prismarine Slab")
mcstair.add("mcl_stairs:stair_prismarine_dark")

mcl_stairs.register_stair_and_slab_simple("mossycobble", "mcl_core:mossycobble", "Moss Stone Stairs", "Moss Stone Slab", "Double Moss Stone Slab")
mcstair.add("mcl_stairs:stair_mossycobble")

mcl_stairs.register_stair_and_slab_simple("lapisblock", "mcl_core:lapisblock", "Lapis Lazuli Stairs", "Lapis Lazuli Slab", "Double Lapis Lazuli Slab")
mcstair.add("mcl_stairs:stair_lapisblock")

mcl_stairs.register_stair_and_slab_simple("goldblock", "mcl_core:goldblock", "Stairs of Gold", "Slab of Gold", "Double Slab of Gold")
mcstair.add("mcl_stairs:stair_goldblock")

mcl_stairs.register_stair_and_slab_simple("ironblock", "mcl_core:ironblock", "Stairs of Iron", "Slab of Iron", "Double Slab of Iron")
mcstair.add("mcl_stairs:stair_ironblock")

mcl_stairs.register_stair_and_slab_simple("andesite_smooth", "mcl_core:andesite_smooth", "Polished Andesite Stairs", "Polished Andesite Slab", "Double Polished Andesite Slab")
mcstair.add("mcl_stairs:stair_andesite_smooth")

mcl_stairs.register_stair_and_slab_simple("diorite_smooth", "mcl_core:diorite_smooth", "Polished Diorite Stairs", "Polished Diorite Slab", "Double Polished Diorite Slab")
mcstair.add("mcl_stairs:stair_diorite_smooth")

mcl_stairs.register_stair_and_slab_simple("granite_smooth", "mcl_core:granite_smooth", "Polished Granite Stairs", "Polished Granite Slab", "Double Polished Granite Slab")
mcstair.add("mcl_stairs:stair_granite_smooth")

mcl_stairs.register_stair("stonebrickmossy", "mcl_core:stonebrickmossy",
		{pickaxey=1},
		{"mcl_core_stonebrick_mossy.png"},
		"Mossy Stone Brick Stairs",
		mcl_sounds.node_sound_stone_defaults(), 1.5, nil, "mcl_core:stonebrickmossy")
mcstair.add("mcl_stairs:stair_stonebrickmossy")

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
mcstair.add("mcl_stairs:stair_stonebrickcracked")

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
	mcstair.add("mcl_stairs:stair_concrete_"..c)
end

