local default_seethru = {air = true}

--- Check if there is a clear line of sight between two points using the slab method https://en.wikipedia.org/wiki/Slab_method
---@param origin vector.Vector
---@param target vector.Vector
---@param seethru? {[string]: boolean} Set (look-up table) of nodes to treat as seethrough. Defaults to {air: true}
---@return boolean True if line-of-sight is clear, false if blocked
function mcl_mobs.check_line_of_sight(origin, target, seethru)
	seethru = seethru or default_seethru

	local dir = vector.subtract(target, origin)

	-- Segment (t in [0,1]) vs axis-aligned box intersection
	local function segment_intersects_aabb(minp, maxp)
		local tmin, tmax = 0.0, 1.0

		local function axis_slab(o, d, mn, mx)
			-- If ray is parallel to slab, it must already be within the slab
			if math.abs(d) < 1e-12 then
				return (o >= mn and o <= mx)
			end

			local t1 = (mn - o) / d
			local t2 = (mx - o) / d
			if t1 > t2 then t1, t2 = t2, t1 end

			if t1 > tmin then tmin = t1 end
			if t2 < tmax then tmax = t2 end
			return tmin <= tmax
		end

		return axis_slab(origin.x, dir.x, minp.x, maxp.x)
			and axis_slab(origin.y, dir.y, minp.y, maxp.y)
			and axis_slab(origin.z, dir.z, minp.z, maxp.z)
	end

	-- Check if a node at the given position blocks line of sight
    local function node_blocks_los(node_pos)
        local node = core.get_node(node_pos)
        if seethru[node.name] then
            return false
        end

        local def = core.registered_nodes[node.name]
        if not (def and def.walkable) then
            return false
        end

        local boxes = core.get_node_boxes and core.get_node_boxes("collision_box", node_pos, node) or nil
        if not boxes or #boxes == 0 then
            return true
        end

        for _, box in ipairs(boxes) do
			local minp = vector.offset(node_pos, box[1], box[2], box[3])
			local maxp = vector.offset(node_pos, box[4], box[5], box[6])
			if minp.x > maxp.x then minp.x, maxp.x = maxp.x, minp.x end
			if minp.y > maxp.y then minp.y, maxp.y = maxp.y, minp.y end
			if minp.z > maxp.z then minp.z, maxp.z = maxp.z, minp.z end
            if segment_intersects_aabb(minp, maxp) then
                return true
            end
        end

        return false
    end

	-- Note: raycasts intersect *selection boxes*, not collision boxes.
	-- Therefore we need to manually check collision boxes along the ray.
    for hit in core.raycast(origin, target, false, true) do
        if hit.type == "node" and node_blocks_los(hit.under) then
            return false
        end
    end

	return true
end


--- Get the collision box for an object (player or entity), adjust feet and eye height for player
---@param obj ObjectRef
---@return table|nil collisionbox {x1, y1, z1, x2, y2, z2} or nil if unavailable
local function get_object_collisionbox(obj)
	if obj:is_player() then
		local props = obj:get_properties()
		return props and props.collisionbox
	else
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.initial_properties then
			return luaentity.initial_properties.collisionbox
		end

		local props = obj:get_properties()
		return props and props.collisionbox
	end
end

--- Check if an origin point/object can see a target object
--- Casts rays to both the feet and head of the target's collision box
---@param origin vector.Vector|ObjectRef Origin position or object
---@param target ObjectRef Target object to check visibility of
---@param seethru? {[string]: boolean} Set of nodes to treat as seethrough
---@return boolean True if target is visible (any ray succeeds)
function mcl_mobs.target_visible(origin, target, seethru)
	if not target then return false end

	local target_pos = target:get_pos()
	if not target_pos then return false end

	-- Determine origin position
	local origin_pos
	if type(origin) == "userdata" then
		-- It's an object
		origin_pos = origin:get_pos()
		if not origin_pos then return false end

		local luaentity = origin:get_luaentity()
		local eye_height = luaentity and luaentity.head_eye_height
		if eye_height then
			origin_pos = vector.offset(origin_pos, 0, eye_height, 0)
		else
			local origin_cbox = get_object_collisionbox(origin)
			if origin_cbox then
				local box_height = origin_cbox[5] - origin_cbox[2]
				eye_height = origin_cbox[2] + (box_height * 0.85)
				origin_pos = vector.offset(origin_pos, 0, eye_height, 0)
			end
		end
	else
		-- It's a vector
		origin_pos = origin
	end

	local target_cbox = get_object_collisionbox(target)
	if not target_cbox then
		return mcl_mobs.check_line_of_sight(origin_pos, target_pos, seethru)
	end

	-- Target points to check
	local target_feet = vector.offset(target_pos, 0, target_cbox[2], 0)
	local target_head = vector.offset(target_pos, 0, target_cbox[5], 0)

	return mcl_mobs.check_line_of_sight(origin_pos, target_head, seethru)
		or mcl_mobs.check_line_of_sight(origin_pos, target_feet, seethru)
end
