function mcl_mobs.mob:fall_damage_step()
	-- ToDo: fall damage based on distance, not velocity
	local velocity = self.object:get_velocity()

	if self.last_velocity.y < -7 and velocity.y == 0 then
		self:deal_damage(math.abs(self.last_velocity.y + 7) * 2, {type = "fall"})
	end
end
