local modpath = minetest.get_modpath(minetest.get_current_modname())

local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
assert(overworld_bounds)

mcl_structures.register_structure("fossil",{
	place_on = {"group:material_stone","group:sand"},
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	sidelen = 16,
	chunk_probability = 1000,
	y_offset = function(pr) return ( pr:next(1,16) * -1 ) -16 end,
	y_max = 15,
	y_min = overworld_bounds.min + 35, -- TODO make technical layer?
	biomes = { "Desert" },
	filenames = {
		modpath.."/schematics/mcl_structures_fossil_skull_1.mts", -- 4×5×5
		modpath.."/schematics/mcl_structures_fossil_skull_2.mts", -- 5×5×5
		modpath.."/schematics/mcl_structures_fossil_skull_3.mts", -- 5×5×7
		modpath.."/schematics/mcl_structures_fossil_skull_4.mts", -- 7×5×5
		modpath.."/schematics/mcl_structures_fossil_spine_1.mts", -- 3×3×13
		modpath.."/schematics/mcl_structures_fossil_spine_2.mts", -- 5×4×13
		modpath.."/schematics/mcl_structures_fossil_spine_3.mts", -- 7×4×13
		modpath.."/schematics/mcl_structures_fossil_spine_4.mts", -- 8×5×13
	},
})
