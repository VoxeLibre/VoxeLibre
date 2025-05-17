local modpath = core.get_modpath(core.get_current_modname())

local overworld_path = modpath..DIR_DELIM.."overworld"..DIR_DELIM
local parts = {
	dofile(overworld_path.."ice_plains_spikes.lua"),
	dofile(overworld_path.."cold_taiga.lua"),
	dofile(overworld_path.."mega_taiga.lua"),
	dofile(overworld_path.."extreme_hills.lua"),
	dofile(overworld_path.."stone_beach.lua"),
}

local overworld_fogcolor = "#C0D8FF"
local frozen_waterfogcolor = "#3938C9"
local OCEAN_MIN = -15

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
		for _,part in ipairs(parts) do
			part.register_biomes()
		end

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
