vl_worlds = {}

local S = minetest.get_translator(minetest.get_current_modname())

local storage = core.get_mod_storage()



-- Mapgen variables
local mg_name = core.get_mapgen_setting("mg_name")
local minecraft_height_limit = 256 -- TODO remove
local superflat = mg_name == "flat" and core.get_mapgen_setting("mcl_superflat_classic") == "true"
local singlenode = mg_name == "singlenode"

-- Calculate mapgen_edge_min/mapgen_edge_max
vl_worlds.chunksize = math.max(1, tonumber(core.get_mapgen_setting("chunksize")) or 5)
vl_worlds.MAP_BLOCKSIZE = math.max(1, core.MAP_BLOCKSIZE or 16)
vl_worlds.mapgen_limit = math.max(1, tonumber(core.get_mapgen_setting("mapgen_limit")) or 31000)
vl_worlds.MAX_MAP_GENERATION_LIMIT = math.max(1, core.MAX_MAP_GENERATION_LIMIT or 31000)

-- Central chunk is offset from 0,0,0 coordinates by 32 nodes (2 blocks)
-- See more in https://git.core.land/VoxeLibre/VoxeLibre/wiki/World-structure%3A-positions%2C-boundaries%2C-blocks%2C-chunks%2C-dimensions%2C-barriers-and-the-void
local central_chunk_offset = -math.floor(vl_worlds.chunksize / 2)

vl_worlds.central_chunk_offset_in_nodes = central_chunk_offset * vl_worlds.MAP_BLOCKSIZE
vl_worlds.chunk_size_in_nodes = vl_worlds.chunksize * vl_worlds.MAP_BLOCKSIZE

local central_chunk_min_pos = central_chunk_offset * vl_worlds.MAP_BLOCKSIZE
local central_chunk_max_pos = central_chunk_min_pos + vl_worlds.chunk_size_in_nodes - 1
local ccfmin = central_chunk_min_pos - vl_worlds.MAP_BLOCKSIZE -- Fullminp/fullmaxp of central chunk, in nodes
local ccfmax = central_chunk_max_pos + vl_worlds.MAP_BLOCKSIZE
local mapgen_limit_b = math.floor(math.min(vl_worlds.mapgen_limit, vl_worlds.MAX_MAP_GENERATION_LIMIT) /
	vl_worlds.MAP_BLOCKSIZE)
local mapgen_limit_min = -mapgen_limit_b * vl_worlds.MAP_BLOCKSIZE
local mapgen_limit_max = (mapgen_limit_b + 1) * vl_worlds.MAP_BLOCKSIZE - 1
local numcmin = math.max(math.floor((ccfmin - mapgen_limit_min) / vl_worlds.chunk_size_in_nodes), 0) -- Number of complete chunks from central chunk
local numcmax = math.max(math.floor((mapgen_limit_max - ccfmax) / vl_worlds.chunk_size_in_nodes), 0) -- fullminp/fullmaxp to effective mapgen limits.

vl_worlds.mapgen_edge_min = central_chunk_min_pos - numcmin * vl_worlds.chunk_size_in_nodes
vl_worlds.mapgen_edge_max = central_chunk_max_pos + numcmax * vl_worlds.chunk_size_in_nodes

---@param x integer
---@return integer
local function coordinate_to_block(x)
	return math.floor(x / vl_worlds.MAP_BLOCKSIZE)
end

---@param x integer
---@return integer
local function coordinate_to_chunk(x)
	return math.floor((coordinate_to_block(x) - central_chunk_offset) / vl_worlds.chunksize)
end

---@param pos Vector
---@return Vector
function vl_worlds.pos_to_block(pos)
	return vector.new(
		coordinate_to_block(pos.x),
		coordinate_to_block(pos.y),
		coordinate_to_block(pos.z)
	)
end

---@param pos Vector
---@return Vector
function vl_worlds.pos_to_chunk(pos)
	return vector.new(
		coordinate_to_chunk(pos.x),
		coordinate_to_chunk(pos.y),
		coordinate_to_chunk(pos.z)
	)
end

local k_positive = math.ceil(vl_worlds.MAX_MAP_GENERATION_LIMIT / vl_worlds.chunk_size_in_nodes)
local k_positive_z = k_positive * 2
local k_positive_y = k_positive_z * k_positive_z

