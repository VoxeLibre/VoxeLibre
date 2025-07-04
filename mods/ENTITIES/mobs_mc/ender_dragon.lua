--###################
--################### ENDERDRAGON
--###################
local S = minetest.get_translator("mobs_mc")

local BEAM_CHECK_FREQUENCY = 1
local POS_CHECK_FREQUENCY = 15
local HEAL_INTERVAL = 1
local HEAL_AMOUNT = 2

-- Rewrite for dragon attack phases and complex circling by Thomas Conway (c.2025)
-- Movement constants
local CIRCLE_RADIUS = 35 -- Radius for circling the portal
local CIRCLE_HEIGHT = 25 -- Height above portal when circling
local ATTACK_COOLDOWN = 8 -- Seconds between attack attempts
local FIREBALL_PHASE_DURATION = 4 -- How long to shoot fireballs after charge
local CHARGE_SPEED = 16 -- Speed during charge attack
local NORMAL_SPEED = 8 -- Normal flight speed
local BREATH_ATTACK_CHANCE = 0.3 -- Chance to use breath attack instead of charge
local MIN_CHARGE_TIME = 2 -- Minimum charge duration in seconds

local function check_beam(self)
	for _, obj in ipairs(minetest.get_objects_inside_radius(self.object:get_pos(), 80)) do
		local luaentity = obj:get_luaentity()
		if luaentity and luaentity.name == "mcl_end:crystal" then
			if luaentity.beam then
				if luaentity.beam == self.beam then
					break
				end
			else
				if self.beam then
					self.beam:remove()
				end
				minetest.add_entity(self.object:get_pos(), "mcl_end:crystal_beam"):get_luaentity():init(self.object, obj)
				break
			end
		end
	end
end

local function check_pos(self)
	if self._portal_pos then
		-- migrate old format
		if type(self._portal_pos) == "string" then
			self._portal_pos = minetest.string_to_pos(self._portal_pos)
		end
		local portal_center = vector.add(self._portal_pos, vector.new(0, 11, 0))
		local pos = self.object:get_pos()
		if vector.distance(pos, portal_center) > 50 then
			self.object:set_pos(self._last_good_pos or portal_center)
		else
			self._last_good_pos = pos
		end
	end
end

-- Get the center point for circling (portal position + height)
local function get_circle_center(self)
	if not self._portal_pos then
		return self.object:get_pos() -- Fallback to current position
	end
	return vector.add(self._portal_pos, vector.new(0, CIRCLE_HEIGHT, 0))
end

-- Make the dragon circle around the portal
local function do_circle_movement(self)
	local center = get_circle_center(self)
	local pos = self.object:get_pos()

	-- Calculate angle based on time for smooth circling
	self._circle_angle = (self._circle_angle or 0) + 0.015 -- Adjust speed of circling
	if self._circle_angle > math.pi * 2 then
		self._circle_angle = self._circle_angle - math.pi * 2
	end

	-- Calculate target position on circle
	local target_x = center.x + math.sin(self._circle_angle) * CIRCLE_RADIUS
	local target_z = center.z + math.cos(self._circle_angle) * CIRCLE_RADIUS
	local target_y = center.y + math.sin(self._circle_angle * 2) * 3 -- Slight vertical movement

	local target = vector.new(target_x, target_y, target_z)

	-- Move towards target position
	local dir = vector.direction(pos, target)
	local vel = vector.multiply(dir, NORMAL_SPEED)

	self.object:set_velocity(vel)

	-- Face movement direction
	local yaw = math.atan2(vel.x, vel.z)
	self.object:set_yaw(yaw)
end

-- Charge attack at player
local function do_charge_attack(self, target_pos)
	local pos = self.object:get_pos()

	-- Aim lower than the player to ensure hit (account for collision box)
	local adjusted_target = vector.new(target_pos.x, target_pos.y - 2, target_pos.z)

	local dir = vector.direction(pos, adjusted_target)
	local vel = vector.multiply(dir, CHARGE_SPEED)

	self.object:set_velocity(vel)

	-- Face target
	local yaw = math.atan2(dir.x, dir.z)
	self.object:set_yaw(yaw)
end

