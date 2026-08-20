vl_worlds = {}

local S = minetest.get_translator(minetest.get_current_modname())

local storage = core.get_mod_storage()



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

-- Other constants
local DIMENSION_NAME_COMPAT = {
	overworld = "overworld", underworld = "nether", fringe = "end", void = "void",
}
vl_worlds.DIMENSION_NAME_COMPAT = DIMENSION_NAME_COMPAT

local REVERSE_DIMENSION_NAME_COMPAT = {
	overworld = "overworld", nether = "underworld", ["end"] = "fringe", void = "void",
}
vl_worlds.REVERSE_DIMENSION_NAME_COMPAT = REVERSE_DIMENSION_NAME_COMPAT

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
vl_worlds.registered_worlds = registered_worlds

---@class vl_worlds.Dimension
---@field id string? - world ID in code and mod storage
---@field name string? - translated string - world name anywhere it would be displayed
---@field start integer - lowest y position that is part of this world
---@field height integer - buildable height of the world, this includes bedrock and such
---@field layers? vl_worlds.Layer[]

---@class vl_worlds.Layer
---@field id string
---@field top integer
---@field bottom integer

---@type vl_worlds.Dimension[]
local world_structure = {
	{
		start = vl_worlds.mapgen_edge_min,
		height = vl_worlds.mapgen_edge_max - vl_worlds.mapgen_edge_min + 1,
	},
}

local ALLOCATIONS_STORAGE_KEY = "dimension_allocations"
local dimension_allocations = core.deserialize(storage:get_string(ALLOCATIONS_STORAGE_KEY)) or {}
assert(type(dimension_allocations) == "table", "Invalid saved dimension allocations")

local function replace_structure_entry(index, parts)
	table.remove(world_structure, index)
	local inserted = 0
	for _, part in ipairs(parts) do
		if part.height > 0 then
			table.insert(world_structure, index + inserted, part)
			inserted = inserted + 1
		end
	end
end

local function allocation_parts(allocation, id)
	local dimension_start = allocation.start
	local lower_void_start = dimension_start - vl_worlds.dimensional_void_size
	local upper_void_start = dimension_start + allocation.height
	local upper_void_height = allocation.reservation_start + allocation.reservation_height - upper_void_start

	return {
		{
			start = allocation.reservation_start,
			height = lower_void_start - allocation.reservation_start,
		},
		{
			id = "void",
			start = lower_void_start,
			height = vl_worlds.dimensional_void_size,
		},
		{
			id = id,
			start = dimension_start,
			height = allocation.height,
		},
		{
			id = "void",
			start = upper_void_start,
			height = upper_void_height,
		},
	}
end

-- Pre-allocate areas from storage. If mod load order will change or one of the mods
-- is no longer loaded, no one should encroach onto this area.
for id, allocation in pairs(dimension_allocations) do
	assert(type(id) == "string" and type(allocation) == "table"
		and type(allocation.start) == "number" and type(allocation.height) == "number"
		and type(allocation.reservation_start) == "number"
		and type(allocation.reservation_height) == "number",
		"Invalid saved allocation for dimension "..tostring(id))
	table.insert(saved_allocations, { id = id, allocation = allocation })
end
table.sort(saved_allocations, function(a, b)
	return a.allocation.reservation_start < b.allocation.reservation_start
end)

for _, saved in ipairs(saved_allocations) do
	local allocation = saved.allocation
	local reservation_end = allocation.reservation_start + allocation.reservation_height
	local inserted = false
	for i, region in ipairs(world_structure) do
		local region_end = region.start + region.height
		if not region.id and allocation.reservation_start >= region.start
				and reservation_end <= region_end then
			replace_structure_entry(i, {
				{ start = region.start, height = allocation.reservation_start - region.start },
				{
					id = "void",
					reservation_id = saved.id,
					start = allocation.reservation_start,
					height = allocation.reservation_height,
				},
				{ start = reservation_end, height = region_end - reservation_end },
			})
			inserted = true
			break
		end
	end
	assert(inserted, "Saved allocation for dimension \""..saved.id.."\" overlaps another allocation or is out of bounds")
end

