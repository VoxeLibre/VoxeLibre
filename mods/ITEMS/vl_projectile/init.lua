vl_projectile = {}
local mod = vl_projectile

local vl_physics_path = core.get_modpath("vl_physics")

local DEBUG = false
local YAW_OFFSET = -math.pi/2
local GRAVITY = tonumber(core.settings:get("movement_gravity"))
local STUCK_TIMEOUT = 60
local STUCK_RECHECK_TIME = 0.25
local enable_pvp = core.settings:get_bool("enable_pvp")

function mod.projectile_physics(obj, entity_def, v, a)
	local le = obj:get_luaentity()
	if not le then return end

	local entity_def = core.registered_entities[le.name]
	local pos = obj:get_pos()
	if not pos then return end

	if vl_physics_path then
		v,a = vl_physics.apply_entity_environmental_physics(obj)
	else
		-- Simple physics
		v = v or obj:get_velocity()
		a = a or vector.zero()

		if not entity_def._vl_projectile.ignore_gravity then
			a = a + vector.new(0,-GRAVITY,0)
		end

		if entity_def.liquid_drag then
			local def = core.registered_nodes[core.get_node(pos).name]
			if def and def.liquidtype ~= "none" then
				-- Slow down arrow in liquids
				local visc = def.liquid_viscosity or 0
				le._viscosity = visc

				local vpenalty = math.max(0.1, 0.98 - 0.1 * visc)
				if math.abs(v.x) > 0.001 then
					v.x = v.x * vpenalty
				end
				if math.abs(v.z) > 0.001 then
					v.z = v.z * vpenalty
				end
			end
		end
	end

	-- Pass to entity
	if v then obj:set_velocity(v) end
	if a then obj:set_acceleration(a) end

	-- Update projectile yaw to match velocity direction
	if v and le and not le._stuck then
		local yaw = core.dir_to_yaw(v) + YAW_OFFSET + (entity_def._vl_projectile.yaw_offset or 0)
		local pitch = math.asin(vector.normalize(v).y) + (entity_def._vl_projectile.pitch_offset or 0)
		obj:set_rotation(vector.new(0,yaw,pitch))
	end
end

function mod.update_projectile(self, dtime)
	if self._removed then return end
	local pos = self.object:get_pos()
	if not pos then return end

	-- Workaround for randomly occurring velocity change between projectile creation
	-- and the first time step
	if self._starting_velocity then
		local curr_velocity = self.object:get_velocity()
		local distance = vector.distance(curr_velocity, self._starting_velocity)
		local length = vector.length(self._starting_velocity)
		if length / distance > 1 then
			self.object:set_velocity(self._starting_velocity)
		end
		self._starting_velocity = nil
	end

	local entity_name = self.name
	local entity_def = core.registered_entities[entity_name] or {}
	local entity_vl_projectile = entity_def._vl_projectile or {}

	-- Update entity timer and remove expired projectiles
	self.timer = (self.timer or 0) + dtime
	local maximum_flight_time = self._vl_projectile.maximum_time or 300
	if (self.timer or 0) > maximum_flight_time then
		mcl_util.remove_entity(self)
		return
	end

	-- Run behaviors
	local behaviors = entity_vl_projectile.behaviors or {}
	for i=1,#behaviors do
		if behaviors[i](self, dtime, entity_def, entity_vl_projectile) or self._removed then
			return
		end
	end

	if not self._stuck then
		mod.projectile_physics(self.object, entity_def)
	end

	-- Update last position
	self._last_pos = pos
end

local function damage_particles(pos, is_critical)
	if is_critical then
		core.add_particlespawner({
			amount = 15,
			time = 0.1,
			minpos = vector.offset(pos, -0.5, -0.5, -0.5),
			maxpos = vector.offset(pos, 0.5, 0.5, 0.5),
			minvel = vector.new(-0.1, -0.1, -0.1),
			maxvel = vector.new(0.1, 0.1, 0.1),
			minexptime = 1,
			maxexptime = 2,
			minsize = 1.5,
			maxsize = 1.5,
			collisiondetection = false,
			vertical = false,
			texture = "mcl_particles_crit.png^[colorize:#bc7a57:127",
		})
	end
end

local function random_hit_positions(positions, placement)
	if positions == "x" then
		return math.random(-4, 4)
	elseif positions == "y" then
		return math.random(0, 10)
	elseif positions == "z" then
		if placement == "front" then
			return 3
		elseif placement == "back" then
			return -3
		end
	end

	return 0
end