---@param pos Vector
---@return integer
function vl_worlds.get_chunk_number(pos) -- unsigned int
	local c = vl_worlds.pos_to_chunk(pos)
	return (c.y + k_positive) * k_positive_y +
		(c.z + k_positive) * k_positive_z +
		c.x + k_positive
end



vl_worlds.dimensional_barrier_size = vl_worlds.MAP_BLOCKSIZE
vl_worlds.dimensional_void_size = 2 * vl_worlds.chunksize

-- TODO move to *_worlds as far as possible
if not superflat and not singlenode then
	-- Normal mode
	--[[ Realm stacking (h is for height)
	- Overworld (h>=256)
	- Void (h>=1000)
	- Realm Barrier (h=11), to allow escaping the End
	- End (h>=256)
	- Void (h>=1000)
	- Nether (h=128)
	- Void (h>=1000)
	]]

	-- Overworld
	mcl_vars.mg_overworld_min = -62
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min + 4
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min + 10
	mcl_vars.mg_lava = true
	mcl_vars.mg_bedrock_is_rough = true

elseif singlenode then
	mcl_vars.mg_overworld_min = -66
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min
	mcl_vars.mg_lava = false
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_is_rough = false
else
	-- Classic superflat
	local ground = tonumber(core.get_mapgen_setting("mgflat_ground_level")) or 8

	mcl_vars.mg_overworld_min = ground - 3
	mcl_vars.mg_overworld_max_official = mcl_vars.mg_overworld_min + minecraft_height_limit
	mcl_vars.mg_bedrock_overworld_min = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_overworld_max = mcl_vars.mg_bedrock_overworld_min
	mcl_vars.mg_lava = false
	mcl_vars.mg_lava_overworld_max = mcl_vars.mg_overworld_min
	mcl_vars.mg_bedrock_is_rough = false
end

mcl_vars.mg_overworld_max = vl_worlds.mapgen_edge_max

-- The Nether (around Y = -29000)
mcl_vars.mg_nether_min = -29067 -- Carefully chosen to be at a mapchunk border
mcl_vars.mg_nether_max = mcl_vars.mg_nether_min + 128
mcl_vars.mg_bedrock_nether_bottom_min = mcl_vars.mg_nether_min
mcl_vars.mg_bedrock_nether_top_max = mcl_vars.mg_nether_max
mcl_vars.mg_nether_deco_max = mcl_vars.mg_nether_max -11 -- this is so ceiling decorations don't spill into other biomes as bedrock generation calls core.generate_decorations to put netherrack under the bedrock
if not superflat then
	mcl_vars.mg_bedrock_nether_bottom_max = mcl_vars.mg_bedrock_nether_bottom_min + 4
	mcl_vars.mg_bedrock_nether_top_min = mcl_vars.mg_bedrock_nether_top_max - 4
	mcl_vars.mg_lava_nether_max = mcl_vars.mg_nether_min + 31
else
	-- Thin bedrock in classic superflat mapgen
	mcl_vars.mg_bedrock_nether_bottom_max = mcl_vars.mg_bedrock_nether_bottom_min
	mcl_vars.mg_bedrock_nether_top_min = mcl_vars.mg_bedrock_nether_top_max
	mcl_vars.mg_lava_nether_max = mcl_vars.mg_nether_min + 2
end
if mg_name == "flat" then
	if superflat then
		mcl_vars.mg_flat_nether_floor = mcl_vars.mg_bedrock_nether_bottom_max + 4
		mcl_vars.mg_flat_nether_ceiling = mcl_vars.mg_bedrock_nether_bottom_max + 52
	else
		mcl_vars.mg_flat_nether_floor = mcl_vars.mg_lava_nether_max + 4
		mcl_vars.mg_flat_nether_ceiling = mcl_vars.mg_lava_nether_max + 52
	end
end

-- The End (surface at ca. Y = -27000)
mcl_vars.mg_end_min = -27073 -- Carefully chosen to be at a mapchunk border
mcl_vars.mg_end_max_official = mcl_vars.mg_end_min + minecraft_height_limit
mcl_vars.mg_end_max = mcl_vars.mg_overworld_min - 2000
mcl_vars.mg_end_platform_pos = { x = 100, y = mcl_vars.mg_end_min + 64, z = 0 }
mcl_vars.mg_end_exit_portal_pos = vector.new(0, mcl_vars.mg_end_min + 71, 0)

