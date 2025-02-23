local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("tiny_tower",{
	chunk_probability = 0.1,
	hash_mindist_2d = 120,
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z, force_placement",
	prepare = { tolerance = 4, clear = false, padding = 2, corners = 1, foundation = -5 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 20,
	y_offset = -1,
	spawn_by = "air",
	check_offset = 1,
	num_spawn_by = 8,
	biomes = { "Forest", "FlowerForest", "BirchForest", "CherryGrove", "RoofedForest", "MesaPlateauF", "MesaPlateauFM", "ExtremeHills+", "Taiga", "MegaTaiga", "MegaSpruceTaiga", "ExtremeHills+", "ExtremeHillsM" },
	filenames = {
		modpath.."/schematics/tower_tiny_1.mts",
		modpath.."/schematics/tower_tiny_1_ruin.mts",
		modpath.."/schematics/tower_tiny_1_stump.mts",
	},
	after_place = function(p,_,pr,p1,p2)
		for _,n in pairs(core.find_nodes_in_area(p1,p2,{"group:wall"})) do
			mcl_walls.update_wall(n)
		end
	end,
	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 1,
			stacks_max = 3,
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
				{ itemstring = "mcl_tools:sword_iron", weight = 15, },
				{ itemstring = "mcl_tools:pick_iron", weight = 15, },
				{ itemstring = "mcl_tools:shovel_iron", weight = 15, },
				{ itemstring = "mcl_torches:torch", weight = 15, amount_min = 3, amount_max=10 },
				{ itemstring = "mcl_fire:flint_and_steel", weight = 1, amount_min = 1, amount_max=1 },
			}
		}}
	}
})

