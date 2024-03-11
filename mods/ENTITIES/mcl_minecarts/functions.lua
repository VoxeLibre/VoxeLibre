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

--[[
  Returns a string description of a direction, with optional _up/_down suffix
]]
function mcl_minecarts:name_from_dir(dir, vertical)
	local res = ""

	if dir.z ==  1 then res = res .. "n" end
	if dir.z == -1 then res = res .. "s" end

	if dir.x == -1 then res = res .. "w" end
	if dir.x ==  1 then res = res .. "e" end

	if vertical then
		if dir.y ==  1 then res = res .. "_up" end
		if dir.y ==  1 then res = res .. "_down" end
	end

	return res
end


--[[
	An array of (u,v,w) positions to check. Actual direction is u * dir + v * right + w * vector.new(0,1,0)
]]
local rail_checks = {
	{  1,  0,  0 }, -- forwards
	{  1,  0,  1 }, -- forwards and up
	{  1,  0, -1 }, -- forwards and down

	{  1,  1,  0 }, -- diagonal left
	{  0,  1,  0 }, -- left
	{  0,  1,  1 }, -- left and up
	{  0,  1, -1 }, -- left and down

	{  1, -1,  0 }, -- diagonal right
	{  0, -1,  0 }, -- right
	{  0, -1,  1 }, -- right and up
	{  0, -1, -1 }, -- right and down

	{ -1,  0,  0 }, -- backwards
}

local rail_checks_diagonal = {
	{ 1,  1,  0 }, -- forward along diagonal
	{ 1,  0,  0 }, -- left
	{ 0,  1,  0 }, -- right
}

local north = vector.new(0,0,1)
local south = vector.new(0,0,-1)
local east  = vector.new(1,0,0)
local west = vector.new(-1,0,0)

-- Rotate diagonal directions 45 degrees clockwise
local diagonal_convert = {
	nw = west,
	ne = north,
	se = east,
	sw = south,
}

function mcl_minecarts:get_rail_direction(pos_, dir, ctrl, old_switch, railtype)
	local pos = vector.round(pos_)

	-- Diagonal conversion
	local checks = rail_checks
	if dir.x ~= 0 and dir.z ~= 0 then
		dir = diagonal_convert[ mcl_minecarts:name_from_dir(dir, false) ]
		checks = rail_checks_diagonal
	end

	-- Calculate coordinate space
	local right = vector.new( dir.z, dir.y, -dir.x)
	local up = vector.new(0,1,0)

	-- Perform checks
	for _,check in ipairs(checks) do
		local check_dir = dir * check[1] + right * check[2] + up * check[3]
		local check_pos = pos + check_dir
		if mcl_minecarts:is_rail(check_pos,railtype) then
			return check_dir
		end
	end

	return vector.new(0,0,0)
end
