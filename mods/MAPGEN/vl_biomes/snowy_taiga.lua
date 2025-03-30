local mod_mcl_core = core.get_modpath("mcl_core")

-- Cold Taiga aka Snowy Taiga
vl_biomes.register_biome({
	name = "ColdTaiga",
	node_dust = "mcl_core:snow",
	node_top = "mcl_core:dirt_with_grass_snow",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 3,
	y_max = vl_biomes.overworld_max,
	humidity_point = 58,
	heat_point = 8,
	_vl_biome_type = "snowy",
	_vl_water_temp = "frozen",
	_vl_grass_palette = "snowy_taiga",
	_vl_foliage_palette = "snowy_taiga",
	_vl_water_palette = "snowy",
	_vl_skycolor = "#839EFF",
	_vl_subbiomes = {
		-- A cold beach-like biome, implemented as low part of Cold Taiga
		beach = {
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_water_top = "mcl_core:ice",
			depth_water_top = 1,
			node_filler = "mcl_core:sandstone",
			depth_filler = 2,
			y_min = 1,
			y_max = 2,
			_vl_foliage_palette = "snowy_taiga_beach",
			_vl_skycolor = vl_biomes.skycolor.icy, -- not default, but icy
		},
		-- Water part of the beach. Added to prevent snow being on the ice.
		beach_water = {
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_water_top = "mcl_core:ice",
			depth_water_top = 1,
			node_filler = "mcl_core:sandstone",
			depth_filler = 2,
			y_min = -4,
			y_max = 0,
			_vl_foliage_palette = "snowy_taiga_beach",
			_vl_skycolor = vl_biomes.skycolor.icy, -- not default, but icy
		},
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			y_max = -5,
			vertical_blend = 1,
			_vl_skycolor = vl_biomes.skycolor.icy, -- not default, but icy
		},
	}
})

-- Small lollipop spruce
vl_biomes.register_decoration({
	biomes = {"ColdTaiga"},
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
	biomes = {"ColdTaiga"},
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

vl_biomes.register_spruce_decoration(11000, 0.00150, "mcl_core_spruce_5.mts", {"ColdTaiga"})
vl_biomes.register_spruce_decoration(2500, 0.00325, "mcl_core_spruce_1.mts", {"ColdTaiga"})
vl_biomes.register_spruce_decoration(7000, 0.00425, "mcl_core_spruce_3.mts", {"ColdTaiga"})
vl_biomes.register_spruce_decoration(9000, 0.00325, "mcl_core_spruce_4.mts", {"ColdTaiga"})
