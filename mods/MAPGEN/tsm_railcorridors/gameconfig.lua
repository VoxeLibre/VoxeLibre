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
	cobweb = "mcl_core:cobweb",
	spawner = "mcl_mobspawners:spawner",

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

-- All spawners spawn cave spiders
function tsm_railcorridors.on_construct_spawner(pos)
	mcl_mobspawners.setup_spawner(pos, "mobs_mc:cave_spider")
end

-- MineClone 2's treasure function. Gets all treasures for a single chest.
-- Based on information from Minecraft Wiki.
function tsm_railcorridors.get_treasures(pr)
	local items = mcl_loot.get_multi_loot({
	{
		stacks_min = 1,
		stacks_max = 1,
		items = {
			{ itemstring = "mobs:nametag", weight = 30 },
			{ itemstring = "mcl_core:apple_gold", weight = 20 },
			{ itemstring = "mcl_books:book", weight = 10 }, -- TODO: Enchanted Book
			{ itemstring = "", weight = 5},
			{ itemstring = "mcl_core:pick_iron", weight = 5 },
			{ itemstring = "mcl:core:apple_gold", weight = 1 }, -- TODO: Enchanted Golden Apple
		}
	},
	{
		stacks_min = 2,
		stacks_max = 4,
		items = {
			{ itemstring = "mcl_farming:bread", weight = 15, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_core:coal_lump", weight = 10, amount_min = 3, amount_max = 8 },
			{ itemstring = "mcl_farming:beetroot_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:melon_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_farming:pumpkin_seeds", weight = 10, amount_min = 2, amount_max = 4 },
			{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
			{ itemstring = "mcl_dye:blue", weight = 5, amount_min = 4, amount_max = 9 },
			{ itemstring = "mesecons:redstone", weight = 5, amount_min = 4, amount_max = 9 },
			{ itemstring = "mcl_core:gold_ingot", weight = 5, amount_min = 1, amount_max = 3 },
			{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 2 },
		}
	},
	{
		stacks_min = 3,
		stacks_max = 3,
		items = {
			{ itemstring = "mcl_minecarts:rail", weight = 20, amount_min = 4, amount_max = 8 },
			{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 1, amount_max = 16 },
			{ itemstring = "mcl_minecarts:rail", weight = 5, amount_min = 1, amount_max = 4 }, -- TODO: Activator Rail
			{ itemstring = "mcl_minecarts:rail", weight = 5, amount_min = 1, amount_max = 4 }, -- TODO: Detector Rail
			{ itemstring = "mcl_minecarts:golden_rail", weight = 5, amount_min = 1, amount_max = 4 },
		}
	}}, pr)

	return items
end
