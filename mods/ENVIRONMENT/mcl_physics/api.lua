local mod = mcl_physics

local registered_environment_effects = {}

function mod.register_environment_effect(effect)
	local list = registered_environment_effects
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

	-- Disable small effects
	if vector.length(v) < 0.01 then v = nil end
	if vector.length(a) < 0.01 then a = nil end

	return v,a
end

function mod.apply_entity_environmental_physics(self, data)
	data = data or {}

	local pos = self.object:get_pos()
	local vel = self.object:get_velocity()
	local new_velocity,new_acceleration = mcl_physics.get_environment_effect(pos, vel, data, 1)

	if new_velocity then print("new_velocity="..tostring(new_velocity)) end
	if new_acceleration then print("new_acceleration="..tostring(new_acceleration)) end

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