local function check_hitpoint(hitpoint)
	if hitpoint.type ~= "object" then return false end

	-- find the closest object that is in the way of the arrow
	-- TODO: change this check when adding mob projectiles
	if hitpoint.ref:is_player() and enable_pvp then
		return true
	end

	local obj = hitpoint.ref
	local le = obj:get_luaentity()
	if not obj:is_player() and le then
		if (le.is_mob or le._hittable_by_projectile) then
			return true
		end
	end

	return false
end

local function handle_player_sticking(self, entity_def, projectile_def, entity)
	if self._in_player or self._blocked then return end
	if not projectile_def.sticks_in_players then return end

	core.after(150, function() mcl_util.remove_entity(self) end)

	-- Handle blocking projectiles
	if mcl_shields.is_blocking(entity) then
		self._blocked = true
		self.object:set_velocity(vector.multiply(self.object:get_velocity(), -0.25))
		return
	end

	-- Handle when the projectile hits the player
	self._placement = math.random(1, 2)

	local placement = self._placement == 1 and "front" or "back"
	self._rotation_station = self.placement == 1 and -90 or 90
	self._in_player = true
	self._y_position = random_hit_positions("y", placement)
	self._x_position = random_hit_positions("x", placement)
	if self._y_position > 6 and self._x_position < 2 and self._x_position > -2 then
		self._attach_parent = "Head"
		self._y_position = self._y_position - 6
	elseif self._x_position > 2 then
		self._attach_parent = "Arm_Right"
		self._y_position = self._y_position - 3
		self._x_position = self._x_position - 2
	elseif self._x_position < -2 then
		self._attach_parent = "Arm_Left"
		self._y_position = self._y_position - 3
		self._x_position = self._x_position + 2
	else
		self._attach_parent = "Body"
	end
	self._z_rotation = math.random(-30, 30)
	self._y_rotation = math.random(-30, 30)
	self.object:set_attach(
		entity, self._attach_parent,
		vector.new(self._x_position, self._y_position, random_hit_positions("z", placement)),
		vector.new(0, self._rotation_station + self._y_rotation, self._z_rotation)
	)

	return true
end

function mod.burns(self, dtime, entity_def, projectile_def)
	mcl_burning.tick(self.object, dtime, self)

	-- mcl_burning.tick may remove object immediately
	local pos = self.object:get_pos()
	if not pos then return true end

	-- Handle getting set on fire
	local node = core.get_node(vector.round(pos))
	if not node or node.name == "ignore" then return end

	local set_on_fire = core.get_item_group(node.name, "set_on_fire")
	if set_on_fire ~= 0 then
		mcl_burning.set_on_fire(self.object, set_on_fire)
	end
end

function mod.has_owner_grace_distance(self, dtime, entity_def, projectile_def)
	local pos = self.object:get_pos()

	self._allow_punch = self._allow_punch or
		not self._owner or not self._startpos or
		pos and vector.distance(self._startpos, pos) > ( projectile_def.grace_distance or 1.5 )
end

function mod.has_tracer(self, dtime, entity_def, projectile_def)
	local hide_tracer = projectile_def.hide_tracer
	if hide_tracer and hide_tracer(self) then return end

	-- Add tracer
	core.add_particlespawner({
		amount = 20,
		time = .2,
		minpos = vector.zero(),
		maxpos = vector.zero(),
		minvel = vector.new(-0.1,-0.1,-0.1),
		maxvel = vector.new(0.1,0.1,0.1),
		minexptime = 0.5,
		maxexptime = 0.5,
		minsize = 2,
		maxsize = 2,
		attached = self.object,
		collisiondetection = false,
		vertical = false,
		texture = projectile_def.tracer_texture or "mobs_mc_arrow_particle.png",
		glow = 1,
	})
end

function mod.replace_with_item_drop(self, pos, projectile_def)
	projectile_def = projectile_def or self._vl_projectile
	local item = self._arrow_item or projectile_def and projectile_def.item

	if item and self._collectable and (projectile_def and projectile_def.creative_collectable or not core.is_creative_enabled("")) then
		-- Prevent item duplication
		self._collectable = false

		local drop_item = core.add_item(pos, item)
		if drop_item then
			drop_item:set_velocity(vector.zero())
			drop_item:set_yaw(self.object:get_yaw())
		end
	end

	mcl_burning.extinguish(self.object)
	mcl_util.remove_entity(self)
end

