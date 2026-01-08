local default_seethru = {["air"] = true}

-- Set of seethru blocks for mob curiosity line-of-sight checks
-- Includes transparent, semi-transparent, and blocks with holes that mobs can see through
mcl_mobs.see_through_nodes = {
	["air"] = true,

	["mcl_core:glass"] = true,
	["mcl_core:glass_black"] = true,
	["mcl_core:glass_blue"] = true,
	["mcl_core:glass_brown"] = true,
	["mcl_core:glass_cyan"] = true,
	["mcl_core:glass_gray"] = true,
	["mcl_core:glass_green"] = true,
	["mcl_core:glass_light_blue"] = true,
	["mcl_core:glass_lime"] = true,
	["mcl_core:glass_magenta"] = true,
	["mcl_core:glass_orange"] = true,
	["mcl_core:glass_pink"] = true,
	["mcl_core:glass_purple"] = true,
	["mcl_core:glass_red"] = true,
	["mcl_core:glass_silver"] = true,
	["mcl_core:glass_white"] = true,
	["mcl_core:glass_yellow"] = true,
	["mcl_amethyst:tinted_glass"] = true,

	["xpanes:pane_natural_flat"] = true,
	["xpanes:pane_natural"] = true,
	["xpanes:pane_black_flat"] = true,
	["xpanes:pane_black"] = true,
	["xpanes:pane_blue_flat"] = true,
	["xpanes:pane_blue"] = true,
	["xpanes:pane_brown_flat"] = true,
	["xpanes:pane_brown"] = true,
	["xpanes:pane_cyan_flat"] = true,
	["xpanes:pane_cyan"] = true,
	["xpanes:pane_gray_flat"] = true,
	["xpanes:pane_gray"] = true,
	["xpanes:pane_green_flat"] = true,
	["xpanes:pane_green"] = true,
	["xpanes:pane_light_blue_flat"] = true,
	["xpanes:pane_light_blue"] = true,
	["xpanes:pane_lime_flat"] = true,
	["xpanes:pane_lime"] = true,
	["xpanes:pane_magenta_flat"] = true,
	["xpanes:pane_magenta"] = true,
	["xpanes:pane_orange_flat"] = true,
	["xpanes:pane_orange"] = true,
	["xpanes:pane_pink_flat"] = true,
	["xpanes:pane_pink"] = true,
	["xpanes:pane_purple_flat"] = true,
	["xpanes:pane_purple"] = true,
	["xpanes:pane_red_flat"] = true,
	["xpanes:pane_red"] = true,
	["xpanes:pane_silver_flat"] = true,
	["xpanes:pane_silver"] = true,
	["xpanes:pane_white_flat"] = true,
	["xpanes:pane_white"] = true,
	["xpanes:pane_yellow_flat"] = true,
	["xpanes:pane_yellow"] = true,

	["xpanes:bar_flat"] = true,
	["xpanes:bar"] = true,
	["xpanes:gold_bar_flat"] = true,
	["xpanes:gold_bar"] = true,

	["mcl_fences:fence"] = true,
	["mcl_fences:spruce_fence"] = true,
	["mcl_fences:birch_fence"] = true,
	["mcl_fences:jungle_fence"] = true,
	["mcl_fences:dark_oak_fence"] = true,
	["mcl_fences:acacia_fence"] = true,
	["mcl_fences:nether_brick_fence"] = true,
	["mcl_fences:crimson_fence"] = true,
	["mcl_fences:warped_fence"] = true,
	["mcl_fences:mangrove_fence"] = true,
	["mcl_fences:cherry_blossom_fence"] = true,
	["mcl_fences:bamboo_fence"] = true,

	["mcl_fences:fence_gate"] = true,
	["mcl_fences:fence_gate_open"] = true,
	["mcl_fences:spruce_fence_gate"] = true,
	["mcl_fences:spruce_fence_gate_open"] = true,
	["mcl_fences:birch_fence_gate"] = true,
	["mcl_fences:birch_fence_gate_open"] = true,
	["mcl_fences:jungle_fence_gate"] = true,
	["mcl_fences:jungle_fence_gate_open"] = true,
	["mcl_fences:dark_oak_fence_gate"] = true,
	["mcl_fences:dark_oak_fence_gate_open"] = true,
	["mcl_fences:acacia_fence_gate"] = true,
	["mcl_fences:acacia_fence_gate_open"] = true,
	["mcl_fences:crimson_fence_gate"] = true,
	["mcl_fences:crimson_fence_gate_open"] = true,
	["mcl_fences:warped_fence_gate"] = true,
	["mcl_fences:warped_fence_gate_open"] = true,
	["mcl_fences:mangrove_fence_gate"] = true,
	["mcl_fences:mangrove_fence_gate_open"] = true,
	["mcl_fences:cherry_blossom_fence_gate"] = true,
	["mcl_fences:cherry_blossom_fence_gate_open"] = true,
	["mcl_fences:bamboo_fence_gate"] = true,
	["mcl_fences:bamboo_fence_gate_open"] = true,
}

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
---@param check_feet? boolean Whether to check line of sight to the target's feet (default: true)
---@param seethru? {[string]: boolean} Set of nodes to treat as seethrough
---@return boolean True if target is visible (any ray succeeds)
function mcl_mobs.target_visible(origin, target, check_feet, seethru)
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

	local target_head = vector.offset(target_pos, 0, target_cbox[5], 0)
	
	if check_feet == false then
		return mcl_mobs.check_line_of_sight(origin_pos, target_head, seethru)
	else
		local target_feet = vector.offset(target_pos, 0, target_cbox[2], 0)
		return mcl_mobs.check_line_of_sight(origin_pos, target_head, seethru)
			or mcl_mobs.check_line_of_sight(origin_pos, target_feet, seethru)
	end
end