-- Realm barrier used to safely separate the End from the void below the Overworld
mcl_vars.mg_realm_barrier_overworld_end_max = mcl_vars.mg_end_max
mcl_vars.mg_realm_barrier_overworld_end_min = mcl_vars.mg_end_max - 11
-- TODO bottom of to-be-moved stuff



local registered_worlds = {}
local world_structure = {
	{
		start = vl_worlds.mapgen_edge_min,
		height = vl_worlds.mapgen_edge_max - vl_worlds.mapgen_edge_min,
	},
}

-- API - attempts to register a world - crashes on failure to prevent damaging the save
-- required parameters in def:
-- id - string - world ID in code and mod storage
-- name - translated string - world name wherever it would be displayed
-- height - integer - buildable height of the world, this includes bedrock and such
-- optional parameters in def:
-- forced_start - integer - forced start height of the world
-- -- - if a dimension is already registered there or the dimension wouldn't fit, causes an error
function vl_worlds.register_world(def)
	local modname = core.get_current_modname()
	local id = def.id
	assert(id ~= nil, "Unable to register world from mod "..modname..": id is nil")
	assert(type(id) == "string", "Unable to register world from mod "..modname..": id is not a string")
	assert(id ~= "void", "Unable to register world from mod "..modname..": \""..id.."\" is a reserved keyword")
	assert(not registered_worlds[id], "World \""..id.."\" already registered!")
	assert(type(def.name) == "string", "Unable to register world \""..id.."\": name is not a string")
	assert(type(def.height) == "number", "Unable to register world \""..id.."\": height is not a number")

	local chunk_alignment = def.height%80>0 and 80-def.height%80 or 0
	local total_dim_size = def.height
		+ 2*vl_worlds.dimensional_void_size -- void below and above the dimension
		+ vl_worlds.dimensional_barrier_size -- barrier below
		+ chunk_alignment -- goes into void above the dimension
	for i, dim in ipairs(world_structure) do
		local wdef, barrier_start1, void_start1, dim_start, void_start2, barrier_start2
		if def.forced_start and dim.start < def.forced_start and dim.start + dim.height > def.forced_start then
			assert(not dim.id, "Tried to force start of dimension \""..id.."\" in space taken by dimension \""..dim.id)
			assert(dim.height - vl_worlds.dimensional_barrier_size >= total_dim_size,
				   "Not enough space to register dimension \""..id.."\" at designed coordinates")

			wdef = {}
			wdef.name = name

			barrier_start1 = dim.start
			void_start1 = def.forced_start - vl_worlds.dimensional_void_size
			dim_start = def.forced_start
			void_start2 = dim_start + def.height
			void_height2 = vl_worlds.dimensional_void_size + chunk_alignment
			barrier_start2 = barrier_start1 + total_dim_size

		elseif not dim.id and dim.height - vl_worlds.dimensional_barrier_size >= total_dim_size then
			wdef = {}
			wdef.name = name

			barrier_start1 = dim.start
			void_start1 = barrier_start1 + vl_worlds.dimensional_barrier_size
			dim_start = void_start1 + vl_worlds.dimensional_void_size
			void_start2 = dim_start + def.height
			void_height2 = vl_worlds.dimensional_void_size + chunk_alignment
			barrier_start2 = barrier_start1 + total_dim_size

		end
		if wdef then
			registered_worlds[id] = wdef
			dim.start = barrier_start2
			dim.height = dim.height - vl_worlds.dimensional_barrier_size - total_dim_size
			table.insert(world_structure, i, {
				id = "void",
				start = void_start2,
				height = void_height2,
			})
			table.insert(world_structure, i, {
				id = id,
				start = dim_start,
				height = def.height,
			})
			table.insert(world_structure, i, {
				id = "void",
				start = void_start1,
				height = vl_worlds.dimensional_void_size - vl_worlds.dimensional_barrier_size,
			})
			table.insert(world_structure, i, {
				start = barrier_start1,
				height = vl_worlds.dimensional_barrier_size,
			})

			core.log(dump(world_structure)) -- TODO debug - remove
			return
		end
	end

	error("Failed to register world \""..id.."\": not enough dimensional space")
end

vl_worlds.register_world({
	id = "underworld",
	name = S("Underworld"),
	height = 256,
})

vl_worlds.register_world({
	id = "fringe",
	name = S("Fringe"),
	height = 2048,
})

vl_worlds.register_world({
	id = "overworld",
	name = S("Overworld"),
	height = 8192,
})
