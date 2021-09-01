function mcl_mobs.mob:env_step()
	self:fall_damage_step()

	if not self.def.breathes_in_water then
		self:breath_step()
	end

	mcl_burning.tick(self.object, dtime, self.data)

	if self.dead then
		return false
	end

	if self.def.ignited_by_sunlight then
		self:sunlight_step()
	end

	if not self.def.unpushable then
		self:collision_step()
	end

	return true
end
