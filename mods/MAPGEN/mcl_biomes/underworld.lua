local modpath = core.get_modpath(core.get_current_modname())

local default_waterfogcolor = "#3F76E4"
local nether_skycolor = "#6EB1FF" -- The Nether biomes seemingly don't use the sky colour, despite having this value according to the wiki. The fog colour is used for both sky and fog.

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
}
