local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("forest_ruins",{
	chunk_probability = 0.2,
	hash_mindist_2d = 80,
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear_bottom = 1, clear_top = 0, padding = 0, corners = 1, foundation = -2 },
	y_offset = function(pr) return -(pr:next(1,2)) end,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "BirchForest", "Forest", "FlowerForest" }, -- TODO: also add to some other biomes?
	filenames = {
		modpath.."/schematics/mcl_extra_structures_birch_forest_ruins_1.mts",
		modpath.."/schematics/mcl_extra_structures_birch_forest_ruins_2.mts",
	},
	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_core:gold_ingot", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tools:sword_stone", weight = 15, },
				{ itemstring = "mcl_tools:pick_stone", weight = 15, },
				{ itemstring = "mcl_tools:shovel_stone", weight = 15, },
				{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 3, amount_max=7 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_fire:flint_and_steel", weight = 1, amount_min = 1, amount_max=1 },
			}
		}}
	}
})

