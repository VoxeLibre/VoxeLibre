local mod_mcl_core = core.get_modpath("mcl_core")
-- Birch Forest
vl_biomes.register_biome({
	name = "BirchForest",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 78,
	heat_point = 31,
	_mcl_biome_type = "medium",
	_mcl_water_temp = "ocean",
	_mcl_grass_palette_index = 15,
	_mcl_foliage_palette_index = 8,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = "#7AA5FF",
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
		},
	}
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow"},
	sidelen = 16,
	noise_params = {
		offset = 0.03,
		scale = 0.0025,
		spread = vector.new(250, 250, 250),
		seed = 11,
		octaves = 3,
		persist = 0.66
	},
	biomes = {"BirchForest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_birch.mts",
	flags = "place_center_x, place_center_z",
})

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 16,
	--[[noise_params = {
		offset = 0.01,
		scale = 0.00001,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.33
	},]]--
	fill_ratio = 0.00002,
	biomes = {"BirchForest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_birch_bee_nest.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
	spawn_by = "group:flower",
	rank = 1550, -- after flowers!
})
