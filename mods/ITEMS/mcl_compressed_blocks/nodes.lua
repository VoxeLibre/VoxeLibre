--Compressed Cobblestone
minetest.register_node("mcl_compressed_blocks:compressed_cobblestone", {
	description = "Compressed Cobblestone",
	_doc_items_longdesc = ("Compressed Cobblestone is a decorative block made from 9 Cobblestone. It is useful for saving space in your inventories."),
	_doc_items_hidden = false,
	tiles = {"mcl_compressed_blocks_compressed_cobblestone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

--Double Compressed Cobble
minetest.register_node("mcl_compressed_blocks:double_compressed_cobblestone", {
	description = "Double Compressed Cobblestone",
	_doc_items_longdesc = ("Double Compressed Cobblestone is a decorative block made from 9 Compressed Cobblestone. It is useful for saving space in your inventories."),
	_doc_items_hidden = false,
	tiles = {"mcl_compressed_blocks_double_compressed_cobblestone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

--Triple Compressed Cobble
minetest.register_node("mcl_compressed_blocks:triple_compressed_cobblestone", {
	description = "Triple Compressed Cobblestone",
	_doc_items_longdesc = ("Triple Compressed Cobblestone is a decorative block made from 9 Double Compressed Cobblestone. It is useful for saving space in your inventories."),
	_doc_items_hidden = false,
	tiles = {"mcl_compressed_blocks_triple_compressed_cobblestone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

--Quadruple Compressed Cobble
minetest.register_node("mcl_compressed_blocks:quadruple_compressed_cobblestone", {
	description = "Quadruple Compressed Cobblestone",
	_doc_items_longdesc = ("Quadruple Compressed Cobblestone is a decorative block made from 9 Triple Compressed Cobblestone. It is useful for saving space in your inventories."),
	_doc_items_hidden = false,
	tiles = {"mcl_compressed_blocks_quadruple_compressed_cobblestone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

--Quintuple Compressed Cobble
minetest.register_node("mcl_compressed_blocks:quintuple_compressed_cobblestone", {
	description = "Quintuple Compressed Cobblestone",
	_doc_items_longdesc = ("Quintuple Compressed Cobblestone is a decorative block made from 9 Quadruple Compressed Cobblestone. It is useful for saving space in your inventories."),
	_doc_items_hidden = false,
	tiles = {"mcl_compressed_blocks_quintuple_compressed_cobblestone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

--Sextuple Compressed Cobble
minetest.register_node("mcl_compressed_blocks:sextuple_compressed_cobblestone", {
	description = "Sextuple Compressed Cobblestone",
	_doc_items_longdesc = ("Sextuple Compressed Cobblestone is a decorative block made from 9 Quintuple Compressed Cobblestone. It is useful for saving space in your inventories."),
	_doc_items_hidden = false,
	tiles = {"mcl_compressed_blocks_sextuple_compressed_cobblestone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

--Septuple Compressed Cobble
minetest.register_node("mcl_compressed_blocks:septuple_compressed_cobblestone", {
	description = "Septuple Compressed Cobblestone",
	_doc_items_longdesc = ("Septuple Compressed Cobblestone is a decorative block made from 9 Sextuple Compressed Cobblestone. It is useful for saving space in your inventories."),
	_doc_items_hidden = false,
	tiles = {"mcl_compressed_blocks_septuple_compressed_cobblestone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
})

--Ocutple Compressed Cobble
minetest.register_node("mcl_compressed_blocks:octuple_compressed_cobblestone", {
	description = "Octuple Compressed Cobblestone",
	_doc_items_longdesc = ("Octuple Compressed Cobblestone is a decorative block made from 9 Septuple Compressed Cobblestone. It is useful for saving space in your inventories."),
	_doc_items_hidden = false,
	tiles = {"mcl_compressed_blocks_octuple_compressed_cobblestone.png"},
	is_ground_content = true,
	stack_max = 64,
	groups = {pickaxey=1, stone=1, building_block=1},
    drop = {

		max_items = 2,
		items = {
			{items = {"mcl_core:diamond 9"}},
			{items = {"mcl_nether:netherite_scrap 18"}},
		},
	},

	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 6,
	_mcl_hardness = 1.5,
	_mcl_silk_touch_drop = true,
})
