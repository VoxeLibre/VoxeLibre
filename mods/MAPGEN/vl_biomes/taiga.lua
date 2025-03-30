local mod_mcl_core = core.get_modpath("mcl_core")

-- Taiga
vl_biomes.register_biome({
	name = "Taiga",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	humidity_point = 58,
	heat_point = 22,
	_vl_biome_type = "cold",
	_vl_water_temp = "cold",
	_vl_grass_palette = "taiga",
	_vl_foliage_palette = "taiga",
	_vl_water_palette = "taiga",
	_vl_skycolor = vl_biomes.skycolor.taiga,
	_vl_subbiomes = {
		beach = {
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_filler = "mcl_core:sandstone",
			depth_filler = 1,
			y_min = 1,
			y_max = 3,
			_vl_foliage_palette = "plains", -- FIXME: remove?
		},
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
		},
	}
})

-- Small lollipop spruce
vl_biomes.register_decoration({
	biomes = {"Taiga"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_spruce_lollipop.mts",
	y_min = 2,
	place_on = {"group:grass_block", "mcl_core:podzol"},
	place_offset_y = 1,
	noise_params = {
		offset = 0.004,
		scale = 0.0022,
		spread = vector.new(250, 250, 250),
		seed = 2500,
		octaves = 3,
		persist = 0.66
	},
})

-- Matchstick spruce: Very few leaves, tall trunk
vl_biomes.register_decoration({
	biomes = {"Taiga"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_spruce_matchstick.mts",
	y_min = 3,
	place_on = {"group:grass_block", "mcl_core:podzol"},
	place_offset_y = 1,
	noise_params = {
		offset = -0.025,
		scale = 0.025,
		spread = vector.new(250, 250, 250),
		seed = 2566,
		octaves = 5,
		persist = 0.60,
	},
})

-- Common spruce
vl_biomes.register_spruce_decoration(11000, 0.00150, "mcl_core_spruce_5.mts", {"Taiga"})
vl_biomes.register_spruce_decoration(2500, 0.00325, "mcl_core_spruce_1.mts", {"Taiga"})
vl_biomes.register_spruce_decoration(7000, 0.00425, "mcl_core_spruce_3.mts", {"Taiga"})
vl_biomes.register_spruce_decoration(9000, 0.00325, "mcl_core_spruce_4.mts", {"Taiga"})

-- Mushrooms in Taiga
vl_biomes.register_decoration({
	biomes = {"Taiga"},
	decoration = "mcl_mushrooms:mushroom_red",
	place_on = {"mcl_core:podzol"},
	fill_ratio = 0.003,
})

vl_biomes.register_decoration({
	biomes = {"Taiga"},
	decoration = "mcl_mushrooms:mushroom_brown",
	place_on = {"mcl_core:podzol"},
	fill_ratio = 0.003,
})
