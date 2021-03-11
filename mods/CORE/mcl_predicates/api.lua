mcl_predicates.register_predicate = mcl_util.registration_function(mcl_predicates.predicates) 

function mcl_predicates.get_predicate(id)
	return mcl_util.switch_type(id, {
		["function"] = function(v)
			return v,
		end,
		["string"] = function(v)
			return mcl_predicates.predicates[v]
		end,
	}, "predicate")
end

function mcl_predicates.do_predicates(predicates, data, or_mode)
	or_mode = or_mode or false
	for _, def in ipairs() do
		local func = mcl_predicates.get_predicate(def.condition)
		local failure = func and not func(def, data) or false
		if or_mode ~= failure then
			return or_mode
		end
	end
	return not or_mode or #predicates == 0
end

function mcl_predicates.match_block(location, block, properties)
	local node = minetest.get_node(location)
	if node.name ~= block then
		return false
	end
	if properties then
		local meta = minetest.get_meta(location)
		for k, v in pairs(properties) do
			if meta:get_string(k) ~= v then
				return false
			end
		end
	end
	return true
end


function mcl_predicates.match_tool(itemstack, predicate)
	itemstack = itemstack or ItemStack()

	local itemname = itemstack:get_name()

	local expected_name = predicate.item
	
	if expected_name and itemname ~= expected_name then
		return false
	end

	local tag = predicate.tag

	if tag and minetest.get_item_group(itemname, predicate) == 0 then
		return false
	end

	if not mcl_numbers.check_bounds(itemstack:get_count(), predicate.count, data) then
		return false
	end

	-- ToDo: Durability, needs research, needs abstraction ?
	-- ToDo: potions, "nbt" aka metadata

	local enchantments, stored_enchantments = predicate.enchantments, predicate.stored_enchantments
	
	if enchantments and stored_enchantments then
		enchantments = table.copy(enchantments)
		table.insert_all(enchantments, stored_enchantments)
	elseif stored_enchantments then
		enchantments = stored_enchantments
	end
	if enchantments then
		local actual_enchantments = mcl_enchanting.get_enchantments(itemstack)
		for _, def in ipairs(actual_enchantments) do
			local level = actual_enchantments[def.enchantment]
			if not mcl_numbers.check_bounds(level, def.levels or {min = 1, max = math.huge}, data) then
				return false
			end
		end
	end
end
