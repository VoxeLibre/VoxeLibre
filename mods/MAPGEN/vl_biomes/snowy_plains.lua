local mod_mcl_core = core.get_modpath("mcl_core")

-- Ice Plains, aka ice flats, aka Snowy Plains
vl_biomes.register_biome({
	name = "IcePlains",
	node_dust = "mcl_core:snow",
	node_top = "mcl_core:dirt_with_grass_snow",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_water_top = "mcl_core:ice",
	depth_water_top = 2,
	node_river_water = "mcl_core:ice",
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 24,
	heat_point = 8,
	_mcl_biome_type = "snowy",
	_mcl_water_temp = "frozen",
	_mcl_grass_palette_index = 10,
	_mcl_foliage_palette_index = 2,
	_mcl_water_palette_index = 5,
	_mcl_skycolor = vl_biomes.skycolor.icy,
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			_mcl_skycolor = vl_biomes.skycolor.icy, -- not default, but icy
		},
	}
})

-- Small “classic” oak (many biomes)
vl_biomes.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block", "mcl_core:dirt", },
	sidelen = 16,
	noise_params = {
		offset = 0.0,
		scale = 0.0002,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.7
	},
	biomes = {"IcePlains"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

-- Rare spruce in Ice Plains
vl_biomes.register_decoration({
	biomes = {"IcePlains"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_spruce_5.mts",
	place_on = {"group:grass_block"},
	noise_params = {
		offset = -0.00075,
		scale = -0.0015,
		spread = vector.new(250, 250, 250),
		seed = 11,
		octaves = 3,
		persist = 0.7
	},
})

-- Place tall grass on snow in Ice Plains
vl_biomes.register_decoration({
	biomes = {"IcePlains"},
	schematic = {
		size = vector.new(1, 2, 1),
		data = {
			{name = "mcl_core:dirt_with_grass", force_place = true, param2 = 10 },
			{name = "mcl_flowers:tallgrass", param2 = 10},
		},
	},
	place_on = {"group:grass_block"},
	place_y_offset = -1,
	noise_params = {
		offset = -0.08,
		scale = 0.09,
		spread = vector.new(15, 15, 15),
		seed = 420,
		octaves = 3,
		persist = 0.6,
	},
	rank = 1500,
})
