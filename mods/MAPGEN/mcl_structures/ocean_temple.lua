local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local water_level = minetest.get_mapgen_setting("water_level")

local spawnon = { "mcl_stairs:slab_prismarine_dark" }

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

vl_structures.register_structure("ocean_temple",{
	chunk_probability = 2,
	hash_mindist_2d = 160,
	place_on = {"group:sand","mcl_core:gravel"},
	spawn_by = {"group:water"},
	num_spawn_by = 4,
	force_placement = true,
	prepare = { tolerance = 8, clear = false, foundation = 3, surface = "water" },
	biomes = ocean_biomes,
	y_max = water_level-4,
	y_min = mcl_vars.mg_overworld_min,
	filenames = {
		modpath .. "/schematics/mcl_structures_ocean_temple.mts",
		modpath .. "/schematics/mcl_structures_ocean_temple_2.mts",
	},
	y_offset = function(pr) return pr:next(-1,0) end,
	after_place = function(p, _, pr, p1, p2)
		vl_structures.spawn_mobs("mobs_mc:guardian",spawnon,p1,p2,pr,5,true)
		vl_structures.spawn_mobs("mobs_mc:guardian_elder",spawnon,p1,p2,pr,1,true)
		vl_structures.construct_nodes(p1,p2,{"group:wall"})
		mcl_ocean.kelp.remove_kelp_below_structure(p1, p2)
	end,
	loot = {
		["mcl_chests:chest_small"] = {
			{
				stacks_min = 3,
				stacks_max = 10,
				items = {
					{ itemstring = "mcl_sus_stew:stew", weight = 10, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_core:paper", weight = 8, amount_min = 1, amount_max = 12 },
					{ itemstring = "mcl_fishing:fish_raw", weight = 5, amount_min = 8, amount_max = 21 },
					{ itemstring = "mcl_fishing:salmon_raw", weight = 7, amount_min = 4, amount_max = 8 },
					{ itemstring = "mcl_tnt:tnt", weight = 1, amount_min = 1, amount_max = 2 },
				}
			},
			{
				stacks_min = 2,
				stacks_max = 6,
				items = {
					{ itemstring = "mcl_core:iron_ingot", weight = 10, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_core:goldblock", weight = 1, amount_min = 1, amount_max = 2 },
					{ itemstring = "mcl_experience:bottle", weight = 5, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_core:diamond", weight = 5, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_fishing:fishing_rod", weight = 1, amount_min = 1, amount_max = 1 },
				}
			},
			{
				stacks_min = 4,
				stacks_max = 4,
				items = {
					--{ itemstring = "FIXME TREASURE MAP", weight = 8, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_books:book", weight = 1, amount_min = 1, amount_max = 5 },
					{ itemstring = "mcl_clock:clock", weight = 1, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_compass:compass", weight = 1, amount_min = 1, amount_max = 1 },
					{ itemstring = "mcl_maps:empty_map", weight = 1, amount_min = 1, amount_max = 1 },
				}
			},
		}
	}
})

vl_structures.register_structure_spawn({
	name = "mobs_mc:guardian",
	y_min = mcl_vars.mg_overworld_min,
	y_max = mcl_vars.mg_overworld_max,
	chance = 10,
	interval = 60,
	limit = 9,
	spawnon = spawnon,
})

vl_structures.register_structure_spawn({
	name = "mobs_mc:guardian_elder",
	y_min = mcl_vars.mg_overworld_min,
	y_max = mcl_vars.mg_overworld_max,
	chance = 100,
	interval = 60,
	limit = 4,
	spawnon = spawnon,
})
