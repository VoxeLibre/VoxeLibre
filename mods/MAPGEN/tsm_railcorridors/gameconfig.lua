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
	if pr:next(0,1000) < 30 then
		return "mcl_farming:bread "..pr:next(1,3)
	elseif pr:next(0,1000) < 50 then
		if pr:next(0,1000) < 500 then
			return "mcl_farming:pumpkin_seeds "..pr:next(1,5)
		else
			return "mcl_farming:melon_seeds "..pr:next(1,5)
		end
	elseif pr:next(0,1000) < 5 then
		return "mcl_tools:pick_iron"
	elseif pr:next(0,1000) < 3 then
		local r = pr:next(0, 1000)
		if r < 400 then
			return "mcl_core:iron_ingot "..pr:next(1,5)
		elseif r < 800 then
			return "mcl_core:gold_ingot "..pr:next(1,3)
		else
			return "mcl_core:diamond "..pr:next(1,2)
		end
	elseif pr:next(0,1000) < 30 then
		return "mcl_torches:torch "..pr:next(1,16)
	elseif pr:next(0,1000) < 20 then
		return "mcl_core:coal_lump "..pr:next(3,8)
	else
		return ""
	end
end
