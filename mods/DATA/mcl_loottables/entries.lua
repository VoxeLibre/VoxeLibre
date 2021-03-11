mcl_loottables.register_entry("mcl_loottables:alternatives", {
	preprocess = function(success, data)
		return success
	end,
})

mcl_loottables.register_entry("mcl_loottables:group", {
	preprocess = function(success, data)
		return false
	end,
})

mcl_loottables.register_entry("mcl_loottables:sequence", {
	preprocess = function(success, data)
		return not success
	end,
})

mcl_loottables.register_entry("mcl_loottables:tag", function(entry, data)
	local stacks = mcl_groupcache.get_items_in_group(entry.name)
	if entry.expand then
		stacks = {stacks[pr:next(1, #stacks)]}
	end
	return stacks
end)

mcl_loottables.register_entry("mcl_loottables:loot_table", {
	process = function(entry, data)
		return mcl_loottables.get_loot(entry.name, data)
	end,
})

mcl_loottables.register_entry("mcl_loottables:empty", {
	process = function(entry, data)
		return {}
	end,
})

mcl_loottables.register_entry("mcl_loottables:item", {
	process = function(entry, data)
		return {item = ItemStack(entry.name)}
	end,
})
 
