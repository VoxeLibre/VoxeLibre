local vector = vector

function mcl_minecarts:get_sign(z)
	if z == 0 then
		return 0
	else
		return z / math.abs(z)
	end
end

function mcl_minecarts:velocity_to_dir(v)
	if math.abs(v.x) > math.abs(v.z) then
		return vector.new(
			mcl_minecarts:get_sign(v.x),
			mcl_minecarts:get_sign(v.y),
			0
		)
	else
		return vector.new(
			0,
			mcl_minecarts:get_sign(v.y),
			mcl_minecarts:get_sign(v.z)
		)
	end
end

function mcl_minecarts:is_rail(pos, railtype)
	local node = minetest.get_node(pos).name
	if node == "ignore" then
		local vm = minetest.get_voxel_manip()
		local emin, emax = vm:read_from_map(pos, pos)
		local area = VoxelArea:new{
			MinEdge = emin,
			MaxEdge = emax,
		}
		local data = vm:get_data()
		local vi = area:indexp(pos)
		node = minetest.get_name_from_content_id(data[vi])
	end
	if minetest.get_item_group(node, "rail") == 0 then
		return false
	end
	if not railtype then
		return true
	end
	return minetest.get_item_group(node, "connect_to_raillike") == railtype
end

function mcl_minecarts:check_front_up_down(pos, dir_, check_down, railtype)
	local dir = vector.new(dir_)
	-- Front
	dir.y = 0
	local cur = vector.add(pos, dir)
	if mcl_minecarts:is_rail(cur, railtype) then
		return dir
	end
	-- Up
	if check_down then
		dir.y = 1
		cur = vector.add(pos, dir)
		if mcl_minecarts:is_rail(cur, railtype) then
			return dir
		end
	end
	-- Down
	dir.y = -1
	cur = vector.add(pos, dir)
	if mcl_minecarts:is_rail(cur, railtype) then
		return dir
	end
	return nil
end

function mcl_minecarts:get_rail_direction(pos_, dir, ctrl, old_switch, railtype)
	local pos = vector.round(pos_)
	local cur
	local left_check, right_check = true, true

	-- Calculate left, right and back
	local left  = vector.new(-dir.z, dir.y,  dir.x)
	local right = vector.new( dir.z, dir.y, -dir.x)
	local back  = vector.new(-dir.x, dir.y, -dir.z)

	if ctrl then
		if old_switch == 1 then
			left_check = false
		elseif old_switch == 2 then
			right_check = false
		end
		if ctrl.left and left_check then
			cur = mcl_minecarts:check_front_up_down(pos, left, false, railtype)
			if cur then
				return cur, 1
			end
			left_check = false
		end
		if ctrl.right and right_check then
			cur = mcl_minecarts:check_front_up_down(pos, right, false, railtype)
			if cur then
				return cur, 2
			end
			right_check = true
		end
	end

	-- Normal
	cur = mcl_minecarts:check_front_up_down(pos, dir, true, railtype)
	if cur then
		return cur
	end

	-- Left, if not already checked
	if left_check then
		cur = mcl_minecarts:check_front_up_down(pos, left, false, railtype)
		if cur then
			return cur
		end
	end

	-- Right, if not already checked
	if right_check then
		cur = mcl_minecarts:check_front_up_down(pos, right, false, railtype)
		if cur then
			return cur
		end
	end
	-- Backwards
	if not old_switch then
		cur = mcl_minecarts:check_front_up_down(pos, back, true, railtype)
		if cur then
			return cur
		end
	end
	return vector.new(0,0,0)
end
