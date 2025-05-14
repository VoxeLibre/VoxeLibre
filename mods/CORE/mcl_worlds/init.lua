mcl_worlds = {}

local get_connected_players = minetest.get_connected_players

mcl_worlds.is_in_void = vl_worlds.is_void

local DIMENSION_IDS = {
	overworld = 0, underworld = 1, fringe = 2, void = 3
}
local DIMENSION_NAME_COMPAT = vl_worlds.DIMENSION_NAME_COMPAT
local REVERSE_DIMENSION_NAME_COMPAT = vl_worlds.REVERSE_DIMENSION_NAME_COMPAT

-- Takes an Y coordinate as input and returns:
-- 1) The corresponding Minecraft layer (can be nil if void)
-- 2) The corresponding Minecraft dimension ("overworld", "nether" or "end") or "void" if it is in the void
-- If the Y coordinate is not located in any dimension, it will return:
--     nil, "void"
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

	local dim_bounds = vl_worlds.get_dimension_bounds(REVERSE_DIMENSION_NAME_COMPAT[dimension_name])
	assert(dim_bounds)

	return dim_bounds.min + offset
end

-- Compat
mcl_worlds.has_weather = vl_worlds.has_weather
mcl_worlds.has_dust = vl_worlds.has_dust
mcl_worlds.register_on_dimension_change = vl_worlds.register_on_dimension_change
mcl_worlds.dimension_change = vl_worlds.dimension_change

local COMPASS_WORKS = {overworld = true, underworld = false, fringe = false, void = true}
-- Takes a position (pos) and returns true if compasses are working here
function mcl_worlds.compass_works(pos)
	local dim = vl_worlds.dimension_at_pos(pos)
	if not dim then return true end

	return COMPASS_WORKS[dim] or true
end

-- Takes a position (pos) and returns true if clocks are working here
mcl_worlds.clock_works = mcl_worlds.compass_works

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
		local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
		assert(overworld_bounds)

		-- MC-style clouds: Layer 127, thickness 4, fly to the “West”
		return {
			height = overworld_bounds.min + 127,
			speed = {x=-2, z=0},
			thickness = 4,
			color = "#FFF0FEF",
		}
	end
end
