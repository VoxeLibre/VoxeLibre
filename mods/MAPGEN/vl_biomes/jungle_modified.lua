local mod_mcl_core = core.get_modpath("mcl_core")

-- Jungle M aka modified Jungle
-- Like Jungle but with even more dense vegetation
vl_biomes.register_biome({
	name = "JungleM",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 92,
	heat_point = 81,
	_vl_biome_type = "medium",
	_vl_water_temp = "lukewarm",
	_vl_grass_palette = "jungle_modified",
	_vl_foliage_palette = "jungle",
	_vl_water_palette = "savanna",
	_vl_skycolor = vl_biomes.skycolor.jungle,
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
	biomes = {"JungleM"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = 0.004,
	_vl_foliage_palette = "jungle",
})

-- Huge jungle tree (4 variants)
for i = 1, 4 do
	vl_biomes.register_decoration({
		biomes = {"JungleM"},
		schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree_huge_"..i..".mts",
		place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
		fill_ratio = 0.003,
		y_min = 4,
		_vl_foliage_palette = "jungle",
	})
end

vl_biomes.register_decoration({
	biomes = {"JungleM"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_tree_2.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	fill_ratio = 0.09,
	_vl_foliage_palette = "jungle",
})

vl_biomes.register_decoration({
	biomes = {"JungleM"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_jungle_bush_oak_leaves.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	place_offset_y = 1,
	noise_params = {
		offset = 0.05,
		scale = 0.025,
		spread = vector.new(250, 250, 250),
		seed = 2930,
		octaves = 4,
		persist = 0.6,
	},
	_vl_foliage_palette = "jungle",
})
