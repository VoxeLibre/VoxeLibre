function mcl_mobs.mob:swap_auto_step_height_adjust()
	local y_vel = self.object:get_velocity().y

	if y_vel == 0 and self.stepheight ~= self.stepheight_backup then
		self.stepheight = self.stepheight_backup
	elseif y_vel ~= 0 and self.stepheight ~= 0 then
		self.stepheight = 0
	end
end
