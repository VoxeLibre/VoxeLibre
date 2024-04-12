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

-- Directional constants
local north = vector.new( 0, 0, 1); local N = 1 -- 4dir = 0
local east  = vector.new( 1, 0, 0); local E = 4 -- 4dir = 1
local south = vector.new( 0, 0,-1); local S = 2 -- 4dir = 2 Note: S is overwritten below with the translator
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

	return get_next_dir(pos, dir, node) == dir
end

local function get_rail_connections(pos, opt)
	local legacy = opt and opt.legacy
	local ignore_neighbor_connections = opt and opt.ignore_neighbor_connections

	local connections = 0
	for i = 1,#CONNECTIONS do
		dir = CONNECTIONS[i]
		local neighbor = vector.add(pos, dir)
		local node = minetest.get_node(neighbor)
		local nodedef = minetest.registered_nodes[node.name]

		-- Only allow connections to the open ends of rails, as decribed by get_next_dir
		if get_path(nodedef, "groups", "rail") and ( legacy or get_path(nodedef, "_mcl_minecarts", "get_next_dir" ) ) then
			local rev_dir = vector.direction(dir,vector.new(0,0,0))
			if ignore_neighbor_connections or is_connection(neighbor, rev_dir) then
				connections = connections + bit.lshift(1,i - 1)
			end
		end
	end
	return connections
end
mod.get_rail_connections = get_rail_connections

local function update_rail_connections(pos, opt)
	local ignore_neighbor_connections = opt and opt.ignore_neighbor_connections

	local node = minetest.get_node(pos)
	local nodedef = minetest.registered_nodes[node.name]
	if not nodedef or not nodedef._mcl_minecarts then
		minetest.log("warning", "attemting to rail connect to "..node.name)
		return
	end

	-- Get the mappings to use
	local rules = HORIZONTAL_RULES_BY_RAIL_GROUP[nodedef.groups.rail]
	if nodedef._mcl_minecarts and nodedef._mcl_minecarts.connection_rules then -- Custom connection rules
		rules = nodedef._mcl_minecarts.connection_rules
	end
	if not rules then return end

	-- Horizontal rules, Check for rails on each neighbor
	local connections = get_rail_connections(pos, opt)

	-- Check for rasing rails to slopes
	for i = 1,#CONNECTIONS do
		local dir = CONNECTIONS[i]
		local neighbor = vector.add(pos, dir)
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
			--print("swapping "..node.name.." for "..new_name..","..tostring(rule[2]).." at "..tostring(pos))
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
		for i=1,#CONNECTIONS do
			local dir = CONNECTIONS[i]
			local higher_rail_pos = vector.offset(pos,dir.x,1,dir.z)
			local rev_dir = vector.direction(dir,vector.new(0,0,0))
			if mcl_minecarts:is_rail(higher_rail_pos) and is_connection(higher_rail_pos, rev_dir) then
				make_sloped_if_straight(pos, rev_dir)
			end
		end
	end

end
mod.update_rail_connections = update_rail_connections

local north = vector.new(0,0,1)
local south = vector.new(0,0,-1)
local east  = vector.new(1,0,0)
local west = vector.new(-1,0,0)

local function is_ahead_slope(pos, dir)
	local ahead = vector.add(pos,dir)
	if mcl_minecarts:is_rail(ahead) then return false end

	local below = vector.offset(ahead,0,-1,0)
	if not mcl_minecarts:is_rail(below) then return false end

	local node_name = force_get_node(below).name
	return minetest.get_item_group(node_name, "rail_slope") ~= 0
end
function mcl_minecarts:get_rail_direction(pos_, dir)
	local pos = vector.round(pos_)

	-- Handle new track types that have track-specific direction handler
	local node = minetest.get_node(pos)
	local node_def = minetest.registered_nodes[node.name]
	local get_next_dir = get_path(node_def,"_mcl_minecarts","get_next_dir")
	if not get_next_dir then return dir end

	dir = node_def._mcl_minecarts.get_next_dir(pos, dir, node)

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
function mod.update_cart_orientation(self)
	local staticdata = self._staticdata

	-- constants
	local _2_pi = math.pi * 2
	local pi = math.pi
	local dir = staticdata.dir

	-- Calculate an angle from the x,z direction components
	local rot_y = math.atan2( dir.x, dir.z ) + ( staticdata.rot_adjust or 0 )
	if rot_y < 0 then
		rot_y = rot_y + _2_pi
	end

	-- Check if the rotation is a 180 flip and don't change if so
	local rot = self.object:get_rotation()
	local diff = math.abs((rot_y - ( rot.y + pi ) % _2_pi) )
	if diff < 0.001 or diff > _2_pi - 0.001 then
		-- Update rotation adjust and recalculate the rotation
		staticdata.rot_adjust = ( ( staticdata.rot_adjust or 0 ) + pi ) % _2_pi
		rot.y = math.atan2( dir.x, dir.z ) + ( staticdata.rot_adjust or 0 )
	else
		rot.y = rot_y
	end

	-- Forward/backwards tilt (pitch)
	if dir.y < 0 then
		rot.x = -0.25 * pi
	elseif dir.y > 0 then
		rot.x = 0.25 * pi
	else
		rot.x = 0
	end

	if ( staticdata.rot_adjust or 0 ) < 0.01 then
		rot.x = -rot.x
	end
	if dir.z ~= 0 then
		rot.x = -rot.x
	end

	self.object:set_rotation(rot)
end

function mod.get_cart_position(cart_staticdata)
	local data = cart_staticdata
	if not data then return nil end
	if not data.connected_at then return nil end

	return vector.add(data.connected_at, vector.multiply(data.dir or vector.zero(), data.distance or 0))
end

function mod.reverse_cart_direction(staticdata)

	-- Complete moving thru this block into the next, reverse direction, and put us back at the same position we were at
	local next_dir = -staticdata.dir
	staticdata.connected_at = staticdata.connected_at + staticdata.dir
	staticdata.distance = 1 - (staticdata.distance or 0)

	-- recalculate direction
	local next_dir,_ = mod:get_rail_direction(staticdata.connected_at, next_dir)
	staticdata.dir = next_dir
end

