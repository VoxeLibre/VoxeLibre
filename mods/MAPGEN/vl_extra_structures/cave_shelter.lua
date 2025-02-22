local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

-- TODO: use a placement logic similar to dungeons?
vl_structures.register_structure("cave_shelter",{
	chunk_probability = 0.05,
	hash_mindist = 120,
	place_on = {"group:material_stone"},
	flags = "place_center_x, place_center_z, all_floors",
	y_max = -10,
	y_min = mcl_vars.mg_overworld_min,
	--[[spawn_by = "group:stone",
	check_offset = 0,
	num_spawn_by = 3,]]
	force_placement = true,
	prepare = { tolerance=false, foundation = false, clear = false }, -- TODO: make clear/foundation not use grass
	filenames = {
		modpath.."/schematics/cave_shelter.mts"
	},
	after_place = function(p,def,pr,p1,p2)
		vl_structures.construct_nodes(p1, p2, {"mcl_furnaces:furnace"}) 
	end,
	loot = {
		["mcl_chests:chest_small"] = {
			{
				stacks_min = 0,
				stacks_max = 1,
				items = {
					{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 2, amount_max = 4 },
					{ itemstring = "mcl_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
				}
			},
			{
				stacks_min = 1,
				stacks_max = 3,
				items = {
					{ itemstring = "mcl_core:iron_ingot", weight = 90, amount_min = 1, amount_max = 2 },
					{ itemstring = "mcl_core:iron_nugget", weight = 50, amount_min = 1, amount_max = 10 },
					{ itemstring = "mcl_core:lapis", weight = 20, amount_min = 1, amount_max = 10 },
					{ itemstring = "mcl_core:gold_ingot", weight = 10, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 4 },
					{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 1 },
				}
			},{
				stacks_min = 1,
				stacks_max = 1,
				items = {
					--{ itemstring = "FIXME TREASURE MAP", weight = 8, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_mobitems:bone", weight = 10, amount_min = 2, amount_max = 4 },
					{ itemstring = "mcl_mobitems:rotten_flesh", weight = 5, amount_min = 3, amount_max = 8 },
					{ itemstring = "mcl_books:book", weight = 5, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_clock:clock", weight = 1, amount_min = 1, amount_max = 1 },
				}
			},
		}
	}
})

