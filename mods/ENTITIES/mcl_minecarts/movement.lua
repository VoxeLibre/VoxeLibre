local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_minecarts
local S = minetest.get_translator(modname)

-- Constants
local mcl_debug,DEBUG = mcl_util.make_mcl_logger("mcl_logging_minecart_debug", "Minecart Debug")
local friction = mcl_minecarts.FRICTION
local MAX_TRAIN_LENGTH = mod.MAX_TRAIN_LENGTH

-- Imports
local train_length = mod.train_length
local update_train = mod.update_train
local link_cart_ahead = mod.link_cart_ahead
local update_cart_orientation = mod.update_cart_orientation
local get_cart_data = mod.get_cart_data
local get_cart_position = mod.get_cart_position

local function detach_minecart(self)
	local staticdata = self._staticdata

	staticdata.connected_at = nil
	self.object:set_velocity(staticdata.dir * staticdata.velocity)
end
mod.detach_minecart = detach_minecart

local function try_detach_minecart(self)
	local staticdata = self._staticdata
	if not staticdata then return end

	-- Don't try to detach if alread detached
	if not staticdata.connected_at then return end

	local node = minetest.get_node(staticdata.connected_at)
	if minetest.get_item_group(node.name, "rail") == 0 then
		detach_minecart(self)
	end
end

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

local function handle_cart_enter_exit(self, pos, next_dir, event)
	local staticdata = self._staticdata

	local dir = staticdata.dir
	local right = vector.new( dir.z, dir.y, -dir.x)
	local up = vector.new(0,1,0)
	for _,check in ipairs(enter_exit_checks) do
		local check_pos = pos + dir * check[1] + right * check[2] + up * check[3]
		local node = minetest.get_node(check_pos)
		local node_def = minetest.registered_nodes[node.name]
		if node_def then
			-- node-specific hook
			local hook_name = "_mcl_minecarts_"..event..check[4]
			local hook = node_def[hook_name]
			if hook then hook(check_pos, self, next_dir, pos) end

			-- global minecart hook
			hook = mcl_minecarts[event..check[4]]
			if hook then hook(check_pos, self, next_dir, node_def) end
		end
	end

	-- Handle cart-specific behaviors
	local hook = self["_mcl_minecarts_"..event]
	if hook then hook(self, pos) end
end
local function set_metadata_cart_status(pos, uuid, state)
	local meta = minetest.get_meta(pos)
	local carts = minetest.deserialize(meta:get_string("_mcl_minecarts_carts")) or {}
	carts[uuid] = state
	meta:set_string("_mcl_minecarts_carts", minetest.serialize(carts))
end
local function handle_cart_enter(self, pos, next_dir)
	--print("entering "..tostring(pos))
	set_metadata_cart_status(pos, self._staticdata.uuid, 1)
	handle_cart_enter_exit(self, pos, next_dir, "on_enter" )
end
local function handle_cart_leave(self, pos, next_dir)
	--print("leaving "..tostring(pos))
	set_metadata_cart_status(pos, self._staticdata.uuid, nil)
	handle_cart_enter_exit(self, pos, next_dir, "on_leave" )
