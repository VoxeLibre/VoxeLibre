local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

vl_structures.register_structure("forest_grave",{
	place_on = {"group:grass_block","group:dirt","mcl_core:dirt_with_grass"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear_bottom = 0, padding = 0, corners = 0, foundation = -2 },
	chunk_probability = 50,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Forest", "RoofedForest", "BirchForest", "FlowerForest", "CherryGrove", "ExtremeHills+" }, -- TODO: also add to some other biomes?
	filenames = {
		modpath.."/schematics/forest_grave.mts",
	},
})

