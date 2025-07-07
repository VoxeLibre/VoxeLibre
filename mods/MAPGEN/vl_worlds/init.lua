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
		height = vl_worlds.mapgen_edge_max - vl_worlds.mapgen_edge_min,
	},
}

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
			wdef.layers = {}

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
				layers = {},
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
			core.log(dump(registered_worlds))
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

	-- we can get here if pos is out of the world bounds
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
			height = 256 - 48,
			forced_start = -29067,
		})

		vl_worlds.register_world({
			id = "fringe",
			name = S("Fringe"),
			height = 25012 + 79,
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
		distance = dim.start + dim.height - pos.y
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

-- Track player dimensions
---@type {string: vl_worlds.Dimension}
local player_dimensions = {}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	local dim = vl_worlds.dimension_at_pos(player:get_pos())
	assert(dim)

	player_dimensions[name] = dim
	last_dimension[name] = REVERSE_DIMENSION_NAME_COMPAT[dim.id] or dim.id
end)

minetest.register_globalstep(function(dtime)
	-- regular updates based on iterval
	dimtimer = dimtimer + dtime;
	if dimtimer < DIM_UPDATE then return end
	dimtimer = 0

	local players = core.get_connected_players()
	for _,player in ipairs(players) do
		local name = player:get_player_name()
		local curr_dim = player_dimensions[name]
		local pos  = player:get_pos()
		if not curr_dim or pos.y < curr_dim.start or pos.y >= curr_dim.start + curr_dim.height then
			dim = vl_worlds.dimension_at_pos(pos)
			player_dimensions[name] = dim
			local compat_name = DIMENSION_NAME_COMPAT[dim.id] or dim.id
			dimension_change(player, compat_name)
		end
	end
end)


-- API
---@class vl_worlds.LayerDef
---@field id string - layer ID in code
---@field bottom integer - start height from the bottom of the dimension (starts from 0)
---@field top integer - height of the last node of the layer relative to start of dimension
---@field has_separate_biomes boolean? defaults to false
-- -- determines whether biomes can be registered as a part of this layer
---@param dim_id string - id of a valid registered dimension
---@param def vl_worlds.LayerDef
function vl_worlds.register_layer(dim_id, def)
	assert(type(dim_id) == "string", "dim_id must be a string")
	assert(registered_worlds[dim_id], "Dimension \""..dim_id.."\" is not registered")
	local id = def.id
	assert(type(id) == "string", "Layer id must be a string")
	assert(not registered_worlds[dim_id].layers[id],
		   "Layer \""..id.."\" in dimension \""..dim_id.."\" already registered")
	assert(type(def.bottom) == "number" and type(def.top) == "number"
				and def.bottom == def.bottom and def.top == def.top,
		   "Unable to register layer \""..id.."\": height of bottom or top of the layer is not a number")
	assert(def.bottom >= 0 and def.top >= def.bottom,
		   "Unable to register layer \""..id.."\": layer bounds negative or inverted")
	for _, dim in ipairs(world_structure) do
		if dim.id == dim_id then
			assert(def.top <= dim.height,
				   "Unable to register layer \""..id.."\" in world \""..dim_id.."\": top out of world bounds")
			local targ_index
			if #dim.layers == 0 then
				targ_index = 1
			else
				if def.has_separate_biomes then
					for i, layer in ipairs(dim.layers) do
						assert(not layer.has_separate_biomes
							or layer.bottom > def.top or layer.top < def.bottom,
							"Separate biome layers colliding: "..layer.id.." and "..def.id)
					end
				end
				for i, layer in ipairs(dim.layers) do
					if layer.bottom > def.bottom then
						targ_index = i
						break
					end
				end
			end
			if not targ_index then
				targ_index = #dim.layers + 1
			end
			table.insert(dim.layers, targ_index, {
				id = id,
				bottom = def.bottom,
				top = def.top,
				has_separate_biomes = def.has_separate_biomes,
			})
			registered_worlds[dim_id].layers[id] = true -- set for now
		end
	end
end

-- API
---@param string dim_id
---@param string layer_id
---@returns {min: integer, max: integer}?
function vl_worlds.get_layer_bounds(dim_id, layer_id)
	for _, dim in ipairs(world_structure) do
		if dim.id == dim_id then
			for _, layer in ipairs(dim.layers) do
				if layer.id == layer_id then
					return {
						min = dim.start + layer.bottom,
						max = dim.start + layer.top,
					}
				end
			end
		end
	end

	return nil
end


vl_worlds.register_layer("overworld", {
	id = "underground-sea",
	bottom = 0,
	top = 58,
	has_separate_biomes = true,
})
vl_worlds.register_layer("overworld", {
	id = "ocean",
	bottom = 58 + 4 - 15,
	top = 58 + 4,
})
vl_worlds.register_layer("overworld", {
	id = "shore",
	bottom = 59,
	top = 65,
	has_separate_biomes = true,
})

local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
vl_worlds.register_layer("overworld", {
	id = "land",
	bottom = 66,
	top = overworld_bounds.max - overworld_bounds.min,
	has_separate_biomes = true,
})

-- API
---@param string dim
---@param string layer
---@param core.BiomeDef def - everything except for ymin/ymax
function vl_worlds.register_biome(dim, layer, def)
	local bounds = vl_worlds.get_layer_bounds(dim, layer)
	if not bounds then
		error("Unknown dimension layer: "..dim.."."..layer)
	end

	def.y_min = bounds.min + (def.offset_bottom or 0)
	def.y_max = bounds.max - (def.offset_top or 0)
	if def.limit_height_bottom then
		def.y_max = math.min(def.y_max, def.y_min + def.limit_height_bottom)
	elseif def.limit_height_top then
		def.y_min = math.max(def.y_min, def.y_max - def.limit_height_top)
	end

	-- Erase these parameters from biome registration data
	def.offset_bottom = nil
	def.offset_top = nil
	def.limit_height_bottom = nil
	def.limit_height_top = nil

	-- TODO support minp/maxp as well

	core.register_biome(def)
end

-- TODO register bedrock, lava and other utility layers from below as has_separate_biomes = false


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