local function stuck_on_step(self, dtime, entity_def, projectile_def)
	-- Don't process objects that have been removed
	local pos = self.object:get_pos()
	if not pos then return true end

	self._stucktimer = (self._stucktimer or 0) + dtime
	if self._stucktimer > STUCK_TIMEOUT then
		mcl_burning.extinguish(self.object)
		mcl_util.remove_entity(self)
		return true
	end

	-- Drop arrow as item when it is no longer stuck
	-- TODO: revist after observer rework
	self._stuckrechecktimer = (self._stuckrechecktimer or 0) + dtime
	if self._stuckrechecktimer > 1 then
		self._stuckrechecktimer = 0
		if self._stuckin then
			local node = core.get_node(self._stuckin)
			local node_def = core.registered_nodes[node.name]
			if node_def and node_def.walkable == false then
				mod.replace_with_item_drop(self, pos, projectile_def)
				return
			end
		end
	end

	-- Don't allow players to pick up arrows stuck in them or other players
	if self._in_player then return true end

	-- Pickup arrow if player is nearby (not in Creative Mode)
	if self._removed then return end

	local function try_pickup_from_player(obj)
		if not obj:is_player() then
			return false
		end

		local player_pos = obj:get_pos()
		local cb = obj:get_properties().collisionbox

		local minp = vector.offset(player_pos, cb[1] - 0.1, cb[2] - 0.1, cb[3] - 0.1)
		local maxp = vector.offset(player_pos, cb[4] + 0.1, cb[5] + 0.1, cb[6] + 0.1)

		if not (pos.x >= minp.x and pos.x <= maxp.x
				and pos.y >= minp.y and pos.y <= maxp.y
				and pos.z >= minp.z and pos.z <= maxp.z) then
			return false
		end

		local player_name = obj:get_player_name()
		local creative = core.is_creative_enabled(player_name)

		if self._collectable and not creative then
			local arrow_item = self._itemstring or self._arrow_item
			if arrow_item and core.registered_items[arrow_item]
					and obj:get_inventory():room_for_item("main", arrow_item) then
				obj:get_inventory():add_item("main", arrow_item)
				self._picked_up = true
			end
		end

		core.sound_play("item_drop_pickup", { pos = pos, max_hear_distance = 16, gain = 1.0 }, true)
		mcl_burning.extinguish(self.object)
		mcl_util.remove_entity(self)
		return true
	end

	for obj in core.objects_inside_radius(pos, 2) do
		if try_pickup_from_player(obj) then
			return true
		end
	end
end

