local frozen_waterfogcolor = "#3938C9"
local overworld_fogcolor = "#C0D8FF"
local OCEAN_MIN = -15

return {
	register_biomes = function()
		-- Ice Plains Spikes (rare)
		minetest.register_biome({
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
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 24,
			heat_point = -5,
			_mcl_biome_type = "snowy",
			_mcl_grass_palette_index = 2,
			_mcl_foliage_palette_index = 2,
			_mcl_water_palette_index = 5,
			_mcl_waterfogcolor = frozen_waterfogcolor,
			_mcl_skycolor = "#7FA1FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "IcePlainsSpikes_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 2,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_river_water = "mcl_core:ice",
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = OCEAN_MIN,
			y_max = 0,
			humidity_point = 24,
			heat_point = -5,
			_mcl_biome_type = "snowy",
			_mcl_grass_palette_index = 2,
			_mcl_foliage_palette_index = 2,
			_mcl_water_palette_index = 5,
			_mcl_waterfogcolor = frozen_waterfogcolor,
			_mcl_skycolor = "#7FA1FF",
			_mcl_fogcolor = overworld_fogcolor
		})
	end,
}