end
local function handle_cart_node_watches(self, dtime)
	local staticdata = self._staticdata
	local watches = staticdata.node_watches or {}
	local new_watches = {}
	for _,node_pos in ipairs(watches) do
		local node = minetest.get_node(node_pos)
		local node_def = minetest.registered_nodes[node.name]
		if node_def then
			local hook = node_def._mcl_minecarts_node_on_step
			if hook and hook(node_pos, self, dtime) then
				new_watches[#new_watches+1] = node_pos
			end
		end
	end

	staticdata.node_watches = new_watches
end

local function handle_cart_collision(cart1, prev_pos, next_dir)
	-- Look ahead one block
	local pos = vector.add(prev_pos, next_dir)

	local meta = minetest.get_meta(pos)
	local carts = minetest.deserialize(meta:get_string("_mcl_minecarts_carts")) or {}
	local cart_uuid = nil
	local dirty = false
	for uuid,v in pairs(carts) do
		-- Clean up dead carts
		local data = get_cart_data(uuid)
		if not data then
			carts[uuid] = nil
			dirty = true
			uuid = nil
		end

		if uuid and uuid ~= cart1._staticdata.uuid then cart_uuid = uuid end
	end
	if dirty then
		meta:set_string("_mcl_minecarts_carts",minetest.serialize(carts))
	end

	local meta = minetest.get_meta(vector.add(pos,next_dir))
	if not cart_uuid then return end

	-- Don't collide with the train car in front of you
	if cart1._staticdata.ahead == cart_uuid then return end

	minetest.log("action","cart #"..cart1._staticdata.uuid.." collided with cart #"..cart_uuid.." at "..tostring(pos))

	-- Standard Collision Handling
	local cart1_staticdata = cart1._staticdata
	local cart2_staticdata = get_cart_data(cart_uuid)

	local u1 = cart1_staticdata.velocity
	local u2 = cart2_staticdata.velocity
	local m1 = cart1_staticdata.mass
	local m2 = cart2_staticdata.mass

	--print("u1="..tostring(u1)..",u2="..tostring(u2))
	if u2 == 0 and u1 < 4 and train_length(cart1) < MAX_TRAIN_LENGTH then
		link_cart_ahead(cart1, {_staticdata=cart2_staticdata})
		cart2_staticdata.dir = mcl_minecarts:get_rail_direction(cart2_staticdata.connected_at, cart1_staticdata.dir)
		cart2_staticdata.velocity = cart1_staticdata.velocity
		return
	end

	-- Calculate new velocities according to https://en.wikipedia.org/wiki/Elastic_collision#One-dimensional_Newtonian
	local c1 = m1 + m2
	local d = m1 - m2
	local v1 = (      d * u1 + 2 * m2 * u2 ) / c1
	local v2 = ( 2 * m1 * u1 +      d * u2 ) / c1

	cart1_staticdata.velocity = v1
	cart2_staticdata.velocity = v2

	-- Force the other cart to move the same direction this one was
	cart2_staticdata.dir = mcl_minecarts:get_rail_direction(cart2_staticdata.connected_at, cart1_staticdata.dir)
end


local function vector_away_from_players(self, staticdata)
	local objs = minetest.get_objects_inside_radius(self.object:get_pos(), 1.1)
	for n=1,#objs do
		local obj = objs[n]
		local player_name = obj:get_player_name()
		if player_name and player_name ~= "" and not ( self._driver and self._driver == player_name ) then
			return obj:get_pos() - self.object:get_pos()
		end
	end

	return nil
end

local function direction_away_from_players(self, staticdata)
	local diff = vector_away_from_players(self, staticdata)
	if not diff then return 0 end

	local length = vector.distance(vector.new(0,0,0),diff)
	local vec = diff / length
	local force = vector.dot( vec, vector.normalize(staticdata.dir) )

	-- Check if this would push past the end of the track and don't move it it would
	-- This prevents an oscillation that would otherwise occur
	local dir = staticdata.dir
	if force > 0 then
		dir = -dir
	end
	if mcl_minecarts:is_rail( staticdata.connected_at + dir ) then
		if force > 0.5 then
			return -length * 4
		elseif force < -0.5 then
			return length * 4
		end
	end
	return 0
end

local function calculate_acceleration(self, staticdata)
	local acceleration = 0

	-- Fix up movement data
	staticdata.velocity = staticdata.velocity or 0

	-- Apply friction if moving
	if staticdata.velocity > 0 then
		acceleration = -friction
	end

	local pos = staticdata.connected_at
	local node_name = minetest.get_node(pos).name
	local node_def = minetest.registered_nodes[node_name]
	local max_vel = mcl_minecarts.speed_max

	if self._go_forward then
		acceleration = 4
	elseif self._brake then
		acceleration = -1.5
	elseif (staticdata.fueltime or 0) > 0 and staticdata.velocity <= 4 then
		acceleration = 0.6
	elseif staticdata.velocity >= ( node_def._max_acceleration_velocity or max_vel ) then
		-- Standard friction
	elseif node_def and node_def._rail_acceleration then
		acceleration = node_def._rail_acceleration * 4
	end

	-- Factor in gravity after everything else
	local gravity_strength = 2.45 --friction * 5
	if staticdata.dir.y < 0 then
		acceleration = gravity_strength - friction
	elseif staticdata.dir.y > 0 then
		acceleration = -gravity_strength + friction
	end

	return acceleration
end

local function reverse_direction(self, staticdata)
	-- Complete moving thru this block into the next, reverse direction, and put us back at the same position we were at
	local next_dir = -staticdata.dir
	staticdata.connected_at = staticdata.connected_at + staticdata.dir
	staticdata.distance = 1 - (staticdata.distance or 0)

	-- recalculate direction
	local next_dir,_ = mcl_minecarts:get_rail_direction(staticdata.connected_at, next_dir, nil, nil, staticdata.railtype)
	staticdata.dir = next_dir
end

local function do_movement_step(self, dtime)
	local staticdata = self._staticdata
	if not staticdata.connected_at then return 0 end

	-- Calculate timestep remaiing in this block
	local x_0 = staticdata.distance or 0
	local remaining_in_block = 1 - x_0
	local a = calculate_acceleration(self, staticdata)
	local v_0 = staticdata.velocity

	-- Repel minecarts
	local away = direction_away_from_players(self, staticdata)
	if away > 0 then
		v_0 = away
	elseif away < 0 then
		reverse_direction(self, staticdata)
		v_0 = -away
	end

	if DEBUG and ( v_0 > 0 or a ~= 0 ) then
		mcl_debug("    cart "..tostring(staticdata.uuid)..
		       ": a="..tostring(a)..
		        ",v_0="..tostring(v_0)..
		        ",x_0="..tostring(x_0)..
		        ",timestep="..tostring(timestep)..
		        ",dir="..tostring(staticdata.dir)..
			",connected_at="..tostring(staticdata.connected_at)..
			",distance="..tostring(staticdata.distance)
		)
	end

	-- Not moving
	if a == 0 and v_0 == 0 then return 0 end

	-- Movement equation with acceleration: x_1 = x_0 + v_0 * t + 0.5 * a * t*t
	local timestep
	local stops_in_block = false
	local inside = v_0 * v_0 + 2 * a * remaining_in_block
	if inside < 0 then
		-- Would stop or reverse direction inside this block, calculate time to v_1 = 0
		timestep = -v_0 / a
		stops_in_block = true
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
	local v_max = mcl_minecarts.speed_max
	if (v_0 ~= v_max) and ( v_0 + a * timestep > v_max) then
		timestep = ( v_max - v_0 ) / a
	end

	-- Prevent infinite loops
	if timestep <= 0 then return 0 end

	-- Calculate v_1 taking v_max into account
	local v_1 = v_0 + a * timestep
	if v_1 > v_max then
		v_1 = v_max
	elseif v_1 < friction / 5 then
		v_1 = 0
	end

	-- Calculate x_1
	local x_1 = x_0 + timestep * v_0 + 0.5 * a * timestep * timestep

	-- Update position and velocity of the minecart
	staticdata.velocity = v_1
	staticdata.distance = x_1

	if DEBUG and (1==0) and ( v_0 > 0 or a ~= 0 ) then
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
		local next_dir,_ = mcl_minecarts:get_rail_direction(pos, staticdata.dir, nil, nil, staticdata.railtype)
		if DEBUG and next_dir ~= staticdata.dir then
			mcl_debug( "Changing direction from "..tostring(staticdata.dir).." to "..tostring(next_dir))
		end

		-- Handle cart collisions
		handle_cart_collision(self, pos, next_dir)

		-- Leave the old node
		handle_cart_leave(self, old_pos, next_dir )

		-- Enter the new node
		handle_cart_enter(self, pos, next_dir)

		-- Handle end of track
		if next_dir == staticdata.dir * -1 and next_dir.y == 0 then
			if DEBUG then mcl_debug("Stopping cart at end of track at "..tostring(pos)) end
			staticdata.velocity = 0
		end

		-- Update cart direction
		staticdata.dir = next_dir
	elseif stops_in_block and v_1 < (friction/5) and a <= 0 then
		-- Handle direction flip due to gravity
		if DEBUG then mcl_debug("Gravity flipped direction") end

		-- Velocity should be zero at this point
		staticdata.velocity = 0

		reverse_direction(self, staticdata)

		-- Intermediate movement
		pos = staticdata.connected_at + staticdata.dir * staticdata.distance
	else
		-- Intermediate movement
		pos = pos + staticdata.dir * staticdata.distance
	end

	self.object:move_to(pos)

	-- Update cart orientation
	update_cart_orientation(self)

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

local function do_movement( self, dtime )
	local staticdata = self._staticdata

	-- Allow the carts to be delay for the rest of the world to react before moving again
	if ( staticdata.delay or 0 ) > dtime then
		staticdata.delay = staticdata.delay - dtime
		return
	else
		staticdata.delay = 0
	end

	-- Break long movements at block boundaries to make it
	-- it impossible to jump across gaps due to server lag
	-- causing large timesteps
	while dtime > 0 do
		local new_dtime = do_movement_step(self, dtime)
		try_detach_minecart(self)

		update_train(self)

		-- Handle node watches here in steps to prevent server lag from changing behavior
		handle_cart_node_watches(self, dtime - new_dtime)

		dtime = new_dtime
	end
end

local function do_detached_movement(self, dtime)
	local staticdata = self._staticdata

	-- Make sure the object is still valid before trying to move it
	if not self.object or not self.object:get_pos() then return end

	-- Apply physics
	if mcl_physics then
		mcl_physics.apply_entity_environmental_physics(self)
	else
		-- Simple physics
		local friction = self.object:get_velocity() or vector.new(0,0,0)
		friction.y = 0

		local accel = vector.new(0,-9.81,0) -- gravity

		-- Don't apply friction in the air
		local pos_rounded = vector.round(self.object:get_pos())
		if minetest.get_node(vector.offset(pos_rounded,0,-1,0)).name ~= "air" then
			accel = vector.add(accel, vector.multiply(friction,-0.9))
		end

		self.object:set_acceleration(accel)
	end

	local away = vector_away_from_players(self, staticdata)
	if away then
		local v = self.object:get_velocity()
		self.object:set_velocity(v - away)
	end

	-- Try to reconnect to rail
	local pos_r = vector.round(self.object:get_pos())
	local node = minetest.get_node(pos_r)
	if minetest.get_item_group(node.name, "rail") ~= 0 then
		staticdata.connected_at = pos_r
		staticdata.railtype = node.name

		local freebody_velocity = self.object:get_velocity()
		staticdata.dir = mod:get_rail_direction(pos_r, mod.snap_direction(freebody_velocity))

		-- Use vector projection to only keep the velocity in the new direction of movement on the rail
		-- https://en.wikipedia.org/wiki/Vector_projection
		staticdata.velocity = vector.dot(staticdata.dir,freebody_velocity)

		-- Clear freebody movement
		self.object:set_velocity(vector.new(0,0,0))
		self.object:set_acceleration(vector.new(0,0,0))
	end
end

--return do_movement, do_detatched_movement
return do_movement,do_detached_movement,handle_cart_enter

