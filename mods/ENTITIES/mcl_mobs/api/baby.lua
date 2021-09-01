function mcl_mobs.mob:baby_step()
	if not self:do_timer("grow_up", true) then
		self:baby_grow_up()
	end
end

function mcl_mobs.mob:baby_grow_up()
	self:debug("growing up")
	self.data.baby = nil

	if self.def.on_grow_up then
		self.def.on_grow_up(self)
	end

	self:update_textures()
	self:update_visual_size()
	self:update_eye_height()
	self:update_collisionbox()
end

function mcl_mobs.mob:boost()
	self:debug("grow up boost")
	self.data.grow_up_timer = self.data.grow_up_timer - self.data.grow_up_timer * mcl_mobs.const.grow_up_boost
	-- ToDo: check whether the Minecraft wiki terminology is right about 10% or whether they actually mean 10 percent points
	-- (10 percent would be 0.1 * self.data.grow_up_timer, 10 percent points would be 0.1 * self.def.grow_up_goal)
end
