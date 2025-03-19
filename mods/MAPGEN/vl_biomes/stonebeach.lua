-- Stone beach, aka Stony Shore
-- Just stone.
-- Not neccessarily a beach at all, only named so according to MC
vl_biomes.register_biome({
	name = "StoneBeach",
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 1,
	y_min = -7,
	y_max = vl_biomes.overworld_max,
	humidity_point = 0,
	heat_point = 8,
	_vl_biome_type = "cold",
	_vl_water_temp = "cold",
	_vl_grass_palette = "stonebeach",
	_vl_foliage_palette = "stonebeach",
	_vl_water_palette = "taiga",
	_vl_skycolor = vl_biomes.skycolor.taiga,
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			y_max = -8,
			vertical_blend = 2,
		},
	}
})
