local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("forest_grave",{
	chunk_probability = 0.1,
	hash_mindist_2d = 120,
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear_bottom = 0, padding = 1, corners = 1, foundation = -2 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Forest", "RoofedForest", "BirchForest", "BirchForestM", "FlowerForest", "Taiga", "CherryGrove", "ExtremeHills+" }, -- TODO: also add to some other biomes?
	filenames = {
		modpath.."/schematics/forest_grave.mts",
	},
})

