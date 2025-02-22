local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("forest_shelter",{
	chunk_probability = 0.5,
	hash_mindist_2d = 80,
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear_bottom = 1, clear_top = 0, padding = 1, corners = 1, foundation = -2 },
	y_offset = -1,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Forest", "RoofedForest", "BirchForest", "BirchForestM", "FlowerForest", "CherryGrove", "Taiga", "MegaTaiga", "MegaSpruceTaiga" },
	filenames = {
		modpath.."/schematics/forest_shelter_1.mts",
	},
	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 1,
			stacks_max = 2,
			items = {
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_core:gold_ingot", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 1, amount_max = 3 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 2,
			items = {
				{ itemstring = "mcl_tools:sword_stone", weight = 15, },
				{ itemstring = "mcl_tools:pick_stone", weight = 15, },
				{ itemstring = "mcl_tools:shovel_stone", weight = 15, },
				{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_fire:flint_and_steel", weight = 1, amount_min = 1, amount_max=1 },
			}
		}}
	},
	after_place = function(p,def,pr,p1,p2)
		vl_structures.construct_nodes(p1, p2, {"mcl_furnaces:furnace"}) 
	end
})

