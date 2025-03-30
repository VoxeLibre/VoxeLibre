local modname = minetest.get_current_modname()
local S = core.get_translator(modname)
local mod = mcl_minecarts
local submod = {}
local ENABLE_TRAINS = core.settings:get_bool("mcl_minecarts_enable_trains",true)

-- Constants
local mcl_debug,DEBUG = mcl_util.make_mcl_logger("mcl_logging_minecart_debug", "Minecart Debug")
--mcl_debug,DEBUG = function(msg) print(msg) end,true

-- Imports
local env_physics
if minetest.get_modpath("mcl_physics") then
	env_physics = mcl_physics
elseif minetest.get_modpath("vl_physics") then
	env_physics = vl_physics
end
local FRICTION = mod.FRICTION
local OFF_RAIL_FRICTION = mod.OFF_RAIL_FRICTION
local MAX_TRAIN_LENGTH = mod.MAX_TRAIN_LENGTH
local SPEED_MAX = 10
local train_length = mod.train_length
local update_train = mod.update_train
local reverse_train = mod.reverse_train
local link_cart_ahead = mod.link_cart_ahead
local get_cart_data = mod.get_cart_data

vl_tuning.setting("gamerule:minecartMaxSpeed", "number", {
	set = function(value) SPEED_MAX = value end,
	get = function() return SPEED_MAX end,
	default = 10,
	description = S("The maximum speed a minecart may reach.")
})

local function reverse_direction(staticdata)
	if staticdata.behind or staticdata.ahead then
		reverse_train(staticdata)
		return
	end

	mod.reverse_cart_direction(staticdata)
end
mod.reverse_direction = reverse_direction


--[[
	Array of hooks { {u,v,w}, name }
	Actual position is pos + u * dir + v * right + w * up
]]
local enter_exit_checks = {
	{ 0, 0, 0, "" },
	{ 0, 0, 1, "_above" },
	{ 0, 0,-1, "_below" },
	{ 0, 1, 0, "_side" },
	{ 0,-1, 0, "_side" },
}

local function handle_cart_enter_exit(staticdata, pos, next_dir, event)
	local luaentity = mcl_util.get_luaentity_from_uuid(staticdata.uuid)
	local dir = staticdata.dir
	local right = vector.new( dir.z, dir.y, -dir.x)
	local up = vector.new(0,1,0)
	for i=1,#enter_exit_checks do
		local check = enter_exit_checks[i]

		local check_pos = pos + dir * check[1] + right * check[2] + up * check[3]
		local node = minetest.get_node(check_pos)
		local node_def = minetest.registered_nodes[node.name]
		if node_def then
			-- node-specific hook
			local hook_name = "_mcl_minecarts_"..event..check[4]
			local hook = node_def[hook_name]
			if hook then hook(check_pos, luaentity, next_dir, pos, staticdata) end

			-- global minecart hook
			hook = mcl_minecarts[event..check[4]]
			if hook then hook(check_pos, luaentity, next_dir, pos, staticdata, node_def) end
		end
	end

	-- Handle cart-specific behaviors
	if luaentity then
		local hook = luaentity["_mcl_minecarts_"..event]
		if hook then hook(luaentity, pos, staticdata) end
	--else
		--minetest.log("warning", "TODO: change _mcl_minecarts_"..event.." calling so it is not dependent on the existence of a luaentity")
	end
end
local function set_metadata_cart_status(pos, uuid, state)
	local meta = minetest.get_meta(pos)
	local carts = minetest.deserialize(meta:get_string("_mcl_minecarts_carts")) or {}
	carts[uuid] = state
	meta:set_string("_mcl_minecarts_carts", minetest.serialize(carts))
end
local function handle_cart_enter(staticdata, pos, next_dir)
	--print("entering "..tostring(pos))
	set_metadata_cart_status(pos, staticdata.uuid, 1)
	handle_cart_enter_exit(staticdata, pos, next_dir, "on_enter" )
end
submod.handle_cart_enter = handle_cart_enter
local function handle_cart_leave(staticdata, pos, next_dir)
	--print("leaving "..tostring(pos))
	set_metadata_cart_status(pos, staticdata.uuid, nil)
	handle_cart_enter_exit(staticdata, pos, next_dir, "on_leave" )
