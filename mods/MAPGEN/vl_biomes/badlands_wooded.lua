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
	_mcl_biome_type = "hot",
	_mcl_water_temp = "warm",
	_mcl_grass_palette_index = 21,
	_mcl_foliage_palette_index = 4,
	_mcl_water_palette_index = 3,
	_mcl_skycolor = "#6EB1FF",
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
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt"},
	sidelen = 16,
	noise_params = {
		offset = 0.015,
		scale = 0.002,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.7
	},
	biomes = {"MesaPlateauF_grasstop"},
	y_min = 30,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})
