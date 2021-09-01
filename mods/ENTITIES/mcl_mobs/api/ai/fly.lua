
--[[
______ _
|  ___| |
| |_  | |_   _
|  _| | | | | |
| |   | | |_| |
\_|   |_|\__, |
          __/ |
         |___/
]]--

--[[
-- state switching logic (stand, walk, run, attacks)
local fly_state_list_wandering = {"stand", "fly"}

local function fly_state_switch(self, dtime)

	if self.hostile and self.attacking then
		self.state = "attack"
		return
	end

	self.state_timer = self.state_timer - dtime
	if self.state_timer <= 0 then
		self.state_timer = math.random(4, 10) + math.random()
		self.state = fly_state_list_wandering[math.random(1, #fly_state_list_wandering)]
	end
end

--check if a mob needs to turn while flying
local function fly_turn_check(self, dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest.yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector.multiply(dir, radius)

    local test_dir = vector.add(pos,dir)

	return minetest.get_item_group(minetest.get_node(test_dir).name, "solid") ~= 0
end

--this is to swap the built in engine acceleration modifier
local function fly_physics_swapper(self, inside_fly_node)

	--should be flyming, gravity is applied, switch to floating
	if inside_fly_node and self.object:get_acceleration().y ~= 0 then
		self.object:set_acceleration(vector.new(0, 0, 0))
	--not be fly, gravity isn't applied, switch to falling
	elseif not inside_fly_node and self.object:get_acceleration().y == 0 then
		self.pitch = 0
		self.object:set_acceleration(vector.new(0, -self.gravity, 0))
	end
end

local random_pitch_multiplier = {-1, 1}
-- states are executed here
local function fly_state_execution(self, dtime)
	local pos = self.object:get_pos()
	pos.y = pos.y + 0.1
	local current_node = minetest.get_node(pos).name
	local inside_fly_node = minetest.get_item_group(current_node, "solid") == 0

	local float_now = false
	--recheck if in water or lava
	if minetest.get_item_group(current_node, "water") ~= 0 or minetest.get_item_group(current_node, "lava") ~= 0 then
		inside_fly_node = false
		float_now = true
	end

	--turn gravity on or off
	fly_physics_swapper(self, inside_fly_node)

	--fly properly if inside fly node
	if inside_fly_node then
		if self.state == "stand" then

			--do animation
			self:set_animation("stand")

			self:set_fly_velocity(0)

			if self.tilt_fly then
				self:set_static_pitch()
			end

			self:lock_yaw()

		elseif self.state == "fly" then

			self.walk_timer = self.walk_timer - dtime

			--reset the walk timer
			if self.walk_timer <= 0 then

				--re-randomize the walk timer
				self.walk_timer = math.random(1, 6) + math.random()

				--set the mob into a random direction
				self.yaw = (math.random() * (math.pi * 2))

				--create a truly random pitch, since there is no easy access to pitch math that I can find
				self.pitch = math.random() * math.random(1, 3) * random_pitch_multiplier[math.random(1,2)]
			end

			--do animation
			self:set_animation("walk")

			--do a quick turn to make mob continuously move
			--if in a bird cage or something
			if fly_turn_check(self, dtime) then
				quick_rotate(self, dtime)
			end

			if self.tilt_fly then
				self:set_dynamic_pitch()
			end

			self:set_fly_velocity(self.walk_velocity)

			--enable rotation locking
			self:movement_rotation_lock()

		elseif self.state == "attack" then

			--execute mob attack type
			--if self.attack_type == "explode" then

				--mobs.explode_attack_fly(self, dtime)

			--elseif self.attack_type == "punch" then

				--mobs.punch_attack_fly(self,dtime)

			if self.attack_type == "projectile" then

				self:projectile_attack_fly(dtime)

			end
		end
	else
		--make the mob float
		if self.floats and float_now then
			self:set_velocity(0)

			self:float()

			if self.tilt_fly then
				self:set_static_pitch()
			end
		end
	end
end


-- move mob in facing direction
--this has been modified to be internal
--internal = lua (self.yaw)
--engine = c++ (self.object:get_yaw())
mobs.set_fly_velocity = function(self, v)

	local yaw = (self.yaw or 0)
	local pitch = (self.pitch or 0)

	if v == 0 then
		pitch = 0
	end

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = (math.sin(yaw) * -v),
		y = pitch,
		z = (math.cos(yaw) * v),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector.length(new_velocity_addition) > vector.length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector.length(goal_velocity) / vector.length(new_velocity_addition)))
	end

	--smooths out mobs a bit
	if vector.length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end

--a quick and simple pitch calculation between two vector positions
mobs.calculate_pitch = function(pos1, pos2)

	if pos1 == nil or pos2 == nil then
		return false
	end

    return(minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos1.x,0,pos1.z),vector.new(pos2.x,0,pos2.z)),0,pos1.y - pos2.y)) + HALF_PI)
end

--make mobs fly up or down based on their y difference
mobs.set_pitch_while_attacking = function(self)
	local pos1 = self.object:get_pos()
	local pos2 = self.attacking:get_pos()

	local pitch = mobs.calculate_pitch(pos2,pos1)

	self.pitch = pitch
end
]]--