-- Breath attack - slower approach with continuous damage
local function do_breath_attack(self, target_pos)
	local pos = self.object:get_pos()

	-- Approach slowly while breathing fire
	local adjusted_target = vector.new(target_pos.x, target_pos.y + 5, target_pos.z)
	local dir = vector.direction(pos, adjusted_target)
	local vel = vector.multiply(dir, NORMAL_SPEED * 0.5) -- Slower for breath attack

	self.object:set_velocity(vel)

	-- Face target
	local yaw = math.atan2(dir.x, dir.z)
	self.object:set_yaw(yaw)

	-- Spawn poison/fire particles (simplified breath attack)
	if math.random() < 0.3 then
		local breath_pos = vector.add(pos, vector.multiply(dir, 3))
		minetest.add_particlespawner({
			amount = 20,
			time = 0.1,
			minpos = breath_pos,
			maxpos = breath_pos,
			minvel = vector.multiply(dir, 5),
			maxvel = vector.multiply(dir, 8),
			minacc = {x=0, y=-0.5, z=0},
			maxacc = {x=0, y=-0.5, z=0},
			minexptime = 1,
			maxexptime = 2,
			minsize = 2,
			maxsize = 4,
			texture = "mcl_particles_dragon_breath.png",
		})

		-- Breath attack damage
		local players = minetest.get_objects_inside_radius(breath_pos, 8)
		for _, player in ipairs(players) do
			if player:is_player() then
				player:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 6},
				})
				-- Apply poison effect (MineClone2 specific)
				if minetest.get_modpath("mcl_effects") then
					mcl_effects.add_effect(player, "poison", 10, 2)
				end
			end
		end
	end

	-- End breath attack after getting close
	if vector.distance(pos, target_pos) < 8 then
		self._attack_phase = "retreat"
		self._retreat_timer = 0
	end
end

-- Fly up after charge attack
local function do_retreat_movement(self)
	local center = get_circle_center(self)
	local pos = self.object:get_pos()

	-- Fly up and toward a circle position
	local retreat_angle = self._circle_angle + math.pi * 0.5 -- Go to a different part of circle
	local target_x = center.x + math.sin(retreat_angle) * CIRCLE_RADIUS
	local target_z = center.z + math.cos(retreat_angle) * CIRCLE_RADIUS
	local target = vector.new(target_x, center.y + 10, target_z)

	local dir = vector.direction(pos, target)
	local vel = vector.multiply(dir, NORMAL_SPEED * 1.2)
	self.object:set_velocity(vel)

	-- Face movement direction
	local yaw = math.atan2(vel.x, vel.z)
	self.object:set_yaw(yaw)

	self._retreat_timer = (self._retreat_timer or 0) + 0.05

	-- After retreating for a bit, switch to fireball phase
	if self._retreat_timer > 2 then
		self._attack_phase = "fireball"
		self._fireball_timer = 0
		self._fireball_shoot_timer = 0
	end
end

-- Hover and shoot fireballs
local function do_fireball_attack(self)
	local pos = self.object:get_pos()

	-- Continue circling but at a higher altitude during fireball phase
	self._circle_angle = (self._circle_angle or 0) + 0.01
	local center = get_circle_center(self)
	center.y = center.y + 10 -- Higher during fireball phase

	local target_x = center.x + math.sin(self._circle_angle) * CIRCLE_RADIUS
	local target_z = center.z + math.cos(self._circle_angle) * CIRCLE_RADIUS
	local target = vector.new(target_x, center.y, target_z)

	local dir = vector.direction(pos, target)
	local vel = vector.multiply(dir, NORMAL_SPEED * 0.7) -- Slower while shooting
	self.object:set_velocity(vel)

	-- Face the player if we have a target
	if self.attack then
		local target_pos = self.attack:get_pos()
		if target_pos then
			local look_dir = vector.direction(pos, target_pos)
			local yaw = math.atan2(look_dir.x, look_dir.z)
			self.object:set_yaw(yaw)

			-- Manually shoot fireballs
			self._fireball_shoot_timer = (self._fireball_shoot_timer or 0) + 0.05
			if self._fireball_shoot_timer > 0.5 then -- Shoot every 0.5 seconds
				self._fireball_shoot_timer = 0

				-- Spawn fireball
				local fireball_pos = vector.add(pos, vector.multiply(look_dir, 3))
				local obj = minetest.add_entity(fireball_pos, "mobs_mc:dragon_fireball")
				if obj then
					local fireball_dir = vector.direction(fireball_pos, target_pos)
					local velocity = 6
					obj:set_velocity(vector.multiply(fireball_dir, velocity))
					obj:set_acceleration({x=0, y=0, z=0})
				end
			end
		end
	end

	self._fireball_timer = (self._fireball_timer or 0) + 0.05

	-- Return to circling after fireball phase
	if self._fireball_timer > FIREBALL_PHASE_DURATION then
		self._attack_phase = "circle"
		self._attack_cooldown = ATTACK_COOLDOWN
	end
