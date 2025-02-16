local modpath = minetest.get_modpath(minetest.get_current_modname())

mcl_structures.register_structure("desert_well",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	not_near = { "desert_temple_new" },
	solid_ground = true,
	sidelen = 4,
	chunk_probability = 600,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	y_offset = -2,
	biomes = { "Desert" },
	filenames = { modpath.."/schematics/mcl_structures_desert_well.mts" },
})
