local vector = vector
local mod = mcl_minecarts
local table_merge = mcl_util.table_merge

local function get_path(base, first, ...)
	if not first then return base end
	if not base then return end
	return get_path(base[first], ...)
end
local function force_get_node(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then return node end

	--local time_start = minetest.get_us_time()
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
	--minetest.log("force_get_node() voxel_manip section took "..((minetest.get_us_time()-time_start)*1e-6).." seconds")
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

function mcl_minecarts.is_rail(self, pos, railtype)
	-- Compatibility with mcl_minecarts:is_rail() usage
	if self ~= mcl_minecarts then
		railtype = pos
		pos = self
	end

	local node_name = force_get_node(pos).name

	if minetest.get_item_group(node_name, "rail") == 0 then
		return false
	end
	if not railtype then
		return true
	end
	return minetest.get_item_group(node_name, "connect_to_raillike") == railtype
end

-- Directional constants
local north = vector.new( 0, 0, 1); local N = 1 -- 4dir = 0
local east  = vector.new( 1, 0, 0); local E = 4 -- 4dir = 1
local south = vector.new( 0, 0,-1); local S = 2 -- 4dir = 2
local west  = vector.new(-1, 0, 0); local W = 8 -- 4dir = 3

-- Share. Consider moving this to some shared location
mod.north = north
mod.south = south
mod.east = east
mod.west = west

--[[
	mcl_minecarts.snap_direction(dir)

	returns a valid cart direction that has the smallest angle difference to `dir'
]]
local VALID_DIRECTIONS = {
	north, vector.offset(north, 0, 1, 0), vector.offset(north, 0, -1, 0),
	south, vector.offset(south, 0, 1, 0), vector.offset(south, 0, -1, 0),
	east,  vector.offset(east,  0, 1, 0), vector.offset(east,  0, -1, 0),
	west,  vector.offset(west,  0, 1, 0), vector.offset(west,  0, -1, 0),
}
function mod.snap_direction(dir)
	dir = vector.normalize(dir)
	local best = nil
	local diff = -1
	for _,d in pairs(VALID_DIRECTIONS) do
		local dot = vector.dot(dir,d)
		if dot > diff then
			best = d
			diff = dot
		end
	end
	return best
end

local CONNECTIONS = { north, south, east, west }
local HORIZONTAL_STANDARD_RULES = {
	[N]       = { "", 0, mask = N, score = 1, can_slope = true },
	[S]       = { "", 0, mask = S, score = 1, can_slope = true },
	[N+S]     = { "", 0, mask = N+S, score = 2, can_slope = true },

	[E]       = { "", 1, mask = E, score = 1, can_slope = true },
	[W]       = { "", 1, mask = W, score = 1, can_slope = true },
	[E+W]     = { "", 1, mask = E+W, score = 2, can_slope = true },
}
mod.HORIZONTAL_STANDARD_RULES = HORIZONTAL_STANDARD_RULES

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
mod.HORIZONTAL_CURVES_RULES = HORIZONTAL_CURVES_RULES

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

local function is_connection(pos, dir)
	local node = force_get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]

	local get_next_dir = get_path(nodedef, "_mcl_minecarts", "get_next_dir")
	if not get_next_dir then return end

	local next_dir = get_next_dir(pos, dir, node)
	next_dir.y = 0
	return vector.equals(next_dir, dir)
end

local function get_rail_connections(pos, opt)
	local legacy = opt and opt.legacy
	local ignore_neighbor_connections = opt and opt.ignore_neighbor_connections

	local connections = 0
	for i = 1,#CONNECTIONS do
		local dir = CONNECTIONS[i]
		local neighbor = vector.add(pos, dir)
		local node = force_get_node(neighbor)
		local nodedef = minetest.registered_nodes[node.name]

		-- Only allow connections to the open ends of rails, as decribed by get_next_dir
		if mcl_minecarts.is_rail(neighbor) and ( legacy or get_path(nodedef, "_mcl_minecarts", "get_next_dir" ) ) then
			local rev_dir = vector.direction(dir,vector.zero())
			if ignore_neighbor_connections or is_connection(neighbor, rev_dir) then
				connections = bit.bor(connections, bit.lshift(1,i - 1))
			end
		end

		-- Check for sloped rail one block down
		local below_neighbor = vector.offset(neighbor, 0, -1, 0)
		node = force_get_node(below_neighbor)
		nodedef = minetest.registered_nodes[node.name]
		if mcl_minecarts.is_rail(below_neighbor) and ( legacy or get_path(nodedef, "_mcl_minecarts", "get_next_dir" ) ) then
			local rev_dir = vector.direction(dir, vector.zero())
			if ignore_neighbor_connections or is_connection(below_neighbor, rev_dir) then
				connections = bit.bor(connections, bit.lshift(1,i - 1))
			end
		end
	end
	return connections
end
mod.get_rail_connections = get_rail_connections

local function apply_connection_rules(node, nodedef, pos, rules, connections)
	-- Select the best allowed connection
	local rule = nil
	local score = 0
	for _,r in pairs(rules) do
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
			--print("swapping "..node.name.." for "..new_name..","..tostring(rule[2]).." at "..tostring(pos))
			node.name = new_name
			node.param2 = rule[2]
			minetest.swap_node(pos, node)
		end

		if rule.after then
			rule.after(rule, pos, connections)
		end
	end
end

local function is_rail_end_connected(pos, dir)
	-- Handle new track types that have track-specific direction handler
	local node = force_get_node(pos)
	local get_next_dir = get_path(minetest.registered_nodes,node.name,"_mcl_minecarts","get_next_dir")
	if not get_next_dir then return false end

	return get_next_dir(pos, dir, node) == dir
end

local function bend_straight_rail(pos, towards)
	local node = force_get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]

	-- Only bend rails
	local rail_type = minetest.get_item_group(node.name, "rail")
	if rail_type == 0 then return end

	-- Only bend unbent rails
	if not nodedef._mcl_minecarts then return end
	if node.name ~= nodedef._mcl_minecarts.base_name then return end

	-- only bend rails that have at least one free end
	local dir1 = minetest.fourdir_to_dir(node.param2)
	local dir2 = minetest.fourdir_to_dir((node.param2+2)%4)
	local dir1_connected = is_rail_end_connected(pos + dir1, dir2)
	local dir2_connected = is_rail_end_connected(pos + dir2, dir1)
	if dir1_connected and dir2_connected then return end

	local connections = {
		vector.direction(pos, towards),
	}
	if dir1_connected then
		connections[#connections+1] = dir1
	end
	if dir2_connected then
		connections[#connections+1] = dir2
	end
	local connections_mask = 0
	for i = 1,#CONNECTIONS do
		for j = 1,#connections do
			if CONNECTIONS[i] == connections[j] then
				connections_mask = bit.bor(connections_mask, bit.lshift(1, i -1))
			end
		end
	end

	local rules = HORIZONTAL_RULES_BY_RAIL_GROUP[nodedef.groups.rail]
	apply_connection_rules(node, nodedef, pos, rules, connections_mask)
end

local function update_rail_connections(pos, opt)
	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	if not nodedef or not nodedef._mcl_minecarts then return end

	-- Get the mappings to use
	local rules = HORIZONTAL_RULES_BY_RAIL_GROUP[nodedef.groups.rail]
	if nodedef._mcl_minecarts and nodedef._mcl_minecarts.connection_rules then -- Custom connection rules
		rules = nodedef._mcl_minecarts.connection_rules
	end
	if not rules then return end

	if not (opt and opt.no_bend_straights) then
		for i = 1,#CONNECTIONS do
			bend_straight_rail(vector.add(pos, CONNECTIONS[i]), pos)
		end
	end

	-- Horizontal rules, Check for rails on each neighbor
	local connections = get_rail_connections(pos, opt)

	-- Check for rasing rails to slopes
	for i = 1,#CONNECTIONS do
		local dir = CONNECTIONS[i]
		local neighbor = vector.add(pos, dir)
		make_sloped_if_straight(vector.offset(neighbor, 0, -1, 0), dir)
	end

	apply_connection_rules(node, nodedef, pos, rules, connections)

	local node_def = minetest.registered_nodes[node.name]
	if get_path(node_def, "_mcl_minecarts", "can_slope") then
		for i=1,#CONNECTIONS do
			local dir = CONNECTIONS[i]
			local higher_rail_pos = vector.offset(pos,dir.x,1,dir.z)
			local rev_dir = vector.direction(dir,vector.zero())
			if mcl_minecarts.is_rail(higher_rail_pos) and is_connection(higher_rail_pos, rev_dir) then
				make_sloped_if_straight(pos, rev_dir)
			end
		end
	end

	-- Recursion guard
	if opt and opt.convert_neighbors == false then return end

	-- Check if the open end of this rail runs into a corner or a tee and convert that node into a tee or a cross
	for i=1,#CONNECTIONS do
		local dir = CONNECTIONS[i]
		if is_connection(pos, dir) then
			local other_pos = pos - dir
			local other_node = core.get_node(other_pos)
			local other_node_def = core.registered_nodes[other_node.name]
			local railtype = get_path(other_node_def, "_mcl_minecarts","railtype")
			if railtype == "corner" or railtype == "tee" then
				update_rail_connections(other_pos, {convert_neighbors = false})
			end
		end
	end
end
mod.update_rail_connections = update_rail_connections

local function is_ahead_slope(pos, dir)
	local ahead = vector.add(pos,dir)
	if mcl_minecarts.is_rail(ahead) then return false end

	local below = vector.offset(ahead,0,-1,0)
	if not mcl_minecarts.is_rail(below) then return false end

	local node_name = force_get_node(below).name
	return minetest.get_item_group(node_name, "rail_slope") ~= 0
end

local function get_rail_direction_inner(pos, dir)
	-- Handle new track types that have track-specific direction handler
	local node = minetest.get_node(pos)
	local get_next_dir = get_path(minetest.registered_nodes,node.name,"_mcl_minecarts","get_next_dir")
	if not get_next_dir then return dir end

	dir = get_next_dir(pos, dir, node)

	-- Handle reversing if there is a solid block in the next position
	local next_pos = vector.add(pos, dir)
	local next_node = minetest.get_node(next_pos)
	local node_def = minetest.registered_nodes[next_node.name]
	if node_def and node_def.groups and ( node_def.groups.solid or node_def.groups.stair ) then
		-- Reverse the direction without giving -0 members
		dir = vector.direction(next_pos, pos)
	end

	-- Handle going downhill
	if is_ahead_slope(pos,dir) then
		dir = vector.offset(dir,0,-1,0)
	end

	return dir
end
function mcl_minecarts.get_rail_direction(self, pos_, dir)
	-- Compatibility with mcl_minecarts:get_rail_direction() usage
	if self ~= mcl_minecarts then
		dir = pos_
		pos_ = self
	end

	local pos = vector.round(pos_)

	-- diagonal direction handling
	if dir.x ~= 0 and dir.z ~= 0 then
		-- Check both possible diagonal movements
		local dir_a = vector.new(dir.x,0,0)
		local dir_b = vector.new(0,0,dir.z)
		local new_dir_a = mcl_minecarts.get_rail_direction(pos, dir_a)
		local new_dir_b = mcl_minecarts.get_rail_direction(pos, dir_b)

		-- If either is the same diagonal direction, continue as you were
		if vector.equals(dir,new_dir_a) or vector.equals(dir,new_dir_b) then
			return dir

		-- Otherwise, if either would try to move in the same direction as
		-- what tried, move that direction
		elseif vector.equals(dir_a, new_dir_a) then
			return new_dir_a
		elseif vector.equals(dir_b, new_dir_b) then
			return new_dir_b
		end

		 -- And if none of these were true, fall thru into standard behavior
	end

	local new_dir = get_rail_direction_inner(pos, dir)

	if new_dir.y ~= 0 then return new_dir end

	-- Check four 45 degree movement
	local next_rails_dir = get_rail_direction_inner(vector.add(pos, new_dir), new_dir)
	if next_rails_dir.y == 0 and vector.equals(next_rails_dir, dir) and not vector.equals(new_dir, next_rails_dir) then
		return vector.add(new_dir, next_rails_dir)
	end

	return new_dir
end

local _2_pi = math.pi * 2
local _half_pi = math.pi * 0.5
local _quart_pi = math.pi * 0.25
local pi = math.pi
function mod.update_cart_orientation(self)
	local staticdata = self._staticdata
	local dir = staticdata.dir

	-- Calculate an angle from the x,z direction components
	local rot_y = math.atan2( dir.z, dir.x ) + ( staticdata.rot_adjust or 0 )
	if rot_y < 0 then
		rot_y = rot_y + _2_pi
	end

	-- Check if the rotation is a 180 flip and don't change if so
	local rot = self.object:get_rotation()
	if not rot then return end
	rot.y = (rot.y - _half_pi + _2_pi) % _2_pi

	local diff = math.abs((rot_y - ( rot.y + pi ) % _2_pi) )
	if diff < 0.001 or diff > _2_pi - 0.001 then
		-- Update rotation adjust
		staticdata.rot_adjust = ( ( staticdata.rot_adjust or 0 ) + pi ) % _2_pi
	else
		rot.y = rot_y
	end

	-- Forward/backwards tilt (pitch)
	if dir.y > 0 then
		rot.x = _quart_pi
	elseif dir.y < 0 then
		rot.x = -_quart_pi
	else
		rot.x = 0
	end

	if ( staticdata.rot_adjust or 0 ) < 0.01 then
		rot.x = -rot.x
	end

	rot.y = (rot.y + _half_pi) % _2_pi
	self.object:set_rotation(rot)
end

function mod.get_cart_position(cart_staticdata)
	local data = cart_staticdata
	if not data then return nil end
	if not data.connected_at then return nil end

	return vector.add(data.connected_at, vector.multiply(data.dir or vector.zero(), data.distance or 0))
end

function mod.reverse_cart_direction(staticdata)
	if staticdata.distance == 0 then
		staticdata.dir = -staticdata.dir
		return
	end

	-- Complete moving thru this block into the next, reverse direction, and put us back at the same position we were at
	local next_dir = -staticdata.dir
	if not staticdata.connected_at then return end

	staticdata.connected_at = staticdata.connected_at + staticdata.dir
	staticdata.distance = 1 - (staticdata.distance or 0)

	-- recalculate direction
	staticdata.dir = mod:get_rail_direction(staticdata.connected_at, next_dir)
end
