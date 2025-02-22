local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("desert_oasis",{
	chunk_probability = 0.2,
	hash_mindist_2d = 80,
	place_on = {"group:sand"},
	flags = "place_center_x, place_center_z",
	prepare = { tolerance = 3, clear_bottom = 1, clear_top = 0, padding = 1, corners = 1, foundation = -2 },
	y_offset = -4,
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	biomes = { "Desert" },
	filenames = {
		modpath.."/schematics/mcl_extra_structures_desert_oasis_1.mts",
		modpath.."/schematics/mcl_extra_structures_desert_oasis_2.mts",
	},
	loot = {
		["mcl_barrels:barrel_closed" ] ={{
			stacks_min = 2,
			stacks_max = 2,
			items = {
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 16, amount_min = 3, amount_max=7 },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:diamond", weight = 3, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_mobitems:saddle", weight = 3, },
				{ itemstring = "mcl_mobitems:iron_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:gold_horse_armor", weight = 1, },
				{ itemstring = "mcl_mobitems:diamond_horse_armor", weight = 1, },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
			}
		},
		{
			stacks_min = 2,
			stacks_max = 2,
			items = {
				{ itemstring = "mcl_core:tree", weight = 1, amount_min = 4, amount_max=6 },
			}
		},
		{
			stacks_min = 1,
			stacks_max = 1,
			items = {
				{ itemstring = "mcl_buckets:bucket_water", weight = 1, amount_min = 1, amount_max=1 },
			}
		}}
	}
})
