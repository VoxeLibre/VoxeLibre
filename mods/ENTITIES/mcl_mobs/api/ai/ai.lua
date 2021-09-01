function mcl_mobs.mob:ai_step(dtime)
	--[[
	if self.has_head then
		mobs.do_head_logic(self,dtime)
	end
	--]]

	self:float_step()

	if self.jump_only then
		jump_state_switch(self, dtime)
		jump_state_execution(self, dtime)
	--swimming
	elseif self.swim then
		swim_state_switch(self, dtime)
		swim_state_execution(self, dtime)
	--flying
	elseif self.fly then
		fly_state_switch(self, dtime)
		fly_state_execution(self, dtime)
	--regular mobs that walk around
	else
		land_state_switch(self, dtime)
		land_state_execution(self, dtime)
	end

	--make it so mobs do not glitch out when walking around/jumping
	self:swap_auto_step_height_adjust()
end
