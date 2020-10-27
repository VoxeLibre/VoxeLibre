mcl_enchanting.total_weight = 0
mcl_enchanting.all_item_groups = {}

for enchantment, enchantment_def in pairs(mcl_enchanting.enchantments) do
	local all_item_groups = {}
	for primary in pairs(enchantment_def.primary) do
		all_item_groups[primary] = true
		mcl_enchanting.all_item_groups[primary] = true
	end
	for secondary in pairs(enchantment_def.secondary) do
		all_item_groups[secondary] = true
		mcl_enchanting.all_item_groups[secondary] = true
	end
	enchantment_def.all = all_item_groups
	mcl_enchanting.total_weight = mcl_enchanting.total_weight + enchantment_def.weight
end

--[[
minetest.register_on_mods_loaded(function()
	for toolname, tooldef in pairs(minetest.registered_tools) do
		for _, material in pairs(tooldef.materials) do
			local full_name = toolname .. ((material == "") and "" or "_" .. material)
			local old_def = minetest.registered_tools[full_name]
			if not old_def then break end
			mcl_enchanting.all_tools[full_name] = toolname
			for _, enchantment in pairs(tooldef.enchantments) do
				local enchantment_def = mcl_enchanting.enchantments[enchantment]
				for lvl = 1, enchantment_def.max_level do
					local new_def = table.copy(old_def)
					new_def.description = minetest.colorize("#54FCFC", old_def.description) .. "\n" .. mcl_enchanting.get_enchantment_description(enchantment, lvl)
					new_def.inventory_image = old_def.inventory_image .. "^[colorize:violet:50"
					new_def.groups.not_in_creative_inventory = 1
					new_def.texture = old_def.texture or full_name:gsub("%:", "_")
					new_def._original_tool = full_name
					enchantment_def.create_itemdef(new_def, lvl)
					minetest.register_tool(":" .. full_name .. "_enchanted_" .. enchantment .. "_" .. lvl, new_def)
				end
			end
		end
	end
end)
--]]

minetest.register_on_mods_loaded(function()
	local register_list = {}
	for toolname, tooldef in pairs(minetest.registered_tools) do
		if tooldef.groups.enchanted then
			break
		end
		local quick_test = false
		for group, groupv in pairs(tooldef.groups) do
			if groupv > 0 and mcl_enchanting.all_item_groups[group] then
				quick_test = true
				break
			end
		end
		if quick_test then
			--print(toolname)
			local expensive_test = false
			for enchantment in pairs(mcl_enchanting.enchantments) do
				if mcl_enchanting.item_supports_enchantment(toolname, enchantment, true) then
					-- print("\tSupports " .. enchantment)
					expensive_test = true
					break
				end
			end
			if expensive_test then
				local new_name = toolname .. "_enchanted"
				minetest.override_item(toolname, {_mcl_enchanting_enchanted_tool = new_name})
				local new_def = table.copy(tooldef)
				new_def.inventory_image = tooldef.inventory_image .. "^[colorize:purple:50"
				new_def.groups.not_in_creative_inventory = 1
				new_def.groups.enchanted = 1
				new_def.texture = tooldef.texture or toolname:gsub("%:", "_")
				new_def._mcl_enchanting_enchanted_tool = new_name
				register_list[":" .. new_name] = new_def
			end
		end
	end
	for new_name, new_def in pairs(register_list) do
		minetest.register_tool(new_name, new_def)
	end
end)

function mcl_enchanting.get_enchantments(itemstack)
	return minetest.deserialize(itemstack:get_meta():get_string("mcl_enchanting:enchantments")) or {}
end

function mcl_enchanting.set_enchantments(itemstack, enchantments, data)
	return itemstack:get_meta():set_string("mcl_enchanting:enchantments", minetest.serialize(enchantments))
end

function mcl_enchanting.get_enchantment(itemstack, enchantment, data)
	return (data or mcl_enchanting.get_enchantments(itemstack))[enchantment] or 0
end

function mcl_enchanting.get_enchantment_description(enchantment, level)
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	return enchantment_def.name .. (enchantment_def.max_level == 1 and "" or " " .. mcl_enchanting.roman_numerals.toRoman(level))
end

function mcl_enchanting.get_enchanted_itemstring(itemname)
	local def =  minetest.registered_items[itemname]
	return def and def._mcl_enchanting_enchanted_tool
end

function mcl_enchanting.item_supports_enchantment(itemname, enchantment, early)
	if not early and not mcl_enchanting.get_enchanted_itemstring(itemname) then
		return false
	end
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	for disallow in pairs(enchantment_def.disallow) do
		if minetest.get_item_group(itemname, disallow) > 0 then
			return false
		end
	end
	for group in pairs(enchantment_def.all) do
		if minetest.get_item_group(itemname, group) > 0 then
			return true
		end
	end
	return false
end

function mcl_enchanting.can_enchant(itemstack, enchantment, level)
	local enchantment_def = mcl_enchanting.enchantments[enchantment]
	if not enchantment_def then
		return false, "enchantment invalid"
	end
	if itemstack:get_name() == "" then
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
	for incompatible in pairs(enchantment_def.incompatible) do
		local incompatible_level = item_enchantments[incompatible]
		if incompatible_level then
			return false, "incompatible", mcl_enchanting.get_enchantment_description(incompatible, incompatible_level)
		end
	end
	return true
end

function mcl_enchanting.enchant(itemstack, enchantment, level)
	local enchanted_itemstack = ItemStack({name = mcl_enchanting.get_enchanted_itemstring(itemstack:get_name()), wear = itemstack:get_wear(), metadata = itemstack:get_metadata()})
	local enchantments = mcl_enchanting.get_enchantments(enchanted_itemstack)
	enchantments[enchantment] = level
	mcl_enchanting.set_enchantments(enchanted_itemstack, enchantments)
	mcl_enchanting.reload_enchantments(enchanted_itemstack, enchantments)
	return enchanted_itemstack
end

function mcl_enchanting.reload_enchantments(itemstack, enchantments)
	local itemdef = itemstack:get_definition()
	for enchantment, level in pairs(enchantments) do
		local func = mcl_enchanting.features[enchantment]
		if func then
			func(itemstack, level, itemdef)
		end
	end
end
