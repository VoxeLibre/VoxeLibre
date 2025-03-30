local mod_mcl_core = core.get_modpath("mcl_core")

-- Mesa Plateau F aka Wooded Badlands
-- Identical to Mesa below Y=30. At Y=30 and above there is a "dry" oak forest
vl_biomes.register_biome({
	name = "MesaPlateauF",
	node_top = "mcl_colorblocks:hardened_clay",
	depth_top = 1,
	node_filler = "mcl_colorblocks:hardened_clay",
	node_riverbed = "mcl_core:redsand",
	depth_riverbed = 1,
	node_stone = "mcl_colorblocks:hardened_clay",
	y_min = 11,
	y_max = 29,
	humidity_point = 0,
	heat_point = 60,
	vertical_blend = 0, -- we want a sharp transition
	_vl_biome_type = "hot",
	_vl_water_temp = "warm",
	_vl_grass_palette = "badlands_wooded",
	_vl_foliage_palette = "badlands",
	_vl_water_palette = "desert",
	_vl_skycolor = "#6EB1FF",
	_vl_subbiomes = {
		-- The oak forest plateau of this biome.
		-- This is a plateau for grass blocks, dry shrubs, tall grass, coarse dirt and oaks.
		-- Strata don't generate here.
		grasstop = {
			node_top = "mcl_core:dirt_with_grass",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 1,
			y_min = 30,
			y_max = vl_biomes.overworld_max,
		},
		sandlevel = {
			node_top = "mcl_core:redsand",
			depth_top = 2,
			node_filler = "mcl_colorblocks:hardened_clay_orange",
			depth_filler = 3,
			node_stone = "mcl_colorblocks:hardened_clay_orange",
			y_min = -5,
			y_max = 10,
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 3,
			node_filler = "mcl_core:sand",
			depth_filler = 2,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_max = -6,
			vertical_blend = 1,
		},
	}
})

-- Random coarse dirt floor in Mesa Plateau F
core.register_ore({
	ore_type = "sheet",
	ore = "mcl_core:coarse_dirt",
	wherein = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
	column_height_max = 1,
	column_midpoint_factor = 0.0,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_threshold = 0.0,
	noise_params = {
		offset = 0,
		scale = 15,
		spread = vector.new(250, 250, 250),
		seed = 24,
		octaves = 3,
		persist = 0.70
	},
	biomes = {"MesaPlateauF_grasstop"},
})
core.register_ore({
	ore_type = "blob",
	ore = "mcl_core:coarse_dirt",
	wherein = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
	clust_scarcity = 1500,
	clust_num_ores = 25,
	clust_size = 7,
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
	biomes = {"MesaPlateauF_grasstop"},
})

-- Small “classic” oak (many biomes)
vl_biomes.register_decoration({
	biomes = {"MesaPlateauF_grasstop"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	y_min = 30,
	place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
	place_offset_y = 1,
	noise_params = {
		offset = 0.015,
		scale = 0.002,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.7
	},
})
