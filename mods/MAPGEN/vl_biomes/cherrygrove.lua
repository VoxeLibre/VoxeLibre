local mod_cherry_blossom = minetest.get_modpath("mcl_cherry_blossom")
-- Cherry Grove
vl_biomes.register_biome({
	name = "CherryGrove",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 18,
	y_max = vl_biomes.overworld_max,
	humidity_point = 41,
	heat_point = 55,
	_mcl_biome_type = "medium",
	_mcl_water_temp = "ocean",
	_mcl_grass_palette_index = 11,
	_mcl_foliage_palette_index = 1,
	_mcl_water_palette_index = 0,
	_mcl_skycolor = "#78A7FF",
	_beach = {
		node_top = "mcl_core:sand",
		depth_top = 2,
		node_filler = "mcl_core:sandstone",
		depth_filler = 2,
		y_min = 0,
		y_max = 2,
	},
	_ocean = {
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		y_max = -1,
	},
})

-- Cherry trees
for i=1,3 do
	mcl_mapgen_core.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 80,
		noise_params = {
			offset = -0.005,
			scale = 0.05,
			spread = {x = 250, y = 250, z = 250},
			seed = 13+i,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"CherryGrove"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_cherry_blossom.."/schematics/mcl_cherry_blossom_tree_"..i..".mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
	mcl_mapgen_core.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 80,
		noise_params = {
			offset = 0.0005,
			scale = 0.0001,
			spread = {x = 250, y = 250, z = 250},
			seed = 32+i,
			octaves = 3,
			persist = 0.01
		},
		biomes = {"CherryGrove"},
		y_min = 1,
		y_max = mcl_vars.mg_overworld_max,
		schematic = mod_cherry_blossom.."/schematics/mcl_cherry_blossom_tree_beehive_"..i..".mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
end

mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:dirt_with_grass"},
	fill_ratio = 0.6,
	biomes = {"CherryGrove"},
	y_min = mcl_vars.mg_overworld_min,
	y_max = mcl_vars.mg_overworld_max,
	decoration = "mcl_cherry_blossom:pink_petals",
})

