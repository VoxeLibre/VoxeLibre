
--[[
 _                     _
| |                   | |
| |     __ _ _ __   __| |
| |    / _` | '_ \ / _` |
| |___| (_| | | | | (_| |
\_____/\__,_|_| |_|\__,_|
]]--

--[[
--this is basically reverse jump_check
local function cliff_check(self, dtime)
	--mobs will flip out if they are falling without this
	if self.object:get_velocity().y ~= 0 then
		return false
	end

	local pos = self.object:get_pos()
    local dir = minetest.yaw_to_dir(self.yaw)
	local collisionbox = self.properties.collisionbox
	local radius = collisionbox[4] + 0.5

	dir = vector.multiply(dir, radius)

	local free_fall, blocker = minetest.line_of_sight(
		{x = pos.x + dir.x, y = pos.y, z = pos.z + dir.z},
		{x = pos.x + dir.x, y = pos.y - self.def.fear_height, z = pos.z + dir.z})

	return free_fall
end

-- state switching logic (stand, walk, run, attacks)
local land_state_list_wandering = {"stand", "walk"}

local function land_state_switch(self, dtime)

	--do math before sure not attacking, following, or running away so continue
	--doing random walking for mobs if all states are not met
	self.state_timer = self.state_timer - dtime

	--only run away
	if self.def.skittish and self.state == "run" then
		self.run_timer = self.run_timer - dtime
		if self.run_timer > 0 then
			return
		end
		--continue
	end

	--ignore everything else if breeding
	if self.breed_lookout_timer and self.breed_lookout_timer > 0 then
		self.state = "breed"
		return
	--reset the state timer to get the mob out of
	--the breed state
	elseif self.state == "breed" then
		self.state_timer = 0
	end

	--ignore everything else if following
	if self:check_following() and self.breed_lookout_timer == 0 and self.breed_timer == 0 then
		self.state = "follow"
		return
	--reset the state timer to get the mob out of
	--the follow state - not the cleanest option
	--but the easiest
	elseif self.state == "follow" then
		self.state_timer = 0
	end

	--only attack
	if self.def.hostile and self.attacking then
		self.state = "attack"
		return
	end

	--if finally reached here then do random wander
	if self.state_timer <= 0 then
		self.state_timer = math.random(4, 10) + math.random()
		self.state = land_state_list_wandering[math.random(1, #land_state_list_wandering)]
	end

end

-- states are executed here
local function land_state_execution(self, dtime)

	--[[ -- this is a debug which shows the timer and makes mobs breed 100 times faster
	print(self.breed_timer)
	if self.breed_timer > 0 then
		self.breed_timer = self.breed_timer - (dtime * 100)
		if self.breed_timer <= 0 then
			self.breed_timer = 0
		end
	end
	] ]--

	--timer to time out looking for mate
	if self.breed_lookout_timer > 0 then
		self.breed_lookout_timer = self.breed_lookout_timer - dtime
		--looking for mate failed
		if self.breed_lookout_timer < 0 then
			self.breed_lookout_timer = 0
		end
	end

	--cool off after breeding
	if self.breed_timer > 0 then
		self.breed_timer = self.breed_timer - dtime
		--do this to skip the first check, using as switch
		if self.breed_timer <= 0 then
			self.breed_timer = 0
		end
	end

	local pos = self.object:get_pos()
	local collisionbox = self.properties.collisionbox
	--get the center of the mob
	pos.y = pos.y + (collisionbox[2] + collisionbox[5] / 2)
	local current_node = minetest.get_node(pos).name
	local float_now = false

	--recheck if in water or lava
	if minetest.get_item_group(current_node, "water") ~= 0 or minetest.get_item_group(current_node, "lava") ~= 0 then
		float_now = true
	end

	--calculate fall damage
	if self.fall_damage then
		self:calculate_fall_damage()
	end

	if self.state == "stand" then

		--do animation
		self:set_animation("stand")

		--set the velocity of the mob
		self:set_velocity(0)

		--animation fixes for explosive mobs
		if self.attack_type == "explode" then
			self:reverse_explosion_animation(dtime)
		end

		self:lock_yaw()
	elseif self.state == "follow" then

		--always look at players
		self:look_at(self.following_person)

		--check distance
		local distance_from_follow_person = vector.distance(self.object:get_pos(), self.following_person:get_pos())
		local distance_2d = mobs.get_2d_distance(self.object:get_pos(), self.following_person:get_pos())

		--don't push the player if too close
		--don't spin around randomly
		if self.follow_distance < distance_from_follow_person and self.minimum_follow_distance < distance_2d then
			self:set_animation("run")
			self:set_velocity(self.run_velocity)

			if self:jump_check() == 1 then
				self:jump(self)
			end
		else
			self:set_mob_animation("stand")
			self:set_velocity(0)
		end

	elseif self.state == "walk" then

		self.walk_timer = self.walk_timer - dtime

		--reset the walk timer
		if self.walk_timer <= 0 then

			--re-randomize the walk timer
			self.walk_timer = math.random(1, 6) + math.random()

			--set the mob into a random direction
			self.yaw = (math.random() * (math.pi * 2))
		end

		--do animation
		self:set_animation("walk")

		--enable rotation locking
		self:movement_rotation_lock()

		--check for nodes to jump over
		local node_in_front_of = self:jump_check()

		if node_in_front_of == 1 then

			self:jump()

		--turn if on the edge of cliff
		--(this is written like this because unlike
		--jump_check which simply tells the mob to jump
		--this requires a mob to turn, removing the
		--ease of a full implementation for it in a single
		--function)
		elseif node_in_front_of == 2 or (self.fear_height ~= 0 and cliff_check(self, dtime)) then
			--turn 45 degrees if so
			quick_rotate(self,dtime)
			--stop the mob so it doesn't fall off
			self:set_velocity(0)
		end

		--only move forward if path is clear
		if node_in_front_of == 0 or node_in_front_of == 1 then
			--set the velocity of the mob
			self:set_velocity(self.walk_velocity)
		end

		--animation fixes for explosive mobs
		if self.attack_type == "explode" then
			self:reverse_explosion_animation(dtime)
		end

	elseif self.state == "run" then

		--do animation
		self:set_animation("run")

		--enable rotation locking
		self:movement_rotation_lock()

		--check for nodes to jump over
		local node_in_front_of = self:jump_check()

		if node_in_front_of == 1 then

			self:jump()

		--turn if on the edge of cliff
		--(this is written like this because unlike
		--jump_check which simply tells the mob to jump
		--this requires a mob to turn, removing the
		--ease of a full implementation for it in a single
		--function)
		elseif node_in_front_of == 2 or (self.fear_height ~= 0 and cliff_check(self, dtime)) then
			--turn 45 degrees if so
			quick_rotate(self, dtime)
			--stop the mob so it doesn't fall off
			self:set_velocity(0)
		end

		--only move forward if path is clear
		if node_in_front_of == 0 or node_in_front_of == 1 then
			--set the velocity of the mob
			self:set_velocity(self.run_velocity)
		end

	elseif self.state == "attack" then

		--execute mob attack type
		if self.attack_type == "explode" then

			self:explode_attack_walk(dtime)

		elseif self.attack_type == "punch" then

			self:punch_attack_walk(dtime)

		elseif self.attack_type == "projectile" then

			self:projectile_attack_walk(dtime)

		end
	elseif self.state == "breed" then

		minetest.add_particlespawner({
			amount = 2,
			time = 0.0001,
			minpos = vector.add(pos, min),
			maxpos = vector.add(pos, max),
			minvel = vector.new(-1,1,-1),
			maxvel = vector.new(1,3,1),
			minexptime = 0.7,
			maxexptime = 1,
			minsize = 1,
			maxsize = 2,
			collisiondetection = false,
			vertical = false,
			texture = "heart.png",
		})

		local mate = self:look_for_mate()

		--found a mate
		if mate then
			self:look_at(mate)
			self:set_velocity(self.walk_velocity)

			--smoosh together basically
			if vector.distance(self.object:get_pos(), mate:get_pos()) <= self.breed_distance then
				self:set_animation("stand")
				if self.special_breed_timer == 0 then
					self.special_breed_timer = 2 --breeding takes 2 seconds
				end

				self.special_breed_timer = self.special_breed_timer - dtime
				if self.special_breed_timer <= 0 then

					--pop a baby out, it's a miracle!
					local baby_pos = vector.divide(vector.add(self.object:get_pos(), mate:get_pos()), 2)
					local baby_mob = minetest.add_entity(pos, self.name, minetest.serialize({baby = true, grow_up_timer = self.grow_up_goal, bred = true}))

					self:play_sound_specific("item_drop_pickup")

					self.special_breed_timer = 0
					self.breed_lookout_timer = 0
					self.breed_timer = self.breed_timer_cooloff

					local mate_entity = mate:get_luaentity()
					mate_entity.special_breed_timer = 0
					mate_entity.breed_lookout_timer = 0
					mate_entity.breed_timer = self.breed_timer_cooloff -- can reuse because it's the same mob
				end
			else
				self:set_animation("walk")
			end
		--couldn't find a mate, just stand there until the player pushes it towards one
		--or the timer runs out
		else
			self:set_mob_animation("stand")
			self:set_velocity(0)
		end

	end

	if float_now then
		self:float()
	else
		local acceleration = self.object:get_acceleration()
		if acceleration and acceleration.y == 0 then
			self.object:set_acceleration(vector.new(0, -self.gravity, 0))
		end
	end
end


-- move mob in facing direction
--this has been modified to be internal
--internal = lua (self.yaw)
--engine = c++ (self.object:get_yaw())
mobs.set_velocity = function(self, v)

	local yaw = (self.yaw or 0)

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = (math.sin(yaw) * -v),
		y = 0,
		z = (math.cos(yaw) * v),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector.length(new_velocity_addition) > vector.length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector.length(goal_velocity) / vector.length(new_velocity_addition)))
	end

	new_velocity_addition.y = 0

	--smooths out mobs a bit
	if vector.length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end



-- calculate mob velocity
mobs.get_velocity = function(self)

	local v = self.object:get_velocity()

	v.y = 0

	if v then
		return vector.length(v)
	end

	return 0
end

--make mobs jump
mobs.jump = function(self, velocity)

    if self.object:get_velocity().y ~= 0 or not self.old_velocity or (self.old_velocity and self.old_velocity.y > 0) then
        return
    end

	--fallback velocity to allow modularity
    velocity = velocity or DEFAULT_JUMP_HEIGHT

    self.object:add_velocity(vector.new(0,velocity,0))
end

--make mobs fall slowly
mobs.mob_fall_slow = function(self)

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = 0,
		y = -2,
		z = 0,
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	new_velocity_addition.x = 0
	new_velocity_addition.z = 0

	if vector.length(new_velocity_addition) > vector.length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector.length(goal_velocity) / vector.length(new_velocity_addition)))
	end

	new_velocity_addition.x = 0
	new_velocity_addition.z = 0

	--smooths out mobs a bit
	if vector.length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end

end

]]--
