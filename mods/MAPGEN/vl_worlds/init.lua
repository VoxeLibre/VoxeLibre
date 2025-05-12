vl_worlds = {}

local S = minetest.get_translator(minetest.get_current_modname())

local storage = core.get_mod_storage()


---@class vl_worlds.Dimension
---@field id string?
---@field start integer
---@field height integer


-- Mapgen variables
local mg_name = core.get_mapgen_setting("mg_name")
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

---@param pos vector.Vector
---@return vector.Vector
function vl_worlds.pos_to_block(pos)
	return vector.new(
		coordinate_to_block(pos.x),
		coordinate_to_block(pos.y),
		coordinate_to_block(pos.z)
	)
end

---@param pos vector.Vector
---@return vector.Vector
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

---@param pos vector.Vector
---@return integer
function vl_worlds.get_chunk_number(pos) -- unsigned int
	local c = vl_worlds.pos_to_chunk(pos)
	return (c.y + k_positive) * k_positive_y +
		(c.z + k_positive) * k_positive_z +
		c.x + k_positive
end



vl_worlds.dimensional_barrier_size = vl_worlds.MAP_BLOCKSIZE
vl_worlds.dimensional_void_size = 2 * vl_worlds.chunksize * vl_worlds.MAP_BLOCKSIZE



local registered_worlds = {}
---@type vl_worlds.Dimension[]
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
		local void_start1, new_start
		if def.forced_start and dim.start < def.forced_start and dim.start + dim.height > def.forced_start then
			assert(not dim.id, "Tried to force start of dimension \""..dump(id).."\" in space taken by dimension \""..dump(dim.id))
			assert(dim.height - vl_worlds.dimensional_barrier_size >= total_dim_size,
				   "Not enough space to register dimension \""..id.."\" at designed coordinates")

			void_start1 = def.forced_start - vl_worlds.dimensional_void_size
			new_start = def.forced_start

		elseif not dim.id and dim.height - vl_worlds.dimensional_barrier_size >= total_dim_size then
			void_start1 = dim.start + vl_worlds.dimensional_barrier_size
			new_start = dim.start + vl_worlds.dimensional_void_size

		end
		if new_start then
			local wdef = {}
			wdef.name = def.name

			registered_worlds[id] = wdef

			local barrier_start1 = dim.start
			local void_start2 = new_start + def.height
			local void_height2 = vl_worlds.dimensional_void_size + chunk_alignment
			local barrier_start2 = void_start2 + void_height2

			dim.start = barrier_start2
			dim.height = dim.height - barrier_start2 + barrier_start1
			table.insert(world_structure, i, {
				id = "void",
				start = void_start2,
				height = void_height2,
			})
			table.insert(world_structure, i, {
				id = id,
				start = new_start,
				height = def.height,
			})
			table.insert(world_structure, i, {
				id = "void",
				start = void_start1,
				height = new_start - void_start1,
			})
			table.insert(world_structure, i, {
				start = barrier_start1,
				height = void_start1 - barrier_start1,
			})

			core.log(dump(world_structure)) -- TODO debug - remove
			return
		end
	end

	error("Failed to register world \""..id.."\": not enough dimensional space")
end

---@param pos vector.Vector
---@returns vl_worlds.Dimension?
function vl_worlds.dimension_at_pos(pos)
	local pos_y = pos.y
	for _, dim in ipairs(world_structure) do
		if( pos_y >= dim.start and pos_y <= dim.start + dim.height) then
			return dim
		end
	end

	-- TODO: determine if we can ever reach this
	return nil
end

---@param name string
---@returns vl_worlds.Dimension?
function vl_worlds.dimension_by_name(name)
	for _, dim in ipairs(world_structure) do
		if( dim.id == name ) then return dim end
	end
	return nil
end

