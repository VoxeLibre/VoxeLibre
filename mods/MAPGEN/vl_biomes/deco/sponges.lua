local b_sponge = {"Plains_deep_ocean", "SunflowerPlains_deep_ocean", "Forest_deep_ocean", "FlowerForest_deep_ocean", "BirchForest_deep_ocean", "BirchForestM_deep_ocean", "RoofedForest_deep_ocean", "Jungle_deep_ocean", "JungleM_deep_ocean", "JungleEdge_deep_ocean", "JungleEdgeM_deep_ocean", "MushroomIsland_deep_ocean", "Desert_deep_ocean", "Savanna_deep_ocean", "SavannaM_deep_ocean", "Mesa_deep_ocean", "MesaBryce_deep_ocean", "MesaPlateauF_deep_ocean", "MesaPlateauFM_deep_ocean"}
-- Wet Sponge
-- TODO: Remove this when we got ocean monuments?
vl_biomes.register_decoration({
	biomes = b_sponge,
	decoration = "mcl_sponges:sponge_wet",
	y_min = mcl_vars.mg_lava_overworld_max + 5,
	y_max = -20,
	place_on = {"mcl_core:dirt", "mcl_core:sand", "mcl_core:gravel"},
	spawn_by = {"group:water"},
	num_spawn_by = 1,
	noise_params = {
		offset = 0.00495,
		scale = 0.006,
		spread = vector.new(250, 250, 250),
		seed = 999,
		octaves = 3,
		persist = 0.666
	},
})
