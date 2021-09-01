function mcl_mobs.mob:update_eye_height()
	local eye_height = self.def.eye_height

	if self.data.baby and self.def.baby_size then
		eye_height = eye_height * self.def.baby_size
	end

	self.eye_height = eye_height
end