-- test for nonexistent 0.89 patch to allow testing on prerelease versions
-- TODO migrate to {0, 90} before release
if mcl_vars.minimum_version(mcl_vars.map_initial_version, {0, 89, 4}) then
	vl_worlds.register_world({
		id = "overworld",
		name = S("Overworld"),
		height = 7550,
		forced_start = -62,
	})

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
else
	if not superflat and not singlenode then
		vl_worlds.register_world({
			id = "overworld",
			name = S("Overworld"),
			height = 30989,
			forced_start = -62,
		})

		vl_worlds.register_world({
			id = "underworld",
			name = S("Underworld"),
			height = 256,
			forced_start = -29067,
		})

		vl_worlds.register_world({
			id = "fringe",
			name = S("Fringe"),
			height = 25012,
			forced_start = -27073,
		})
	elseif superflat then
		local ground = tonumber(core.get_mapgen_setting("mgflat_ground_level")) or 8
		vl_worlds.register_world({
			id = "overworld",
			name = S("Overworld"),
			height = vl_worlds.mapgen_edge_max - ground + 3,
			forced_start = ground - 3,
		})

		vl_worlds.register_world({
			id = "underworld",
			name = S("Underworld"),
			height = 256,
			forced_start = -29067,
		})

		vl_worlds.register_world({
			id = "fringe",
			name = S("Fringe"),
			height = 25079,
			forced_start = -27073,
		})
	else
		vl_worlds.register_world({
			id = "overworld",
			name = S("Overworld"),
			height = vl_worlds.mapgen_edge_max + 65,
			forced_start = -65,
		})

		vl_worlds.register_world({
			id = "underworld",
			name = S("Underworld"),
			height = 256,
			forced_start = -29067,
		})

		vl_worlds.register_world({
			id = "fringe",
			name = S("Fringe"),
			height = 25007,
			forced_start = -27073,
		})
	end
end

-- API
-- id - string - registered dimension
function vl_worlds.get_dimension_bounds(id)
	if id == "void" then -- TODO improve the warning, maybe log also for nil id?
		core.log("warning", "There's more than one void, attempting to check void bounds this way is not recommended")
	end
	for _, dim in ipairs(world_structure) do
		if dim.id == id then
			return {
				min = dim.start,
				max = dim.start + dim.height,
			}
		end
	end
end

-- API
-- id - string - registered dimension
-- diff - integer - negative expands downwards, positive expands upwards
function vl_worlds.expand_dimension(id, diff)
	if not id or id == "void" or not diff or diff == 0 then return end -- TODO log a warning
	for i, dim in ipairs(world_structure) do
		if dim.id == id then
			if diff < 0 and world_structure[i-2].height >= vl_worlds.dimensional_barrier_size - diff then
				world_structure[i-2].height = world_structure[i-2].height + diff
				world_structure[i-1].start = world_structure[i-1].start + diff
				dim.start = dim.start + diff
				dim.height = dim.height - diff
			elseif diff > 0 and world_structure[i+2].height >= vl_worlds.dimensional_barrier_size + diff then
				world_structure[i+2].height = world_structure[i+2].height - diff
				world_structure[i+2].start = world_structure[i+2].start + diff
				world_structure[i-1].start = world_structure[i-1].start + diff
				dim.height = dim.height + diff
			end
			return -- TODO signal success/failure
		end
	end
end



-- DEPRECATED
local deprecated = {}
vl_legacy.show_deprecated_field_warnings(mcl_vars, "mcl_vars", deprecated)

local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
deprecated.mg_overworld_min = overworld_bounds.min
deprecated.mg_bedrock_overworld_min = overworld_bounds.min
deprecated.mg_bedrock_overworld_max = overworld_bounds.min + 4
deprecated.mg_lava_overworld_max = overworld_bounds.min + 10 -- TODO query layers instead
deprecated.mg_overworld_max = overworld_bounds.max
if not superflat and not singlenode then
	deprecated.mg_lava = true
	deprecated.mg_bedrock_is_rough = true
else
	deprecated.mg_lava = false
	deprecated.mg_lava_overworld_max = deprecated.mg_overworld_min
	deprecated.mg_bedrock_is_rough = false
end

local nether_bounds = vl_worlds.get_dimension_bounds("underworld")
deprecated.mg_nether_min = nether_bounds.min
deprecated.mg_nether_max = nether_bounds.min + 128

local end_bounds = vl_worlds.get_dimension_bounds("fringe")
deprecated.mg_end_min = end_bounds.min
deprecated.mg_end_max = end_bounds.max

for i, dim in ipairs(world_structure) do
	if dim.id == "fringe" then
		local barrier = world_structure[i+2]
		deprecated.mg_realm_barrier_overworld_end_min = barrier.start
		deprecated.mg_realm_barrier_overworld_end_max = barrier.start + barrier.height
		break
	end
end
-- end of DEPRECATED

-- TODO remove
mcl_vars.mg_bedrock_nether_bottom_min = nether_bounds.min
mcl_vars.mg_nether_deco_max = mcl_vars.mg_nether_max - 11 -- this is so ceiling decorations don't spill into other biomes as bedrock generation calls core.generate_decorations to put netherrack under the bedrock
mcl_vars.mg_bedrock_nether_top_max = mcl_vars.mg_nether_max
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
mcl_vars.mg_end_platform_pos = { x = 100, y = mcl_vars.mg_end_min + 64, z = 0 }
mcl_vars.mg_end_exit_portal_pos = vector.new(0, mcl_vars.mg_end_min + 71, 0)
