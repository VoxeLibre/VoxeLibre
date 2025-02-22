local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("tree_hideout",{
	chunk_probability = 0.1,
	hash_mindist_2d = 120,
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 6, clear = false, clear_bottom = 10, padding = -3, corners = 5, foundation = 2 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Forest" }, -- TODO: also add to some other biomes, with biome adaptation?
	filenames = {
		modpath.."/schematics/tree_hideout.mts",
	},
	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max = 7 },
				{ itemstring = "mcl_core:gold_ingot", weight = 3, amount_min = 2, amount_max = 6 },
				{ itemstring = "mcl_core:gold_nugget", weight = 3, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_core:iron_ingot", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:iron_nugget", weight = 5, amount_min = 1, amount_max = 6 },
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:sword_stone", weight = 15, },
				{ itemstring = "mcl_tools:pick_stone", weight = 15, },
				{ itemstring = "mcl_tools:shovel_stone", weight = 15, },
				{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 3, amount_max = 7 },
			}}
		}
	}
})

