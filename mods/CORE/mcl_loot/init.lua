mcl_loot = {}

--[[
Select a number of itemstacks out of a pool of treasure definitions randomly.

Parameters:
* loot_definitions: Probabilities and information about the loot to select. Syntax:

{
	stacks_min = 1,	-- Mamimum number of item stacks to get
	stacks_max = 3, -- Number of repetitions, maximum
	items = { -- Table of possible loot items. This function selects between stacks_min and stacks_max of these.
		{
		itemstring = "example:item1", -- Which item to select
		amount_min = 1,		-- Minimum size of itemstack. Optional (default: 1)
		amount_max = 10,	-- Maximum size of item stack. Must not exceed item definition's stack_max. Optional (default: 1)
		wear_min = 1,		-- Minimum wear value. Must be at lest 1. Optional (default: no wear)
		wear_max = 1,		-- Maxiumum wear value. Must be at lest 1. Optional (default: no wear)
		weight = 5,		-- Likelihood of this item being selected
		},
		{ -- more tables like above, one table per item stack }
	}
}
* pr: PseudoRandom object

How weight works: The probability of a single item stack being selected is weight/total_weight, with
total_weight being the sum of all weight values in the items table.

Returns: Table of itemstrings
]]
function mcl_loot.get_loot(loot_definitions, pr)
	local items = {}

	local total_weight = 0
	for i=1, #loot_definitions.items do
		total_weight = total_weight + loot_definitions.items[i].weight
	end

	local stacks = pr:next(loot_definitions.stacks_min, loot_definitions.stacks_max)
	for s=1, stacks do
		local r = pr:next(1, total_weight)

		local accumulated_weight = 0
		local item
		for i=1, #loot_definitions.items do
			accumulated_weight = accumulated_weight + loot_definitions.items[i].weight
			if accumulated_weight >= r then
				item = loot_definitions.items[i]
				break
			end
		end
		if item then
			local itemstring = item.itemstring
			if item.amount_min and item.amount_max then
				itemstring = itemstring .. " " .. pr:next(item.amount_min, item.amount_max)
			end
			if item.wear_min and item.wear_max then
				if not item.amount_min and not item.amount_max then
					itemstring = itemstring .. " 1"
				end
				itemstring = itemstring .. " " .. pr:next(item.wear_min, item.wear_max)
			end
			table.insert(items, itemstring)
		else
			minetest.log("error", "[mcl_loot] INTERNAL ERROR! Failed to select random loot item!")
		end
	end

	return items
end

--[[
Repeat mcl_loot.get_loot multiple times for various loot_definitions.
Useful for filling chests.

* multi_loot_definitions: Table of loot_definitions (see mcl_loot.get_loot)
* pr: PseudoRandom object

Returns: Table of itemstrings ]]
function mcl_loot.get_multi_loot(multi_loot_definitions, pr)
	local items = {}
	for m=1, #multi_loot_definitions do
		local group = mcl_loot.get_loot(multi_loot_definitions[m], pr)
		for g=1, #group do
			table.insert(items, group[g])
		end
	end
	return items
end
