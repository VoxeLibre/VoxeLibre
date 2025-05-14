mcl_worlds = {}

local get_connected_players = minetest.get_connected_players

mcl_worlds.is_in_void = vl_worlds.is_void

-- Takes an Y coordinate as input and returns:
-- 1) The corresponding Minecraft layer (can be nil if void)
-- 2) The corresponding Minecraft dimension ("overworld", "nether" or "end") or "void" if it is in the void
-- If the Y coordinate is not located in any dimension, it will return:
--     nil, "void"
local DIMENSION_IDS = {
	overworld = 0, underworld = 1, fringe = 2, void = 3
}
local DIMENSION_NAME_COMPAT = {
	overworld = "overworld", underworld = "nether", fringe = "end", void = "void",
}
local REVERSE_DIMENSION_NAME_COMPAT = {
	overworld = "overworld", nether = "underworld", ["end"] = "fringe", void = "void",
}
---@deprecated
function mcl_worlds.y_to_layer(y)
	local dim = vl_worlds.dimension_at_pos(vector.new(0,y,0))
	if not dim or dim.id == "void" then
		return nil, "void", 3
	end

	return y - dim.start, DIMENSION_NAME_COMPAT[dim.id] or dim.id, DIMENSION_IDS[dim.id] or -1
end

-- Takes a pos and returns the dimension it belongs to (same as above)
---@deprecated
function mcl_worlds.pos_to_dimension(pos)
	local dim = vl_worlds.dimension_at_pos(pos)
	if not dim or dim.id == "void" then
		return nil, "void", 3
	end

	return DIMENSION_NAME_COMPAT[dim.id] or dim.id, DIMENSION_IDS[dim.id] or -1
end

-- Takes a Minecraft layer and a “dimension” name
-- and returns the corresponding Y coordinate for
-- VoxeLibre
-- dimension_name is one of "overworld", "nether", "end" (default: "overworld").
---@deprecated
function mcl_worlds.layer_to_y(offset, dimension_name)
	dimension_name = dimension_name or "overworld"

	local dim = vl_worlds.dimension_by_name(REVERSE_DIMENSION_NAME_COMPAT[dimension_name])
	assert(dim)

	return dim.start + offset
end

mcl_worlds.has_weather = vl_worlds.has_weather
mcl_worlds.has_dust = vl_worlds.has_dust

local COMPASS_WORKS = {overworld = true, underworld = false, fringe = false, void = true}
-- Takes a position (pos) and returns true if compasses are working here
function mcl_worlds.compass_works(pos)
	local dim = vl_worlds.dimension_at_pos(pos)
	if not dim then return true end

	return COMPASS_WORKS[dim] or true
end

-- Takes a position (pos) and returns true if clocks are working here
mcl_worlds.clock_works = mcl_worlds.compass_works

--------------- CALLBACKS ------------------
mcl_worlds.registered_on_dimension_change = {}

-- Register a callback function func(player, dimension).
-- It will be called whenever a player changes between dimensions.
-- The void counts as dimension.
-- * player: The player who changed the dimension
-- * dimension: The new dimension of the player ("overworld", "nether", "end", "void").
function mcl_worlds.register_on_dimension_change(func)
	table.insert(mcl_worlds.registered_on_dimension_change, func)
end

-- Playername-indexed table containig the name of the last known dimension the
-- player was in.
local last_dimension = {}

-- Notifies this mod about a dimension change of a player.
-- * player: Player who changed the dimension
-- * dimension: New dimension ("overworld", "nether", "end", "void")
function mcl_worlds.dimension_change(player, dimension)
	local playername = player:get_player_name()
	for i=1, #mcl_worlds.registered_on_dimension_change do
		mcl_worlds.registered_on_dimension_change[i](player, dimension, last_dimension[playername])
	end
	last_dimension[playername] = dimension
end

local dimension_change = mcl_worlds.dimension_change

----------------------- INTERNAL STUFF ----------------------

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

	local players = get_connected_players()
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

function mcl_worlds.get_cloud_parameters()
	if minetest.get_mapgen_setting("mg_name") == "valleys" then
		return {
			height = 384, --valleys has a much higher average elevation thus often "normal" landscape ends up in the clouds
			speed = {x=-2, z=0},
			thickness=5,
			color="#FFF0FEF",
			ambient = "#201060",
		}
	else
		local overworld = vl_worlds.dimension_by_name("overworld")
		assert(overworld)

		-- MC-style clouds: Layer 127, thickness 4, fly to the “West”
		return {
			height = overworld.start + 127,
			speed = {x=-2, z=0},
			thickness = 4,
			color = "#FFF0FEF",
		}
	end
end
