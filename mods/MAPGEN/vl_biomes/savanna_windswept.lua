local mod_mcl_core = core.get_modpath("mcl_core")
-- Savanna M aka Shattered Savanna aka Windswept Savanna
-- Changes to Savanna: Coarse Dirt. No sand beach. No oaks.
-- Otherwise identical to Savanna
vl_biomes.register_biome({
	name = "SavannaM",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:coarse_dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 48,
	heat_point = 100,
	weight = mcl_vars.biome_weights and 0.75 or 1.0, -- Luanti 5.11+
	_vl_biome_type = "hot",
	_vl_water_temp = "lukewarm",
	_vl_grass_palette = "savanna_windswept",
	_vl_foliage_palette = "savanna",
	_vl_water_palette = "savanna",
	_vl_skycolor = "#6EB1FF",
	_vl_subbiomes = {
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
		},
	}
})

-- Acacia (many variants)
for a = 1, 7 do
	vl_biomes.register_decoration({
		biomes = {"SavannaM"},
		schematic = mod_mcl_core .. "/schematics/mcl_core_acacia_" .. a .. ".mts",
		place_on = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:coarse_dirt"},
		place_offset_y = 1,
		fill_ratio = 0.0002,
	})
end
