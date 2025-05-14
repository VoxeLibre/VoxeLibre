local modpath = minetest.get_modpath(minetest.get_current_modname())
local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
assert(overworld_bounds)

mcl_structures.register_structure("desert_well",{
	place_on = {"group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	not_near = { "desert_temple_new" },
	solid_ground = true,
	sidelen = 4,
	chunk_probability = 600,
	y_max = overworld_bounds.max,
	y_min = 1, -- TODO: de-hardcode
	y_offset = -2,
	biomes = { "Desert" },
	filenames = { modpath.."/schematics/mcl_structures_desert_well.mts" },
})
