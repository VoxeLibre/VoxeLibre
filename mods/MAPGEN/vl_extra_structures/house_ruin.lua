local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

-- TODO: merge with forest ruin?
vl_structures.register_structure("ruin",{
	chunk_probability = 0.05,
	hash_mindist_2d = 120,
	place_on = {"group:grass_block","mcl_core:dirt_with_grass"},
	biomes = { "Plains", "SunflowerPlains", "Forest", "FlowerForest", "BrichForest" },
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear = false, padding = 2, corners = 2, foundation = -2 },
	y_max = mcl_vars.mg_overworld_max,
	y_min = 5,
	filenames = {
		modpath.."/schematics/house_ruin_1.mts",
	},
})

