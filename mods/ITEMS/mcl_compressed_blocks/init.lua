local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
local mod = {}
mcl_compressed_block = mod

local LABELS = {
	[0] = "@1",
	"Compressed @1",
	"Double Compressed @1",
	"Triple Compressed @1",
	"Quadruple Compressed @1",
	"Quintuple Compressed @1",
	"Sextuple Compressed @1",
	"Septuple Compressed @1",
	"Octuple Compressed @1",
}
local NODE_NAMES = {
	[0] = "",
	"compressed_",
	"double_compressed_",
	"triple_compressed_",
	"quadruple_compressed_",
	"quintuple_compressed_",
	"sextuple_compressed_",
	"septuple_compressed_",
	"octuple_compressed_",
}
local BLAST_RESISTENCE = {
	11, 19, 33, 58, 102, 179, 313, 548,
}
local HARDNESS = {
	 3,  4,  5,  7,   9,  12,  16,  21,
}

local block_name = "Cobblestone"
function mod.register_block_compression(base_block, block_name, max_levels, final_drops)
	local base_nodedef = minetest.registered_nodes[base_block]
	assert(base_nodedef)

	local prev_name = base_block
	for i = 1,(max_levels-1) do
		local overlay_level = math.ceil(i/max_levels * 8)
		local name = "mcl_compressed_blocks:"..NODE_NAMES[i]..block_name

		minetest.register_node(name,{
			description = S(LABELS[i], base_nodedef.description),
			_doc_items_longdesc = (
				"@1 is a decorative block made from 9 @2. It is useful for saving space in your inventories."
				):gsub("@1",LABELS[i]:gsub("@1",block_name)):gsub("@2",LABELS[i-1]:gsub("@1",block_name)),
			_doc_items_hidden = false,
			tiles = {base_nodedef.tiles[1].."^mcl_compressed_blocks_"..tostring(overlay_level).."x_overlay.png"},
			is_ground_content = true,
			stack_max = 64,
			groups = {pickaxey=1, stone=1, building_block=1},
			sounds = base_nodedef.sounds,
			_mcl_blast_resistance = BLAST_RESISTENCE[i],
			_mcl_hardness = HARDNESS[i],
		})

		minetest.register_craft({
			output = name,
			recipe = {
				{ prev_name, prev_name, prev_name },
				{ prev_name, prev_name, prev_name },
				{ prev_name, prev_name, prev_name },
			},
		})
		minetest.register_craft({
			output = prev_name .. " 9",
			recipe = {
				{ name },
			},
		})
		prev_name = name
	end

	-- Compression Terminal Block
	local name = "mcl_compressed_blocks:"..NODE_NAMES[max_levels]..block_name
	minetest.register_node(name,{
		description = S(LABELS[max_levels], base_nodedef.description),
		_doc_items_longdesc = (
			"@1 is a decorative block made from 9 @2. It is useful for saving space in your inventories."
			):gsub("@1",LABELS[max_levels]:gsub("@1",block_name)):gsub("@2",LABELS[max_levels-1]:gsub("@1",block_name)),
		_doc_items_hidden = false,
		tiles = {base_nodedef.tiles[1].."^mcl_compressed_blocks_8x_overlay.png"},
		is_ground_content = true,
		stack_max = 64,
		groups = {pickaxey=1, stone=1, building_block=1},
		drop = final_drops,
		sounds = base_nodedef.sounds,
		_mcl_blast_resistance = BLAST_RESISTENCE[max_levels],
		_mcl_hardness = HARDNESS[max_levels],
		_mcl_silk_touch_drop = true,
	})
	minetest.register_craft({
		output = name,
		recipe = {
			{ prev_name, prev_name, prev_name },
			{ prev_name, prev_name, prev_name },
			{ prev_name, prev_name, prev_name },
		},
	})
	minetest.register_craft({
		output = prev_name .. " 9",
		recipe = {
			{ name },
		},
	})
end

mod.register_block_compression("mcl_core:cobble", "cobblestone", 8, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
})
mod.register_block_compression("mcl_deepslate:deepslate_cobbled", "deepslate_cobbled", 8, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
})
mod.register_block_compression("mcl_core:granite", "granite", 5, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
})
mod.register_block_compression("mcl_core:diorite", "diorite", 6, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
})
mod.register_block_compression("mcl_core:andesite", "andesite", 6, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
})
