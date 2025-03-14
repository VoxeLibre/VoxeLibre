--[[Check for a protection violation in a given area.
--
-- Applies is_protected() to a 3D lattice of points in the defined volume. The points are spaced
-- evenly throughout the volume and have a spacing similar to, but no larger than, "interval".
--
-- @param pos1          A position table of the area volume's first edge.
-- @param pos2          A position table of the area volume's second edge.
-- @param player        The player performing the action.
-- @param interval	    Optional. Max spacing between checked points at the volume.
--      Default: Same as core.is_area_protected.
--
-- @return	true on protection violation detection. false otherwise.
--
-- @notes   *All corners and edges of the defined volume are checked.
]]
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
-- @param position      A position table to check for protection violation.
-- @param player        The player performing the action.
--
-- @return	true on protection violation detection. false otherwise.
]]
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
	vector.in_area = function(pos, min, max)
		return (pos.x >= min.x) and (pos.x <= max.x) and
		       (pos.y >= min.y) and (pos.y <= max.y) and
		       (pos.z >= min.z) and (pos.z <= max.z)
	end
end

function mcl_util.area_overlaps(a0, a1, b0, b1)
	if not ( (a0.x <= b0.x and b0.x <= a1.x) or (a0.x <= b1.x and b1.x <= a1.x) ) then return false end
	if not ( (a0.y <= b0.y and b0.y <= a1.y) or (a0.y <= b1.y and b1.y <= a1.y) ) then return false end
	if not ( (a0.z <= b0.z and b0.z <= a1.z) or (a0.z <= b1.z and b1.z <= a1.z) ) then return false end
	return true
end
