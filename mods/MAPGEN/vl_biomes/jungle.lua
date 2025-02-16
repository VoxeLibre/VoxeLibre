local mod_mcl_core = core.get_modpath("mcl_core")

-- Jungle
vl_biomes.register_biome({
	name = "Jungle",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 88,
	heat_point = 81,
	_mcl_biome_type = "medium",
	_mcl_water_temp = "lukewarm",
	_mcl_grass_palette_index = 24,
	_mcl_foliage_palette_index = 12,
	_mcl_water_palette_index = 2,
	_mcl_skycolor = vl_biomes.skycolor.jungle,
	_vl_subbiomes = {
		shore = {
			node_top = "mcl_core:dirt",
			depth_top = 1,
			y_min = -2,
			y_max = 0,
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
			y_max = -3,
			vertical_blend = 1,
		},
	}
})

-- Small “classic” oak (many biomes)
vl_biomes.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.004,
	biomes = {"Jungle"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

-- Huge jungle tree (4 variants)
for i = 1, 4 do
	vl_biomes.register_decoration({
		deco_type = "schematic",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		fill_ratio = 0.0008,
		biomes = {"Jungle"},
		y_min = 4,
		y_max = vl_biomes.overworld_max,
		schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree_huge_"..i..".mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
end

-- Common jungle tree
vl_biomes.register_decoration({
	biomes = {"Jungle"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.025,
})

vl_biomes.register_decoration({
	biomes = {"Jungle"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree_2.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.015,
})

vl_biomes.register_decoration({
	biomes = {"Jungle"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree_3.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.005,
})

vl_biomes.register_decoration({
	biomes = {"Jungle"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree_4.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.005,
})

-- Jungle bush
vl_biomes.register_decoration({
	biomes = {"Jungle"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_bush_oak_leaves.mts",
	y_min = 3,
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	noise_params = {
		offset = 0.0196,
		scale = 0.015,
		spread = vector.new(250, 250, 250),
		seed = 2930,
		octaves = 4,
		persist = 0.6,
	},
})

vl_biomes.register_decoration({
	biomes = {"Jungle" },
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_bush_oak_leaves_2.mts",
	y_min = 3,
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	noise_params = {
		offset = 0.0196,
		scale = 0.005,
		spread = vector.new(250, 250, 250),
		seed = 2930,
		octaves = 4,
		persist = 0.6,
	},
})
