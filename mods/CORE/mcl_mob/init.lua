MCLMob = class(MCLEntity)

function MCLMob:get_hp()
	self:meta():get_float("hp")
end

function MCLMob:set_hp()
	self:meta():set_float("hp", hp)
end

function MCLMob:on_damage(damage, source)
	MCLEntity.on_damage(self, damage, source)

	local new_hp = self:get_hp()
	if new_hp <= 0 and new_hp + damage > 0 then
		self:on_death(source)
	end
end
