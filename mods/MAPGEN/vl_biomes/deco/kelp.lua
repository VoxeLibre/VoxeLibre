-- TODO: move to mcl_ocean?
local surfaces = {"mcl_core:dirt", "mcl_core:sand", "mcl_core:gravel"}
local nodes = {"mcl_ocean:kelp_dirt", "mcl_ocean:kelp_sand", "mcl_ocean:kelp_gravel"}
local function register_kelp_decoration(offset, scale, biomes)
	for s = 1, #surfaces do
		mcl_mapgen_core.register_decoration({
			name = "Kelp on "..surfaces[s],
			deco_type = "simple",
			rank = 1500,
			place_on = {surfaces[s]},
			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = scale,
				spread = vector.new(100, 100, 100),
				seed = 32,
				octaves = 3,
				persist = 0.6,
			},
			biomes = biomes,
			y_min = vl_biomes.DEEP_OCEAN_MIN,
			y_max = -6,
			decoration = nodes[s],
			param2 = 16,
			param2_max = 96, -- height * 16
			place_offset_y = -1,
			flags = "force_placement",
			spawn_by = "mcl_core:water_source",
			check_offset = 1,
			num_spawn_by = 9,
		})
	end
end

-- TODO: use temperature classes, also to control amount?
register_kelp_decoration(-0.5, 1, {
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
