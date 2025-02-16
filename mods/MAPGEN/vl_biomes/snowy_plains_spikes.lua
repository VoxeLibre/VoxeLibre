local modpath = core.get_modpath(core.get_current_modname())

-- Ice Plains Spikes (rare) aka Ice Spikes
vl_biomes.register_biome({
	name = "IcePlainsSpikes",
	node_top = "mcl_core:snowblock",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_water_top = "mcl_core:ice",
	depth_water_top = 1,
	node_river_water = "mcl_core:ice",
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 24,
	heat_point = -5,
	_mcl_biome_type = "snowy",
	_mcl_water_temp = "frozen",
	_mcl_grass_palette_index = 2,
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

-- FIXME: on slopes, they tend to float on one side. Use even larger spikes and a negative y_offset? Use terraforming with ice?
-- Large ice spike
vl_biomes.register_decoration({
	biomes = {"IcePlainsSpikes"},
	schematic = modpath .. "/schematics/mcl_structures_ice_spike_large.mts",
	terrain_feature = true,
	place_on = {"mcl_core:snowblock", "mcl_core:snow", "group:grass_block_snow"},
	y_min = 4,
	noise_params = {
		offset = 0.00040,
		scale = 0.001,
		spread = vector.new(250, 250, 250),
		seed = 1133,
		octaves = 4,
		persist = 0.67,
	},
})

-- Small ice spike
vl_biomes.register_decoration({
	biomes = {"IcePlainsSpikes"},
	schematic = modpath .. "/schematics/mcl_structures_ice_spike_small.mts",
	terrain_feature = true,
	place_on = {"mcl_core:snowblock", "mcl_core:snow", "group:grass_block_snow"},
	y_min = 4,
	noise_params = {
		offset = 0.005,
		scale = 0.001,
		spread = vector.new(250, 250, 250),
		seed = 1133,
		octaves = 4,
		persist = 0.67,
	},
})
