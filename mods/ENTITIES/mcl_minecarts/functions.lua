local vector = vector
local mod = mcl_minecarts
local table_merge = mcl_util.table_merge

function get_path(base, first, ...)
	if not first then return base end
	if not base then return end
	return get_path(base[first], ...)
end

local function force_get_node(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then return node end

	local vm = minetest.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos, pos)
	local area = VoxelArea:new{
		MinEdge = emin,
		MaxEdge = emax,
	}
	local data = vm:get_data()
	local param_data = vm:get_light_data()
	local param2_data = vm:get_param2_data()

	local vi = area:indexp(pos)
	return {
		name = minetest.get_name_from_content_id(data[vi]),
		param = param_data[vi],
		param2 = param2_data[vi]
	}
end

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
	local node_name = force_get_node(pos).name

	if minetest.get_item_group(node_name, "rail") == 0 then
		return false
	end
	if not railtype then
		return true
	end
	return minetest.get_item_group(node_name, "connect_to_raillike") == railtype
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


local north = vector.new( 0, 0, 1); local N = 1
local south = vector.new( 0, 0,-1); local S = 2 -- Note: S is overwritten below with the translator
local east  = vector.new( 1, 0, 0); local E = 4
local west  = vector.new(-1, 0, 0); local W = 8

-- Share. Consider moving this to some shared location
mod.north = north
mod.south = south
mod.east = east
mod.west = west

local CONNECTIONS = { north, south, east, west }
local HORIZONTAL_STANDARD_RULES = {
	[N]       = { "", 0, mask = N, score = 1, can_slope = true },
	[S]       = { "", 0, mask = S, score = 1, can_slope = true },
	[N+S]     = { "", 0, mask = N+S, score = 2, can_slope = true },

	[E]       = { "", 1, mask = E, score = 1, can_slope = true },
	[W]       = { "", 1, mask = W, score = 1, can_slope = true },
	[E+W]     = { "", 1, mask = E+W, score = 2, can_slope = true },
}

local HORIZONTAL_CURVES_RULES = {
	[N+E]     = { "_corner", 3, name = "ne corner", mask = N+E, score = 3 },
	[N+W]     = { "_corner", 2, name = "nw corner", mask = N+W, score = 3 },
	[S+E]     = { "_corner", 0, name = "se corner", mask = S+E, score = 3 },
	[S+W]     = { "_corner", 1, name = "sw corner", mask = S+W, score = 3 },

	[N+E+W]   = { "_tee_off", 3, mask = N+E+W, score = 4 },
	[S+E+W]   = { "_tee_off", 1, mask = S+E+W, score = 4 },
	[N+S+E]   = { "_tee_off", 0, mask = N+S+E, score = 4 },
	[N+S+W]   = { "_tee_off", 2, mask = N+S+W, score = 4 },

	[N+S+E+W] = { "_cross", 0, mask = N+S+E+W, score = 5 },
}

table_merge(HORIZONTAL_CURVES_RULES, HORIZONTAL_STANDARD_RULES)
local HORIZONTAL_RULES_BY_RAIL_GROUP = {
	[1] = HORIZONTAL_STANDARD_RULES,
	[2] = HORIZONTAL_CURVES_RULES,
}

local function check_connection_rule(pos, connections, rule)
	-- All bits in the mask must be set for the connection to be possible
	if bit.band(rule.mask,connections) ~= rule.mask then
		--print("Mask mismatch ("..tostring(rule.mask)..","..tostring(connections)..")")
		return false
	end

	-- If there is an allow filter, that mush also return true
	if rule.allow and rule.allow(rule, connections, pos) then
		return false
	end

	return true
end
mod.check_connection_rules = check_connection_rules

local function make_sloped_if_straight(pos, dir)
	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]

	local param2 = 0
	if dir == east then
		param2 = 3
	elseif dir == west then
		param2 = 1
	elseif dir == north then
		param2 = 2
	elseif dir == south then
		param2 = 0
	end

	if get_path( nodedef, "_mcl_minecarts", "railtype" ) == "straight" then
		minetest.swap_node(pos, {name = nodedef._mcl_minecarts.base_name .. "_sloped", param2 = param2})
	end
