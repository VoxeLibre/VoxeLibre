-- boulders, in MegaTaiga and MegaSpruceTaiga
--local modname = core.get_current_modname()
local modpath = core.get_modpath("mcl_terrain_features") -- FIXME: move to this module

-- Mossy cobblestone boulder (3x3)
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt"},
	terrain_feature = true,
	sidelen = 80,
	noise_params = {
		offset = 0.00015,
		scale = 0.001,
		spread = vector.new(300, 300, 300),
		seed = 775703,
		octaves = 4,
		persist = 0.63,
	},
	biomes = { "MegaTaiga", "MegaSpruceTaiga" },
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = modpath .. "/schematics/mcl_structures_boulder.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

-- Small mossy cobblestone boulder (2x2)
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt"},
	terrain_feature = true,
	sidelen = 80,
	noise_params = {
		offset = 0.001,
		scale = 0.001,
		spread = vector.new(300, 300, 300),
		seed = 775704,
		octaves = 4,
		persist = 0.63,
	},
	biomes = { "MegaTaiga", "MegaSpruceTaiga" },
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = modpath .. "/schematics/mcl_structures_boulder_small.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})
