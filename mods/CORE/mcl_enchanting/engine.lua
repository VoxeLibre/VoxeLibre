function mcl_enchanting.get_enchantments(itemstack)
	return minetest.deserialize(itemstack:get_meta():get_string("mcl_enchanting:enchantments")) or {}
end

function mcl_enchanting.set_enchantments(itemstack, enchantments)
	itemstack:get_meta():set_string("mcl_enchanting:enchantments", minetest.serialize(enchantments))
	local itemdef = itemstack:get_definition()
	if itemstack:get_name() ~= "mcl_enchanting:book_enchanted" then
		if itemdef.tool_capabilities then
			itemstack:get_meta():set_tool_capabilities(itemdef.tool_capabilities)
		end
		for enchantment, level in pairs(enchantments) do
			local enchantment_def = mcl_enchanting.enchantments[enchantment]
			if enchantment_def.on_enchant then
				enchantment_def.on_enchant(itemstack, level, itemdef)
			end
		end
	end
	tt.reload_itemstack_description(itemstack)
end

function mcl_enchanting.get_enchantment(itemstack, enchantment)
	if itemstack:get_name() == "mcl_enchanting:book_enchanted" then
		return 0
	end
	return mcl_enchanting.get_enchantments(itemstack)[enchantment] or 0
end

function mcl_enchanting.has_enchantment(itemstack, enchantment)
	return mcl_enchanting.get_enchantment(itemstack, enchantment) > 0
end

function mcl_enchanting.get_enchantment_description(enchantment, level)
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	return enchantment_def.name .. (enchantment_def.max_level == 1 and "" or " " .. mcl_enchanting.roman_numerals.toRoman(level))
end

function mcl_enchanting.get_colorized_enchantment_description(enchantment, level)
	return minetest.colorize(mcl_enchanting.enchantments[enchantment].curse and "#FC5454" or "#A8A8A8", mcl_enchanting.get_enchantment_description(enchantment, level))
end

function mcl_enchanting.get_enchanted_itemstring(itemname)
	local def = minetest.registered_items[itemname]
	return def and def._mcl_enchanting_enchanted_tool
end

function mcl_enchanting.is_enchanted_def(itemname)
	return minetest.get_item_group(itemname, "enchanted") > 0
end

function mcl_enchanting.is_enchanted(itemstack)
	return mcl_enchanting.is_enchanted_def(itemstack:get_name())
end

function mcl_enchanting.item_supports_enchantment(itemname, enchantment, early)
	if itemname == "mcl_enchanting:book_enchanted" then
		return true, true
	end
	if not early and not mcl_enchanting.get_enchanted_itemstring(itemname) then
		return false
	end
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	local itemdef = minetest.registered_items[itemname]
	if itemdef.type ~= "tool" and enchantment_def.requires_tool then
		return false
	end
	for disallow in pairs(enchantment_def.disallow) do
		if minetest.get_item_group(itemname, disallow) > 0 then
			return false
		end
	end
	for group in pairs(enchantment_def.primary) do
		if minetest.get_item_group(itemname, group) > 0 then
			return true, true
		end
	end
	for group in pairs(enchantment_def.secondary) do
		if minetest.get_item_group(itemname, group) > 0 then
			return true, false
		end
	end
	return false
end

function mcl_enchanting.can_enchant(itemstack, enchantment, level)
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	if not enchantment_def then
		return false, "enchantment invalid"
	end
	local itemname = itemstack:get_name()
	if itemname == "" then
		return false, "item missing"
	end
	if not mcl_enchanting.item_supports_enchantment(itemstack:get_name(), enchantment) then
		return false, "item not supported"
	end
	if not level then
		return false, "level invalid"
	end
	if level > enchantment_def.max_level then
		return false, "level too high", enchantment_def.max_level
	elseif  level < 1 then
		return false, "level too small", 1
	end
	local item_enchantments = mcl_enchanting.get_enchantments(itemstack)
	local enchantment_level = item_enchantments[enchantment]
	if enchantment_level then
		return false, "incompatible", mcl_enchanting.get_enchantment_description(enchantment, enchantment_level)
	end
	if itemname ~= "mcl_enchanting:book_enchanted" then
		for incompatible in pairs(enchantment_def.incompatible) do
			local incompatible_level = item_enchantments[incompatible]
			if incompatible_level then
				return false, "incompatible", mcl_enchanting.get_enchantment_description(incompatible, incompatible_level)
			end
		end
	end
	return true
