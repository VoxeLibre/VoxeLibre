mcl_loottables.register_entry = mcl_util.registration_function(mcl_loottables.entries)
mcl_loottables.register_table = mcl_util.registration_function(mcl_loottables.tables, function(name, def)
	local function set_parents(parent)
		for _, child in ipairs(parent.children or parent.entries or parent.pools or {}) do
			child.parent = parent
			set_parents(child)
		end
	end
	set_parents(def)
end)


function mcl_loottables.get_table(def)
	return mcl_util.switch_type(def, {
		["nil"] = function()
			return {}
		end,
		["string"] = function()
			return mcl_loottables.tables[def], "table"
		end,
		["table"] = function()
			return def
		end,
	}, "loot table")
end

function mcl_loottables.get_entry_type(entry)
	return mcl_loottables.entries[entry.type]
end

function mcl_loottables.get_candidates(entries, data, func)
	local candidates = {}
	for _, entry in ipairs(entries) do
		local success = mcl_predicates.do_predicates(entry.conditions, data)
		
		if success then
			local children = entry.children

			if children then
				table.insert_all(candidates, mcl_loottables.get_candidates(children, data, mcl_loottables.get_entry_type(entry).preprocess))
			else
				table.insert(candidates, entry)
			end
		end

		if func and func(success, data) then
			break
		end
	end
	return candidates
end

function mcl_loottables.do_item_modifiers(itemstack, node, data)
	if node then
		mcl_functions.do_item_modifiers(itemstack, node.functions, data)
		mcl_loottables.do_item_modifiers(itemstack, node.parent, data)
	end
end

function mcl_loottables.do_pools(pools, functions, data)
	local luck = data.luck or 0
	local stacks = {}
	for _, pool in ipairs(pools or {}) do
		if mcl_conditions.do_conditions(pool.conditions, data) do
			local rolls = mcl_loottables.get_number(pool.rolls, data) + mcl_loottables.get_number(pool.bonus_rolls, data) * luck
			for i = 1, rolls do
				local candidates = mcl_loottables.get_candidates(pool.entries, data)

				if #candidates > 0 then
					local total_weight = 0
					local weights = {}
					for _, candidate in ipairs(candidates)
						total_weight = total_weight + math.floor((candidate.weight or 1) + (candidate.quality or 0) * luck)
						table.insert(weights, total_weight)
					end
					
					local selected
					local rnd = mcl_util.rand(data.pr, 0, weight - 1)
					for i, w in ipairs(weights) do
						if rnd < w then
							selected = candidates[i]
							break
						end
					end
					
					local func = mcl_loottables.get_entry_type(entry).process
					local stacks = func(selected, data)

					for _, stack in ipairs(stacks) do
						mcl_item_modifiers.do_item_modifiers(stack, selected, data)
					end
					table.insert_all(stacks, stack)
				end
			end
		end
	end
	return stacks
end

function mcl_loottables.get_loot(def, data)
	def = mcl_loottables.get_table(def)
	return mcl_loottables.do_pools(def.pools)
end

function mcl_loottables.drop_loot(def, data)
	local loot = mcl_loottables.get_loot(def, data)
	local old_loot = table.copy(loot)
	for _, stack in ipairs(old_loot) do
		local max_stack = stack:get_stack_max()
		while max_stack < stack:get_count() do
			table.insert(loot, stack:take_items(max_stack))
		end
	end
	return loot
end

function mcl_loottables.fill_chest(def, data)
	local loot = mcl_loottables.get_loot(def, data)
end
