local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("statue",{
	chunk_probability = 0.2,
	hash_mindist_2d = 120,
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear_bottom = 0, clear_top = 0, padding = 1, corners = 1, foundation = -2 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "MegaTaiga", "MegaSpruceTaiga", "CherryGrove", "Swampland", "ExtremeHills+", "MesaPlateauF" }, -- TODO: also add to some other biomes?
	filenames = {
		modpath.."/schematics/statue_1.mts",
		modpath.."/schematics/statue_2.mts",
	},
	loot = {
		["mcl_chests:chest_small" ] ={{
			stacks_min = 1,
			stacks_max = 2,
			items = {
				{ itemstring = "mcl_core:iron_nugget", weight = 15, amount_min = 1, amount_max = 10 },
				{ itemstring = "mcl_core:iron_ingot", weight = 5, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:gold_nugget", weight = 4, amount_min = 1, amount_max = 8 },
				{ itemstring = "mcl_core:gold_ingot", weight = 3, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:diamond", weight = 1, amount_min = 2, amount_max = 5 },
				{ itemstring = "mcl_core:emerald", weight = 1, amount_min = 2, amount_max = 5 },
				{ itemstring = "mcl_core:lapis", weight = 3, amount_min = 2, amount_max = 10 },
			}
		}}
	}
})