end

mcl_mobs.register_mob("mobs_mc:enderdragon", {
	description = S("Ender Dragon"),
	type = "monster",
	spawn_class = "hostile",
	pathfinding = 1,
	attacks_animals = true,
	walk_chance = 100,
	initial_properties = {
		hp_max = 200,
		hp_min = 200,
		collisionbox = {-2, 3, -2, 2, 5, 2},
	},
	xp_min = 500,
	xp_max = 500,
	physical = false,
	visual = "mesh",
	mesh = "mobs_mc_dragon.b3d",
	textures = {
		{"mobs_mc_dragon.png"},
	},
	visual_size = {x=3, y=3},
	view_range = 64,
	walk_velocity = 6,
	run_velocity = 6,
	can_despawn = false,
	sounds = {
		-- TODO: more sounds
		shoot_attack = "mobs_mc_ender_dragon_shoot",
		attack = "mobs_mc_ender_dragon_attack",
		distance = 60,
	},
	physical = true,
	damage = 10,
	knock_back = false,
	jump = true,
	jump_height = 14,
	fly = true,
	makes_footstep_sound = false,
	dogshoot_switch = 1,
	dogshoot_count_max =5,
	dogshoot_count2_max = 5,
	passive = false,
	attack_animals = true,
	lava_damage = 0,
	fire_damage = 0,
	on_rightclick = nil,
	attack_type = "dogshoot",
	arrow = "mobs_mc:dragon_fireball",
	shoot_interval = 0.5,
	shoot_offset = -1.0,
	xp_min = 500,
	xp_max = 500,
	animation = {
		fly_speed = 8, stand_speed = 8,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	ignores_nametag = true,

	-- Override the standard movement and attacking
	do_states = function(self, dtime)
		-- Dragon has custom movement, don't use standard states
		return true
	end,

	-- Disable standard attack routine
	set_state = function(self, state)
		-- Prevent standard state changes
	end,

	do_custom = function(self, dtime)
		-- Timer updates
		if self._pos_timer == nil or self._pos_timer > POS_CHECK_FREQUENCY then
			self._pos_timer = 0
			check_pos(self)
		end
		if self._beam_timer == nil or self._beam_timer > BEAM_CHECK_FREQUENCY then
			self._beam_timer = 0
			check_beam(self)
		end

		self._beam_timer = self._beam_timer + dtime
		self._pos_timer = self._pos_timer + dtime

		-- Healing from crystals
		if self.beam ~= nil then
			self._heal_timer = (self._heal_timer or 0) + dtime
			if self._heal_timer > HEAL_INTERVAL then
				self.health = math.min(self.initial_properties.hp_max, self.health + HEAL_AMOUNT)
				self._heal_timer = self._heal_timer - HEAL_INTERVAL
			end
		end

		-- Contact damage implementation
		local contact_damage_timer = self._contact_damage_timer or 0
		contact_damage_timer = contact_damage_timer + dtime
		if contact_damage_timer >= 0.5 then
			self._contact_damage_timer = 0
			local pos = self.object:get_pos()
			local players = minetest.get_objects_inside_radius(pos, 4)
			for _, player in ipairs(players) do
				if player:is_player() then
					player:punch(self.object, 1.0, {
						full_punch_interval = 1.0,
						damage_groups = {fleshy = 10},
					})
				end
			end
		else
			self._contact_damage_timer = contact_damage_timer
		end

		-- Update boss bar
		mcl_bossbars.update_boss(self.object, "Ender Dragon", "light_purple")

		-- Initialize attack phase if not set
		if not self._attack_phase then
			self._attack_phase = "circle"
		end

		-- Check for players in range
		local player_in_range = false
		local closest_player = nil
		local closest_dist = 100

		local pos = self.object:get_pos()
		for _, player in pairs(minetest.get_connected_players()) do
			local player_pos = player:get_pos()
			local dist = vector.distance(pos, player_pos)
			if dist < self.view_range and dist < closest_dist then
				closest_player = player
				closest_dist = dist
				player_in_range = true
			end
		end

		-- Update attack target
		if player_in_range and closest_player then
			self.attack = closest_player
		else
			self.attack = nil
			-- Always return to circling when no players in range
			self._attack_phase = "circle"
			self._attack_cooldown = 0
		end

		-- Attack cooldown
		if self._attack_cooldown and self._attack_cooldown > 0 then
			self._attack_cooldown = self._attack_cooldown - dtime
		end

		-- Movement behavior based on phase
		if self._attack_phase == "circle" then
			do_circle_movement(self)

			-- Start attack if player in range and cooldown expired
			if self.attack and (not self._attack_cooldown or self._attack_cooldown <= 0) then
				if math.random() < 0.015 then -- Lower chance for less frequent attacks
					if math.random() < BREATH_ATTACK_CHANCE then
						self._attack_phase = "breath"
					else
						self._attack_phase = "charge"
					end
					self._charge_target = self.attack:get_pos()
					self._charge_timer = 0
				end
			end

		elseif self._attack_phase == "charge" then
			if self._charge_target and self.attack then
				-- Update target position for moving players
				self._charge_target = self.attack:get_pos()
				do_charge_attack(self, self._charge_target)

				-- Update charge timer
				self._charge_timer = (self._charge_timer or 0) + dtime

				-- Charge for at least MIN_CHARGE_TIME before checking distance
				local pos = self.object:get_pos()
				if self._charge_timer >= MIN_CHARGE_TIME and
				   (vector.distance(pos, self._charge_target) < 10 or pos.y < self._charge_target.y) then
					self._attack_phase = "retreat"
					self._retreat_timer = 0
					self._charge_timer = nil
				end
			else
				self._attack_phase = "circle"
				self._charge_timer = nil
			end

		elseif self._attack_phase == "breath" then
			if self._charge_target and self.attack then
				-- Update target position for moving players
				self._charge_target = self.attack:get_pos()
				do_breath_attack(self, self._charge_target)
			else
				self._attack_phase = "circle"
			end

		elseif self._attack_phase == "retreat" then
			do_retreat_movement(self)

		elseif self._attack_phase == "fireball" then
			do_fireball_attack(self)
		end

		-- Always ensure some movement to prevent getting stuck
		local vel = self.object:get_velocity()
		if vector.length(vel) < 1 then
			self._attack_phase = "circle"
			self._circle_angle = (self._circle_angle or 0) + 0.5 -- Jump ahead in circle
		end

		return false -- Allow other processing to continue
	end,

	on_die = function(self, pos, cmi_cause)
		if self._portal_pos then
			mcl_portals.spawn_gateway_portal()
			mcl_structures.place_structure(self._portal_pos,mcl_structures.registered_structures["end_exit_portal_open"],PseudoRandom(minetest.get_mapgen_setting("seed")),-1)
			if self._initial then
				mcl_experience.throw_xp(pos, 11500) -- 500 + 11500 = 12000
				minetest.set_node(vector.add(self._portal_pos, vector.new(0, 5, 0)), {name = "mcl_end:dragon_egg"})
			end
		end

		-- Free The End Advancement
		for _,players in pairs(minetest.get_objects_inside_radius(pos,64)) do
			if players:is_player() then
				awards.unlock(players:get_player_name(), "mcl:freeTheEnd")
			end
		end
	end,
	fire_resistant = true,
	is_boss = true,
})


local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

-- dragon fireball (projectile)
mcl_mobs.register_arrow("mobs_mc:dragon_fireball", {
	visual = "sprite",
	visual_size = {x = 1.25, y = 1.25},
	textures = {"mobs_mc_dragon_fireball.png"},
	velocity = 6,
	_vl_projectile = {
		damage_groups = {fleshy = 12}
	},

	hit_player = function(self, player)
	end,

	hit_mob = function(self, mob)
		core.sound_play("tnt_explode", {pos = mob:get_pos(), gain = 1.5, max_hear_distance = 2*64}, true)
	end,

	-- node hit, explode
	hit_node = function(self, pos, node)
		mcl_mobs.mob_class.boom(self,pos, 2)
	end
})

mcl_mobs.register_egg("mobs_mc:enderdragon", S("Ender Dragon"), "#252525", "#b313c9", 0, true)


mcl_wip.register_wip_item("mobs_mc:enderdragon")
mcl_mobs:non_spawn_specific("mobs_mc:enderdragon","overworld",0,minetest.LIGHT_MAX+1)