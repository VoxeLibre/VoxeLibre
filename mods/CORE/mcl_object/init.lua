MCLObject = class()

function MCLObject:constructor(obj)
	self.object = obj.object or obj
	self.IS_MCL_OBJECT = true
end

function MCLObject:on_punch(hitter, time_from_last_punch, tool_capabilities, dir, damage)
	local source = MCLDamageSource({is_punch = true, raw_source_object = hitter})

	local knockback = {
		hitter = hitter,
		time_from_last_punch = time_from_last_punch,
		tool_capabilities = tool_capabilities,
		dir = dir,
	}

	self:damage(damage, source, knockback)
	return true
end

function MCLObject:apply_knockback(strength, dir)
	local oldvel = self.object:get_velocity()
	local vel = vector.multiply(vector.normalize(vector.new(dir.x, 0, dir.z)), strength)

	if self:is_on_ground() then
		local old_y = oldvel.y / 2

		y = math.min(0.4, old_y / 2 + strenth)
		vel.y
	end

	vel = vector.subtract(vel, vector.divide(vector.new(oldvel.x, 0, oldvel.z), 2))

	self.object:add_velocity(vel)
end

-- use this function to deal regular damage to an object (do NOT use :punch() unless toolcaps need to be handled)
function MCLObject:damage(damage, source, knockback)
	damage = self:damage_modifier(damage, source) or damage
	self:set_hp(self:get_hp() - damage)

	if type(knockback) == "table" then
		knockback = self:calculate_knockback(
			knockback.hitter,
			knockback.time_from_last_punch,
			knockback.tool_capabilities,
			knockback.dir or vector.direction(knockback.hitter:get_pos(), self.object:get_pos(),
			knockback.distance or vector.distance(knockback.hitter:get_pos(), self.object:get_pos(),
			damage,
			source)
	end

	table.insert(self.damage_info, {
		damage = damage,
		source = source,
		knockback = knockback,
	})

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

MCLObject.calculate_knockback = minetest.calculate_knockback

function minetest.calculate_knockback()
	return 0
end

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
