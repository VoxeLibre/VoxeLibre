local S = minetest.get_translator(minetest.get_current_modname())

-- Armor
tt.register_snippet(function(itemstring)
	--local def = minetest.registered_items[itemstring]
	local s = ""
	local head = minetest.get_item_group(itemstring, "armor_head")
	local torso = minetest.get_item_group(itemstring, "armor_torso")
	local legs = minetest.get_item_group(itemstring, "armor_legs")
	local feet = minetest.get_item_group(itemstring, "armor_feet")
	if head > 0 then
		s = s .. S("Head armor")
	end
	if torso > 0 then
		s = s .. S("Torso armor")
	end
	if legs > 0 then
		s = s .. S("Legs armor")
	end
	if feet > 0 then
		s = s .. S("Feet armor")
	end
	if s == "" then
		s = nil
	end
	return s
end)

tt.register_snippet(function(itemstring, _, itemstack)
	--local def = minetest.registered_items[itemstring]
	local s = ""
	local use = minetest.get_item_group(itemstring, "mcl_armor_uses")
	local pts = minetest.get_item_group(itemstring, "mcl_armor_points")
	if pts > 0 then
		s = s .. S("Armor points: @1", pts)
		s = s .. "\n"
	end
	local remaining_uses = use
	if itemstack then
		local unbreaking = mcl_enchanting.get_enchantment(itemstack, "unbreaking")
		if unbreaking > 0 then
			use = math.floor(use / (0.6 + 0.4 / (unbreaking + 1)))
		end
		remaining_uses = math.round(use - (itemstack:get_wear() * use) / 65535)
	end
	if use > 0 then
		if use ~= remaining_uses then
			use = remaining_uses .. "/" .. use -- implicit conversion from number to string
		end
		s = s .. S("Armor durability: @1", use)
	end
	if s == "" then
		s = nil
	end
	return s
end)
-- Horse armor
tt.register_snippet(function(itemstring)
	local armor_g = minetest.get_item_group(itemstring, "horse_armor")
	if armor_g and armor_g > 0 then
		return S("Protection: @1%", 100 - armor_g)
	end
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if not def then return end

	local s = ""
	if def.groups.eatable and def.groups.eatable > 0 then
		s = s .. S("Hunger points: +@1", def.groups.eatable)
	end
	if def._mcl_saturation and def._mcl_saturation > 0 then
		if s ~= "" then
			s = s .. "\n"
		end
		s = s .. S("Saturation points: +@1", string.format("%.1f", def._mcl_saturation))
	end
	if s == "" then
		s = nil
	end
	return s
end)

tt.register_snippet(function(itemstring)
	--local def = minetest.registered_items[itemstring]
	if minetest.get_item_group(itemstring, "crush_after_fall") == 1 then
		return S("Deals damage when falling"), mcl_colors.YELLOW
	end
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if not def then return end

	if def.groups.place_flowerlike == 1 then
		return S("Grows on grass blocks or dirt")
	elseif def.groups.place_flowerlike == 2 then
		return S("Grows on grass blocks, podzol, dirt or coarse dirt")
	end
end)

tt.register_snippet(function(itemstring)
	local def = minetest.registered_items[itemstring]
	if not def then return end

	if def.groups.flammable then
		return S("Flammable")
	elseif def.groups.collectible then
		return S("Collectible")
	end
end)

tt.register_snippet(function(itemstring)
	if itemstring == "mcl_heads:zombie" then
		return S("Zombie view range: -50%")
	elseif itemstring == "mcl_heads:skeleton" then
		return S("Skeleton view range: -50%")
	elseif itemstring == "mcl_heads:stalker" then
		return S("Stalker view range: -50%")
	end
end)

tt.register_snippet(function(itemstring, _, itemstack)
	if itemstring:sub(1, 23) == "mcl_fishing:fishing_rod" or itemstring:sub(1, 12) == "mcl_bows:bow" then
		local stack = itemstack or ItemStack(itemstring)
		local use = mcl_util.calculate_durability(stack)
		local remaining_use = math.round(use - (stack:get_wear() * use) / 65535)
		return S("Durability: @1", S("@1 uses", remaining_use .."/".. use))
	end
end)


-- Potions info
tt.register_snippet(function(itemstring, _, itemstack)
	if not itemstack then return end
	local def = itemstack:get_definition()
	if not def then return end

	if def.groups._mcl_potion ~= 1 then return end

	local s = ""
	local meta = itemstack:get_meta()
	local potency = meta:get_int("mcl_potions:potion_potent")
	local plus = meta:get_int("mcl_potions:potion_plus")
	local sl_factor = 1
	if def.groups.splash_potion == 1 then
		sl_factor = mcl_potions.SPLASH_FACTOR
	elseif def.groups.ling_potion == 1 then
		sl_factor = mcl_potions.LINGERING_FACTOR
	end
	if def._dynamic_tt then s = s.. def._dynamic_tt((potency+1)*sl_factor).. "\n" end
	local effects = def._effect_list
	if effects then
		local effect
		local dur
		local timestamp
		local ef_level
		local roman_lvl
		local factor
		local ef_tt
		for name, details in pairs(effects) do
			effect = mcl_potions.registered_effects[name]
			if details.dur_variable then
				dur = details.dur * math.pow(mcl_potions.PLUS_FACTOR, plus) * sl_factor
				if potency > 0 and details.uses_level then
					dur = dur / math.pow(mcl_potions.POTENT_FACTOR, potency)
				end
			else
				dur = details.dur
			end
			timestamp = math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
			if details.uses_level then
				ef_level = details.level + details.level_scaling * (potency)
			else
				ef_level = details.level
			end
			if ef_level > 1 then roman_lvl = " ".. mcl_util.to_roman(ef_level)
			else roman_lvl = "" end
			s = s.. effect.description.. roman_lvl.. " (".. timestamp.. ")\n"
			if effect.uses_factor then factor = effect.level_to_factor(ef_level) end
			if effect.get_tt then ef_tt = minetest.colorize("grey", effect.get_tt(factor)) else ef_tt = "" end
			if ef_tt ~= "" then s = s.. ef_tt.. "\n" end
			if details.effect_stacks then s = s.. minetest.colorize("grey", S("...stacks")).. "\n" end
		end
	end
	return s:trim()
end)


-- Fireworks info
tt.register_snippet(function(itemstring, _, itemstack)
	if not itemstack then return end
	local def = itemstack:get_definition()
	if not def then return end

	if not def._vl_fireworks_tt then return end

	local s = ""
	local meta = itemstack:get_meta()
	local stars = meta:get("vl_fireworks:stars") or core.serialize({})
	s = s .. def._vl_fireworks_tt(meta:get_float("vl_fireworks:duration"),
								  core.deserialize(stars))

	return s:trim()
end)
tt.register_snippet(function(itemstring, _, itemstack)
	if not itemstack then return end
	local def = itemstack:get_definition()
	if not def then return end

	if not def.groups.firework_star or def.groups.firework_star == 0 then return end

	local s = ""
	local meta = itemstack:get_meta()
	local effect = meta:get("vl_fireworks:star_effect") or core.serialize({fn="generic"})
	if effect then
		s = vl_fireworks.star_tt(core.deserialize(effect))
	end

	return s
end)
