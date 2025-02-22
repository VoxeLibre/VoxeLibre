local mod_mcl_core = core.get_modpath("mcl_core")
-- Flower Forest
vl_biomes.register_biome({
	name = "FlowerForest",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 3,
	y_max = vl_biomes.overworld_max,
	humidity_point = 44,
	heat_point = 32,
	weight = mcl_vars.biome_weights and 0.75 or 1.0, -- Luanti 5.11+
	_vl_biome_type = "medium",
	_vl_water_temp = "ocean",
	_vl_grass_palette = "forest_flower",
	_vl_foliage_palette = "forest",
	_vl_water_palette = "plains",
	_vl_skycolor = "#79A6FF",
	_vl_subbiomes = {
		beach = {
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_filler = "mcl_core:sandstone",
			depth_filler = 1,
			y_min = -2,
			y_max = 2,
			_vl_foliage_palette = "plains", -- FIXME: remove
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
			y_max = -3,
		},
	}
})

-- Small “classic” oak (many biomes)
vl_biomes.register_decoration({
	biomes = {"FlowerForest"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	noise_params = {
		offset = 0.01,
		scale = 0.0022,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
})

vl_biomes.register_decoration({
	biomes = {"FlowerForest"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic_bee_nest.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = 0.0002,
	spawn_by = "group:flower",
	rank = 1550, -- after flowers!
})

-- Birch
vl_biomes.register_decoration({
	biomes = {"FlowerForest"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_birch.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	noise_params = {
		offset = 0.000333,
		scale = -0.0015,
		spread = vector.new(250, 250, 250),
		seed = 11,
		octaves = 3,
		persist = 0.66
	},
})
vl_biomes.register_decoration({
	biomes = {"FlowerForest"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_birch_bee_nest.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	spawn_by = "group:flower",
	fill_ratio = 0.00002,
	rank = 1550, -- after flowers!
})
