-- This file stores the various node types. This makes it easier to plug this mod into subgames
-- in which you need to change the node names.

-- Adapted for MineClone 2!

-- Node names (Don't use aliases!)
tsm_railcorridors.nodes = {
	dirt = "mcl_core:dirt",
	chest = "mcl_chests:chest",
	rail = "mcl_minecarts:rail",
	torch_floor = "mcl_torches:torch",
	torch_wall = "mcl_torches:torch_wall",

	--[[ Wood types for the corridors. Corridors are made out of full wood blocks
	and posts. For each corridor system, a random wood type is chosen with the chance
	specified in per mille. ]]
	corridor_woods = {
		{ wood = "mcl_core:wood", post = "mcl_fences:fence", chance = 900},
		{ wood = "mcl_core:darkwood", post = "mcl_fences:dark_oak_fence", chance = 100},
	},
}

-- Fallback function. Returns a random treasure. This function is called for chests
-- only if the Treasurer mod is not found.
-- pr: A PseudoRandom object
function tsm_railcorridors.get_default_treasure(pr)
	-- UNUSED IN MINECLONE 2!
end

-- MineClone 2's treasure function. Gets all treasures for a single chest.
-- Based on information from Minecraft Wiki.
function tsm_railcorridors.get_treasures(pr)
	local items = {}
	-- First roll
	local r1 = pr:next(1,71)
	if r1 <= 30 then
		table.insert(items, "mobs:nametag")
	elseif r1 <= 50 then
		table.insert(items, "mcl_core:apple_gold")
	elseif r1 <= 60 then
		-- TODO: Enchanted Book
		table.insert(items, "mcl_books:book")
	elseif r1 <= 65 then
		-- Nothing!
	elseif r1 <= 70 then
		table.insert(items, "mcl_tools:pick_iron")
	else
		-- TODO: Enchanted Golden Apple
		table.insert(items, "mcl_core:apple_gold")
	end

	-- Second roll
	local r2stacks = pr:next(2,4)
	for i=1, r2stacks do
		local r2 = pr:next(1,83)
		if r2 <= 15 then
			table.insert(items, "mcl_farming:bread "..pr:next(1,3))
		elseif r2 <= 25 then
			table.insert(items, "mcl_core:coal_lump "..pr:next(3,8))
		elseif r2 <= 35 then
			table.insert(items, "mcl_farming:beetroot_seeds "..pr:next(2,4))
		elseif r2 <= 45 then
			table.insert(items, "mcl_farming:melon_seeds "..pr:next(2,4))
		elseif r2 <= 55 then
			table.insert(items, "mcl_farming:pumpkin_seeds "..pr:next(2,4))
		elseif r2 <= 65 then
			table.insert(items, "mcl_core:iron_ingot "..pr:next(1,5))
		elseif r2 <= 70 then
			table.insert(items, "mcl_dye:blue "..pr:next(4,9))
		elseif r2 <= 75 then
			table.insert(items, "mesecons:redstone "..pr:next(4,9))
		elseif r2 <= 80 then
			table.insert(items, "mcl_core:gold_ingot "..pr:next(1,3))
		else
			table.insert(items, "mcl_core:diamond "..pr:next(1,2))
		end
	end

	-- Third roll
	for i=1, 3 do
		local r3 = pr:next(1,50)
		if r3 <= 20 then
			table.insert(items, "mcl_minecarts:rail "..pr:next(4,8))
		elseif r3 <= 35 then
			table.insert(items, "mcl_torches:torch "..pr:next(1,16))
		elseif r3 <= 40 then
			-- TODO: Activator Rail
			table.insert(items, "mcl_minecarts:rail "..pr:next(1,4))
		elseif r3 <= 45 then
			-- TODO: Detector Rail
			table.insert(items, "mcl_minecarts:rail "..pr:next(1,4))
		else
			table.insert(items, "mcl_minecarts:golden_rail "..pr:next(1,4))
		end
	end

	return items
end
