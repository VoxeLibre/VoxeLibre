local mod = mcl_physics

local registered_environment_effects = {}

function mod.register_enviornment_effect(effect)
	local list = registered_effects
	list[#list + 1] = effect
end

function mod.get_environment_effect(pos, vel, staticdata, mass)
	local v = vector.new(0,0,0)
	local a = vector.new(0,0,0)

	-- Accumulate all enviornmental effects
	for _,effect in ipairs(registered_environment_effects) do
		local dv,da = effect(pos, vel, staticdata)
		if dv then
			v = v + dv
		end
		if da then
			a = a + da
		end
	end

	if vector.length(v) > 0.01 or vector.length(a) > vector.length(a) > 0.01 then
		return v,a
	else
		return -- nil,nil
	end
end

function mod.apply_entity_environmental_physics(self, data)
	data = data or {}

	local pos = self.object:get_pos()
	local vel = self.object:get_velocity()
	local new_velocity,new_acceleration = mcl_physics.get_environment_effect(pos, vel, data, 1)

	-- Update entity states
	self._flowing = data.flowing

	-- Apply environmental effects if there are any
	if new_velocity or new_acceleration then
		if new_acceleration then self.object:set_acceleration(new_acceleration) end
		if new_velocity then self.object:set_velocity(new_velocity) end

		self.physical_state = true
		self._flowing = true
		self.object:set_properties({
			physical = true
		})
	end
end
