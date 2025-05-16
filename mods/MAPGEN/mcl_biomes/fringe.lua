local modpath = core.get_modpath(core.get_current_modname())

local mg_name = minetest.get_mapgen_setting("mg_name")
local mg_seed = minetest.get_mapgen_setting("seed")

local default_waterfogcolor = "#3F76E4"
local end_skycolor = "#000000"
local end_fogcolor = "#A080A0" -- The End biomes seemingly don't use the fog colour, despite having this value according to the wiki. The sky colour is used for both sky and fog.

return {
	register_biomes = function()
		--[[ THE END ]]
		minetest.register_biome({
			name = "End",
			node_stone = "air",
			node_filler = "air",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_end_min,
			y_max = mcl_vars.mg_end_max + 80,
			heat_point = 1000, --ridiculously high values so End Island always takes precedent
			humidity_point = 1000,
			vertical_blend = 16,
			_mcl_biome_type = "medium",
			_mcl_grass_palette_index = 0,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = end_skycolor,
			_mcl_fogcolor = end_fogcolor
		})
		minetest.register_biome({
			name = "EndBarrens",
			node_stone = "air",
			node_filler = "air",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_end_min,
			y_max = mcl_vars.mg_end_max + 80,
			heat_point = 1000,
			humidity_point = 1000,
			vertical_blend = 16,
			_mcl_biome_type = "medium",
			_mcl_grass_palette_index = 0,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = end_skycolor,
			_mcl_fogcolor = end_fogcolor
		})
		minetest.register_biome({
			name = "EndMidlands",
			node_stone = "air",
			node_filler = "air",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_end_min,
			y_max = mcl_vars.mg_end_max + 80,
			heat_point = 1000,
			humidity_point = 1000,
			vertical_blend = 16,
			_mcl_biome_type = "medium",
			_mcl_grass_palette_index = 0,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = end_skycolor,
			_mcl_fogcolor = end_fogcolor
		})
		minetest.register_biome({
			name = "EndHighlands",
			node_stone = "air",
			node_filler = "air",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_end_min,
			y_max = mcl_vars.mg_end_max + 80,
			heat_point = 1000,
			humidity_point = 1000,
			vertical_blend = 16,
			_mcl_biome_type = "medium",
			_mcl_grass_palette_index = 0,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = end_skycolor,
			_mcl_fogcolor = end_fogcolor
		})
		minetest.register_biome({
			name = "EndSmallIslands",
			node_stone = "air",
			node_filler = "air",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_end_min,
			y_max = mcl_vars.mg_end_max + 80,
			heat_point = 1000,
			humidity_point = 1000,
			vertical_blend = 16,
			_mcl_biome_type = "medium",
			_mcl_grass_palette_index = 0,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = end_skycolor,
			_mcl_fogcolor = end_fogcolor
		})

		minetest.register_biome({
			name = "EndBorder",
			node_stone = "air",
			node_filler = "air",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			y_min = mcl_vars.mg_end_min,
			y_max = mcl_vars.mg_end_max + 80,
			heat_point = 500,
			humidity_point = 500,
			vertical_blend = 16,
			max_pos = vector.new(1250, mcl_vars.mg_end_min + 512, 1250),
			min_pos = vector.new(-1250, mcl_vars.mg_end_min, -1250),
			_mcl_biome_type = "medium",
			_mcl_grass_palette_index = 0,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = end_skycolor,
			_mcl_fogcolor = end_fogcolor
		})

		minetest.register_biome({
			name = "EndIsland",
			node_stone = "air",
			node_filler = "air",
			node_water = "air",
			node_river_water = "air",
			node_cave_liquid = "air",
			max_pos = vector.new(650, mcl_vars.mg_end_min + 512, 650),
			min_pos = vector.new(-650, mcl_vars.mg_end_min, -650),
			heat_point = 50,
			humidity_point = 50,
			vertical_blend = 16,
			_mcl_biome_type = "medium",
			_mcl_grass_palette_index = 0,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 0,
			_mcl_waterfogcolor = default_waterfogcolor,
			_mcl_skycolor = end_skycolor,
			_mcl_fogcolor = end_fogcolor
		})
	end,
	register_ores = function()
		--[[ THE END ]]

		-- Generate fake End
		-- TODO: Remove the "ores" when there's a better End generator
		-- FIXME: Broken lighting in v6 mapgen

		local end_wherein
		if mg_name == "v6" then
			end_wherein = {"air", "mcl_core:stone"}
		else
			end_wherein = {"air"}
		end

		local mult = 1.0

		minetest.register_ore({
			ore_type = "stratum",
			ore = "mcl_end:end_stone",
			wherein = end_wherein,
			biomes = {"EndSmallIslands", "Endborder"},
			y_min = mcl_vars.mg_end_min + 64,
			y_max = mcl_vars.mg_end_min + 80,
			clust_num_ores = 3375,
			clust_size = 15,

			noise_params = {
				offset = mcl_vars.mg_end_min + 70,
				scale = -1,
				spread = vector.new(84, 84, 84),
				seed = 145,
				octaves = 3,
				persist = 0.6,
				lacunarity = 2,
				--flags = "defaults",
			},

			np_stratum_thickness = {
				offset = 0,
				scale = 15,
				spread = vector.new(84, 84, 84),
				seed = 145,
				octaves = 3,
				persist = 0.6,
				lacunarity = 2,
				--flags = "defaults",
			},
			clust_scarcity = 1,
		})

		minetest.register_ore({
			ore_type = "stratum",
			ore = "mcl_end:end_stone",
			wherein = end_wherein,
			biomes = {"End", "EndMidlands", "EndHighlands", "EndBarrens"},
			y_min = mcl_vars.mg_end_min + 64,
			y_max = mcl_vars.mg_end_min + 80,

			noise_params = {
				offset = mcl_vars.mg_end_min + 70,
				scale = -1,
				spread = vector.new(126, 126, 126),
				seed = mg_seed + 9999,
				octaves = 3,
				persist = 0.5,
			},

			np_stratum_thickness = {
				offset = -2,
				scale = 10,
				spread = vector.new(126, 126, 126),
				seed = mg_seed + 9999,
				octaves = 3,
				persist = 0.5,
			},
			clust_scarcity = 1,
		})

		minetest.register_ore({
			ore_type = "stratum",
			ore = "mcl_end:end_stone",
			wherein = end_wherein,
			biomes = {"End", "EndMidlands", "EndHighlands", "EndBarrens"},
			y_min = mcl_vars.mg_end_min + 64,
			y_max = mcl_vars.mg_end_min + 80,

			noise_params = {
				offset = mcl_vars.mg_end_min + 72,
				scale = -3,
				spread = vector.new(84, 84, 84),
				seed = mg_seed + 999,
				octaves = 4,
				persist = 0.8,
			},

			np_stratum_thickness = {
				offset = -4,
				scale = 10,
				spread = vector.new(84, 84, 84),
				seed = mg_seed + 999,
				octaves = 4,
				persist = 0.8,
			},
			clust_scarcity = 1,
		})
		minetest.register_ore({
			ore_type = "stratum",
			ore = "mcl_end:end_stone",
			wherein = end_wherein,
			biomes = {"End", "EndMidlands", "EndHighlands", "EndBarrens"},
			y_min = mcl_vars.mg_end_min + 64,
			y_max = mcl_vars.mg_end_min + 80,

			noise_params = {
				offset = mcl_vars.mg_end_min + 70,
				scale = -2,
				spread = vector.new(84, 84, 84),
				seed = mg_seed + 99,
				octaves = 4,
				persist = 0.85,
			},

			np_stratum_thickness = {
				offset = -3,
				scale = 5,
				spread = vector.new(63, 63, 63),
				seed = mg_seed + 50,
				octaves = 4,
				persist = 0.85,
			},
			clust_scarcity = 1,
		})
	end,
	register_decorations = function()
		--[[ THE END ]]

		-- Chorus plant
		mcl_mapgen_core.register_decoration({
			name = "mcl_biomes:chorus",
			deco_type = "simple",
			place_on = {"mcl_end:end_stone"},
			flags = "all_floors",
			sidelen = 16,
			noise_params = {
				offset = -0.012,
				scale = 0.024,
				spread = vector.new(100, 100, 100),
				seed = 257,
				octaves = 3,
				persist = 0.6
			},
			y_min = mcl_vars.mg_end_min,
			y_max = mcl_vars.mg_end_max,
			decoration = "mcl_end:chorus_plant",
			height = 1,
			height_max = 8,
			biomes = {"End", "EndMidlands", "EndHighlands", "EndBarrens", "EndSmallIslands"},
		})
		mcl_mapgen_core.register_decoration({
			name = "mcl_biomes:chorus_plant",
			deco_type = "simple",
			place_on = {"mcl_end:chorus_plant"},
			flags = "all_floors",
			sidelen = 16,
			fill_ratio = 10,
			--[[noise_params = {
				offset = -0.012,
				scale = 0.024,
				spread = vector.new(100, 100, 100),
				seed = 257,
				octaves = 3,
				persist = 0.6
			},--]]
			y_min = mcl_vars.mg_end_min,
			y_max = mcl_vars.mg_end_max,
			decoration = "mcl_end:chorus_flower",
			height = 1,
			biomes = {"End", "EndMidlands", "EndHighlands", "EndBarrens", "EndSmallIslands"},
			gen_callback = function(t, minp, maxp, blockseed)
				local pr = PcgRandom(blockseed + mg_seed + 99682)
				for _, pos in ipairs(t) do
					local x, y, z = pos.x, pos.y, pos.z
					if x < -10 or x > 10 or z < -10 or z > 10 then
						local realpos = vector.new(x, y + 1, z)
						local node = minetest.get_node(realpos)
						if node and node.name == "mcl_end:chorus_flower" then
							mcl_end.grow_chorus_plant(realpos, node, pr)
						end
					end
				end
			end,
		})
		-- TODO: End cities
	end,
}
