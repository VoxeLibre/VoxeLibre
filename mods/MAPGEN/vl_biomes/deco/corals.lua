-- TODO: use priorities, and move this to the module where coral blocks are defined?
local mod_mcl_structures = minetest.get_modpath("mcl_structures")
local coral_min = vl_biomes.OCEAN_MIN
local coral_max = -10
local warm_oceans = vl_biomes.by_water_temp.warm

-- Coral Reefs
for _, c in ipairs({ "brain", "horn", "bubble", "tube", "fire" }) do
	local noise = {
		offset = -0.0085,
		scale = 0.002,
		spread = vector.new(25, 120, 25),
		seed = 235,
		octaves = 5,
		persist = 1.8,
		lacunarity = 3.5,
		flags = "absvalue"
	}
	mcl_mapgen_core.register_decoration({
		deco_type = "schematic",
		place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
		sidelen = 80,
		noise_params = noise,
		biomes = warm_oceans,
		y_min = coral_min,
		y_max = coral_max,
		schematic = mod_mcl_structures .. "/schematics/mcl_structures_coral_" .. c .. "_1.mts",
		rotation = "random",
		flags = "all_floors,force_placement",
	})
	mcl_mapgen_core.register_decoration({
		deco_type = "schematic",
		place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
		noise_params = noise,
		sidelen = 80,
		biomes = warm_oceans,
		y_min = coral_min,
		y_max = coral_max,
		schematic = mod_mcl_structures .. "/schematics/mcl_structures_coral_" .. c .. "_2.mts",
		rotation = "random",
		flags = "all_floors,force_placement",
	})

	mcl_mapgen_core.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_ocean:" .. c .. "_coral_block"},
		sidelen = 16,
		fill_ratio = 3,
		y_min = coral_min,
		y_max = coral_max,
		decoration = "mcl_ocean:" .. c .. "_coral",
		biomes = warm_oceans,
		flags = "force_placement, all_floors",
		height = 1,
		height_max = 1,
	})
	mcl_mapgen_core.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_ocean:horn_coral_block"},
		sidelen = 16,
		fill_ratio = 7,
		y_min = coral_min,
		y_max = coral_max,
		decoration = "mcl_ocean:" .. c .. "_coral_fan",
		biomes = warm_oceans,
		flags = "force_placement, all_floors",
		height = 1,
		height_max = 1,
	})
end

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
	sidelen = 16,
	noise_params = {
		offset = -0.0085,
		scale = 0.002,
		spread = vector.new(25, 120, 25),
		seed = 235,
		octaves = 5,
		persist = 1.8,
		lacunarity = 3.5,
		flags = "absvalue"
	},
	y_min = coral_min,
	y_max = coral_max,
	decoration = "mcl_ocean:dead_brain_coral_block",
	biomes = warm_oceans,
	flags = "force_placement",
	height = 1,
	height_max = 1,
	place_offset_y = -1,
})

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_ocean:dead_brain_coral_block"},
	sidelen = 16,
	fill_ratio = 3,
	y_min = coral_min,
	y_max = coral_max,
	decoration = "mcl_ocean:sea_pickle_1_dead_brain_coral_block",
	biomes = warm_oceans,
	flags = "force_placement, all_floors",
	height = 1,
	height_max = 1,
	place_offset_y = -1,
})
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_ocean:dead_brain_coral_block"},
	sidelen = 16,
	fill_ratio = 3,
	y_min = coral_min,
	y_max = coral_max,
	decoration = "mcl_ocean:sea_pickle_2_dead_brain_coral_block",
	biomes = warm_oceans,
	flags = "force_placement, all_floors",
	height = 1,
	height_max = 1,
	place_offset_y = -1,
})
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_ocean:dead_brain_coral_block"},
	sidelen = 16,
	fill_ratio = 2,
	y_min = coral_min,
	y_max = coral_max,
	decoration = "mcl_ocean:sea_pickle_3_dead_brain_coral_block",
	biomes = warm_oceans,
	flags = "force_placement, all_floors",
	height = 1,
	height_max = 1,
	place_offset_y = -1,
})
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_ocean:dead_brain_coral_block"},
	sidelen = 16,
	fill_ratio = 2,
	y_min = coral_min,
	y_max = coral_max,
	decoration = "mcl_ocean:sea_pickle_4_dead_brain_coral_block",
	biomes = warm_oceans,
	flags = "force_placement, all_floors",
	height = 1,
	height_max = 1,
	place_offset_y = -1,
})
--rare CORAl easter egg
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:sand", "mcl_core:gravel"},
	fill_ratio = 0.0001,
	sidelen = 80,
	biomes = warm_oceans,
	y_min = coral_min,
	y_max = coral_max,
	schematic = mod_mcl_structures .. "/schematics/coral_cora.mts",
	rotation = "random",
	flags = "all_floors,force_placement",
})

