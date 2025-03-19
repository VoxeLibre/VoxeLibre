local mod_mcl_core = core.get_modpath("mcl_core")
-- Savanna
vl_biomes.register_biome({
	name = "Savanna",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 2,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 36,
	heat_point = 79,
	_vl_biome_type = "hot",
	_vl_water_temp = "lukewarm",
	_vl_grass_palette = "savanna",
	_vl_foliage_palette = "savanna",
	_vl_water_palette = "savanna",
	_vl_skycolor = "#6EB1FF",
	_vl_subbiomes = {
		beach = {
			node_top = "mcl_core:sand",
			depth_top = 3,
			node_filler = "mcl_core:sandstone",
			depth_filler = 2,
			y_min = -1,
			y_max = 0,
			_vl_foliage_palette = "plains", -- FIXME: remove?
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

vl_biomes.register_decoration({
	biomes = {"Savanna"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	fill_ratio = 0.0004,
})

-- Acacia (many variants)
for a = 1, 7 do
	vl_biomes.register_decoration({
		biomes = {"Savanna"},
		schematic = mod_mcl_core .. "/schematics/mcl_core_acacia_" .. a .. ".mts",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:coarse_dirt"},
		fill_ratio = 0.0002,
	})
end
