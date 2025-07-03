-- (C. 2024) Thomas Conway <smokey@tilde.team> - original mod author, overlay texture artist, implemented colorizer system
-- (C. 2024) Teknomunk, - created and optimized the API system to generalize compressed block registry
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
local function N(s) return s end
local mod = {}
mcl_compressed_block = mod

local LABELS = {
	[0] = N("@1"),
	N("Compressed @1"),
	N("Double Compressed @1"),
	N("Triple Compressed @1"),
	N("Quadruple Compressed @1"),
	N("Quintuple Compressed @1"),
	N("Sextuple Compressed @1"),
	N("Septuple Compressed @1"),
	N("Octuple Compressed @1"),
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
local BLAST_RESISTANCE = {
	11, 19, 33, 58, 102, 179, 313, 548,
}
local HARDNESS = {
	 3,  4,  5,  7,   9,  12,  16,  21,
}

--local block_name = "Cobblestone"
function mod.register_block_compression(base_block, block_name, max_levels, final_drops, overlay_color, gem_overlay_color)
	local base_nodedef = minetest.registered_nodes[base_block]
	assert(base_nodedef)

	local prev_name = base_block
	for i = 1,(max_levels-1) do
		local overlay_level = math.ceil(i/max_levels * 8)
		local name = "mcl_compressed_blocks:"..NODE_NAMES[i]..block_name

		-- Build tile texture with optional overlay colorization
		local tile_texture = base_nodedef.tiles[1].."^mcl_compressed_blocks_"..tostring(overlay_level).."x_overlay.png"
		if overlay_color then
			tile_texture = base_nodedef.tiles[1].."^(mcl_compressed_blocks_"..tostring(overlay_level).."x_overlay.png^[colorize:"..overlay_color..")"
		end

		minetest.register_node(name,{
			description = S(LABELS[i], base_nodedef.description),
			_doc_items_longdesc = S(
				"@1 is a decorative block made from 9 @2. It is useful for saving space in your inventories.",
				S(LABELS[i], S(block_name)), S(LABELS[i-1], S(block_name))
			),
			_doc_items_hidden = false,
			tiles = {tile_texture},
			is_ground_content = true,
			stack_max = 64,
			groups = {pickaxey=1, stone=1, building_block=1},
			sounds = base_nodedef.sounds,
			_mcl_blast_resistance = BLAST_RESISTANCE[i],
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

	-- Build terminal block tile texture with optional colorization
	local terminal_tile = base_nodedef.tiles[1].."^mcl_compressed_blocks_8x_overlay.png"
	if overlay_color then
		terminal_tile = base_nodedef.tiles[1].."^(mcl_compressed_blocks_8x_overlay.png^[colorize:"..overlay_color..")"
	end
	if gem_overlay_color then
		terminal_tile = terminal_tile.."^(mcl_compressed_blocks_gem_overlay.png^[colorize:"..gem_overlay_color..")"
	else
		terminal_tile = terminal_tile.."^mcl_compressed_blocks_gem_overlay.png"
	end

	minetest.register_node(name,{
		description = S(LABELS[max_levels], base_nodedef.description),
		_doc_items_longdesc = S(
			"@1 is a decorative block made from 9 @2. It is useful for saving space in your inventories.",
			S(LABELS[max_levels], S(block_name)), S(LABELS[max_levels-1], S(block_name))
		),
		_doc_items_hidden = false,
		tiles = {terminal_tile},

		is_ground_content = true,
		stack_max = 64,
		groups = {pickaxey=1, stone=1, building_block=1},
		drop = final_drops,
		sounds = base_nodedef.sounds,
		_mcl_blast_resistance = BLAST_RESISTANCE[max_levels],
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

-- Example registrations with custom colors
mod.register_block_compression("mcl_core:cobble", "cobblestone", 8, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
}, nil, "#77cefb:120") -- No overlay colorization, bright blue gem

mod.register_block_compression("mcl_deepslate:deepslate_cobbled", "deepslate_cobbled", 8, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
}, "#0080FF:120", "#8A2BE2:120") -- Blue overlay, blue-violet gem

mod.register_block_compression("mcl_core:granite", "granite", 5, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
}, "#FF4500:120", "#FF6347:120") -- Orange-red overlay, tomato gem

mod.register_block_compression("mcl_core:diorite", "diorite", 6, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
}, "#C0C0C0:120", "#E6E6FA:120") -- Silver overlay, lavender gem

mod.register_block_compression("mcl_core:andesite", "andesite", 6, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
}, "#696969:120", "#A52A2A:120") -- Dim gray overlay, brown gem

-- Example: Change only the gem color, keep default overlay
mod.register_block_compression("mcl_core:stone", "stone", 7, {
	max_items = 2,
	items = {
		{items = {"mcl_core:diamond 9"}},
		{items = {"mcl_nether:netherite_scrap 18"}},
	},
}, nil, "#FFD700:120") -- Default overlay, gold gem
