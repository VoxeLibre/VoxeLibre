local math_pi     = math.pi
local math_sin    = math.sin
local math_cos    = math.cos
local math_random = math.random
local DOUBLE_PI   = math_pi * 2

-- localize vector functions
local vector_new      = vector.new
local vector_length   = vector.length
local vector_multiply = vector.multiply

local minetest_yaw_to_dir = minetest.yaw_to_dir

-- move mob in facing direction
--this has been modified to be internal
--internal = lua (self.yaw)
--engine = c++ (self.object:get_yaw())
mobs.set_velocity = function(self, v)
	
	local yaw = (self.yaw or 0)

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = (math_sin(yaw) * -v),
		y = 0,
		z = (math_cos(yaw) * v),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector_length(new_velocity_addition) > vector_length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector_length(goal_velocity) / vector_length(new_velocity_addition)))
	end

	new_velocity_addition.y = 0

	--smooths out mobs a bit
	if vector_length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end



-- calculate mob velocity
mobs.get_velocity = function(self)

	local v = self.object:get_velocity()

	v.y = 0

	if v then
		return vector_length(v)
	end

	return 0
end

--make mobs jump
mobs.jump = function(self, velocity)

    if self.object:get_velocity().y ~= 0 or not self.old_velocity or (self.old_velocity and self.old_velocity.y > 0) then
        return
    end

	--fallback velocity to allow modularity
    velocity = velocity or 8

    self.object:add_velocity(vector_new(0,velocity,0))    
end

--make mobs flop
mobs.flop = function(self, velocity)

    if self.object:get_velocity().y ~= 0 or not self.old_velocity or (self.old_velocity and self.old_velocity.y > 0) then
        return false
    end

	mobs.set_velocity(self, 0)

	--fallback velocity to allow modularity
    velocity = velocity or 8

	--create a random direction (2d yaw)
	local dir = DOUBLE_PI * math_random()

	--create a random force value
	local force = math_random(0,3) + math_random()

	--convert the yaw to a direction vector then multiply it times the force
	local final_additional_force = vector_multiply(minetest_yaw_to_dir(dir), force)

	--place in the "flop" velocity to make the mob flop
	final_additional_force.y = velocity	

    self.object:add_velocity(final_additional_force)

	return true
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
		x = (math_sin(yaw) * -v),
		y = pitch,
		z = (math_cos(yaw) * v),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector_length(new_velocity_addition) > vector_length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector_length(goal_velocity) / vector_length(new_velocity_addition)))
	end

	--smooths out mobs a bit
	if vector_length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end