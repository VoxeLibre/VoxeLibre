local modpath = minetest.get_modpath(minetest.get_current_modname())

vl_structures.register_structure("fossil", {
	chunk_probability = 10, -- only in deserts
	place_on = { "group:material_stone", "group:sand" },
	flags = "place_center_x, place_center_z",
	prepare = false,
	rank = 900, -- actually a terrain feature,
	terrain_feature = false, -- but add them to /locate nevertheless
	y_offset = function(pr) return pr:next(-32,-16) end,
	y_max = 15,
	y_min = mcl_vars.mg_overworld_min + 35,
	biomes = { "Desert" },
	filenames = {
		modpath.."/schematics/mcl_structures_fossil_skull_1.mts", -- 4x5x5
		modpath.."/schematics/mcl_structures_fossil_skull_2.mts", -- 5x5x5
		modpath.."/schematics/mcl_structures_fossil_skull_3.mts", -- 5x5x7
		modpath.."/schematics/mcl_structures_fossil_skull_4.mts", -- 7x5x5
		modpath.."/schematics/mcl_structures_fossil_spine_1.mts", -- 3x3x13
		modpath.."/schematics/mcl_structures_fossil_spine_2.mts", -- 5x4x13
		modpath.."/schematics/mcl_structures_fossil_spine_3.mts", -- 7x4x13
		modpath.."/schematics/mcl_structures_fossil_spine_4.mts", -- 8x5x13
	},
})
