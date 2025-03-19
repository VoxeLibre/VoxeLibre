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
	_vl_biome_type = "medium",
	_vl_water_temp = "ocean",
	_vl_grass_palette = "birchforest",
	_vl_foliage_palette = "birchforest",
	_vl_water_palette = "plains",
	_vl_skycolor = "#7AA5FF",
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
		},
	}
})

vl_biomes.register_decoration({
	biomes = {"BirchForest"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_birch.mts",
	place_on = {"group:grass_block_no_snow"},
	noise_params = {
		offset = 0.03,
		scale = 0.0025,
		spread = vector.new(250, 250, 250),
		seed = 11,
		octaves = 3,
		persist = 0.66
	},
})

vl_biomes.register_decoration({
	biomes = {"BirchForest"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_birch_bee_nest.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	spawn_by = "group:flower",
	fill_ratio = 0.00002,
	rank = 1550, -- after flowers!
})
