local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
--local S = minetest.get_translator(modname)

local seed = minetest.get_mapgen_setting("seed")
local water_level = minetest.get_mapgen_setting("water_level")
local pr = PseudoRandom(seed)

--schematics by chmodsayshello
local schems = {
	modpath.."/schematics/mcl_structures_shipwreck_full_damaged.mts",
	modpath.."/schematics/mcl_structures_shipwreck_full_normal.mts",
	modpath.."/schematics/mcl_structures_shipwreck_full_back_damaged.mts",
	modpath.."/schematics/mcl_structures_shipwreck_half_front.mts",
	modpath.."/schematics/mcl_structures_shipwreck_half_back.mts",
}

local ocean_biomes = {
	"RoofedForest_ocean",
	"JungleEdgeM_ocean",
	"BirchForestM_ocean",
	"BirchForest_ocean",
	"IcePlains_deep_ocean",
	"Jungle_deep_ocean",
	"Savanna_ocean",
	"MesaPlateauF_ocean",
	"ExtremeHillsM_deep_ocean",
	"Savanna_deep_ocean",
	"SunflowerPlains_ocean",
	"Swampland_deep_ocean",
	"Swampland_ocean",
	"MegaSpruceTaiga_deep_ocean",
	"ExtremeHillsM_ocean",
	"JungleEdgeM_deep_ocean",
	"SunflowerPlains_deep_ocean",
	"BirchForest_deep_ocean",
	"IcePlainsSpikes_ocean",
	"Mesa_ocean",
	"StoneBeach_ocean",
	"Plains_deep_ocean",
	"JungleEdge_deep_ocean",
	"SavannaM_deep_ocean",
	"Desert_deep_ocean",
	"Mesa_deep_ocean",
	"ColdTaiga_deep_ocean",
	"Plains_ocean",
	"MesaPlateauFM_ocean",
	"Forest_deep_ocean",
	"JungleM_deep_ocean",
	"FlowerForest_deep_ocean",
	"MushroomIsland_ocean",
	"MegaTaiga_ocean",
	"StoneBeach_deep_ocean",
	"IcePlainsSpikes_deep_ocean",
	"ColdTaiga_ocean",
	"SavannaM_ocean",
	"MesaPlateauF_deep_ocean",
	"MesaBryce_deep_ocean",
	"ExtremeHills+_deep_ocean",
	"ExtremeHills_ocean",
	"MushroomIsland_deep_ocean",
	"Forest_ocean",
	"MegaTaiga_deep_ocean",
	"JungleEdge_ocean",
	"MesaBryce_ocean",
	"MegaSpruceTaiga_ocean",
	"ExtremeHills+_ocean",
	"Jungle_ocean",
	"RoofedForest_deep_ocean",
	"IcePlains_ocean",
	"FlowerForest_ocean",
	"ExtremeHills_deep_ocean",
	"MesaPlateauFM_deep_ocean",
	"Desert_ocean",
	"Taiga_ocean",
	"BirchForestM_deep_ocean",
	"Taiga_deep_ocean",
	"JungleM_ocean"
}

local beach_biomes = {
	"FlowerForest_beach",
	"Forest_beach",
	"StoneBeach",
	"ColdTaiga_beach_water",
	"Taiga_beach",
	"Savanna_beach",
	"Plains_beach",
	"ExtremeHills_beach",
	"ColdTaiga_beach",
	"Swampland_shore",
	"MushroomIslandShore",
	"JungleM_shore",
	"Jungle_shore"
}

mcl_structures.register_structure("shipwreck",{
	place_on = {"group:sand","mcl_core:gravel"},
	spawn_by = {"group:water"},
	num_spawn_by = 4,
	noise_params = {
		offset = 0,
		scale = 0.000022,
		spread = {x = 250, y = 250, z = 250},
		seed = 3,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	sidelen = 16,
	flags = "force_placement",
	biomes = ocean_biomes,
	y_max = water_level-4,
	y_min = mcl_vars.mg_overworld_min,
	filenames = schems,
	y_offset = function(pr) return pr:next(-4,-2) end,
	loot = {
		["mcl_chests:chest_small"] = {
			stacks_min = 3,
			stacks_max = 10,
			items = {
				{ itemstring = "mcl_sus_stew:stew", weight = 10, amount_min = 1, amount_max = 1 },
				{ itemstring = "mcl_core:paper", weight = 8, amount_min = 1, amount_max = 12 },
				{ itemstring = "mcl_farming:wheat_item", weight = 7, amount_min = 8, amount_max = 21 },
				{ itemstring = "mcl_farming:carrot_item", weight = 7, amount_min = 4, amount_max = 8 },
				{ itemstring = "mcl_farming:potato_item_poison", weight = 7, amount_min = 2, amount_max = 6 },
				{ itemstring = "mcl_farming:potato_item", weight = 7, amount_min = 2, amount_max = 6 },
				--{ itemstring = "TODO:moss_block", weight = 7, amount_min = 1, amount_max = 4 },
				{ itemstring = "mcl_core:coal_lump", weight = 6, amount_min = 2, amount_max = 8 },
				{ itemstring = "mcl_mobitems:rotten_flesh", weight = 5, amount_min = 5, amount_max = 24 },
				{ itemstring = "mcl_farming:potato_item", weight = 3, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_armor:helmet_leather_enchanted", weight = 3, func = function(stack, pr)
						mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
				{ itemstring = "mcl_armor:chestplate_leather_enchanted", weight = 3, func = function(stack, pr)
						mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
				{ itemstring = "mcl_armor:leggings_leather_enchanted", weight = 3, func = function(stack, pr)
						mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
				{ itemstring = "mcl_armor:boots_leather_enchanted", weight = 3, func = function(stack, pr)
						mcl_enchanting.enchant_uniform_randomly(stack, {"soul_speed"}) end },
				--{ itemstring = "TODO:bamboo", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_farming:pumpkin", weight = 2, amount_min = 1, amount_max = 3 },
				{ itemstring = "mcl_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },

			},
			{
			stacks_min = 3,
			stacks_max = 10,
			items = {
				{ itemstring = "mcl_core:iron_ingot", weight = 8, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:iron_nugget", weight = 8, amount_min = 1, amount_max = 10 },
				{ itemstring = "mcl_core:emerald", weight = 8, amount_min = 1, amount_max = 12 },
				{ itemstring = "mcl_dye:blue", weight = 8, amount_min = 1, amount_max = 12 },
				{ itemstring = "mcl_core:gold_ingot", weight = 8, amount_min = 1, amount_max = 5 },
				{ itemstring = "mcl_core:gold_nugget", weight = 8, amount_min = 1, amount_max = 10 },
				{ itemstring = "mcl_experience:bottle", weight = 8, amount_min = 1, amount_max = 10 },
				{ itemstring = "mcl_core:diamond", weight = 8, amount_min = 1, amount_max = 10 },
				}
			}
		}
	}
})
