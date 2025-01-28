-- Mega Spruce Taiga aka Old Growth Spruce Taiga
vl_biomes.register_biome({
	name = "MegaSpruceTaiga",
	node_top = "mcl_core:podzol",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 100,
	heat_point = 8,
	_mcl_biome_type = "cold",
	_mcl_water_temp = "cold",
	_mcl_grass_palette_index = 5,
	_mcl_foliage_palette_index = 10,
	_mcl_water_palette_index = 4,
	_mcl_skycolor = vl_biomes.skycolor.taiga,
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
		},
	}
})

-- Huge spruce
vl_biomes.register_spruce_decoration(3000, 0.0030, "mcl_core_spruce_huge_1.mts", {"MegaSpruceTaiga"})
vl_biomes.register_spruce_decoration(4000, 0.0036, "mcl_core_spruce_huge_2.mts", {"MegaSpruceTaiga"})
vl_biomes.register_spruce_decoration(6000, 0.0036, "mcl_core_spruce_huge_3.mts", {"MegaSpruceTaiga"})
vl_biomes.register_spruce_decoration(6600, 0.0036, "mcl_core_spruce_huge_4.mts", {"MegaSpruceTaiga"})

-- Common spruce
vl_biomes.register_spruce_decoration(2500, 0.00325, "mcl_core_spruce_1.mts", {"MegaSpruceTaiga"})
vl_biomes.register_spruce_decoration(7000, 0.00425, "mcl_core_spruce_3.mts", {"MegaSpruceTaiga"})
vl_biomes.register_spruce_decoration(5000, 0.00250, "mcl_core_spruce_2.mts", {"MegaSpruceTaiga"})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	rank = 1500,
	place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:dirt_with_grass", "mcl_core:coarse_dirt", "group:hardened_clay"},
	sidelen = 16,
	noise_params = {
		offset = 0.01,
		scale = 0.003,
		spread = vector.new(100, 100, 100),
		seed = 1972,
		octaves = 3,
		persist = 0.6
	},
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	biomes = {"MegaSpruceTaiga"},
	decoration = "mcl_core:deadbush",
	height = 1,
})

-- Mushrooms in Taiga
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:podzol"},
	sidelen = 80,
	fill_ratio = 0.003,
	biomes = {"MegaSpruceTaiga"},
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_mushrooms:mushroom_red",
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:podzol"},
	sidelen = 80,
	fill_ratio = 0.003,
	biomes = {"MegaSpruceTaiga"},
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_mushrooms:mushroom_brown",
})