function mod.sticks(self, dtime, entity_def, projectile_def)
	-- Force the projectile to survive collisions (Otherwise, the projectile can't stick in nodes)
	projectile_def.survive_collision = true
	projectile_def.sticks_in_nodes = true

	-- Stuck handling
	if self._stuck then
		stuck_on_step(self, dtime, entity_def, projectile_def)
		return true
	end
end

function mod.collides_with_solids(self, dtime, entity_def, projectile_def)
	local pos = self.object:get_pos()

	-- Don't try to do anything on first update
	if not self._last_pos then return end

	-- Check if the object can collide with this node
	local node = core.get_node(pos)
	local node_def = core.registered_nodes[node.name]
	local collides_with = projectile_def.collides_with
	local physical = (entity_def.initial_properties and entity_def.initial_properties.physical) or entity_def.physical

	if not collides_with or not mcl_util.match_node_to_filter(node.name, collides_with) then
		if physical then
			-- Projectile has stopped in one axis, so it probably hit something.
			-- This detection is a bit clunky, but sadly, MT does not offer a direct collision detection for us. :-(
			local vel = self.object:get_velocity()
			if not self._last_velocity then
				self._last_velocity = vel
				return
			end

			local delta_v = (vel - self._last_velocity)
			local vel_length = vector.length(vel)
			if vel_length > 1 then delta_v = delta_v / vel_length end
			self._last_velocity = vel
			if math.abs(delta_v.x) <= 0.1 and math.abs(delta_v.z) <= 0.1 and math.abs(delta_v.y) <= 0.2 then
				return
			end
		elseif node_def and not node_def.walkable then
			return
		end
	end

	-- Handle sticking in nodes
	if projectile_def.sticks_in_nodes then
		local vel = self.object:get_velocity()
		local dpos = vector.round(pos) -- digital pos

		-- Check for the node to which the arrow is pointing
		local dir
		if math.abs(vel.y) < 0.00001 then
			if self._last_pos.y < pos.y then
				dir = vector.new(0, 1, 0)
			else
				dir = vector.new(0, -1, 0)
			end
		else
			dir = core.facedir_to_dir(core.dir_to_facedir(core.yaw_to_dir(self.object:get_yaw()-YAW_OFFSET)))
		end
		self._stuckin = vector.add(dpos, dir)

		local snode = core.get_node(self._stuckin)
		local sdef = core.registered_nodes[snode.name]

		-- If node is non-walkable, unknown or ignore, don't make arrow stuck.
		-- This causes a deflection in the engine.
		if not sdef or sdef.walkable == false or snode.name == "ignore" then
			self._stuckin = nil
			if self._deflection_cooloff <= 0 then
				-- Lose 1/3 of velocity on deflection
				local newvel = vector.multiply(vel, 0.6667)

				self.object:set_velocity(newvel)
				-- Reset deflection cooloff timer to prevent many deflections happening in quick succession
				self._deflection_cooloff = 1.0
			end
			return
		end

		-- Node was walkable, make arrow stuck
		self._stuck = true
		self._stucktimer = 0
		self._stuckrechecktimer = 0

		self.object:set_velocity(vector.zero())
		self.object:set_acceleration(vector.zero())

		-- Trigger hits on the node the projectile hit
		local hook = sdef._vl_projectile and sdef._vl_projectile.on_collide
		if hook then hook(self, self._stuckin, snode, sdef) end
	end

	-- Call entity collided hook
	local hook = projectile_def.on_collide_with_solid
	if hook then hook(self, pos, node, node_def) end

	-- Call node collided hook
	local hook = node_def and node_def._vl_projectile and node_def._vl_projectile.on_collide
	if hook then hook(self, pos, node, node_def) end

	-- Play sounds
	local sounds = projectile_def.sounds or {}
	local sound = sounds.on_solid_collision or sounds.on_collision
	if type(sound) == "function" then sound = sound(self, entity_def, projectile_def, "node", pos, node, node_def) end
	if sound then
		local arg2 = table.copy(sound[2])
		arg2.pos = pos
		core.sound_play(sound[1], arg2, sound[3])
	end

	-- Normally objects should be removed on collision with solids
	local survive_collision = projectile_def.survive_collision
	if type(survive_collision) == "function" then
		survive_collision = survive_collision(self, entity_def, projectile_def, "node", node, node_def)
	end
	if not survive_collision then
		mcl_util.remove_entity(self)
	end

	-- Done with behaviors
	return true
end

local function handle_entity_collision(self, entity_def, projectile_def, object)
	-- Arrows stuck in players can't collide with entities
	if self._in_player then return end

	-- Check if this is allowed
	local allow_punching = projectile_def.allow_punching or true
	if type(allow_punching) == "function" then
		allow_punching = allow_punching(self, entity_def, projectile_def, object)
	end
	if not allow_punching then return end

	local pos = self.object:get_pos()
	local dir = vector.normalize(self.object:get_velocity())
	local object_lua = object:get_luaentity()

	-- Allow entities to selectively prevent being hit
	local entity_hook = object_lua and object_lua._vl_projectile and object_lua._vl_projectile.can_punch
	if entity_hook and entity_hook(object_lua, self) == false then
		return
	end

	-- Normally objects should be removed on collision with entities
	local survive_collision = projectile_def.survive_collision

	-- Apply damage
	-- Note: Damage blocking for shields is handled in mcl_shields with an mcl_damage modifier.
	--       We need to know it to avoid setting blocking players on fire and activating collision callbacks.
	local do_damage, object_blocking = false, false
	if object:is_player() and projectile_def.damages_players then
		do_damage = true
		object_blocking = mcl_shields.is_blocking(object)

		if handle_player_sticking(self, entity_def, projectile_def, object) then
			-- Force the projectile to survive if it stuck in a player
			survive_collision = true
		end
	elseif object_lua and (object_lua.is_mob or object_lua._hittable_by_projectile) then
		do_damage = true
	end

	local object_alive = true

	if do_damage then
		-- Get damage
		local dmg = projectile_def.damage_groups or 0
		if type(dmg) == "function" then
			dmg = dmg(self, entity_def, projectile_def, object)
		end

		object:punch(self.object, 1.0, projectile_def.tool or {full_punch_interval = 1.0, damage_groups = dmg}, dir )

		-- Guard against crashes when projectiles get destroyed in response to what it punched
		if self._removed or not self.object:get_pos() then return true end

		-- Guard against crashes when the object the projectile collided with was destroyed
		if (object_lua and object_lua._removed) or not object:get_pos() then object_alive = false end

		-- Indicate damage
		damage_particles(vector.add(pos, vector.multiply(self.object:get_velocity(), 0.1)), self._is_critical)

		-- Light things on fire
		if object_alive and not object_blocking
				and mcl_burning.is_burning(self.object) then
			mcl_burning.set_on_fire(object, 5)
		end
	end

	if not object_blocking then
		-- Call entity collision hook
		local hook = projectile_def.on_collide_with_entity
		if hook then hook(self, pos, object) end

		-- Call reverse entity collision hook
		local other_entity_def = core.registered_entities[object.name] or {}
		local other_entity_vl_projectile = other_entity_def._vl_projectile or {}
		local hook = other_entity_vl_projectile and other_entity_vl_projectile.on_collide
		if hook then hook(object, self) end
	end

	-- Play sounds
	local sounds = projectile_def.sounds or {}
	local sound = sounds.on_entity_collion or sounds.on_collision
	if type(sound) == "function" then sound = sound(self, entity_def, projectile_def, "entity", object) end
	if sound then
		local arg2 = table.copy(sound[2])
		arg2.pos = pos
		core.sound_play(sound[1], arg2, sound[3])
	end

	-- Remove the projectile if it didn't survive
	if type(survive_collision) == "function" then
		survive_collision = survive_collision(self, entity_def, projectile_def, "entity", object)
	end
	if not survive_collision then
		mcl_util.remove_entity(self)
	end

	return true
end

function mod.collides_with_entities(self, dtime, entity_def, projectile_def)
	local pos = self.object:get_pos()

	local objects = core.get_objects_inside_radius(pos, 1.5)
	for i = 1,#objects do
		local object = objects[i]
		local entity = object:get_luaentity()

		if object ~= self.object and (not entity or entity.name ~= self.name) then
			if object:is_player() then
				return handle_entity_collision(self, entity_def, projectile_def, object)
			elseif (entity.is_mob or entity._hittable_by_projectile) then
				return handle_entity_collision(self, entity_def, projectile_def, object)
			end
		end
	end
end

function mod.raycast_collides_with_entities(self, dtime, entity_def, projectile_def)
	local closest_object, closest_distance

	local pos = self.object:get_pos()
	if not pos then return end

	local arrow_dir = self.object:get_velocity()

	--create a raycast from the arrow based on the velocity of the arrow to deal with lag
	local raycast = core.raycast(pos, vector.add(pos, vector.multiply(arrow_dir, 0.1)), true, false)
	for hitpoint in raycast do
		if check_hitpoint(hitpoint) then
			local hitpoint_ref = hitpoint.ref
			local dist = vector.distance(hitpoint_ref:get_pos(), pos)
			if not closest_distance or dist < closest_distance then
				closest_object = hitpoint_ref
				closest_distance = dist
			end
		end
	end

	if closest_object then
		return handle_entity_collision(self, entity_def, projectile_def, closest_object)
	end
end

function mod.create(entity_id, options)
	local pos = options.pos
	local obj = core.add_entity(pos, entity_id, options.staticdata)

	-- Set initial velocity and acceleration
	local a, v
	if options.dir then
		v = vector.multiply(options.dir, options.velocity or 0)
		a = vector.multiply(v, -math.abs(options.drag or 0))
	else
		a = vector.zero()
		v = a
	end
	local entity_def = core.registered_entities[entity_id]
	mod.projectile_physics(obj, entity_def, v, a)

	-- Update projectile parameters
	local luaentity = obj:get_luaentity()
	if options.owner_id then
		luaentity._owner = options.owner_id
	elseif options.owner then
		luaentity._owner = mcl_util.get_entity_id(options.owner)
	end
	luaentity._starting_velocity = obj:get_velocity()
	luaentity._startpos = pos
	luaentity._vl_projectile = {
		extra = options.extra,
	}

	-- And provide the caller with the created object
	return obj
end

function mod.register(name, def)
	local def_vl_projectile = def._vl_projectile
	assert(def_vl_projectile, "vl_projectile.register() requires definition to define _vl_projectile")
	local behaviors = def_vl_projectile.behaviors

	assert(behaviors, "vl_projectile.register() requires definition to define _vl_projectile.behaviors")
	for i = 1,#behaviors do
		assert(behaviors[i] and type(behaviors[i]) == "function", "def._vl_projectile.behaviors["..i.." is malformed")
		if behaviors[i] == vl_projectile.has_owner_grace_distance then
			local old_allow_punching = def_vl_projectile.allow_punching
			if old_allow_punching then
				def_vl_projectile.allow_punching = function(self, ...)
					if not self._allow_punch then return false end

					return old_allow_punching(self, ...)
				end
			else
				def_vl_projectile.allow_punching = function(self, ...)
					if not self._allow_punch then return false end

					return true
				end
			end
		end
	end

	if not def.on_step then
		def.on_step = mod.update_projectile
	end

	def._thrower = nil
	def._shooter = nil
	def._last_pos = nil

	core.register_entity(name, def)
end
