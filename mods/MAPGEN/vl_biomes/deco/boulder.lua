-- boulders, in MegaTaiga and MegaSpruceTaiga
local modpath = core.get_modpath(core.get_current_modname())

-- Mossy cobblestone boulder (3x3)
vl_biomes.register_decoration({
	biomes = { "MegaTaiga", "MegaSpruceTaiga" },
	schematic = modpath .. "/schematics/mcl_structures_boulder.mts",
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt"},
	place_offset_y = 0, -- TODO: make schematic less tall?
	noise_params = {
		offset = 0.00015,
		scale = 0.001,
		spread = vector.new(300, 300, 300),
		seed = 775703,
		octaves = 4,
		persist = 0.63,
	},
	terrain_feature = true,
})

-- Small mossy cobblestone boulder (2x2)
vl_biomes.register_decoration({
	biomes = { "MegaTaiga", "MegaSpruceTaiga" },
	schematic = modpath .. "/schematics/mcl_structures_boulder_small.mts",
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	place_on = {"mcl_core:podzol", "mcl_core:dirt", "mcl_core:coarse_dirt"},
	place_offset_y = 0, -- TODO: make schematic less tall?
	noise_params = {
		offset = 0.001,
		scale = 0.001,
		spread = vector.new(300, 300, 300),
		seed = 775704,
		octaves = 4,
		persist = 0.63,
	},
	terrain_feature = true,
})