-- API - attempts to register a world - crashes on failure to prevent damaging the save
-- required parameters in def:
---@class vl_worlds.DimensionDef
---@field id string - world ID in code and mod storage
---@field name string - translated string - world name anywhere it would be displayed
---@field height integer - buildable height of the world, this includes bedrock and such
---@field forced_start? integer forced start height of the world (optional)
---@param def vl_worlds.DimensionDef
-- -- - if a dimension is already registered there or the dimension wouldn't fit, causes an error
function vl_worlds.register_world(def)
	local modname = core.get_current_modname()
	local id = def.id
	assert(id ~= nil, "Unable to register world from mod "..modname..": id is nil")
	assert(type(id) == "string", "Unable to register world from mod "..modname..": id is not a string")
	assert(id ~= "void", "Unable to register world from mod "..modname..": \""..id.."\" is a reserved keyword")
	assert(not registered_worlds[id], "World \""..id.."\" already registered!")
	assert(type(def.name) == "string", "Unable to register world \""..id.."\": name is not a string")
	assert(type(def.height) == "number" and def.height > 0 and def.height % 1 == 0,
		"Unable to register world \""..id.."\": height is not a positive integer")

	local saved = dimension_allocations[id]
	if saved then
		assert(saved.height == def.height,
			"Dimension \""..id.."\" was previously allocated with height "..saved.height
			..", but is now being registered with height "..def.height)
		assert(not def.forced_start or def.forced_start == saved.start,
			"Dimension \""..id.."\" was previously allocated at "..saved.start
			..", but is now being forced to start at "..def.forced_start)

		for i, region in ipairs(world_structure) do
			if region.reservation_id == id then
				replace_structure_entry(i, allocation_parts(saved, id))
				registered_worlds[id] = { name = def.name }
				return
			end
		end
		error("Saved allocation for dimension \""..id.."\" was not reserved")
	end

	local chunk_alignment = def.height % vl_worlds.chunk_size_in_nodes
	chunk_alignment = chunk_alignment > 0 and vl_worlds.chunk_size_in_nodes - chunk_alignment or 0
	local total_dim_size = def.height
		+ 2*vl_worlds.dimensional_void_size -- void below and above the dimension
		+ vl_worlds.dimensional_barrier_size -- barrier below
		+ chunk_alignment -- goes into void above the dimension
	for i, dim in ipairs(world_structure) do
		local void_start1, new_start, forced_reservation_end
		if def.forced_start then
			void_start1 = def.forced_start - vl_worlds.dimensional_void_size
			new_start = def.forced_start
			local reservation_start = void_start1 - vl_worlds.dimensional_barrier_size
			local region_end = dim.start + dim.height
			local dimension_end = def.forced_start + def.height
			forced_reservation_end = math.min(reservation_start + total_dim_size, region_end)
			if dim.id or reservation_start < dim.start or dimension_end > region_end then
				new_start = nil
			end
		elseif not dim.id and dim.height >= total_dim_size then
			void_start1 = dim.start + vl_worlds.dimensional_barrier_size
			new_start = void_start1 + vl_worlds.dimensional_void_size

		end
		if new_start then
			local void_start2 = new_start + def.height
			local void_height2 = vl_worlds.dimensional_void_size + chunk_alignment
			local reservation_start = void_start1 - vl_worlds.dimensional_barrier_size
			local reservation_end = forced_reservation_end or void_start2 + void_height2
			local region_end = dim.start + dim.height
			local allocation = {
				start = new_start,
				height = def.height,
				reservation_start = reservation_start,
				reservation_height = reservation_end - reservation_start,
			}

			local parts = allocation_parts(allocation, id)
			table.insert(parts, 1, {
				start = dim.start,
				height = reservation_start - dim.start,
			})
			table.insert(parts, {
				start = reservation_end,
				height = region_end - reservation_end,
			})
			replace_structure_entry(i, parts)
			dimension_allocations[id] = allocation
			storage:set_string(ALLOCATIONS_STORAGE_KEY, core.serialize(dimension_allocations))
			registered_worlds[id] = { name = def.name }
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
		if pos_y >= dim.start and pos_y < dim.start + dim.height then
			return dim
		end
	end

	-- we can get here if pos is out of the world bounds
	return nil
end

