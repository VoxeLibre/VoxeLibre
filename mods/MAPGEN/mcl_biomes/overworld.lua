local modpath = core.get_modpath(core.get_current_modname())

local overworld_path = modpath..DIR_DELIM.."overworld"..DIR_DELIM
local ice_plains_spikes = dofile(overworld_path.."ice_plains_spikes.lua")
local cold_taiga = dofile(overworld_path.."cold_taiga.lua")
local mega_taiga = dofile(overworld_path.."mega_taiga.lua")

local overworld_fogcolor = "#C0D8FF"
local frozen_waterfogcolor = "#3938C9"
local OCEAN_MIN = -15
local ocean_skycolor = "#7BA4FF" -- This is the case for all ocean biomes except for non-deep frozen oceans! Those oceans will have their own colour instead of this one.
local cold_waterfogcolor = "#3D57D6"
local beach_skycolor = "#78A7FF" -- This is the case for all beach biomes except for the snowy ones! Those beaches will have their own colour instead of this one.

-- List of Overworld biomes without modifiers.
-- IMPORTANT: Don't forget to add new Overworld biomes to this list!
local overworld_biomes = {
	"IcePlains",
	"IcePlainsSpikes",
	"ColdTaiga",
	"ExtremeHills",
	"ExtremeHillsM",
	"ExtremeHills+",
	"Taiga",
	"MegaTaiga",
	"MegaSpruceTaiga",
	"StoneBeach",
	"Plains",
	"SunflowerPlains",
	"Forest",
	"FlowerForest",
	"BirchForest",
	"BirchForestM",
	"RoofedForest",
	"Swampland",
	"Jungle",
	"JungleM",
	"JungleEdge",
	"JungleEdgeM",
	"MushroomIsland",
	"Desert",
	"Savanna",
	"SavannaM",
	"Mesa",
	"MesaBryce",
	"MesaPlateauF",
	"MesaPlateauFM",
	"MangroveSwamp",
	"BambooJungle",
	"BambooJungleM",
	"BambooJungleEdge",
	"BambooJungleEdgeM",
}

return {
	biomes = overworld_biomes,
	register_biomes = function()
		ice_plains_spikes.register_biomes()
		cold_taiga.register_biomes()
		mega_taiga.register_biomes()

		-- Extreme Hills
		-- Sparsely populated grasslands with little tallgras and trees.
		minetest.register_biome({
			name = "ExtremeHills",
			node_top = "mcl_core:dirt_with_grass",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 4,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = 4,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 10,
			heat_point = 45,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 6,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ExtremeHills_beach",
			node_top = "mcl_core:sand",
			depth_top = 2,
			depth_water_top = 1,
			node_filler = "mcl_core:sandstone",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = -4,
			y_max = 3,
			humidity_point = 10,
			heat_point = 45,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 6,
			_mcl_foliage_palette_index = 1,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = beach_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ExtremeHills_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 4,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = OCEAN_MIN,
			y_max = -5,
			vertical_blend = 1,
			humidity_point = 10,
			heat_point = 45,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 6,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

		-- Extreme Hills M
		-- Just gravel.
		minetest.register_biome({
			name = "ExtremeHillsM",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_riverbed = "mcl_core:gravel",
			depth_riverbed = 3,
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 0,
			heat_point = 25,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 7,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ExtremeHillsM_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 3,
			y_min = OCEAN_MIN,
			y_max = 0,
			humidity_point = 0,
			heat_point = 25,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 7,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

		-- Extreme Hills+
		-- This biome is near-identical to Extreme Hills on the surface but has snow-covered mountains with spruce/oak
		-- forests above a certain height.
		minetest.register_biome({
			name = "ExtremeHills+",
			node_top = "mcl_core:dirt_with_grass",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 4,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = 1,
			y_max = 41,
			humidity_point = 24,
			heat_point = 25,
			vertical_blend = 6,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 8,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		---- Sub-biome for Extreme Hills+ for those snow forests
		minetest.register_biome({
			name = "ExtremeHills+_snowtop",
			node_dust = "mcl_core:snow",
			node_top = "mcl_core:dirt_with_grass_snow",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 4,
			node_river_water = "mcl_core:ice",
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = 42,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 24,
			heat_point = 25,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 8,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "ExtremeHills+_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 4,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 4,
			y_min = OCEAN_MIN,
			y_max = 0,
			humidity_point = 24,
			heat_point = 25,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 8,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

		-- Stone beach
		-- Just stone.
		-- Not neccessarily a beach at all, only named so according to MC
		minetest.register_biome({
			name = "StoneBeach",
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 1,
			y_min = -7,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 0,
			heat_point = 8,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 9,
			_mcl_foliage_palette_index = 11,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = "#7DA2FF",
			_mcl_fogcolor = overworld_fogcolor
		})

		minetest.register_biome({
			name = "StoneBeach_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 1,
			y_min = OCEAN_MIN,
			y_max = -8,
			vertical_blend = 2,
			humidity_point = 0,
			heat_point = 8,
			_mcl_biome_type = "cold",
			_mcl_grass_palette_index = 9,
			_mcl_foliage_palette_index = 0,
			_mcl_water_palette_index = 4,
			_mcl_waterfogcolor = cold_waterfogcolor,
			_mcl_skycolor = ocean_skycolor,
			_mcl_fogcolor = overworld_fogcolor
		})

		-- Ice Plains
		minetest.register_biome({
			name = "IcePlains",
			node_dust = "mcl_core:snow",
			node_top = "mcl_core:dirt_with_grass_snow",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 2,
			node_water_top = "mcl_core:ice",
			depth_water_top = 2,
			node_river_water = "mcl_core:ice",
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = 1,
			y_max = mcl_vars.mg_overworld_max,
			humidity_point = 24,
			heat_point = 8,
			_mcl_biome_type = "snowy",
			_mcl_grass_palette_index = 10,
			_mcl_foliage_palette_index = 2,
			_mcl_water_palette_index = 5,
			_mcl_waterfogcolor = frozen_waterfogcolor,
			_mcl_skycolor = "#7FA1FF",
			_mcl_fogcolor = overworld_fogcolor
		})
		minetest.register_biome({
			name = "IcePlains_ocean",
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 2,
			y_min = OCEAN_MIN,
			y_max = 0,
			humidity_point = 24,
			heat_point = 8,
			_mcl_biome_type = "snowy",
			_mcl_grass_palette_index = 10,
			_mcl_foliage_palette_index = 2,
			_mcl_water_palette_index = 5,
			_mcl_waterfogcolor = frozen_waterfogcolor,
			_mcl_skycolor = "#7FA1FF",
			_mcl_fogcolor = overworld_fogcolor
		})
	end,
}