end

local function update_rail_connections(pos, update_neighbors)
	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	if not nodedef._mcl_minecarts then
		minetest.log("warning", "attemting to rail connect "..node.name)
		return
	end

	-- Get the mappings to use
	local rules = HORIZONTAL_RULES_BY_RAIL_GROUP[nodedef.groups.rail]
	if nodedef._mcl_minecarts and nodedef._mcl_minecarts.connection_rules then -- Custom connection rules
		rules = nodedef._mcl_minecarts.connection_rules
	end
	if not rules then return end

	-- Horizontal rules, Check for rails on each neighbor
	local connections = 0
	for i,dir in ipairs(CONNECTIONS) do
		local neighbor = vector.add(pos, dir)
		local node = minetest.get_node(neighbor)
		local nodedef = minetest.registered_nodes[node.name]

		-- Only allow connections to the open ends of rails, as decribed by get_next_dir
		if get_path(nodedef, "groups", "rail") and get_path(nodedef, "_mcl_minecarts", "get_next_dir" ) then
			local rev_dir = vector.direction(dir,vector.new(0,0,0))
			--local next_dir = nodedef._mcl_minecarts.get_next_dir(neighbor, rev_dir, node)
			if mcl_minecarts:is_connection(neighbor, rev_dir) then
				connections = connections + bit.lshift(1,i - 1)
			end
		end

		-- Check for rasing rails to slopes
		make_sloped_if_straight( vector.offset(neighbor, 0, -1, 0), dir )
	end

	-- Select the best allowed connection
	local rule = nil
	local score = 0
	for k,r in pairs(rules) do
		if check_connection_rule(pos, connections, r) then
			if r.score > score then
				--print("Best rule so far is "..dump(r))
				score = r.score
				rule = r
			end
		end
	end
	if rule then

		-- Apply the mapping
		local new_name = nodedef._mcl_minecarts.base_name..rule[1]
		if new_name ~= node.name or node.param2 ~= rule[2] then
			print("swapping "..node.name.." for "..new_name..","..tostring(rule[2]).." at "..tostring(pos))
			node.name = new_name
			node.param2 = rule[2]
			minetest.swap_node(pos, node)
		end

		if rule.after then
			rule.after(rule, pos, connections)
		end
	end

	local node_def = minetest.registered_nodes[node.name]
	if get_path(node_def, "_mcl_minecarts", "can_slope") then
		for _,dir in ipairs(CONNECTIONS) do
			local higher_rail_pos = vector.offset(pos,dir.x,1,dir.z)
			local rev_dir = vector.direction(dir,vector.new(0,0,0))
			if mcl_minecarts:is_rail(higher_rail_pos) and mcl_minecarts:is_connection(higher_rail_pos, rev_dir) then
				make_sloped_if_straight(pos, rev_dir)
			end
		end
	end

end
mod.update_rail_connections = update_rail_connections

--[[
	An array of (u,v,w) positions to check. Actual direction is u * dir + v * right + w * up
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

function mcl_minecarts:is_connection(pos, dir)
	local node = force_get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]

	local get_next_dir = get_path(nodedef, "_mcl_minecarts", "get_next_dir")
	if not get_next_dir then return end

	return get_next_dir(pos, dir, node) == dir
end

function mcl_minecarts:get_rail_direction(pos_, dir, ctrl, old_switch, railtype)
	local pos = vector.round(pos_)

	-- Handle new track types that have track-specific direction handler
	local node = minetest.get_node(pos)
	local node_def = minetest.registered_nodes[node.name]
	if node_def and node_def._mcl_minecarts and node_def._mcl_minecarts.get_next_dir then
		return node_def._mcl_minecarts.get_next_dir(pos, dir, node)
	end

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
