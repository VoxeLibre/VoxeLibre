-- TODO: move to mcl_ocean with a late registration (when biomes are registered)?
local surfaces = {"mcl_core:dirt", "mcl_core:sand", "mcl_core:gravel", "mcl_core:redsand"}
local nodes = {"mcl_ocean:seagrass_dirt", "mcl_ocean:seagrass_sand", "mcl_ocean:seagrass_gravel", "mcl_ocean:seagrass_redsand"}
local function register_seagrass_decoration(offset, scale, biomes, suffix)
	for s = 1, #surfaces do
		vl_biomes.register_decoration({
			name = "Seagrass on "..surfaces[s]..(suffix or ""),
			biomes = biomes,
			decoration = nodes[s],
			param2 = 3, -- always use meshoption 3
			y_min = vl_biomes.DEEP_OCEAN_MIN,
			y_max = 1,
			place_on = {surfaces[s]},
			place_offset_y = -1,
			spawn_by = "mcl_core:water_source",
			check_offset = 1,
			num_spawn_by = 5,
			noise_params = {
				offset = offset,
				scale = scale,
				spread = vector.new(100, 100, 100),
				seed = 16,
				octaves = 3,
				persist = 0.6,
			},
			flags = "force_placement",
			rank = 1500,
		})
	end
end

-- TODO: use temperature classes, rather than hardcoding biome lists here?
-- Also would allow for more/less seagrass depending on temperature class
register_seagrass_decoration(0, 0.5, {
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
	"Jungle_shore",
	"JungleM_shore",
	"Savanna_beach",
	"FlowerForest_beach",
	"ColdTaiga_beach_water",
	"ExtremeHills_beach",
	"BambooJungle_ocean", -- borders mangrove as sand contrast is already high
	"BambooJungleM_ocean", -- borders mangrove as sand contrast is already high
	"BambooJungleEdge_ocean", -- borders mangrove as sand contrast is already high
	"BambooJungleEdgeM_ocean", -- borders mangrove as sand contrast is already high
	"Forest_beach", -- borders swamp, for more consistency as sand contrast is already high
	"BirchForest_beach", -- borders swamp, for more consistency as sand contrast is already high
	"RoofedForest_beach", -- borders swamp, for more consistency
})

-- More seagrass in swamps (except deep ocean)
register_seagrass_decoration(0.3, 0.4, {
	"Swampland_ocean",
	"Swampland_shore",
	"MangroveSwamp",
	"MangroveSwamp_ocean",
}, "swamp")
