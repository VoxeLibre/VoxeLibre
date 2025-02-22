local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("forest_well",{
	chunk_probability = 0.2,
	hash_mindist_2d = 120,
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear_bottom = 1, clear_top = 0, padding = 1, corners = 1, foundation = -2 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	spawn_by = "group:dirt",
	check_offset = 1,
	num_spawn_by = 3,
	biomes = { "Forest", "FlowerForest", "BirchForest", "CherryGrove", "RoofedForest", "MesaPlateauF", "ExtremeHills+", "Taiga", "MegaTaiga", "MegaSpruceTaiga" },
	filenames = {
		modpath.."/schematics/forest_well_1.mts",
		modpath.."/schematics/forest_well_2.mts",
	},
})

