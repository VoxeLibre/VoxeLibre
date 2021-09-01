function mcl_mobs.mob:on_step(dtime, moveresult)
	self.dtime = dtime
	self:reload_properties()

	local stunned = self.stun_timer and self:do_timer("stun")

	-- can be true (currently stunned), nil (not stunned) or false (stopped being stunned in this tick, which is what we want to check for here)
	if stunned == false then
		self.object:set_texture_mod("")
	end

	self:update_node_type()
	self:movement_step()

	if self.dead then
		self:death_step()
		return
	end

	if self.def.hostile and not minetest.settings:get_bool("mclPeacefulMode") then
		self:debug("peaceful mode active, removing")
		self:deal_damage(self.data.health, {type = "out_of_world"})
	end

	if self.data.can_despawn then
		if not self:despawn_step() then
			return
		end
	end

	if self.def.on_step then
		if self.def.on_step(self, dtime, moveresult) == false then
			return
		end
	end

	if not self.data.silent then
		self:sound_step()
	end

	self:easteregg_step()

	if not self:env_step() then
		return
	end

	if self.data.baby then
		self:baby_step()
	end

	if self.data.gotten and not self:do_timer("gotten", true) then
		self.data.gotten = nil
	end

	if not self.data.no_ai and not stunned then
		self:ai_step()
	end

	self:backup_movement()
end
