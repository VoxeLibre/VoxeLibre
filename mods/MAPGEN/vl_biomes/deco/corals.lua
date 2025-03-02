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
		offset = -0.0025,
		scale = 0.002,
		spread = vector.new(25, 120, 25),
		seed = 235,
		octaves = 4,
		persist = 1.8,
		lacunarity = 3.5,
		flags = "absvalue"
	}
	vl_biomes.register_decoration({
		name = "coral_deco_"..c.."_s1",
		biomes = warm_oceans,
		schematic = modpath .. "/schematics/mcl_structures_coral_" .. c .. "_1.mts",
		y_min = coral_min,
		y_max = coral_max,
		place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
		place_offset_y = 1,
		spawn_by = "mcl_core:water_source",
		check_offset = 1,
		num_spawn_by = 12,
		noise_params = noise,
		flags = "all_floors,force_placement",
		gen_callback = clear_kelp,
		terrain_feature = true,
	})
	vl_biomes.register_decoration({
		name = "coral_deco_"..c.."_s2",
		biomes = warm_oceans,
		schematic = modpath .. "/schematics/mcl_structures_coral_" .. c .. "_2.mts",
		y_min = coral_min,
		y_max = coral_max,
		place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
		spawn_by = "mcl_core:water_source",
		check_offset = 1,
		num_spawn_by = 12,
		noise_params = noise,
		flags = "all_floors,force_placement",
		gen_callback = clear_kelp,
		terrain_feature = true,
	})

	vl_biomes.register_decoration({
		biomes = warm_oceans,
		decoration = "mcl_ocean:" .. c .. "_coral",
		y_min = coral_min,
		y_max = coral_max,
		place_on = {"mcl_ocean:" .. c .. "_coral_block"},
		spawn_by = "mcl_core:water_source",
		check_offset = 1,
		num_spawn_by = 12,
		fill_ratio = 3,
		flags = "force_placement, all_floors",
		terrain_feature = true,
	})

	vl_biomes.register_decoration({
		biomes = warm_oceans,
		decoration = "mcl_ocean:" .. c .. "_coral_fan",
		y_min = coral_min,
		y_max = coral_max,
		place_on = {"mcl_ocean:horn_coral_block"},
		spawn_by = "mcl_core:water_source",
		check_offset = 1,
		num_spawn_by = 12,
		fill_ratio = 7,
		flags = "force_placement, all_floors",
		terrain_feature = true,
	})
end

vl_biomes.register_decoration({
	biomes = warm_oceans,
	decoration = "mcl_ocean:dead_brain_coral_block",
	y_min = coral_min,
	y_max = coral_max,
	place_on = {"group:sand", "mcl_core:gravel", "mcl_mud:mud"},
	place_offset_y = -1,
	noise_params = {
		offset = -0.0085,
		scale = 0.002,
		spread = vector.new(25, 120, 25),
		seed = 235,
		octaves = 4,
		persist = 1.8,
		lacunarity = 3.5,
		flags = "absvalue"
	},
	flags = "force_placement",
	terrain_feature = true,
})

vl_biomes.register_decoration({
	biomes = warm_oceans,
	decoration = "mcl_ocean:sea_pickle_1_dead_brain_coral_block",
	y_min = coral_min,
	y_max = coral_max,
	place_on = {"mcl_ocean:dead_brain_coral_block"},
	place_offset_y = -1,
	fill_ratio = 3,
	flags = "force_placement, all_floors",
	terrain_feature = true,
})
vl_biomes.register_decoration({
	biomes = warm_oceans,
	decoration = "mcl_ocean:sea_pickle_2_dead_brain_coral_block",
	y_min = coral_min,
	y_max = coral_max,
	place_on = {"mcl_ocean:dead_brain_coral_block"},
	place_offset_y = -1,
	fill_ratio = 3,
	flags = "force_placement, all_floors",
	terrain_feature = true,
})
vl_biomes.register_decoration({
	biomes = warm_oceans,
	decoration = "mcl_ocean:sea_pickle_3_dead_brain_coral_block",
	y_min = coral_min,
	y_max = coral_max,
	place_on = {"mcl_ocean:dead_brain_coral_block"},
	place_offset_y = -1,
	fill_ratio = 2,
	flags = "force_placement, all_floors",
	terrain_feature = true,
})
vl_biomes.register_decoration({
	biomes = warm_oceans,
	decoration = "mcl_ocean:sea_pickle_4_dead_brain_coral_block",
	y_min = coral_min,
	y_max = coral_max,
	place_on = {"mcl_ocean:dead_brain_coral_block"},
	place_offset_y = -1,
	fill_ratio = 2,
	flags = "force_placement, all_floors",
	terrain_feature = true,
})
