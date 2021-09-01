function mcl_mobs.mob:deal_damage(damage, reason)
	if self.dead or self.data.invulnerable then
		return 0
	end

	if reason.flags.is_fire and self.def.fire_damage_resistant then
		return 0
	end

	damage = mcl_damage.run_modifiers(self.object, damage, reason)

	if damage > 0 then
		mcl_damage.run_damage_callbacks(self.object, damage, reason)
		self.data.health = self.data.health - damage
		self.stun_timer = mcl_mobs.const.stun_timer
		self:update_movement()
		self.object:set_texture_mod("^[colorize:red:120")

		if self.data.health < 0 then
			self:die(reason)
		else
			self:play_sound("damage")
		end
	end

	return damage
end

function mcl_mobs.mob:on_punch(puncher, time_from_last_punch, tool_capabilities, direction, damage)
	if damage < 0 then
		return
	end

	local reason = {}
	mcl_damage.from_punch(reason, puncher)
	mcl_damage.finish_reason(reason)

	if self.def.on_punch then
		local args = {puncher = puncher, time_from_last_punch = time_from_last_punch, tool_capabilities = tool_capabilities, direction = direction}
		if self.def.on_punch(self, damage, reason, args) == false then
			return true
		end
	end

	self:get_angry(reason.source)

	-- PANIC AND RUN
	if self.def.skittish then
		self.state = "run"

		self.run_timer = mcl_mobs.const.run_timer

		local pos1 = self.object:get_pos()
		pos1.y = 0
		local pos2 = reason.source:get_pos()
		pos2.y = 0


		local dir = vector.direction(pos2, pos1)

		self.yaw = minetest.dir_to_yaw(direction)
	end

	if reason.type == "player" then
		mcl_hunger.exhaust(puncher:get_player_name(), mcl_hunger.EXHAUST_ATTACK)
	end

	damage = self:deal_damage(damage, reason)

	if damage > 0 then
		self:play_sound_specific("default_punch")
		self:knockback(reason.source)
	end

	return true
end

function mcl_mobs.mob:update_armor_groups()
	self.object:set_armor_groups(self.def.armor_groups)
end
