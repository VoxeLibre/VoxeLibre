--[[
mobs.climb = function(self)

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = 0,
		y = DEFAULT_CLIMB_SPEED,
		z = 0,
	}

	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	new_velocity_addition.x = 0
	new_velocity_addition.z = 0

	--smooths out mobs a bit
	if vector.length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end
]]
