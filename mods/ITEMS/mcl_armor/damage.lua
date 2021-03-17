local old_damage_modifier = MCLObject.damage_modifier

function MCLObject:damage_modifier(damage, source)
	local damage_old = old_damage_modifier(damage, source)
	if damage_old then
		return damage_old
	end

	if damage < 0 then
		return
	end

	if source.bypasses_armor and source.bypasses_magic then
		return
	end

	local uses = math.max(1, math.floor(math.abs(damage) / 4))

	local source_object = source:source_object()
	local equipment = self:equipment()

	local points = self:base_armor_points()
	local toughness = 0
	local protection_factor = 0
	local thorns_damage_regular = 0
	local thorns_damage_irregular = 0
	local thorns_pieces = {}

	for location, rawstack in pairs(equipment:get_armor()) do
		local stack = MCLItemStack(rawstack)

		if not source.bypasses_armor then
			points = points + stack:group("armor_points")
			toughness = toughness + stack:group("armor_toughness")

			stack:use_durability(uses)
			equipment[location](equipment, rawstack)
		end

		if not source.bypasses_magic then
			protection_factor = protection_factor + 1 * stack:get_enchantment("protection")

			if source.is_explosion then
				protection_factor = protection_factor + 2 * stack:get_enchantment("blast_protection")
			end

			if source.is_fire then
				protection_factor = protection_factor + 2 * stack:get_enchantment("fire_protection")
			end

			if source.is_projectile then
				protection_factor = protection_factor + 2 * stack:get_enchantment("projectile_protection")
			end

			if source.is_fall then
				protection_factor = protection_factor + 3 * stack:get_enchantment("feather_falling")
			end
		end

		if source_object then
			local thorns_level = stack:get_enchantment("thorns")

			if thorns_level > 0 then
				local do_irregular_damage = thorns_level > 10

				if do_irregular_damage or thorns_damage_regular < 4 and math.random() < thorns_level * 0.15 then
					if do_irregular_damage then
						thorns_damage_irregular = thorns_damage_irregular + thorns_level - 10
					else
						thorns_damage_regular = math.min(4, thorns_damage_regular + math.random(4))
					end
				end

				table.insert(thorns_pieces, {location = location, stack = stack})
			end
		end

	end

	-- https://minecraft.gamepedia.com/Armor#Damage_protection
	damage = damage * (1 - math.min(20, math.max((points / 5), points - damage / (2 + (toughness / 4)))) / 25)

	-- https://minecraft.gamepedia.com/Armor#Enchantments
	damage = damage * (1 - math.min(20, protection_factor) / 25)

	local thorns_damage = thorns_damage_regular + thorns_damage_irregular

	if thorns_damage > 0 and source_object ~= self then
		local thorns_damage_source = MCLDamageSource({direct_object = self, source_object = source_object, is_thorns = true})
		local thorns_knockback = source_object:get_knockback(thorns_damage_source, nil, nil, nil, nil, thorns_damage)

		source_object:damage(thorns_damage, thorns_damage_source, thorns_knockback)

		local piece = thorns_pieces[math.random(#thorns_pieces)]
		local mclstack = piece.stack
		mclstack:use_durability(2)
		equipment[piece.location](equipment, mclstack.stack)
	end

	return math.floor(damage + 0.5)
end

function MCLObject:base_armor_points()
	return 0
end