-- test for nonexistent 0.89 patch to allow testing on prerelease versions
-- TODO migrate to {0, 90} before release
if false and mcl_vars.minimum_version(mcl_vars.map_initial_version, {0, 89, 4}) then
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
---@paramm id string - registered dimension
---@returns {min: integer, max: integer}?
function vl_worlds.get_dimension_bounds(id)
	if id == "void" then -- TODO improve the warning, maybe log also for nil id?
		core.log("warning", "There's more than one void, attempting to check void bounds this way is not recommended")
	end
	for _, dim in ipairs(world_structure) do
		if dim.id == id then
			return {
				min = dim.start,
				max = dim.start + dim.height - 1,
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

local VOID_DEADLY_TOLERANCE = 64 -- the player must be this many nodes “deep” into the void to be damaged
---@param pos vector.Vector
---@returns boolean,boolean
function vl_worlds.is_void(pos)
	local dim = vl_worlds.dimension_at_pos(pos)
	if not dim then return true, true end
	if dim.id ~= "void" then return false, false end

	-- Check if the registered dimension is above or below pos and calculate the distance into the void
	local distance
	local below = vl_worlds.dimension_at_pos(vector.new(0, dim.start - 1, 0 ))
	if not below or not below.id then
		-- above the current position
		distance = dim.start + dim.height - 1 - pos.y
	else
		-- below the current position
		distance = pos.y - dim.start
	end

	return true, distance > VOID_DEADLY_TOLERANCE
end

---@param pos vector.Vector
---@returns boolean
function vl_worlds.has_weather(pos)
	local dim = vl_worlds.dimension_at_pos(pos)
	if not dim then return false end

	local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
	assert(overworld_bounds)

	if pos.y > overworld_bounds.max then return false end
	if pos.y < overworld_bounds.min - 64 then return false end
	return true
end

---@param pos vector.Vector
---@returns boolean
function vl_worlds.has_dust(pos)
	local dim = vl_worlds.dimension_at_pos(pos)
	if not dim then return false end

	local underworld_bounds = vl_worlds.get_dimension_bounds("underworld")
	assert(underworld_bounds)

	if pos.y > underworld_bounds.max + 138 then return false end
	if pos.y < underworld_bounds.min - 10 then return false end
	return true
end

--- dimension change notifications
--------------- CALLBACKS ------------------
local registered_on_dimension_change = {}

-- Register a callback function func(player, dimension).
-- It will be called whenever a player changes between dimensions.
-- The void counts as dimension.
-- * player: The player who changed the dimension
-- * dimension: The new dimension of the player ("overworld", "nether", "end", "void").
function vl_worlds.register_on_dimension_change(func)
	table.insert(registered_on_dimension_change, func)
end

-- Playername-indexed table containig the name of the last known dimension the
-- player was in.
local last_dimension = {}

-- Notifies this mod about a dimension change of a player.
-- * player: Player who changed the dimension
-- * dimension: New dimension ("overworld", "nether", "end", "void")
function vl_worlds.dimension_change(player, dimension)
	local playername = player:get_player_name()
	for i=1, #registered_on_dimension_change do
		registered_on_dimension_change[i](player, dimension, last_dimension[playername])
	end
	last_dimension[playername] = dimension
end

local dimension_change = vl_worlds.dimension_change
-- Update the dimension callbacks every DIM_UPDATE seconds
local DIM_UPDATE = 1
local dimtimer = 0

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local dim = vl_worlds.dimension_at_pos(player:get_pos())
	last_dimension[name] = dim and (DIMENSION_NAME_COMPAT[dim.id] or dim.id) or "void"
end)

minetest.register_on_leaveplayer(function(player)
	last_dimension[player:get_player_name()] = nil
end)

minetest.register_globalstep(function(dtime)
	-- regular updates based on iterval
	dimtimer = dimtimer + dtime;
	if dimtimer < DIM_UPDATE then return end
	dimtimer = 0

	local players = core.get_connected_players()
	for _,player in ipairs(players) do
		local name = player:get_player_name()
		local dim = vl_worlds.dimension_at_pos(player:get_pos())
		local compat_name = dim and (DIMENSION_NAME_COMPAT[dim.id] or dim.id) or "void"
		if compat_name ~= last_dimension[name] then
			dimension_change(player, compat_name)
		end
	end
end)


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
deprecated.mg_nether_max = nether_bounds.max

local end_bounds = vl_worlds.get_dimension_bounds("fringe")
deprecated.mg_end_min = end_bounds.min
deprecated.mg_end_max = end_bounds.max

for i, dim in ipairs(world_structure) do
	if dim.id == "fringe" then
		local barrier = world_structure[i+2]
		deprecated.mg_realm_barrier_overworld_end_min = barrier.start
		deprecated.mg_realm_barrier_overworld_end_max = barrier.start + barrier.height - 1
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
