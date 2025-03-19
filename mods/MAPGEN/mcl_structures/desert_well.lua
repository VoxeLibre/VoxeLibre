local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

vl_structures.register_structure("desert_well",{
	chunk_probability = 1,
	hash_mindist_2d = 1,
	place_on = {"group:sand"},
	flags = "place_center_x, place_center_z",
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -2,
	biomes = { "Desert" },
	filenames = { modpath.."/schematics/mcl_structures_desert_well.mts" },
})
