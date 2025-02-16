local mod_mcl_mushrooms = core.get_modpath("mcl_mushrooms")
-- Mushroom Island / Mushroom Island Shore (rare) aka Mushroom Fields
-- Not neccessarily an island at all, only named after Minecraft's biome
vl_biomes.register_biome({
	name = "MushroomIsland",
	node_top = "mcl_core:mycelium",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1, -- was 4, with Shore below
	y_max = 20, -- Note: Limited in height!
	vertical_blend = 1,
	humidity_point = 106,
	heat_point = 50,
	_mcl_biome_type = "medium",
	_mcl_water_temp = "ocean",
	_mcl_grass_palette_index = 29,
	_mcl_foliage_palette_index = 17,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = vl_biomes.skycolor.jungle,
	_vl_subbiomes = {
		-- _shore = { name = "MushroomIslandShore", y_min = 1, y_max = 3, },
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 3,
		},
	}
})

local ratio_mushroom_mycelium = 0.002
local ratio_mushroom_mycelium_huge = ratio_mushroom_mycelium * (11 / 12)
local ratio_mushroom_mycelium_giant = ratio_mushroom_mycelium * (1 / 12)

vl_biomes.register_decoration({
	biomes = {"MushroomIsland"}, --"MushroomIslandShore"},
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_huge_brown.mts",
	place_on = {"mcl_core:mycelium"},
	fill_ratio = ratio_mushroom_mycelium_huge,
	rotation = "0",
})

vl_biomes.register_decoration({
	biomes = {"MushroomIsland"}, --"MushroomIslandShore"},
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_giant_brown.mts",
	place_on = {"mcl_core:mycelium"},
	fill_ratio = ratio_mushroom_mycelium_giant,
	rotation = "0",
})

vl_biomes.register_decoration({
	biomes = {"MushroomIsland"}, --"MushroomIslandShore"},
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_huge_red.mts",
	place_on = {"mcl_core:mycelium"},
	fill_ratio = ratio_mushroom_mycelium_huge,
	rotation = "0",
})

vl_biomes.register_decoration({
	biomes = {"MushroomIsland"}, --"MushroomIslandShore"},
	schematic = mod_mcl_mushrooms .. "/schematics/mcl_mushrooms_giant_red.mts",
	place_on = {"mcl_core:mycelium"},
	fill_ratio = ratio_mushroom_mycelium_giant,
	rotation = "0",
})

-- Mushrooms in mushroom biome
vl_biomes.register_decoration({
	biomes = {"MushroomIsland"}, --"MushroomIsland_shore"},
	decoration = "mcl_mushrooms:mushroom_red",
	place_on = {"mcl_core:mycelium"},
	fill_ratio = 0.009,
	noise_threshold = 2.0,
})

vl_biomes.register_decoration({
	biomes = {"MushroomIsland"}, --"MushroomIsland_shore"},
	decoration = "mcl_mushrooms:mushroom_brown",
	place_on = {"mcl_core:mycelium"},
	fill_ratio = 0.009,
})
