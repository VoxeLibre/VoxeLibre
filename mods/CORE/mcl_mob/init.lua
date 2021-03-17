MCLMob = class(MCLEntity)

function MCLMob:get_hp()
	self:meta():get_float("hp")
end

function MCLMob:set_hp()
	self:meta():set_float("hp", hp)
end

function MCLMob:on_damage(hp_change, source, info)
	MCLEntity.on_damage(self, hp_change, source, info)

	local new_hp = self:get_hp()
	if new_hp <= 0 and new_hp + hp_change > 0 then
		self:on_death(source)
	end
end
