function mcl_armor.damage_modifier(obj, hp_change, reason)
	if hp_change > 0 then
		return hp_change
	end

	local damage = -hp_change
	local flags = reason.flags

	if flags.bypasses_armor and flags.bypasses_magic then
		return hp_change
	end

	local uses = math.max(1, math.floor(damage / 4))

	local points = 0
	local toughness = 0
	local enchantment_protection_factor = 0

	local thorns_damage_regular = 0
	local thorns_damage_irregular = 0
	local thorns_pieces = {}

	local inv = mcl_util.get_inventory(obj)

	if inv then
		for name, element in pairs(mcl_armor.elements) do
			local itemstack = inv:get_stack("armor", element.index)
			if not itemstack:is_empty() then
				local itemname = itemstack:get_name()
				local enchantments = mcl_enchanting.get_enchantments(itemstack)

				if not flags.bypasses_armor then
					points = points + minetest.get_item_group(itemname, "mcl_armor_points")
					toughness = toughness + minetest.get_item_group(itemname, "mcl_armor_toughness")

					mcl_util.use_item_durability(itemstack, uses)
					inv:set_stack("armor", element.index, itemstack)
				end

				if not flags.bypasses_magic then
					local function add_enchantments(tbl)
						if tbl then
							for _, enchantment in pairs(tbl) do
								local level = enchantments[enchantment.id]

								if level and level > 0 then
									enchantment_protection_factor = enchantment_protection_factor + level * enchantment.factor
								end
							end
						end
					end

					add_enchantments(mcl_armor.protection_enchantments.wildcard)
					add_enchantments(mcl_armor.protection_enchantments.types[reason.type])

					for flag, value in pairs(flags) do
						if value then
							add_enchantments(mcl_armor.protection_enchantments.flags[flag])
						end
					end
				end

				if reason.source and enchantments.thorns > 0 then
					local do_irregular_damage = enchantments.thorns > 10

					if do_irregular_damage or thorns_damage_regular < 4 and math.random() < enchantments.thorns * 0.15 then
						if do_irregular_damage then
							thorns_damage_irregular = thorns_damage_irregular + throrns_level - 10
						else
							thorns_damage_regular = math.min(4, thorns_damage_regular + math.random(4))
						end
					end

					table.insert(thorns_pieces, {index = element.index, itemstack = itemstack})
				end
			end
		end
	end

	-- https://minecraft.gamepedia.com/Armor#Damage_protection
	damage = damage * (1 - math.min(20, math.max((points / 5), points - damage / (2 + (toughness / 4)))) / 25)

	-- https://minecraft.gamepedia.com/Armor#Enchantments
	damage = damage * (1 - math.min(20, enchantment_protection_factor) / 25)

	local thorns_damage = thorns_damage_regular + thorns_damage_irregular

	if thorns_damage > 0 and reason.source ~= obj then
		mcl_util.deal_damage(reason.source, {type = "thorns", direct = obj, source = reason.source})

		local thorns_item = thorns_pieces[math.random(#thorns_pieces)]
		mcl_util.use_item_durability(thorns_item.itemstack, 2)
		inv:set_stack("armor", thorns_item.index, thorns_item.itemstack)
	end

	mcl_armor.update(obj)

	return -math.floor(damage + 0.5)
end
