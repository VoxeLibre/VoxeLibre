-- TODO: move to mcl_ocean?
local function register_seagrass_decoration(grasstype, offset, scale, biomes)
	local seed, nodes, surfaces, param2, param2_max, y_max
	if grasstype == "seagrass" then
		seed = 16
		surfaces = {"mcl_core:dirt", "mcl_core:sand", "mcl_core:gravel", "mcl_core:redsand"}
		nodes = {"mcl_ocean:seagrass_dirt", "mcl_ocean:seagrass_sand", "mcl_ocean:seagrass_gravel", "mcl_ocean:seagrass_redsand"}
		y_max = 0
	elseif grasstype == "kelp" then
		seed = 32
		param2 = 16
		param2_max = 96
		surfaces = {"mcl_core:dirt", "mcl_core:sand", "mcl_core:gravel"}
		nodes = {"mcl_ocean:kelp_dirt", "mcl_ocean:kelp_sand", "mcl_ocean:kelp_gravel"}
		y_max = -6
	end
	local noise = {
		offset = offset,
		scale = scale,
		spread = vector.new(100, 100, 100),
		seed = seed,
		octaves = 3,
		persist = 0.6,
	}

	for s = 1, #surfaces do
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			rank = 1500,
			place_on = {surfaces[s]},
			sidelen = 16,
			noise_params = noise,
			biomes = biomes,
			y_min = vl_biomes.DEEP_OCEAN_MIN,
			y_max = y_max,
			decoration = nodes[s],
			param2 = param2,
			param2_max = param2_max,
			place_offset_y = -1,
			flags = "force_placement",
		})
	end
end

-- TODO: use temperature classes, rather than hardcoding biome lists here?
-- Also would allow for more/less seagrass depending on temperature class
register_seagrass_decoration("seagrass", 0, 0.5, {
	"ColdTaiga_ocean",
	"ExtremeHills_ocean",
	"ExtremeHillsM_ocean",
	"ExtremeHills+_ocean",
	"Taiga_ocean",
	"MegaTaiga_ocean",
	"MegaSpruceTaiga_ocean",
	"StoneBeach_ocean",
	"Plains_ocean",
	"SunflowerPlains_ocean",
	"Forest_ocean",
	"FlowerForest_ocean",
	"BirchForest_ocean",
	"BirchForestM_ocean",
	"RoofedForest_ocean",
	"Swampland_ocean",
	"Jungle_ocean",
	"JungleM_ocean",
	"JungleEdge_ocean",
	"JungleEdgeM_ocean",
	"MushroomIsland_ocean",
	"Desert_ocean",
	"Savanna_ocean",
	"SavannaM_ocean",
	"Mesa_ocean",
	"MesaBryce_ocean",
	"MesaPlateauF_ocean",
	"MesaPlateauFM_ocean",

	"ColdTaiga_deep_ocean",
	"ExtremeHills_deep_ocean",
	"ExtremeHillsM_deep_ocean",
	"ExtremeHills+_deep_ocean",
	"Taiga_deep_ocean",
	"MegaTaiga_deep_ocean",
	"MegaSpruceTaiga_deep_ocean",
	"StoneBeach_deep_ocean",
	"Plains_deep_ocean",
	"SunflowerPlains_deep_ocean",
	"Forest_deep_ocean",
	"FlowerForest_deep_ocean",
	"BirchForest_deep_ocean",
	"BirchForestM_deep_ocean",
	"RoofedForest_deep_ocean",
	"Swampland_deep_ocean",
	"Jungle_deep_ocean",
	"JungleM_deep_ocean",
	"JungleEdge_deep_ocean",
	"JungleEdgeM_deep_ocean",
	"MushroomIsland_deep_ocean",
	"Desert_deep_ocean",
	"Savanna_deep_ocean",
	"SavannaM_deep_ocean",
	"Mesa_deep_ocean",
	"MesaBryce_deep_ocean",
	"MesaPlateauF_deep_ocean",
	"MesaPlateauFM_deep_ocean",

	"Mesa_sandlevel",
	"MesaBryce_sandlevel",
	"MesaPlateauF_sandlevel",
	"MesaPlateauFM_sandlevel",
	"Swampland_shore",
	"Jungle_shore",
	"JungleM_shore",
	"Savanna_beach",
	"FlowerForest_beach",
	"ColdTaiga_beach_water",
	"ExtremeHills_beach",
})

register_seagrass_decoration("kelp", -0.5, 1, {
	"ExtremeHillsM_ocean",
	"ExtremeHills+_ocean",
	"MegaTaiga_ocean",
	"MegaSpruceTaiga_ocean",
	"Plains_ocean",
	"SunflowerPlains_ocean",
	"Forest_ocean",
	"FlowerForest_ocean",
	"BirchForest_ocean",
	"BirchForestM_ocean",
	"RoofedForest_ocean",
	"Swampland_ocean",
	"Jungle_ocean",
	"JungleM_ocean",
	"JungleEdge_ocean",
	"JungleEdgeM_ocean",
	"MushroomIsland_ocean",

	"ExtremeHillsM_deep_ocean",
	"ExtremeHills+_deep_ocean",
	"MegaTaiga_deep_ocean",
	"MegaSpruceTaiga_deep_ocean",
	"Plains_deep_ocean",
	"SunflowerPlains_deep_ocean",
	"Forest_deep_ocean",
	"FlowerForest_deep_ocean",
	"BirchForest_deep_ocean",
	"BirchForestM_deep_ocean",
	"RoofedForest_deep_ocean",
	"Swampland_deep_ocean",
	"Jungle_deep_ocean",
	"JungleM_deep_ocean",
	"JungleEdge_deep_ocean",
	"JungleEdgeM_deep_ocean",
	"MushroomIsland_deep_ocean",
})
