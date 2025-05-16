local modpath = core.get_modpath(core.get_current_modname())

local default_waterfogcolor = "#3F76E4"
local nether_skycolor = "#6EB1FF" -- The Nether biomes seemingly don't use the sky colour, despite having this value according to the wiki. The fog colour is used for both sky and fog.

local mod_mcl_crimson = minetest.get_modpath("mcl_crimson")
local mod_mcl_blackstone = minetest.get_modpath("mcl_blackstone")

return {
	register_biomes = function()
		--[[ THE NETHER ]]
		-- the following decoration is a hack to cover exposed bedrock in netherrack - be careful not to put any ceiling decorations in a way that would apply to this (they would get generated regardless of biome)
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_core:bedrock"},
			sidelen = 16,
			fill_ratio = 10,
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_max + 15,
			height = 6,
			max_height = 10,
			decoration = "mcl_nether:netherrack",
			flags = "all_ceilings",
			param2 = 0,
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_core:bedrock"},
			sidelen = 16,
			fill_ratio = 10,
			y_min = mcl_vars.mg_nether_min - 10,
			y_max = mcl_vars.mg_lava_nether_max,
			height = 7,
			max_height = 14,
			decoration = "mcl_nether:netherrack",
			flags = "all_floors,force_placement",
			param2 = 0,
		})

		minetest.register_biome({
			name = "Nether",
			node_filler = "mcl_nether:netherrack",
			node_stone = "mcl_nether:netherrack",
			node_top = "mcl_nether:netherrack",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_nether_min,

			y_max = mcl_vars.mg_nether_max + 80,
			heat_point = 100,
			humidity_point = 0,
			_mcl_biome_type = "hot",
			_mcl_grass_palette_index = 17,
			_mcl_foliage_palette_index = 3,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = nether_skycolor,
			_mcl_fogcolor = "#330808"
		})

		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_nether:glowstone", "mcl_nether:magma"},
			sidelen = 16,
			fill_ratio = 10,
			biomes = {"Nether"},
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_deco_max,
			decoration = "mcl_nether:netherrack",
			flags = "all_floors",
			param2 = 0,
		})

		minetest.register_biome({
			name = "SoulsandValley",
			node_filler = "mcl_nether:netherrack",
			node_stone = "mcl_nether:netherrack",
			node_top = "mcl_blackstone:soul_soil",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_nether_min,
			y_max = mcl_vars.mg_nether_max + 80,
			heat_point = 77,
			humidity_point = 33,
			_mcl_biome_type = "hot",
			_mcl_grass_palette_index = 17,
			_mcl_foliage_palette_index = 3,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = nether_skycolor,
			_mcl_fogcolor = "#1B4745"
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_nether:magma"},
			sidelen = 16,
			fill_ratio = 10,
			biomes = {"SoulsandValley"},
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_deco_max,
			decoration = "mcl_blackstone:soul_soil",
			flags = "all_floors, all_ceilings",
			param2 = 0,
		})

		minetest.register_ore({
			ore_type = "blob",
			ore = "mcl_nether:soul_sand",
			wherein = {"mcl_nether:netherrack", "mcl_blackstone:soul_soil"},
			clust_scarcity = 100,
			clust_num_ores = 225,
			clust_size = 15,
			biomes = {"SoulsandValley"},
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_deco_max,
			noise_params = {
				offset = 0,
				scale = 1,
				spread = vector.new(250, 250, 250),
				seed = 12345,
				octaves = 3,
				persist = 0.6,
				lacunarity = 2,
				flags = "defaults",
			}
		})
		minetest.register_biome({
			name = "CrimsonForest",
			node_filler = "mcl_nether:netherrack",
			node_stone = "mcl_nether:netherrack",
			node_top = "mcl_crimson:crimson_nylium",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_nether_min,
			y_max = mcl_vars.mg_nether_max + 80,
			heat_point = 60,
			humidity_point = 47,
			_mcl_biome_type = "hot",
			_mcl_grass_palette_index = 17,
			_mcl_foliage_palette_index = 3,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = nether_skycolor,
			_mcl_fogcolor = "#330303"
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_nether:magma", "mcl_blackstone:blackstone"},
			sidelen = 16,
			fill_ratio = 10,
			biomes = {"CrimsonForest"},
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_deco_max,
			decoration = "mcl_crimson:crimson_nylium",
			flags = "all_floors",
			param2 = 0,
		})
		minetest.register_biome({
			name = "WarpedForest",
			node_filler = "mcl_nether:netherrack",
			node_stone = "mcl_nether:netherrack",
			node_top = "mcl_crimson:warped_nylium",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_nether_min,
			y_max = mcl_vars.mg_nether_max + 80,
			heat_point = 37,
			humidity_point = 70,
			_mcl_biome_type = "hot",
			_mcl_grass_palette_index = 17,
			_mcl_foliage_palette_index = 3,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = nether_skycolor,
			_mcl_fogcolor = "#1A051A"
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_nether:magma", "mcl_blackstone:blackstone"},
			sidelen = 16,
			fill_ratio = 10,
			biomes = {"WarpedForest"},
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_deco_max,
			decoration = "mcl_crimson:warped_nylium",
			flags = "all_floors",
			param2 = 0,
		})
		minetest.register_biome({
			name = "BasaltDelta",
			node_filler = "mcl_nether:netherrack",
			node_stone = "mcl_nether:netherrack",
			node_top = "mcl_blackstone:basalt",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_nether_min,
			y_max = mcl_vars.mg_nether_max + 80,
			heat_point = 27,
			humidity_point = 80,
			_mcl_biome_type = "hot",
			_mcl_grass_palette_index = 17,
			_mcl_foliage_palette_index = 3,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = nether_skycolor,
			_mcl_fogcolor = "#685F70"
		})

		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_blackstone:blackstone", "mcl_nether:magma"},
			sidelen = 16,
			fill_ratio = 10,
			biomes = {"BasaltDelta"},
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_deco_max,
			decoration = "mcl_blackstone:basalt",
			flags = "all_floors",
			param2 = 0,
		})

		minetest.register_ore({
			ore_type = "blob",
			ore = "mcl_blackstone:blackstone",
			wherein = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_core:gravel"},
			clust_scarcity = 100,
			clust_num_ores = 400,
			clust_size = 20,
			biomes = {"BasaltDelta"},
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_deco_max,
			noise_params = {
				offset = 0,
				scale = 1,
				spread = vector.new(250, 250, 250),
				seed = 12345,
				octaves = 3,
				persist = 0.6,
				lacunarity = 2,
				flags = "defaults",
			}
		})
	end,
	register_ores = function()
		--[[ NETHER GENERATION ]]
		-- Soul sand
		minetest.register_ore({
			ore_type = "sheet",
			ore = "mcl_nether:soul_sand",
			-- Note: Stone is included only for v6 mapgen support. Netherrack is not generated naturally
			-- in v6, but instead set with the on_generated function in mcl_mapgen_core.
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			clust_scarcity = 13 * 13 * 13,
			clust_size = 5,
			y_min = mcl_vars.mg_nether_min,
			y_max = mcl_worlds.layer_to_y(64, "nether"),
			noise_threshold = 0.0,
			noise_params = {
				offset = 0.5,
				scale = 0.1,
				spread = vector.new(5, 5, 5),
				seed = 2316,
				octaves = 1,
				persist = 0.0
			},
		})

		-- Magma blocks
		minetest.register_ore({
			ore_type = "blob",
			ore = "mcl_nether:magma",
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			clust_scarcity = 8 * 8 * 8,
			clust_num_ores = 45,
			clust_size = 6,
			y_min = mcl_worlds.layer_to_y(23, "nether"),
			y_max = mcl_worlds.layer_to_y(37, "nether"),
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
		})
		minetest.register_ore({
			ore_type = "blob",
			ore = "mcl_nether:magma",
			wherein = {"mcl_nether:netherrack"},
			clust_scarcity = 10 * 10 * 10,
			clust_num_ores = 65,
			clust_size = 8,
			y_min = mcl_worlds.layer_to_y(23, "nether"),
			y_max = mcl_worlds.layer_to_y(37, "nether"),
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
		})

		-- Glowstone
		minetest.register_ore({
			ore_type = "blob",
			ore = "mcl_nether:glowstone",
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			clust_scarcity = 26 * 26 * 26,
			clust_size = 5,
			y_min = mcl_vars.mg_lava_nether_max + 10,
			y_max = mcl_vars.mg_nether_max - 13,
			noise_threshold = 0.0,
			noise_params = {
				offset = 0.5,
				scale = 0.1,
				spread = vector.new(5, 5, 5),
				seed = 17676,
				octaves = 1,
				persist = 0.0
			},
		})

		-- Gravel (Nether)
		minetest.register_ore({
			ore_type = "sheet",
			ore = "mcl_core:gravel",
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			column_height_min = 1,
			column_height_max = 1,
			column_midpoint_factor = 0,
			y_min = mcl_worlds.layer_to_y(63, "nether"),
			-- This should be 65, but for some reason with this setting, the sheet ore really stops at 65. o_O
			y_max = mcl_worlds.layer_to_y(65 + 2, "nether"),
			noise_threshold = 0.2,
			noise_params = {
				offset = 0.0,
				scale = 0.5,
				spread = vector.new(20, 20, 20),
				seed = 766,
				octaves = 3,
				persist = 0.6,
			},
		})

		-- Nether quartz
		if minetest.settings:get_bool("mcl_generate_ores", true) then
			minetest.register_ore({
				ore_type = "scatter",
				ore = "mcl_nether:quartz_ore",
				wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
				clust_scarcity = 850,
				clust_num_ores = 4, -- MC cluster amount: 4-10
				clust_size = 3,
				y_min = mcl_vars.mg_nether_min,
				y_max = mcl_vars.mg_nether_max,
			})
			minetest.register_ore({
				ore_type = "scatter",
				ore = "mcl_nether:quartz_ore",
				wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
				clust_scarcity = 1650,
				clust_num_ores = 8, -- MC cluster amount: 4-10
				clust_size = 4,
				y_min = mcl_vars.mg_nether_min,
				y_max = mcl_vars.mg_nether_max,
			})
		end

		-- Lava springs in the Nether
		minetest.register_ore({
			ore_type = "scatter",
			ore = "mcl_nether:nether_lava_source",
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			clust_scarcity = 13500, --rare
			clust_num_ores = 1,
			clust_size = 1,
			y_min = mcl_vars.mg_lava_nether_max,
			y_max = mcl_vars.mg_nether_max - 13,
		})

		local lava_biomes = {"BasaltDelta", "Nether"}
		minetest.register_ore({
			ore_type = "scatter",
			ore = "mcl_nether:nether_lava_source",
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			clust_scarcity = 500,
			clust_num_ores = 1,
			clust_size = 1,
			biomes = lava_biomes,
			y_min = mcl_vars.mg_nether_min,
			y_max = mcl_vars.mg_lava_nether_max + 1,
		})

		minetest.register_ore({
			ore_type = "scatter",
			ore = "mcl_nether:nether_lava_source",
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			clust_scarcity = 1000,
			clust_num_ores = 1,
			clust_size = 1,
			biomes = lava_biomes,
			y_min = mcl_vars.mg_lava_nether_max + 2,
			y_max = mcl_vars.mg_lava_nether_max + 12,
		})

		minetest.register_ore({
			ore_type = "scatter",
			ore = "mcl_nether:nether_lava_source",
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			clust_scarcity = 2000,
			clust_num_ores = 1,
			clust_size = 1,
			biomes = lava_biomes,
			y_min = mcl_vars.mg_lava_nether_max + 13,
			y_max = mcl_vars.mg_lava_nether_max + 48,
		})
		minetest.register_ore({
			ore_type = "scatter",
			ore = "mcl_nether:nether_lava_source",
			wherein = {"mcl_nether:netherrack", "mcl_core:stone"},
			clust_scarcity = 3500,
			clust_num_ores = 1,
			clust_size = 1,
			biomes = lava_biomes,
			y_min = mcl_vars.mg_lava_nether_max + 49,
			y_max = mcl_vars.mg_nether_max - 13,
		})
	end,
	register_decorations = function()
		--[[ NETHER ]]
		--NETHER WASTES (Nether)
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_nether:netherrack", "mcl_nether:magma"},
			sidelen = 16,
			fill_ratio = 0.04,
			biomes = {"Nether"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 1,
			flags = "all_floors",
			decoration = "mcl_fire:eternal_fire",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_nether:netherrack"},
			sidelen = 16,
			fill_ratio = 0.013,
			biomes = {"Nether"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 1,
			flags = "all_floors",
			decoration = "mcl_mushrooms:mushroom_brown",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_nether:netherrack"},
			sidelen = 16,
			fill_ratio = 0.012,
			biomes = {"Nether"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 1,
			flags = "all_floors",
			decoration = "mcl_mushrooms:mushroom_red",
		})

		-- WARPED FOREST
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_crimson:warped_nylium"},
			sidelen = 16,
			fill_ratio = 0.02,
			biomes = {"WarpedForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 10,
			flags = "all_floors",
			decoration = "mcl_crimson:warped_fungus",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			name = "mcl_biomes:warped_tree1",
			place_on = {"mcl_crimson:warped_nylium"},
			sidelen = 16,
			fill_ratio = 0.007,
			biomes = {"WarpedForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 15,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_crimson .. "/schematics/warped_fungus_1.mts",
			size = vector.new(5, 11, 5),
			rotation = "random",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			name = "mcl_biomes:warped_tree2",
			place_on = {"mcl_crimson:warped_nylium"},
			sidelen = 16,
			fill_ratio = 0.005,
			biomes = {"WarpedForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 10,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_crimson .. "/schematics/warped_fungus_2.mts",
			size = vector.new(5, 6, 5),
			rotation = "random",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			name = "mcl_biomes:warped_tree3",
			place_on = {"mcl_crimson:warped_nylium"},
			sidelen = 16,
			fill_ratio = 0.003,
			biomes = {"WarpedForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 14,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_crimson .. "/schematics/warped_fungus_3.mts",
			size = vector.new(5, 12, 5),
			rotation = "random",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_crimson:warped_nylium", "mcl_crimson:twisting_vines"},
			sidelen = 16,
			fill_ratio = 0.032,
			biomes = {"WarpedForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors",
			height = 2,
			height_max = 8,
			decoration = "mcl_crimson:twisting_vines",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_crimson:warped_nylium"},
			sidelen = 16,
			fill_ratio = 0.0812,
			biomes = {"WarpedForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors",
			max_height = 5,
			decoration = "mcl_crimson:warped_roots",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_crimson:crimson_nylium"},
			sidelen = 16,
			fill_ratio = 0.052,
			biomes = {"WarpedForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors",
			decoration = "mcl_crimson:nether_sprouts",
		})
		-- CRIMSON FOREST
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_crimson:crimson_nylium"},
			sidelen = 16,
			fill_ratio = 0.02,
			biomes = {"CrimsonForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 10,
			flags = "all_floors",
			decoration = "mcl_crimson:crimson_fungus",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			name = "mcl_biomes:crimson_tree1",
			place_on = {"mcl_crimson:crimson_nylium"},
			sidelen = 16,
			fill_ratio = 0.008,
			biomes = {"CrimsonForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 10,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_1.mts",
			size = vector.new(5, 8, 5),
			rotation = "random",
		})
		minetest.register_alias("mcl_biomes:crimson_tree", "mcl_biomes:crimson_tree1") -- legacy inconsistency, fixed 08/2024
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			name = "mcl_biomes:crimson_tree2",
			place_on = {"mcl_crimson:crimson_nylium"},
			sidelen = 16,
			fill_ratio = 0.006,
			biomes = {"CrimsonForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 15,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_2.mts",
			size = vector.new(5, 12, 5),
			rotation = "random",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			name = "mcl_biomes:crimson_tree3",
			place_on = {"mcl_crimson:crimson_nylium"},
			sidelen = 16,
			fill_ratio = 0.004,
			biomes = {"CrimsonForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 20,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_crimson .. "/schematics/crimson_fungus_3.mts",
			size = vector.new(7, 13, 7),
			rotation = "random",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_crimson:warped_nylium", "mcl_crimson:weeping_vines", "mcl_nether:netherrack"},
			sidelen = 16,
			fill_ratio = 0.063,
			biomes = {"CrimsonForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_deco_max,
			flags = "all_ceilings",
			height = 2,
			height_max = 8,
			decoration = "mcl_crimson:weeping_vines",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_crimson:crimson_nylium"},
			sidelen = 16,
			fill_ratio = 0.082,
			biomes = {"CrimsonForest"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors",
			max_height = 5,
			decoration = "mcl_crimson:crimson_roots",
		})

		--SOULSAND VALLEY
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soul_sand"},
			sidelen = 16,
			fill_ratio = 0.062,
			biomes = {"SoulsandValley"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors",
			max_height = 5,
			decoration = "mcl_blackstone:soul_fire",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soulsand"},
			sidelen = 16,
			fill_ratio = 0.000212,
			biomes = {"SoulsandValley"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_blackstone .. "/schematics/mcl_blackstone_nether_fossil_1.mts",
			size = vector.new(5, 8, 5),
			rotation = "random",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soulsand"},
			sidelen = 16,
			fill_ratio = 0.0002233,
			biomes = {"SoulsandValley"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_blackstone .. "/schematics/mcl_blackstone_nether_fossil_2.mts",
			size = vector.new(5, 8, 5),
			rotation = "random",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soulsand"},
			sidelen = 16,
			fill_ratio = 0.000225,
			biomes = {"SoulsandValley"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_blackstone .. "/schematics/mcl_blackstone_nether_fossil_3.mts",
			size = vector.new(5, 8, 5),
			rotation = "random",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			place_on = {"mcl_blackstone:soul_soil", "mcl_nether:soulsand"},
			sidelen = 16,
			fill_ratio = 0.00022323,
			biomes = {"SoulsandValley"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors, place_center_x, place_center_z",
			schematic = mod_mcl_blackstone .. "/schematics/mcl_blackstone_nether_fossil_4.mts",
			size = vector.new(5, 8, 5),
			rotation = "random",
		})
		--BASALT DELTA
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			decoration = "mcl_blackstone:basalt",
			place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
			sidelen = 80,
			height_max = 55,
			noise_params = {
				offset = -0.0085,
				scale = 0.002,
				spread = vector.new(25, 120, 25),
				seed = 2325,
				octaves = 5,
				persist = 2,
				lacunarity = 3.5,
				flags = "absvalue"
			},
			biomes = {"BasaltDelta"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_deco_max - 50,
			flags = "all_floors, all ceilings",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			decoration = "mcl_blackstone:basalt",
			place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
			sidelen = 80,
			height_max = 15,
			noise_params = {
				offset = -0.0085,
				scale = 0.004,
				spread = vector.new(25, 120, 25),
				seed = 235,
				octaves = 5,
				persist = 2.5,
				lacunarity = 3.5,
				flags = "absvalue"
			},
			biomes = {"BasaltDelta"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_deco_max - 15,
			flags = "all_floors, all ceilings",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			decoration = "mcl_blackstone:basalt",
			place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
			sidelen = 80,
			height_max = 3,
			fill_ratio = 0.4,
			biomes = {"BasaltDelta"},
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_deco_max - 15,
			flags = "all_floors, all ceilings",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			decoration = "mcl_nether:magma",
			place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
			sidelen = 80,
			fill_ratio = 0.082323,
			biomes = {"BasaltDelta"},
			place_offset_y = -1,
			y_min = mcl_vars.mg_lava_nether_max + 1,
			flags = "all_floors, all ceilings",
		})
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			decoration = "mcl_nether:nether_lava_source",
			place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
			spawn_by = {"mcl_blackstone:basalt", "mcl_blackstone:blackstone"},
			num_spawn_by = 14,
			sidelen = 80,
			fill_ratio = 4,
			biomes = {"BasaltDelta"},
			place_offset_y = -1,
			y_min = mcl_vars.mg_lava_nether_max + 1,
			y_max = mcl_vars.mg_nether_max - 5,
			flags = "all_floors, force_placement",
		})
	end,
}
