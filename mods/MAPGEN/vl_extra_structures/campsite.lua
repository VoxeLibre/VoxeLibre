local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

vl_structures.register_structure("campsite",{
	chunk_probability = 0.1,
	hash_mindist_2d = 80,
	place_on = {"group:grass_block"},
	flags = "place_center_x, place_center_z",
	y_max = mcl_vars.mg_overworld_max,
	y_min = 1,
	prepare = { tolerance = 1, foundation = -2, clear_top = 1, padding = 1, corners = 1 }, -- low tolerance, perform little terraforming
	biomes = { "Forest", "FlowerForest", "Plains", "SunflowerPlains", "Savanna", "SavannaM", "Taiga", "ColdTaiga" },
	filenames = {
		modpath.."/schematics/campsite_1.mts"
	},
	loot = {
		["mcl_chests:trapped_chest_small"] = {
			{
				stacks_min = 1,
				stacks_max = 3,
				items = {
					{ itemstring = "mcl_sus_stew:stew", weight = 10, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_core:paper", weight = 8, amount_min = 1, amount_max = 12 },
					{ itemstring = "mcl_farming:wheat_item", weight = 7, amount_min = 8, amount_max = 21 },
					{ itemstring = "mcl_farming:carrot_item", weight = 7, amount_min = 4, amount_max = 8 },
					{ itemstring = "mcl_farming:potato_item_poison", weight = 7, amount_min = 2, amount_max = 6 },
					{ itemstring = "mcl_farming:potato_item", weight = 7, amount_min = 2, amount_max = 6 },
					{ itemstring = "mcl_core:coal_lump", weight = 6, amount_min = 2, amount_max = 8 },
					{ itemstring = "mcl_mobitems:rotten_flesh", weight = 5, amount_min = 5, amount_max = 24 },
					{ itemstring = "mcl_farming:potato_item", weight = 3, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_armor:helmet_leather_enchanted", weight = 3, func = function(stack, _)
							mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
					{ itemstring = "mcl_armor:chestplate_leather_enchanted", weight = 3, func = function(stack, _)
							mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
					{ itemstring = "mcl_armor:leggings_leather_enchanted", weight = 3, func = function(stack, _)
							mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
					{ itemstring = "mcl_armor:boots_leather_enchanted", weight = 3, func = function(stack, _)
							mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
					{ itemstring = "mcl_bamboo:bamboo", weight = 2, amount_min = 1, amount_max = 3 },
					{ itemstring = "mcl_farming:pumpkin", weight = 2, amount_min = 1, amount_max = 3 },
					{ itemstring = "mcl_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
				}
			},
			{
				stacks_min = 1,
				stacks_max = 2,
				items = {
					{ itemstring = "mcl_core:iron_ingot", weight = 90, amount_min = 1, amount_max = 2 },
					{ itemstring = "mcl_core:iron_nugget", weight = 50, amount_min = 1, amount_max = 10 },
					{ itemstring = "mcl_core:emerald", weight = 40, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_core:lapis", weight = 20, amount_min = 1, amount_max = 10 },
					{ itemstring = "mcl_core:gold_ingot", weight = 10, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_core:gold_nugget", weight = 10, amount_min = 1, amount_max = 4 },
					{ itemstring = "mcl_experience:bottle", weight = 5, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 1 },
				}
			},{
				stacks_min = 1,
				stacks_max = 1,
				items = {
					--{ itemstring = "FIXME TREASURE MAP", weight = 8, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_core:paper", weight = 20, amount_min = 1, amount_max = 10 },
					{ itemstring = "mcl_mobitems:feather", weight = 10, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_books:book", weight = 5, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_clock:clock", weight = 1, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_compass:compass", weight = 1, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_maps:empty_map", weight = 1, amount_min = 1, amount_max = 1 },
				}
			},
		}
	}
	-- TODO: spawn a band of pillagers?
})

