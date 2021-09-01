
--[[
 _____          _
/  ___|        (_)
\ `--.__      ___ _ __ ___
 `--. \ \ /\ / / | '_ ` _ \
/\__/ /\ V  V /| | | | | | |
\____/  \_/\_/ |_|_| |_| |_|
]]--

--[[

-- state switching logic (stand, walk, run, attacks)
local swim_state_list_wandering = {"stand", "swim"}

local function swim_state_switch(self, dtime)
	self.state_timer = self.state_timer - dtime
	if self.state_timer <= 0 then
		self.state_timer = math.random(4,10) + math.random()
		self.state = swim_state_list_wandering[math.random(1, #swim_state_list_wandering)]
	end
end

--check if a mob needs to turn while swimming
local swim_turn_check = function(self,dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest_yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector.multiply(dir, radius)

    local test_dir = vector.add(pos,dir)

	return minetest_get_item_group(minetest_get_node(test_dir).name, "solid") ~= 0
end

--this is to swap the built in engine acceleration modifier
local function swim_physics_swapper(self, inside_swim_node)

	--should be swimming, gravity is applied, switch to floating
	if inside_swim_node and self.object:get_acceleration().y ~= 0 then
		self.object:set_acceleration(vector.new(0, 0, 0))
	--not be swim, gravity isn't applied, switch to falling
	elseif not inside_swim_node and self.object:get_acceleration().y == 0 then
		self.pitch = 0
		self.object:set_acceleration(vector.new(0, -self.gravity, 0))
	end
end

local random_pitch_multiplier = {-1,1}
-- states are executed here
local function swim_state_execution(self, dtime)

	local pos = self.object:get_pos()

	pos.y = pos.y + self.object:get_properties().collisionbox[5]
	local current_node = minetest_get_node(pos).name
	local inside_swim_node = false

	--quick scan everything to see if inside swim node
	for _,id in pairs(self.swim_in) do
		if id == current_node then
			inside_swim_node = true
			break
		end
	end

	--turn gravity on or off
	swim_physics_swapper(self, inside_swim_node)

	--swim properly if inside swim node
	if inside_swim_node then

		if self.state == "stand" then

			--do animation
			self:set_animation("stand")

			self:set_swim_velocity(0)

			if self.tilt_swim then
				self:set_static_pitch()
			end

			self:lock_yaw()

		elseif self.state == "swim" then

			self.walk_timer = self.walk_timer - dtime

			--reset the walk timer
			if self.walk_timer <= 0 then

				--re-randomize the walk timer
				self.walk_timer = math.random(1, 6) + math.random()

				--set the mob into a random direction
				self.yaw = (math.random() * (math.pi * 2))

				--create a truly random pitch, since there is no easy access to pitch math that I can find
				self.pitch = math.random() * math.random(1, 3) * random_pitch_multiplier[math.random(1, 2)]
			end

			--do animation
			self:set_animation("walk")

			--do a quick turn to make mob continuously move
			--if in a fish tank or something
			if swim_turn_check(self, dtime) then
				quick_rotate(self, dtime)
			end

			self:set_swim_velocity(self.walk_velocity)

			--only enable tilt swimming if enabled
			if self.tilt_swim then
				self:set_dynamic_pitch()
			end

			--enable rotation locking
			self:movement_rotation_lock()
		end
	--flop around if not inside swim node
	else
		--do animation
		self:set_mob_animation("stand")

		self:flop()

		if self.tilt_swim then
			self:set_static_pitch()
		end
	end

end


--make mobs flop
mobs.flop = function(self, velocity)

    if self.object:get_velocity().y ~= 0 or not self.old_velocity or (self.old_velocity and self.old_velocity.y > 0) then
        return false
    end

	mobs.set_velocity(self, 0)

	--fallback velocity to allow modularity
    velocity = velocity or DEFAULT_JUMP_HEIGHT

	--create a random direction (2d yaw)
	local dir = DOUBLE_PI * math.random()

	--create a random force value
	local force = math.random(0,3) + math.random()

	--convert the yaw to a direction vector then multiply it times the force
	local final_additional_force = vector.multiply(minetest_yaw_to_dir(dir), force)

	--place in the "flop" velocity to make the mob flop
	final_additional_force.y = velocity

    self.object:add_velocity(final_additional_force)

	return true
end



-- move mob in facing direction
--this has been modified to be internal
--internal = lua (self.yaw)
--engine = c++ (self.object:get_yaw())
mobs.set_swim_velocity = function(self, v)

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
]]--
