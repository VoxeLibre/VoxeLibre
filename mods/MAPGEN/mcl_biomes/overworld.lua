local modpath = core.get_modpath(core.get_current_modname())

local overworld_path = modpath..DIR_DELIM.."overworld"..DIR_DELIM
local parts = {
	dofile(overworld_path.."ice_plains_spikes.lua"),
	dofile(overworld_path.."cold_taiga.lua"),
	dofile(overworld_path.."mega_taiga.lua"),
	dofile(overworld_path.."extreme_hills.lua"),
	dofile(overworld_path.."stone_beach.lua"),
	dofile(overworld_path.."ice_plains.lua"),
}

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
	end,
}
