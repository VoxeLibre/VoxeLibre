MCLObject = class()

function MCLObject:constructor(obj)
	self.object = obj.object or obj
	self.IS_MCL_OBJECT = true
end

function MCLObject:on_punch(hitter, time_from_last_punch, tool_capabilities, dir, hp)
	local source = MCLDamageSource():punch(nil, hitter)

	hp = self:damage_modifier(hp, source) or hp

	self.damage_info = {
		hp = hp,
		source = source,
		info = {
			tool_capabilities = tool_capabilities,
		},
	}

	return hp
end

-- use this function to deal regular damage to an object (do NOT use :punch() unless toolcaps need to be handled)
function MCLObject:damage(hp, source)
	hp = self:damage_modifier(hp, source) or hp
	self:set_hp(self:get_hp() - hp)

	self.damage_info = {
		hp = hp,
		source = source,
	}

	return hp
end

function MCLObject:wield_index()
end

MCLObject:__getter("equipment", function(self)
	return MCLEquipment(self:inventory(), self:wield_index())
end)

function MCLObject:get_hp()
	return self.object:get_hp()
end

function MCLObject:set_hp(hp)
	self.object:set_hp(hp)
end

function MCLObject:add_velocity(vel)
	self.object:add_velocity(vel)
end

function MCLObject:death_drop(inventory, listname, index, stack)
	minetest.add_item(self.object:get_pos(), stack)
	inventory:set_stack(listname, index, nil)
end

function MCLObject:on_death(source)
	local inventory = self:inventory()
	if inventory then
		for listname, list in pairs(inventory:get_lists()) do
			for index, stack in pairs(list) do
				if stack:get_name() ~= "" and then
					 self:death_drop(inventory, listname, index, stack)
				end
			end
		end
	end
end

function MCLObject:damage_modifier(hp, source)
	if self.invulnerable and not source.bypasses_invulnerability then
		return 0
	end
end

function MCLObject:on_damage(hp_change, source, info)
end

function MCLObject:on_step()
	local damage_info = self.damage_info
	if damage_info then
		self.damage_info = nil
		self:on_damage(damage_info.hp, damage_info.source, damage_info.info)
	end
end
