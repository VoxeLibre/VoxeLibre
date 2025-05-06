local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local water_level = minetest.get_mapgen_setting("water_level")

local cold_oceans = {
	"RoofedForest_ocean",
	"BirchForestM_ocean",
	"BirchForest_ocean",
	"IcePlains_deep_ocean",
	"ExtremeHillsM_deep_ocean",
	"SunflowerPlains_ocean",
	"MegaSpruceTaiga_deep_ocean",
	"ExtremeHillsM_ocean",
	"SunflowerPlains_deep_ocean",
	"BirchForest_deep_ocean",
	"IcePlainsSpikes_ocean",
	"StoneBeach_ocean",
	"ColdTaiga_deep_ocean",
	"Forest_deep_ocean",
	"FlowerForest_deep_ocean",
	"MegaTaiga_ocean",
	"StoneBeach_deep_ocean",
	"IcePlainsSpikes_deep_ocean",
	"ColdTaiga_ocean",
	"ExtremeHills+_deep_ocean",
	"ExtremeHills_ocean",
	"Forest_ocean",
	"MegaTaiga_deep_ocean",
	"MegaSpruceTaiga_ocean",
	"ExtremeHills+_ocean",
	"RoofedForest_deep_ocean",
	"IcePlains_ocean",
	"FlowerForest_ocean",
	"ExtremeHills_deep_ocean",
	"Taiga_ocean",
	"BirchForestM_deep_ocean",
	"Taiga_deep_ocean",
}

local warm_oceans = {
	"JungleEdgeM_ocean",
	"Jungle_deep_ocean",
	"Savanna_ocean",
	"MesaPlateauF_ocean",
	"Swampland_ocean",
	"Mesa_ocean",
	"Plains_ocean",
	"MesaPlateauFM_ocean",
	"MushroomIsland_ocean",
	"SavannaM_ocean",
	"JungleEdge_ocean",
	"MesaBryce_ocean",
	"Jungle_ocean",
	"Desert_ocean",
	"JungleM_ocean",
	"JungleEdgeM_deep_ocean",
	"Jungle_deep_ocean",
	"Savanna_deep_ocean",
	"MesaPlateauF_deep_ocean",
	"Swampland_deep_ocean",
	"Mesa_deep_ocean",
	"Plains_deep_ocean",
	"MesaPlateauFM_deep_ocean",
	"MushroomIsland_deep_ocean",
	"SavannaM_deep_ocean",
	"JungleEdge_deep_ocean",
	"MesaBryce_deep_ocean",
	"Jungle_deep_ocean",
	"Desert_deep_ocean",
	"JungleM_deep_ocean",
}

local cold = {
	place_on = {"group:sand","mcl_core:gravel","mcl_core:dirt","mcl_core:clay","group:material_stone"},
	spawn_by = {"group:water"},
	num_spawn_by = 2,
	chunk_probability = 10, -- todo: 15?
	biomes = cold_oceans,
	y_min = mcl_vars.mg_overworld_min,
	y_max = water_level - 6,
	y_offset = -1,
	flags = "place_center_x, place_center_z, force_placement",
	prepare = { foundation = -3, clear = false, surface = "water", mode = "min" },
	filenames = {
		modpath.."/schematics/mcl_structures_ocean_ruins_cold_1.mts",
		modpath.."/schematics/mcl_structures_ocean_ruins_cold_2.mts",
		modpath.."/schematics/mcl_structures_ocean_ruins_cold_3.mts",
	},
	loot = {
		["mcl_chests:chest_small" ] = {
			{
			stacks_min = 2,
			stacks_max = 4,
			items = {
				{ itemstring = "mcl_core:coal_lump", weight = 25, amount_min = 1, amount_max=4 },
				{ itemstring = "mcl_farming:wheat_item", weight = 25, amount_min = 2, amount_max=3 },
				{ itemstring = "mcl_core:gold_nugget", weight = 25, amount_min = 1, amount_max=3 },
				--{ itemstring = "mcl_maps:treasure_map", weight = 20, }, --FIXME Treasure map

				{ itemstring = "mcl_books:book", weight = 10, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end },
				{ itemstring = "mcl_fishing:fishing_rod_enchanted", weight = 20, func = function(stack, pr)
					mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}, pr)
				end  },
				{ itemstring = "mcl_core:emerald", weight = 15, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_armor:chestplate_leather", weight = 15, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_core:apple_gold", weight = 20, },
				{ itemstring = "mcl_armor:helmet_gold", weight = 15, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_core:gold_ingot", weight = 15, amount_min = 2, amount_max = 7 },
				{ itemstring = "mcl_core:iron_ingot", weight = 15, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:apple_gold_enchanted", weight = 2, },
				}
			}
		}
	},
	after_place = function(pos)
		local minp = vector.offset(pos, -10, -4, -10)
		local maxp = vector.offset(pos,  10,  2,  10)
		mcl_ocean.kelp.remove_kelp_below_structure(minp, maxp)
	end,
}

local warm = table.copy(cold)
warm.biomes = warm_oceans
warm.filenames = {
	modpath.."/schematics/mcl_structures_ocean_ruins_warm_1.mts",
	modpath.."/schematics/mcl_structures_ocean_ruins_warm_2.mts",
	modpath.."/schematics/mcl_structures_ocean_ruins_warm_3.mts",
	modpath.."/schematics/mcl_structures_ocean_ruins_warm_4.mts",
}

vl_structures.register_structure("cold_ocean_ruins",cold)
vl_structures.register_structure("warm_ocean_ruins",warm)
