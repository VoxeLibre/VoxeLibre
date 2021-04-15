local math_pi     = math.pi
local math_sin    = math.sin
local math_cos    = math.cos

-- localize vector functions
local vector_new    = vector.new
local vector_length = vector.length

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