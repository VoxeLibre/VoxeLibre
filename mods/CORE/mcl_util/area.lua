-- Localized functions
local min = math.min
local max = math.max

--[[Check for a protection violation in a given area.
--
-- Applies is_protected() to a 3D lattice of points in the defined volume. The points are spaced
-- evenly throughout the volume and have a spacing similar to, but no larger than, "interval".
--
-- @param pos1 vector.Vector      A position table of the area volume's first edge.
-- @param pos2 vector.Vector      A position table of the area volume's second edge.
-- @param player core.Player      The player performing the action.
-- @param interval number         Optional. Max spacing between checked points at the volume.
--                                Default: Same as core.is_area_protected.
--
-- @return boolean true on protection violation detection and false otherwise.
--
-- @notes   *All corners and edges of the defined volume are checked.
--]]
function mcl_util.check_area_protection(pos1, pos2, player, interval)
	local name = player and player:get_player_name() or ""

	local protected_pos = core.is_area_protected(pos1, pos2, name, interval)
	if protected_pos then
		core.record_protection_violation(protected_pos, name)
		return true
	end

	return false
end

--[[Check for a protection violation on a single position.
--
-- @param position vector.Vector    A position table to check for protection violation.
-- @param player core.Player        The player performing the action.
--
-- @return boolean true on protection violation detection and false otherwise.
--]]
function mcl_util.check_position_protection(position, player)
	local name = player and player:get_player_name() or ""

	if core.is_protected(position, name) then
		core.record_protection_violation(position, name)
		return true
	end

	return false
end

if not vector.in_area then
	-- backport from Luanti 5.8, can be removed when the minimum version is 5.8
	---@diagnostic disable-next-line:duplicate-set-field
	vector.in_area = function(pos, minp, maxp)
		return (pos.x >= minp.x) and (pos.x <= maxp.x) and
		       (pos.y >= minp.y) and (pos.y <= maxp.y) and
		       (pos.z >= minp.z) and (pos.z <= maxp.z)
	end
end

---@param a0 vector.Vector Area a minimum point
---@param a1 vector.Vector Area a maximum point
---@param b0 vector.Vector Area b minimum point
---@param b1 vector.Vector Area b maximum point
---@return boolean
function mcl_util.area_overlaps(a0, a1, b0, b1)
	if not ( (a0.x <= b0.x and b0.x <= a1.x) or (a0.x <= b1.x and b1.x <= a1.x) ) then return false end
	if not ( (a0.y <= b0.y and b0.y <= a1.y) or (a0.y <= b1.y and b1.y <= a1.y) ) then return false end
	if not ( (a0.z <= b0.z and b0.z <= a1.z) or (a0.z <= b1.z and b1.z <= a1.z) ) then return false end
	return true
end

---@param pos0 vector.Vector
---@param pos1 vector.Vector
---@return vector.Vector,vector.Vector
function mcl_util.normalize_area(pos0, pos1)
	local minp = vector.new(min(pos0.x, pos1.x), min(pos0.y, pos1.y), min(pos0.z, pos1.z))
	local maxp = vector.new(max(pos0.x, pos1.x), max(pos0.y, pos1.y), max(pos0.z, pos1.z))
	return minp, maxp
end

---@param a0 vector.Vector Area a minimum point
---@param a1 vector.Vector Area a maximum point
---@param b0 vector.Vector Area b minimum point
---@param b1 vector.Vector Area b maximum point
---@return vector.Vector?,vector.Vector?
function mcl_util.intersect_area(a0,a1, b0,b1)
	local minp = vector.new(max(a0.x, b0.x), max(a0.y, b0.y), max(a0.z, b0.z))
	local maxp = vector.new(min(a1.x, b1.x), min(a1.y, b1.y), min(a1.z, b1.z))

	if minp.x > maxp.x or minp.y > maxp.y or minp.z > minp.z then return end
	return minp, maxp
end

---@param block vector.Vector
---@return vector.Vector,vector.Vector
function mcl_util.block_to_area(block)
	local size = mcl_vars.MAP_BLOCKSIZE
	local start = vector.multiply(block, size)
	return start, vector.offset(start, size-1, size-1, size-1)
end

---@param chunk vector.Vector
---@return vector.Vector,vector.Vector
function mcl_util.chunk_to_area(chunk)
	local size = mcl_vars.chunk_size_in_nodes
	local offset = mcl_vars.central_chunk_offset_in_nodes
	local start = vector.new(chunk.x * size + offset, chunk.y * size + offset, chunk.z * size + offset)
	return start, vector.offset(start, size-1, size-1, size-1)
end

---@param a {minp: vector.Vector, maxp: vector.Vector}
---@param pos vector.Vector
---@return vector.Vector?,vector.Vector?
local function area_iterator_get_next_pos(a, pos)
	local minp, maxp = a.minp, a.maxp

	pos.x = pos.x + 1
	if pos.x ~= maxp.x then return pos, pos end

	pos.y = pos.y + 1
	pos.x = minp.x
	if pos.y ~= maxp.y then return pos, pos end

	pos.z = pos.z + 1
	pos.y = minp.y
	if pos.z ~= maxp.z then return pos, pos end
end

---@param minp vector.Vector
---@param maxp vector.Vector
function mcl_util.iterate_area(minp, maxp)
	return area_iterator_get_next_pos, {minp=minp, max=maxp}, vector.copy(minp)
end
