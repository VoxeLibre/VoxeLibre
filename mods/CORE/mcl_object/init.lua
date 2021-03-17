MCLObject = class()

function MCLObject:constructor(obj)
	self.object = obj.object or obj
	self.IS_MCL_OBJECT = true
end

function MCLObject:on_punch(hitter, time_from_last_punch, tool_capabilities, dir, damage)
	local source = MCLDamageSource({is_punch = true, raw_source_object = hitter})

	damage = self:damage_modifier(damage, source) or damage

	self.damage_info = {
		damage = damage,
		source = source,
		knockback = self:get_knockback(source, time_from_last_punch, tool_capabilities, dir, nil, damage),
	}

	return damage
end

-- use this function to deal regular damage to an object (do NOT use :punch() unless toolcaps need to be handled)
function MCLObject:damage(damage, source, knockback)
	damage = self:damage_modifier(damage, source) or damage
	self:set_hp(self:get_hp() - damage)

	self.damage_info = {
		damage = damage,
		source = source,
		knockback = knockback,
	}

	return damage
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

function MCLObject:damage_modifier(damage, source)
	if self.invulnerable and not source.bypasses_invulnerability then
		return 0
	end
end

function MCLObject:on_damage(damage, source, knockback)
end

function MCLObject:get_knockback(source, time_from_last_punch, tool_capabilities, dir, distance, damage)
	local direct_object = source:direct_object()

	return self:calculate_knockback(
		self.object,
		direct_object,
		time_from_last_punch or 1.0,
		tool_capabilities or {fleshy = damage},
		dir or vector.direction(direct_object:get_pos(), self.object:get_pos()),
		distance or vector.distance(direct_object:get_pos(), self.object:get_pos()),
		damage = damage,
	)
end

MCLObject.calculate_knockback = minetest.calculate_knockback

function MCLObject:on_step()
	local damage_info = self.damage_info
	if damage_info then
		self.damage_info = nil
		self:on_damage(damage_info.damage, damage_info.source)

		if damage_info.knockback then
			self.object:add_velocity(damage_info.knockback)
		end
	end
end
