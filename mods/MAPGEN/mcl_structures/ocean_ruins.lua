local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)

local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
assert(overworld_bounds)

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
	spawn_by = {"mcl_core:water_source"},
	num_spawn_by = 2,
	fill_ratio = 0.01,
	flags = "place_center_x, place_center_z, force_placement",
	solid_ground = true,
	make_foundation = true,
	y_offset = -1,
	y_min = overworld_bounds.min,
	y_max = -2,	-- TODO: de-hardcode this
	biomes = cold_oceans,
	chunk_probability = 400,
	sidelen = 20,
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

mcl_structures.register_structure("cold_ocean_ruins",cold)
mcl_structures.register_structure("warm_ocean_ruins",warm)