end

function mcl_enchanting.enchant(itemstack, enchantment, level)
	itemstack:set_name(mcl_enchanting.get_enchanted_itemstring(itemstack:get_name()))
	local enchantments = mcl_enchanting.get_enchantments(itemstack)
	enchantments[enchantment] = level
	mcl_enchanting.set_enchantments(itemstack, enchantments)
	return itemstack
end

function mcl_enchanting.combine(itemstack, combine_with)
	local itemname = itemstack:get_name()
	local combine_name = combine_with:get_name()
	local enchanted_itemname = mcl_enchanting.get_enchanted_itemstring(itemname)
	if enchanted_itemname ~= mcl_enchanting.get_enchanted_itemstring(combine_name) and combine_name ~= "mcl_enchanting:book_enchanted" then
		return false
	end
	local enchantments = mcl_enchanting.get_enchantments(itemstack)
	for enchantment, combine_level in pairs(mcl_enchanting.get_enchantments(combine_with)) do
		local enchantment_def = mcl_enchanting.enchantments[enchantment]
		local enchantment_level = enchantments[enchantment]
		if enchantment_level then
			if enchantment_level == combine_level then
				enchantment_level = math.min(enchantment_level + 1, enchantment_def.max_level)
			else
				enchantment_level = math.max(enchantment_level, combine_level)
			end
		elseif mcl_enchanting.item_supports_enchantment(itemname, enchantment) then
			local supported = true
			for incompatible in pairs(enchantment_def.incompatible) do
				if enchantments[incompatible] then
					supported = false
					break
				end
			end
			if supported then
				enchantment_level = combine_level
			end
		end
		if enchantment_level and enchantment_level > 0 then
			enchantments[enchantment] = enchantment_level
		end
	end
	local any_enchantment = false
	for enchantment, enchantment_level in pairs(enchantments) do
		if enchantment_level > 0 then
			any_enchantment = true
			break
		end
	end
	if any_enchantment then
		itemstack:set_name(enchanted_itemname)
	end
	mcl_enchanting.set_enchantments(itemstack, enchantments)
	return true
end

function mcl_enchanting.initialize()
	local all_groups = {}
	for enchantment, enchantment_def in pairs(mcl_enchanting.enchantments) do
		for primary in pairs(enchantment_def.primary) do
			all_groups[primary] = true
		end
		for secondary in pairs(enchantment_def.secondary) do
			all_groups[secondary] = true
		end
	end
	local register_tool_list = {}
	local register_item_list = {}
	for itemname, itemdef in pairs(minetest.registered_items) do
		if itemdef.groups.enchanted then
			break
		end
		local quick_test = false
		for group, groupv in pairs(itemdef.groups) do
			if groupv > 0 and all_groups[group] then
				quick_test = true
				break
			end
		end
		if quick_test then
			if mcl_enchanting.debug then
				print(itemname)
			end
			local expensive_test = false
			for enchantment in pairs(mcl_enchanting.enchantments) do
				if mcl_enchanting.item_supports_enchantment(itemname, enchantment, true) then
					expensive_test = true
					if mcl_enchanting.debug then 
						print("\tSupports " .. enchantment)
					else
						break
					end
				end
			end
			if expensive_test then
				local new_name = itemname .. "_enchanted"
				minetest.override_item(itemname, {_mcl_enchanting_enchanted_tool = new_name})
				local new_def = table.copy(itemdef)
				new_def.inventory_image = itemdef.inventory_image .. "^[brighten^[colorize:purple:50"
				if new_def.wield_image then
					new_def.wield_image = new_def.wield_image .. "^[brighten^[colorize:purple:50"
				end
				new_def.groups.not_in_creative_inventory = 1
				new_def.groups.enchanted = 1
				new_def.texture = itemdef.texture or itemname:gsub("%:", "_")
				new_def._mcl_enchanting_enchanted_tool = new_name
				local register_list = register_item_list
				if itemdef.type == "tool" then
					register_list = register_tool_list
				end
				register_list[":" .. new_name] = new_def
			end
		end
	end
	for new_name, new_def in pairs(register_item_list) do
		minetest.register_craftitem(new_name, new_def)
	end
	for new_name, new_def in pairs(register_tool_list) do
		minetest.register_tool(new_name, new_def)
	end
end

