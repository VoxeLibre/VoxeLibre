local mod_mcl_core = core.get_modpath("mcl_core")
-- Forest
vl_biomes.register_biome({
	name = "Forest",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 61,
	heat_point = 45,
	_mcl_biome_type = "medium",
	_mcl_water_temp = "ocean",
	_mcl_grass_palette_index = 13,
	_mcl_foliage_palette_index = 7,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = "#79A6FF",
	_vl_subbiomes = {
		beach = {
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_filler = "mcl_core:sandstone",
			depth_filler = 1,
			y_min = -1,
			y_max = 0,
			_mcl_foliage_palette_index = 1, -- FIXME: remove?
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
			y_max = -2,
		},
	}
})

for i = 1, 4 do
	mcl_mapgen_core.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		sidelen = 16,
		noise_params = {
			offset = 0.000545,
			scale = 0.0011,
			spread = vector.new(250, 250, 250),
			seed = 3 + 5 * i,
			octaves = 3,
			persist = 0.66
		},
		biomes = {"Forest"},
		y_min = 1,
		y_max = vl_biomes.overworld_max,
		schematic = mod_mcl_core .. "/schematics/mcl_core_oak_large_"..i..".mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
end

-- Small “classic” oak (many biomes)
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 16,
	noise_params = {
		offset = 0.025,
		scale = 0.0022,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.66
	},
	biomes = {"Forest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
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
	},]]
	fill_ratio = 0.00002,
	biomes = {"Forest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic_bee_nest.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
	spawn_by = "group:flower",
	rank = 1550, -- after flowers!
})

-- Rare balloon oak
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 16,
	noise_params = {
		offset = 0.002083,
		scale = 0.0022,
		spread = vector.new(250, 250, 250),
		seed = 3,
		octaves = 3,
		persist = 0.6,
	},
	biomes = {"Forest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_balloon.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

-- Birch
mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 16,
	noise_params = {
		offset = 0.000333,
		scale = -0.0015,
		spread = vector.new(250, 250, 250),
		seed = 11,
		octaves = 3,
		persist = 0.66
	},
	biomes = {"Forest"},
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
	biomes = {"Forest"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_birch_bee_nest.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
	spawn_by = "group:flower",
	rank = 1550, -- after flowers!
})
