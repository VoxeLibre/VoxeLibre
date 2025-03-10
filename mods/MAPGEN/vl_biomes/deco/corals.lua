-- TODO: move corals to the mcl_ocean module?
local modpath = core.get_modpath(core.get_current_modname())

local coral_min = vl_biomes.OCEAN_MIN
local coral_max = -10
local warm_oceans = table.copy(vl_biomes.by_water_temp.warm)
for _, v in ipairs(vl_biomes.by_water_temp.lukewarm) do table.insert(warm_oceans, v) end
--core.log("action", "Warm oceans: "..dump(warm_oceans,""))

local function clear_kelp(t, minp, maxp, blockseed)
	for _,pos in pairs(t) do
		local pos_minp = vector.offset(pos, -8, -4, -8)
		local pos_maxp = vector.offset(pos,  8,  2,  8)
		mcl_ocean.kelp.remove_kelp_below_structure(pos_minp, pos_maxp)
	end
end

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
		name = "coral_deco_"..c.."_s1",
		deco_type = "schematic",
		place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
		terrain_feature = true,
		sidelen = 80,
		noise_params = noise,
		biomes = warm_oceans,
		y_min = coral_min,
		y_max = coral_max,
		schematic = modpath .. "/schematics/mcl_structures_coral_" .. c .. "_1.mts",
		rotation = "random",
		flags = "all_floors,force_placement",
		spawn_by = "mcl_core:water_source",
		check_offset = 1,
		num_spawn_by = 12,
		gen_callback = clear_kelp,
	})
	mcl_mapgen_core.register_decoration({
		name = "coral_deco_"..c.."_s2",
		deco_type = "schematic",
		place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
		terrain_feature = true,
		noise_params = noise,
		sidelen = 80,
		biomes = warm_oceans,
		y_min = coral_min,
		y_max = coral_max,
		schematic = modpath .. "/schematics/mcl_structures_coral_" .. c .. "_2.mts",
		rotation = "random",
		flags = "all_floors,force_placement",
		spawn_by = "mcl_core:water_source",
		check_offset = 1,
		num_spawn_by = 12,
		gen_callback = clear_kelp,
	})

	mcl_mapgen_core.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_ocean:" .. c .. "_coral_block"},
		terrain_feature = true,
		sidelen = 16,
		fill_ratio = 3,
		y_min = coral_min,
		y_max = coral_max,
		decoration = "mcl_ocean:" .. c .. "_coral",
		biomes = warm_oceans,
		flags = "force_placement, all_floors",
		height = 1,
		spawn_by = "mcl_core:water_source",
		check_offset = 1,
		num_spawn_by = 12,
	})

	mcl_mapgen_core.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_ocean:horn_coral_block"},
		terrain_feature = true,
		sidelen = 16,
		fill_ratio = 7,
		y_min = coral_min,
		y_max = coral_max,
		decoration = "mcl_ocean:" .. c .. "_coral_fan",
		biomes = warm_oceans,
		flags = "force_placement, all_floors",
		height = 1,
		spawn_by = "mcl_core:water_source",
		check_offset = 1,
		num_spawn_by = 12,
	})
end

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
	terrain_feature = true,
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
	terrain_feature = true,
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
	terrain_feature = true,
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
	terrain_feature = true,
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
	terrain_feature = true,
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
--rare CORAl easter egg (multicolored coral)
mcl_mapgen_core.register_decoration({
	name = "coral_deco_cora",
	deco_type = "schematic",
	place_on = {"group:sand", "mcl_core:gravel"},
	terrain_feature = true,
	fill_ratio = 0.0001,
	sidelen = 80,
	biomes = warm_oceans,
	y_min = coral_min,
	y_max = coral_max,
	schematic = modpath .. "/schematics/coral_cora.mts",
	rotation = "random",
	flags = "all_floors,force_placement",
	spawn_by = "mcl_core:water_source",
	check_offset = 1,
	num_spawn_by = 12,
	gen_callback = clear_kelp,
})