end
submod.handle_cart_leave = handle_cart_leave
local function handle_cart_node_watches(staticdata, dtime)
	local watches = staticdata.node_watches or {}
	local new_watches = {}
	local luaentity = mcl_util.get_luaentity_from_uuid(staticdata.uuid)
	for i=1,#watches do
		local node_pos = watches[i]
		local node = minetest.get_node(node_pos)
		local node_def = minetest.registered_nodes[node.name]
		if node_def then
			local hook = node_def._mcl_minecarts_node_on_step
			if hook and hook(node_pos, luaentity, dtime, staticdata) then
				new_watches[#new_watches+1] = node_pos
			end
		end
	end

	staticdata.node_watches = new_watches
end

local function detach_minecart(staticdata)
	handle_cart_leave(staticdata, staticdata.connected_at, staticdata.dir)
	staticdata.connected_at = nil
	mod.break_train_at(staticdata)

	local luaentity = mcl_util.get_luaentity_from_uuid(staticdata.uuid)
	if luaentity then
		luaentity.object:set_velocity(staticdata.dir * staticdata.velocity)
	end
end
mod.detach_minecart = detach_minecart

local function try_detach_minecart(staticdata)
	if not staticdata or not staticdata.connected_at then return end
	if not mod:is_rail(staticdata.connected_at) then
		if DEBUG then mcl_debug("Detaching minecart #"..tostring(staticdata.uuid)) end
		detach_minecart(staticdata)
	end
end

local function handle_cart_collision(cart1_staticdata, prev_pos, next_dir)
	if not cart1_staticdata then return end

	-- Look ahead one block
	local pos = vector.add(prev_pos, next_dir)

	local meta = minetest.get_meta(pos)
	local carts = minetest.deserialize(meta:get_string("_mcl_minecarts_carts")) or {}
	local cart_uuid = nil
	local dirty = false
	for uuid,_ in pairs(carts) do
		-- Clean up dead carts
		local data = get_cart_data(uuid)
		if not data or not data.connected_at then
			carts[uuid] = nil
			dirty = true
			uuid = nil
		end

		if uuid and uuid ~= cart1_staticdata.uuid then cart_uuid = uuid end
	end
	if dirty then
		meta:set_string("_mcl_minecarts_carts",minetest.serialize(carts))
	end

	if not cart_uuid then return end

	-- Don't collide with the train car in front of you
	if cart1_staticdata.ahead == cart_uuid then return end

	--minetest.log("action","cart #"..cart1_staticdata.uuid.." collided with cart #"..cart_uuid.." at "..tostring(pos))

	-- Standard Collision Handling
	local cart2_staticdata = get_cart_data(cart_uuid)

	local u1 = cart1_staticdata.velocity
	local u2 = cart2_staticdata.velocity
	local m1 = cart1_staticdata.mass
	local m2 = cart2_staticdata.mass

	if ENABLE_TRAINS and u2 == 0 and u1 < 4 and train_length(cart1_staticdata) < MAX_TRAIN_LENGTH then
		link_cart_ahead(cart1_staticdata, cart2_staticdata)
		cart2_staticdata.dir = mcl_minecarts.get_rail_direction(cart2_staticdata.connected_at, cart1_staticdata.dir)
		cart2_staticdata.velocity = cart1_staticdata.velocity
		return
	end

	-- Reverse direction of the second cart if it is pointing in the wrong direction for this collision
	local rel = vector.direction(cart1_staticdata.connected_at, cart2_staticdata.connected_at)
	local dir2 = cart2_staticdata.dir
	local col_dir = vector.dot(rel, dir2)
	if col_dir < 0 then
		cart2_staticdata.dir = -dir2
		u2 = -u2
	end

	-- Calculate new velocities according to https://en.wikipedia.org/wiki/Elastic_collision#One-dimensional_Newtonian
	local c1 = m1 + m2
	local d = m1 - m2
	local v1 = (      d * u1 + 2 * m2 * u2 ) / c1
	local v2 = ( 2 * m1 * u1 +      d * u2 ) / c1

	cart1_staticdata.velocity = v1
	cart2_staticdata.velocity = v2
end

local function vector_away_from_players(cart, staticdata)
	local function player_repel(obj)
		-- Only repel from players
		local player_name = obj:get_player_name()
		if not player_name or player_name == "" then return false end

		-- Don't repel away from players in minecarts
		local player_meta = mcl_playerinfo.get_mod_meta(player_name, modname)
		if player_meta.attached_to then return false end

		return true
	end

	-- Get the cart position
	local cart_pos = mod.get_cart_position(staticdata)
	if cart then cart_pos = cart.object:get_pos() end
	if not cart_pos then return nil end

	for _,obj in pairs(minetest.get_objects_inside_radius(cart_pos, 1.1)) do
		if player_repel(obj) then
			return obj:get_pos() - cart_pos
		end
	end

	return nil
end

local function direction_away_from_players(staticdata)
	local diff = vector_away_from_players(nil,staticdata)
	if not diff then return 0 end

	local length = vector.distance(vector.zero(),diff)
	local vec = diff / length
	local force = vector.dot( vec, vector.normalize(staticdata.dir) )

	-- Check if this would push past the end of the track and don't move it it would
	-- This prevents an oscillation that would otherwise occur
	local dir = staticdata.dir
	if force > 0 then
		dir = -dir
	end
	if mcl_minecarts.is_rail( staticdata.connected_at + dir ) then
		if force > 0.5 then
			return -length * 4
		elseif force < -0.5 then
			return length * 4
		end
	end
	return 0
end

local look_directions = {
	[0] = mod.north,
	mod.west,
	mod.south,
	mod.east,
}
local function calculate_acceleration(staticdata)
	local acceleration = 0

	-- Fix up movement data
	staticdata.velocity = staticdata.velocity or 0

	-- Apply friction if moving
	if staticdata.velocity > 0 then
		acceleration = -FRICTION
	end

	local pos = staticdata.connected_at
	local node_name = minetest.get_node(pos).name
	local node_def = minetest.registered_nodes[node_name]

	local ctrl = staticdata.controls or {}
	local time_active = minetest.get_gametime() - 0.25

	if (ctrl.forward or 0) > time_active then
		if staticdata.velocity <= 0.05 then
			local look_dir = look_directions[ctrl.look or 0] or mod.north
			local dot = vector.dot(staticdata.dir, look_dir)
			if dot < 0 then
				reverse_direction(staticdata)
			end
		end
		acceleration = 4
	elseif (ctrl.brake or 0) > time_active then
		acceleration = -1.5
	elseif (staticdata.fueltime or 0) > 0 and staticdata.velocity <= 4 then
		acceleration = 0.6
	elseif staticdata.velocity >= ( node_def._max_acceleration_velocity or SPEED_MAX ) then
		-- Standard friction
	elseif node_def and node_def._rail_acceleration then
		local rail_accel = node_def._rail_acceleration
		if type(rail_accel) == "function" then
			acceleration = (rail_accel(pos, staticdata) or 0) * 4
		else
			acceleration = rail_accel * 4
		end
	end

	-- Factor in gravity after everything else
	local gravity_strength = 2.45 --friction * 5
	if staticdata.dir.y < 0 then
		acceleration = acceleration + gravity_strength - FRICTION
	elseif staticdata.dir.y > 0 then
		acceleration = acceleration - gravity_strength - FRICTION
	end

	return acceleration
end

local function do_movement_step(staticdata, dtime)
	if not staticdata.connected_at then return 0 end

	-- Calculate timestep remaiing in this block
	local x_0 = staticdata.distance or 0
	local remaining_in_block = 1 - x_0

	-- Apply velocity impulse
	local v_0 = staticdata.velocity or 0
	local ctrl = staticdata.controls or {}
	if ctrl.impulse then
		local impulse = ctrl.impulse
		ctrl.impulse = nil

		local new_v_0 = v_0 + impulse
		if new_v_0 > SPEED_MAX then
			new_v_0 = SPEED_MAX
		elseif new_v_0 < 0.025 then
			new_v_0 = 0
		end
		v_0 = new_v_0
	end

	-- Calculate acceleration
	local a = 0
	if staticdata.ahead or staticdata.behind then
		-- Calculate acceleration of the entire train
		local count = 0
		for cart in mod.train_cars(staticdata) do
			count = count + 1
			if cart.behind then
				a = a + calculate_acceleration(cart)
			end
		end
		a = a / count
	else
		a = calculate_acceleration(staticdata)
	end

	-- Repel minecarts
	local away = direction_away_from_players(staticdata)
	if away > 0 then
		v_0 = away
	elseif away < 0 then
		reverse_direction(staticdata)
		v_0 = -away
	end

	if DEBUG and ( v_0 > 0 or a ~= 0 ) then
		mcl_debug("    cart "..tostring(staticdata.uuid)..
		       ": a="..tostring(a)..
		        ",v_0="..tostring(v_0)..
		        ",x_0="..tostring(x_0)..
			",dtime="..tostring(dtime)..
		        ",dir="..tostring(staticdata.dir)..
			",connected_at="..tostring(staticdata.connected_at)..
			",distance="..tostring(staticdata.distance)
		)
	end

	-- Not moving
	if a == 0 and v_0 == 0 then return 0 end

	-- Prevent movement into solid blocks
	if staticdata.distance == 0 then
		local next_node = core.get_node(staticdata.connected_at + staticdata.dir)
		local next_node_def = core.registered_nodes[next_node.name]
		if not next_node_def or next_node_def.groups and (next_node_def.groups.solid or next_node_def.groups.stair) then
			reverse_direction(staticdata)
			return 0
		end
	end

	-- Movement equation with acceleration: x_1 = x_0 + v_0 * t + 0.5 * a * t*t
	local timestep
	local stops_in_block = false
	local inside = v_0 * v_0 + 2 * a * remaining_in_block
	if inside < 0 then
		-- Would stop or reverse direction inside this block, calculate time to v_1 = 0
		timestep = -v_0 / a
		stops_in_block = true
		if timestep <= 0.01 then
			reverse_direction(staticdata)
		end
	elseif a ~= 0 then
		-- Setting x_1 = x_0 + remaining_in_block, and solving for t gives:
		timestep = ( math.sqrt( v_0 * v_0 + 2 * a * remaining_in_block) - v_0 ) / a
	else
		timestep = remaining_in_block / v_0
	end

	-- Truncate timestep to remaining time delta
	if timestep > dtime then
		timestep = dtime
	end

	-- Truncate timestep to prevent v_1 from being larger that speed_max
	if (v_0 < SPEED_MAX) and ( v_0 + a * timestep > SPEED_MAX) then
		timestep = ( SPEED_MAX - v_0 ) / a
	end

	-- Prevent infinite loops
	if timestep <= 0 then return 0 end

	-- Calculate v_1 taking SPEED_MAX into account
	local v_1 = v_0 + a * timestep
	if v_1 > SPEED_MAX then
		v_1 = SPEED_MAX
	elseif v_1 < 0.025 then
		v_1 = 0
	end

	-- Calculate x_1
	local x_1 = x_0 + (timestep * v_0 + 0.5 * a * timestep * timestep) / vector.length(staticdata.dir)

	-- Update position and velocity of the minecart
	staticdata.velocity = v_1
	staticdata.distance = x_1

	if DEBUG and ( v_0 > 0 or a ~= 0 ) then
		mcl_debug( "-   cart #"..tostring(staticdata.uuid)..
		       ": a="..tostring(a)..
		        ",v_0="..tostring(v_0)..
		        ",v_1="..tostring(v_1)..
		        ",x_0="..tostring(x_0)..
		        ",x_1="..tostring(x_1)..
		        ",timestep="..tostring(timestep)..
		        ",dir="..tostring(staticdata.dir)..
			",connected_at="..tostring(staticdata.connected_at)..
			",distance="..tostring(staticdata.distance)
		)
	end

	-- Entity movement
	local pos = staticdata.connected_at

	-- Handle movement to next block, account for loss of precision in calculations
	if x_1 >= 0.99 then
		staticdata.distance = 0

		-- Anchor at the next node
		local old_pos = pos
		pos = pos + staticdata.dir
		staticdata.connected_at = pos

		-- Get the next direction
		local next_dir,_ = mcl_minecarts.get_rail_direction(pos, staticdata.dir, nil, nil, staticdata.railtype)
		if DEBUG and next_dir ~= staticdata.dir then
			mcl_debug( "Changing direction from "..tostring(staticdata.dir).." to "..tostring(next_dir))
		end

		-- Handle cart collisions
		handle_cart_collision(staticdata, pos, next_dir)

		-- Leave the old node
		handle_cart_leave(staticdata, old_pos, next_dir )

		-- Enter the new node
		handle_cart_enter(staticdata, pos, next_dir)

		-- Handle end of track
		if next_dir == staticdata.dir * -1 and next_dir.y == 0 then
			if DEBUG then mcl_debug("Stopping cart at end of track at "..tostring(pos)) end
			staticdata.velocity = 0
		end

		-- Update cart direction
		staticdata.dir = next_dir
	elseif stops_in_block and v_1 < (FRICTION/5) and a <= 0 and staticdata.dir.y > 0 then
		-- Handle direction flip due to gravity
		if DEBUG then mcl_debug("Gravity flipped direction") end

		-- Velocity should be zero at this point
		staticdata.velocity = 0

		reverse_direction(staticdata)

		-- Intermediate movement
		pos = staticdata.connected_at + staticdata.dir * staticdata.distance
	else
		-- Intermediate movement
		pos = pos + staticdata.dir * staticdata.distance
	end

	-- Debug reporting
	if DEBUG and ( v_0 > 0 or v_1 > 0 ) then
		mcl_debug( "    cart #"..tostring(staticdata.uuid)..
		       ": a="..tostring(a)..
		        ",v_0="..tostring(v_0)..
		        ",v_1="..tostring(v_1)..
		        ",x_0="..tostring(x_0)..
		        ",x_1="..tostring(x_1)..
		        ",timestep="..tostring(timestep)..
		        ",dir="..tostring(staticdata.dir)..
			",pos="..tostring(pos)..
			",connected_at="..tostring(staticdata.connected_at)..
			",distance="..tostring(staticdata.distance)
		)
	end

	-- Report the amount of time processed
	return dtime - timestep
end

function submod.do_movement( staticdata, dtime )
	assert(staticdata)

	-- Break long movements at block boundaries to make it
	-- it impossible to jump across gaps due to server lag
	-- causing large timesteps
	while dtime > 0 do
		local new_dtime = do_movement_step(staticdata, dtime)
		try_detach_minecart(staticdata)

		update_train(staticdata)

		-- Handle node watches here in steps to prevent server lag from changing behavior
		handle_cart_node_watches(staticdata, dtime - new_dtime)

		dtime = new_dtime
	end
end

function submod.do_detached_movement(self)
	local staticdata = self._staticdata

	-- Make sure the object is still valid before trying to move it
	local velocity = self.object:get_velocity()
	if not self.object or not velocity then return end

	-- Apply physics
	if env_physics then
		env_physics.apply_entity_environmental_physics(self)
	else
		-- Simple physics
		local friction = velocity or vector.zero()
		friction.y = 0

		local accel = vector.new(0,-9.81,0) -- gravity

		-- Don't apply friction in the air
		local pos_rounded = vector.round(self.object:get_pos())
		if minetest.get_node(vector.offset(pos_rounded,0,-1,0)).name ~= "air" then
			accel = vector.add(accel, vector.multiply(friction,-OFF_RAIL_FRICTION))
		end

		self.object:set_acceleration(accel)
	end

	-- Shake the cart (also resets pitch)
	local rot = self.object:get_rotation()
	local shake_amount = 0.05 * vector.length(velocity)
	rot.x = (math.random() - 0.5) * shake_amount
	rot.z = (math.random() - 0.5) * shake_amount
	self.object:set_rotation(rot)

	local away = vector_away_from_players(self, staticdata)
	if away then
		local v = self.object:get_velocity()
		self.object:set_velocity((v - away)*0.65)

		-- Boost the minecart vertically a bit to get over the edge of rails and things like carpets
		local boost = vector.offset(vector.multiply(vector.normalize(away), 0.1), 0, 0.07, 0) -- 1/16th + 0.0075
		local pos = self.object:get_pos()
		if pos.y - math.floor(pos.y) < boost.y then
			self.object:set_pos(vector.add(pos,boost))
		end
	end

	-- Try to reconnect to rail
	local pos = self.object:get_pos()
	local yaw = self.object:get_yaw()
	local yaw_dir = minetest.yaw_to_dir(yaw)
	local test_positions = {
		pos,
		vector.offset(vector.add(pos, vector.multiply(yaw_dir, 0.5)),0,-0.55,0),
		vector.offset(vector.add(pos, vector.multiply(yaw_dir,-0.5)),0,-0.55,0),
	}

	for i=1,#test_positions do
		local test_pos = test_positions[i]
		local pos_r = vector.round(test_pos)
		local node = minetest.get_node(pos_r)
		if minetest.get_item_group(node.name, "rail") ~= 0 then
			staticdata.connected_at = pos_r
			staticdata.railtype = node.name

			local freebody_velocity = self.object:get_velocity()
			staticdata.dir = mod:get_rail_direction(pos_r, mod.snap_direction(freebody_velocity))

			-- Use vector projection to only keep the velocity in the new direction of movement on the rail
			-- https://en.wikipedia.org/wiki/Vector_projection
			staticdata.velocity = vector.dot(staticdata.dir,freebody_velocity)
			--print("Reattached velocity="..tostring(staticdata.velocity)..", freebody_velocity="..tostring(freebody_velocity))

			-- Clear freebody movement
			self.object:set_velocity(vector.zero())
			self.object:set_acceleration(vector.zero())
			return
		end
	end

	-- Reset pitch if still not attached
	rot = self.object:get_rotation()
	rot.x = 0
	self.object:set_rotation(rot)
end

--return do_movement, do_detatched_movement
return submod

