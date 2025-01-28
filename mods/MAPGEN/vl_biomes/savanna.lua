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
	_mcl_biome_type = "hot",
	_mcl_water_temp = "lukewarm",
	_mcl_grass_palette_index = 1,
	_mcl_foliage_palette_index = 3,
	_mcl_water_palette_index = 2,
	_mcl_skycolor = "#6EB1FF",
	_vl_subbiomes = {
		beach = {
			node_top = "mcl_core:sand",
			depth_top = 3,
			node_filler = "mcl_core:sandstone",
			depth_filler = 2,
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

mcl_mapgen_core.register_decoration({
	deco_type = "schematic",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	sidelen = 80,
	fill_ratio = 0.0004,
	biomes = {"Savanna"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
})

-- Acacia (many variants)
for a = 1, 7 do
	mcl_mapgen_core.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:coarse_dirt"},
		sidelen = 16,
		fill_ratio = 0.0002,
		biomes = {"Savanna"},
		y_min = 1,
		y_max = vl_biomes.overworld_max,
		schematic = mod_mcl_core .. "/schematics/mcl_core_acacia_" .. a .. ".mts",
		flags = "place_center_x, place_center_z",
		rotation = "random",
	})
end
