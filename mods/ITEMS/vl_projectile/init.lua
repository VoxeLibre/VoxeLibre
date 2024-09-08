local mod = {}
vl_projectile = mod

local vl_physics_path = minetest.get_modpath("vl_physics")

local YAW_OFFSET = -math.pi/2
local GRAVITY = tonumber(minetest.settings:get("movement_gravity"))
local enable_pvp = minetest.settings:get_bool("enable_pvp")

local function dir_to_pitch(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

function mod.projectile_physics(obj, entity_def, v, a)
	local le = obj:get_luaentity()
	local entity_def = minetest.registered_entities[le.name]
	local pos = obj:get_pos()
	if not pos then return end

	if vl_physics_path then
		v,a = vl_physics.apply_entity_environmental_physics(obj)
	else
		-- Simple physics
		v = v or obj:get_velocity()
		a = a or vector.zero()

		if not entity_def.ignore_gravity then
			a = a + vector.new(0,-GRAVITY,0)
		end

		if entity_def.liquid_drag then
			local def = minetest.registered_nodes[minetest.get_node(pos).name]
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
		local yaw = minetest.dir_to_yaw(v) + YAW_OFFSET
		local pitch = dir_to_pitch(v)
		obj:set_rotation(vector.new(0,yaw,pitch))
	end
end

function mod.update_projectile(self, dtime)
	if self._removed then return end

	local entity_name = self.name
	local entity_def = minetest.registered_entities[entity_name] or {}
	local entity_vl_projectile = entity_def._vl_projectile or {}

	-- Update entity timer
	self.timer = (self.timer or 0) + dtime

	-- Run behaviors
	local behaviors = entity_vl_projectile.behaviors or {}
	for i=1,#behaviors do
		if behaviors[i](self, dtime, entity_def, entity_vl_projectile) then
			return
		end
	end

	mod.projectile_physics(self.object, entity_def)
end

local function damage_particles(pos, is_critical)
	if is_critical then
		minetest.add_particlespawner({
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

	if not hitpoint.ref:is_player() and hitpoint.ref:get_luaentity() then
		if (hitpoint.ref:get_luaentity().is_mob or hitpoint.ref:get_luaentity()._hittable_by_projectile) then
			return true
		end
	end

	return false
end
local function handle_player_sticking(self, entity_def, projectile_def, entity)
	if self._in_player or self._blocked then return end
	if not projectile_def.sticks_in_players then return end

	minetest.after(150, function()
		self._removed = true
		self.object:remove()
	end)

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
end

function mod.collides_with_solids(self, dtime, entity_def, projectile_def)
	local pos = self.object:get_pos()
	if not pos then return end

	-- Don't try to do anything on first update
	if not self._last_pos then
		self._last_pos = pos
		return
	end

	-- Check if the object can collide with this node
	local node = minetest.get_node(pos)
	local node_def = minetest.registered_nodes[node.name]
	local collides_with = projectile_def.collides_with

	if entity_def.physical then
		-- Projectile has stopped in one axis, so it probably hit something.
		-- This detection is a bit clunky, but sadly, MT does not offer a direct collision detection for us. :-(
		local vel = self.object:get_velocity()
		if math.abs(vel.x) >= 0.0001 and math.abs(vel.z) >= 0.0001 and math.abs(vel.y) >= 0.0001 then
			self._last_pos = pos
			return
		end
	else
		if node_def and not node_def.walkable and (not collides_with or not mcl_util.match_node_to_filter(node.name, collides_with)) then
			self._last_pos = pos
			return
		end
	end

	-- Call entity collied hook
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
		minetest.sound_play(sound[1], arg2, sound[3])
	end

	-- Normally objects should be removed on collision with solids
	if not projectile_def.survive_collision then
		self._removed = true
		self.object:remove()
	end

	-- Done with behaviors
	return true
end

local function handle_entity_collision(self, entity_def, projectile_def, object)
	local pos = self.object:get_pos()
	local dir = vector.normalize(self.object:get_velocity())
	local self_vl_projectile = self._vl_projectile

	-- Allow punching
	local allow_punching = projectile_def.allow_punching or true
	if type(allow_punching) == "function" then
		allow_punching = allow_punching(self, entity_def, projectile_def, object)
	end

	if allow_punching then
		-- Get damage
		local dmg = projectile_def.damage_groups or 0
		if type(dmg) == "function" then
			dmg = dmg(self, entity_def, projectile_def, object)
		end

		local object_lua = object:get_luaentity()

		-- Apply damage
		-- Note: Damage blocking for shields is handled in mcl_shields with an mcl_damage modifier
		local do_damage = false
		if object:is_player() and projectile_def.damanges_players and self_vl_projectile.owner ~= object:get_player_name() then
			do_damage = true

			handle_player_sticking(self, entity_def, projectile_def, object)
		elseif object_lua and (object_lua.is_mob or object_lua._hittable_by_projectile) and self_vl_projectile.owner ~= object then
			do_damage = true
		end

		if do_damage then
			object:punch(self.object, 1.0, projectile_def.tool or { full_punch_interval = 1.0, damage_groups = dmg }, dir )

			-- Indicate damage
			damage_particles(vector.add(pos, vector.multiply(self.object:get_velocity(), 0.1)), self._is_critical)

			-- Light things on fire
			if mcl_burning.is_burning(self.object) then
				mcl_burning.set_on_fire(obj, 5)
			end
		end
	end

	-- Call entity collision hook
	local hook = projectile_def.on_collide_with_entity
	if hook then hook(self, pos, object) end

	-- Call reverse entity collision hook
	local other_entity_def = minetest.registered_entities[object.name] or {}
	local other_entity_vl_projectile = other_entity_def._vl_projectile or {}
	local hook = other_entity_vl_projectile and other_entity_vl_projectile.on_collide
	if hook then hook(object, self) end

	-- Play sounds
	local sounds = projectile_def.sounds or {}
	local sound = sounds.on_entity_collion or sounds.on_collision
	if type(sound) == "function" then sound = sound(self, entity_def, projectile_def, "entity", object) end
	if sound then
		local arg2 = table.copy(sound[2])
		arg2.pos = pos
		minetest.sound_play(sound[1], arg2, sound[3])
	end

	-- Normally objects should be removed on collision with entities
	if not projectile_def.survive_collision then
		self._removed = true
		self.object:remove()
	end

	return true
end

function mod.collides_with_entities(self, dtime, entity_def, projectile_def)
	local pos = self.object:get_pos()

	local hit = nil
	local owner = self._vl_projectile.owner

	local objects = minetest.get_objects_inside_radius(pos, 1.5)
	for i = 1,#objects do
		local object = objects[i]
		local entity = object:get_luaentity()

		if entity and entity.name ~= self.object:get_luaentity().name then
			if object:is_player() and owner ~= object:get_player_name() then
				return handle_entity_collision(self, entity_def, projectile_def, object)
			elseif (entity.is_mob or entity._hittable_by_projectile) and owner ~= object then
				return handle_entity_collision(self, entity_def, projectile_def, object)
			end
		end
	end
end

function mod.raycast_collides_with_entities(self, dtime, entity_def, projectile_def)
	local closest_object, closest_distance

	local pos = self.object:get_pos()
	local arrow_dir = self.object:get_velocity()

	--create a raycast from the arrow based on the velocity of the arrow to deal with lag
	local raycast = minetest.raycast(pos, vector.add(pos, vector.multiply(arrow_dir, 0.1)), true, false)
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
	local obj = minetest.add_entity(pos, entity_id, options.staticdata)

	-- Set initial velocity and acceleration
	local a, v
	if options.dir then
		v = vector.multiply(options.dir, options.velocity or 0)
		a = vector.multiply(v, -math.abs(options.drag))
	else
		a = vector.zero()
		v = a
	end
	mod.projectile_physics(obj, entity_def, v, a)

	-- Update projectile parameters
	local luaentity = obj:get_luaentity()
	luaentity._vl_projectile = {
		owner = options.owner,
		extra = options.extra,
	}

	-- And provide the caller with the created object
	return obj
end

function mod.register(name, def)
	assert(def._vl_projectile)
	local behaviors = def._vl_projectile.behaviors
	for i = 1,#behaviors do
		assert(behaviors[i])
	end

	if not def.on_step then
		def.on_step = mod.update_projectile
	end

	def._thrower = nil
	def._shooter = nil
	def._last_pos = nil

	minetest.register_entity(name, def)
end

