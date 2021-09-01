function mcl_mobs.mob:despawn_on_activate()
	self.data.can_despawn = self.data.can_despawn ~= false and self.def.can_despawn
	if self.data.can_despawn then
		self.life_timer = life_timer -- how much time is left until next despawn check
	end
end

function mcl_mobs.mob:despawn_step()
	if not self:do_timer("life") then
		self.life_timer = life_timer
		return not self:check_despawn()
	end
	return true
end

function mcl_mobs.mob:check_despawn()
	self:debug("checking for nearby players")
	if not self:is_player_near(despawn_radius) then
		self:debug("despawning")
		self.object:remove()
		return true
	end
	return false
end
