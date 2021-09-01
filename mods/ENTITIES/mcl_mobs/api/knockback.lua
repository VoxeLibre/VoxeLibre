function mcl_mobs.mob:knockback(hitter)
	if self.def.knockback_multiplier == 0 then
		return
	end

	if hitter:get_attach() == self.object then
		return
	end

	local velocity = self.object:get_velocity()

	local pos1 = self.object:get_pos()
	pos1.y = 0
	local pos2 = hitter:get_pos()
	pos2.y = 0
	local dir = vector.direction(pos2, pos1)

	local up = mcl_mobs.const.knockback_up

	if velocity.y ~= 0 then
		up = 0
	end

	local multiplier = mcl_mobs.const.knockback

	local knockback_level = mcl_enchanting.get_enchantment(mcl_util.get_wield_item(hitter), "knockback")
	if knockback_level > 0 then
		multiplier = multiplier + knockback_level * 3
	end

	dir = vector.multiply(dir, multiplier * self.def.knockback_multiplier)
	dir.y = up * self.def.knockback_multiplier

	self.object:add_velocity(dir)
end
