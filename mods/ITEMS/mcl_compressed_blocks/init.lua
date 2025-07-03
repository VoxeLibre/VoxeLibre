-- (C. 2024) Thomas Conway <smokey@tilde.team> - original mod author, overlay texture artist, implemented colorizer system
-- (C. 2024) Teknomunk, - created and optimized the API system to generalize compressed block registry
local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local function N(s) return s end
local mod = {}
mcl_compressed_block = mod

-- Configuration constants
local COMPRESSION_RATIO = 9

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

-- Balanced progression formulas
local function calculate_blast_resistance(level, base_resistance)
	base_resistance = base_resistance or 6
	return math.floor(base_resistance * (1.8 ^ level))
end

local function calculate_hardness(level, base_hardness)
	base_hardness = base_hardness or 2
	return math.floor(base_hardness * (1.4 ^ level))
end

-- Utility function to safely get tile texture
local function get_base_tile(nodedef)
	if not nodedef.tiles or #nodedef.tiles == 0 then
		return "unknown_node.png"
	end

	local tile = nodedef.tiles[1]
	if type(tile) == "table" then
		return tile.name or tile.image or "unknown_node.png"
	end
	return tile
end

-- Build texture with overlay and colorization
local function build_texture(base_tile, overlay_level, overlay_color, gem_overlay_color, is_terminal)
	local texture = base_tile .. "^mcl_compressed_blocks_" .. tostring(overlay_level) .. "x_overlay.png"

	if overlay_color then
		texture = base_tile .. "^(mcl_compressed_blocks_" .. tostring(overlay_level) .. "x_overlay.png^[colorize:" .. overlay_color .. ")"
	end

	if is_terminal then
		if gem_overlay_color then
			texture = texture .. "^(mcl_compressed_blocks_gem_overlay.png^[colorize:" .. gem_overlay_color .. ")"
		else
			texture = texture .. "^mcl_compressed_blocks_gem_overlay.png"
		end
	end

	return texture
end

-- Register a single compression level
local function register_compression_level(base_nodedef, base_tile, level, max_levels, block_name, prev_name, overlay_color, gem_overlay_color, final_drops)
	local overlay_level = math.ceil(level / max_levels * 8)
	local name = "mcl_compressed_blocks:" .. NODE_NAMES[level] .. block_name
	local is_terminal = (level == max_levels)

	-- Calculate dynamic properties
	local blast_resistance = calculate_blast_resistance(level, base_nodedef._mcl_blast_resistance)
	local hardness = calculate_hardness(level, base_nodedef._mcl_hardness)

	-- Build texture
	local tile_texture = build_texture(base_tile, overlay_level, overlay_color, gem_overlay_color, is_terminal)

	-- Create node definition
	local nodedef = {
		description = S(LABELS[level], base_nodedef.description),
		_doc_items_longdesc = S(
			"@1 is a decorative block made from 9 @2. It is useful for saving space in your inventories.",
			S(LABELS[level], S(block_name)),
			level > 1 and S(LABELS[level-1], S(block_name)) or base_nodedef.description
		),
		_doc_items_hidden = false,
		tiles = {tile_texture},
		is_ground_content = base_nodedef.is_ground_content or true,
		stack_max = 64,
		groups = base_nodedef.groups or {pickaxey=1, stone=1, building_block=1},
		sounds = base_nodedef.sounds,
		_mcl_blast_resistance = blast_resistance,
		_mcl_hardness = hardness,
	}

	-- Terminal block specific properties
	if is_terminal then
		nodedef.drop = final_drops
		nodedef._mcl_silk_touch_drop = true
	end

	minetest.register_node(name, nodedef)

	-- Register crafting recipes
	minetest.register_craft({
		output = name,
		recipe = {
			{ prev_name, prev_name, prev_name },
			{ prev_name, prev_name, prev_name },
			{ prev_name, prev_name, prev_name },
		},
	})

	minetest.register_craft({
		output = prev_name .. " " .. COMPRESSION_RATIO,
		recipe = {
			{ name },
		},
	})

	return name
end

-- Default drop configuration for consistency
local function create_default_drops()
	return {
		max_items = 2,
		items = {
			{items = {"mcl_core:diamond 9"}},
			{items = {"mcl_nether:netherite_scrap 18"}},
		},
	}
end

---@class vl_compressed_blocks.Def
---@field base string
---@field name string
---@field levels integer
---@field drops table
---@field overlay_color? string
---@field gem_color? string

-- Main compression registration function
---@param def vl_compressed_blocks.Def
function mod.register_block_compression(def)
	local final_drops = def.drops or create_default_drops()

	local base_nodedef = minetest.registered_nodes[def.base]
	local base_tile = get_base_tile(base_nodedef)

	local prev_name = def.base

	-- Register intermediate compression levels
	for i = 1, def.levels - 1 do
		prev_name = register_compression_level(
			base_nodedef, base_tile, i, def.levels, def.name,
			prev_name, def.overlay_color, nil, nil
		)
	end

	-- Register terminal compression level
	register_compression_level(
		base_nodedef, base_tile, def.levels, def.levels, def.name,
		prev_name, def.overlay_color, def.gem_color, final_drops
	)
end

-- Register included blocks
mod.register_block_compression({
	base = "mcl_core:cobble",
	name = "cobblestone",
	levels = 8,
	overlay_color = nil,
	gem_color = "#77cefb:120",

	drops = {
		max_items = 2,
		items = {
			{items = {"mcl_core:diamond 9"}},
			{items = {"mcl_nether:netherite_scrap 18"}},
		},
	}
})
mod.register_block_compression({
	base = "mcl_deepslate:deepslate_cobbled",
	name = "deepslate_cobbled",
	levels = 8,
	overlay_color = "#292b53:120",
	gem_color = "#8A2BE2:120",

	drops = {
		max_items = 3,
		items = {
			{items = {"mcl_core:diamond 12"}},
			{items = {"mcl_nether:netherite_scrap 24"}},
		},
	}
})
mod.register_block_compression({
	base = "mcl_core:granite",
	name = "granite",
	levels = 5,
	overlay_color = "#734638:120",
	gem_color = "#FF6347:120",

	drops = {
		max_items = 2,
		items = {
			{items = {"mcl_core:gold_ingot 16"}},
			{items = {"mcl_nether:quartz 32"}},
		},
	}
})
mod.register_block_compression({
	base = "mcl_core:diorite",
	name = "diorite",
	levels = 6,
	overlay_color = "#5e5468:120",
	gem_color = "#E6E6FA:120",
	drops = {
		max_items = 2,
		items = {
			{items = {"mcl_core:iron_ingot 24"}},
			{items = {"mcl_core:quartz 20"}},
		},
	}
})
mod.register_block_compression({
	base = "mcl_core:andesite",
	name = "andesite",
	levels = 6,
	overlay_color = "#243d2b:120",
	gem_color = "#138834:120",

	drops = {
		max_items = 3,
		items = {
			{items = {"mcl_core:iron_ingot 18"}},
			{items = {"mcl_core:copper_ingot 32"}},
			{items = {"mcl_core:coal_lump 48"}},
		},
	}
})
mod.register_block_compression({
	base = "mcl_core:stone",
	name = "stone",
	levels = 7,
	overlay_color = "#554c3d",
	gem_color = "#FFD700:120",

	drops = {
		max_items = 2,
		items = {
			{items = {"mcl_core:diamond 15"}},
			{items = {"mcl_core:emerald 8"}},
		},
	}
})
