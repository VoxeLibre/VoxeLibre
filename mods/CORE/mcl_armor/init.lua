local old_damage_handler = MCLObject.handle_damage

function MCLObject:handle_damage(hp, source)
	local hp_old = old_damage_handler(hp, source)
	if hp_old then
		return hp_old
	end

	if source.bypasses_armor and source.bypasses_magic then
		return
	end

	local heal_max = 0
	local items = 0
	local armor_damage = math.max(1, math.floor(math.abs(hp) / 4))

	local total_points = 0
	local total_toughness = 0
	local epf = 0
	local thorns_damage = 0
	local thorns_damage_regular = 0

	for location, stack in pairs(self:equipment():get_armor()) do
		if stack:get_count() > 0 then
			local enchantments = mcl_enchanting.get_enchantments(stack)
			local pts = stack:get_definition().groups["mcl_armor_points"] or 0
			local tough = stack:get_definition().groups["mcl_armor_toughness"] or 0
			total_points = total_points + pts
			total_toughness = total_toughness + tough
			local protection_level = enchantments.protection or 0
			if protection_level > 0 then
				epf = epf + protection_level * 1
			end
			local blast_protection_level = enchantments.blast_protection or 0
			if blast_protection_level > 0 and damage_type == "explosion" then
				epf = epf + blast_protection_level * 2
			end
			local fire_protection_level = enchantments.fire_protection or 0
			if fire_protection_level > 0 and (damage_type == "burning" or damage_type == "fireball" or reason.type == "node_damage" and
				(reason.node == "mcl_fire:fire" or reason.node == "mcl_core:lava_source" or reason.node == "mcl_core:lava_flowing")) then
				epf = epf + fire_protection_level * 2
			end
			local projectile_protection_level = enchantments.projectile_protection or 0
			if projectile_protection_level and (damage_type == "projectile" or damage_type == "fireball") then
				epf = epf + projectile_protection_level * 2
			end
				local feather_falling_level = enchantments.feather_falling or 0
				if feather_falling_level and reason.type == "fall" then
					epf = epf + feather_falling_level * 3
				end

				local did_thorns_damage = false
				local thorns_level = enchantments.thorns or 0
				if thorns_level then
					if thorns_level > 10 then
						thorns_damage = thorns_damage + thorns_level - 10
						did_thorns_damage = true
					elseif thorns_damage_regular < 4 and thorns_level * 0.15 > math.random() then
						local thorns_damage_regular_new = math.min(4, thorns_damage_regular + math.random(4))
						thorns_damage = thorns_damage + thorns_damage_regular_new - thorns_damage_regular
						thorns_damage_regular = thorns_damage_regular_new
						did_thorns_damage = true
					end
				end

				-- Damage armor
				local use = stack:get_definition().groups["mcl_armor_uses"] or 0
				if use > 0 and regular_reduction then
					local unbreaking_level = enchantments.unbreaking or 0
					if unbreaking_level > 0 then
						use = use / (0.6 + 0.4 / (unbreaking_level + 1))
					end
					local wear = armor_damage * math.floor(65536/use)
					if did_thorns_damage then
						wear = wear * 3
					end
					stack:add_wear(wear)
				end

				local item = stack:get_name()
				armor_inv:set_stack("armor", i, stack)
				player_inv:set_stack("armor", i, stack)
				items = items + 1
				if stack:get_count() == 0 then
					armor:set_player_armor(player)
					armor:update_inventory(player)
				end
			end
		end
		local damage = math.abs(hp_change)

		if regular_reduction then
			-- Damage calculation formula (from <https://minecraft.gamepedia.com/Armor#Damage_protection>)
			damage = damage * (1 - math.min(20, math.max((total_points/5), total_points - damage / (2+(total_toughness/4)))) / 25)
		end
		damage = damage * (1 - (math.min(20, epf) / 25))
		damage = math.floor(damage+0.5)

		if reason.type == "punch" and thorns_damage > 0 then
			local obj = reason.object
			if obj then
				local luaentity = obj:get_luaentity()
				if luaentity then
					local shooter = obj._shooter
					if shooter then
						obj = shooter
					end
				end
				obj:punch(player, 1.0, {
					full_punch_interval=1.0,
					damage_groups = {fleshy = thorns_damage},
				})
			end
		end

		hp_change = -math.abs(damage)
	return hp
end
