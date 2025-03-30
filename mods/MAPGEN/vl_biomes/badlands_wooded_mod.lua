local mod_mcl_core = core.get_modpath("mcl_core")
-- Mesa Plateau FM aka Modified Wooded Badlands Plateau
-- Dryer and more "chaotic"/"weathered down" variant of MesaPlateauF:
-- oak forest is less dense, more coarse dirt, more erratic terrain, vertical blend, more red sand layers,
-- red sand as ores, red sandstone at sandlevel
vl_biomes.register_biome({
	name = "MesaPlateauFM",
	node_top = "mcl_colorblocks:hardened_clay",
	depth_top = 1,
	node_filler = "mcl_colorblocks:hardened_clay",
	node_riverbed = "mcl_core:redsand",
	depth_riverbed = 2,
	node_stone = "mcl_colorblocks:hardened_clay",
	y_min = 12,
	y_max = 29,
	humidity_point = -5,
	heat_point = 60,
	vertical_blend = 5,
	_vl_biome_type = "hot",
	_vl_water_temp = "warm",
	_vl_grass_palette = "badlands_wooded_mod",
	_vl_foliage_palette = "badlands",
	_vl_water_palette = "desert",
	_vl_skycolor = "#6EB1FF",
	_vl_subbiomes = {
		-- Grass plateau
		grasstop = {
			node_top = "mcl_core:dirt_with_grass",
			depth_top = 1,
			node_filler = "mcl_core:coarse_dirt",
			depth_filler = 2,
			node_riverbed = "mcl_core:redsand",
			depth_riverbed = 1,
			y_min = 30,
			y_max = vl_biomes.overworld_max,
		},
		sandlevel = {
			node_top = "mcl_core:redsand",
			depth_top = 3,
			node_filler = "mcl_colorblocks:hardened_clay_orange",
			depth_filler = 3,
			node_stone = "mcl_colorblocks:hardened_clay",
			-- red sand has wider reach than in other mesa biomes
			y_min = -7,
			y_max = 11,
			vertical_blend = 4,
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 3,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 3,
			y_min = vl_biomes.OCEAN_MIN,
			y_max = -8,
			vertical_blend = 2,
		},
	}
})

core.register_ore({
	ore_type = "sheet",
	ore = "mcl_core:coarse_dirt",
	wherein = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
	column_height_max = 1,
	column_midpoint_factor = 0.0,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_threshold = -2.5,
	noise_params = {
		offset = 1,
		scale = 15,
		spread = vector.new(250, 250, 250),
		seed = 24,
		octaves = 3,
		persist = 0.80
	},
	biomes = {"MesaPlateauFM_grasstop"},
})

core.register_ore({
	ore_type = "blob",
	ore = "mcl_core:coarse_dirt",
	wherein = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
	clust_scarcity = 1800,
	clust_num_ores = 65,
	clust_size = 15,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_params = {
		offset = 0,
		scale = 1,
		spread = vector.new(250, 250, 250),
		seed = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	},
	biomes = {"MesaPlateauFM_grasstop"},
})

-- Occasionally dig out portions of MesaPlateauFM
core.register_ore({
	ore_type = "blob",
	ore = "air",
	wherein = {"group:hardened_clay", "group:sand", "mcl_core:coarse_dirt"},
	clust_scarcity = 4000,
	clust_size = 5,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_params = {
		offset = 0,
		scale = 1,
		spread = vector.new(250, 250, 250),
		seed = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	},
	biomes = {"MesaPlateauFM", "MesaPlateauFM_grasstop"},
})

core.register_ore({
	ore_type = "blob",
	ore = "mcl_core:redsandstone",
	wherein = {"mcl_colorblocks:hardened_clay_orange"},
	clust_scarcity = 300,
	clust_size = 8,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_params = {
		offset = 0,
		scale = 1,
		spread = vector.new(250, 250, 250),
		seed = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	},
	biomes = {"MesaPlateauFM_sandlevel"},
})

-- More red sand in MesaPlateauFM
core.register_ore({
	ore_type = "sheet",
	ore = "mcl_core:redsand",
	wherein = {"group:hardened_clay"},
	clust_scarcity = 1,
	clust_num_ores = 12,
	clust_size = 10,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_threshold = 0.1,
	noise_params = {
		offset = 0,
		scale = 15,
		spread = vector.new(130, 130, 130),
		seed = 95,
		octaves = 3,
		persist = 0.70
	},
	biomes = {"MesaPlateauFM"},
})

core.register_ore({
	ore_type = "blob",
	ore = "mcl_core:redsand",
	wherein = {"group:hardened_clay"},
	clust_scarcity = 1500,
	clust_size = 4,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_params = {
		offset = 0,
		scale = 1,
		spread = vector.new(250, 250, 250),
		seed = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	},
	biomes = {"MesaPlateauFM", "MesaPlateauFM_grasstop", "MesaPlateauFM_sandlevel"},
})

-- Small “classic” oak (many biomes)
vl_biomes.register_decoration({
	biomes = {"MesaPlateauFM_grasstop"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	y_min = 30,
	place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
	place_offset_y = 1,
	noise_params = {
		offset = 0.008,
		scale = 0.002,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.7
	},
})
