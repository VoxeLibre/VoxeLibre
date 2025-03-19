local mod_mcl_core = core.get_modpath("mcl_core")

-- Extreme Hills M aka Windswept Gravelly Hills
-- Just gravel.
vl_biomes.register_biome({
	name = "ExtremeHillsM",
	node_top = "mcl_core:gravel",
	depth_top = 1,
	node_filler = "mcl_core:gravel",
	depth_filler = 3,
	node_riverbed = "mcl_core:gravel",
	depth_riverbed = 3,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	humidity_point = 0,
	heat_point = 25,
	_vl_biome_type = "cold",
	_vl_water_temp = "cold",
	_vl_grass_palette = "windswepthills_gravelly",
	_vl_foliage_palette = "stonebeach",
	_vl_water_palette = "taiga",
	_vl_skycolor = vl_biomes.skycolor.taiga,
	_vl_subbiomes = {
		ocean = {
			node_riverbed = "mcl_core:sand",
			depth_riverbed = 3,
		},
	}
})

-- Small dirt patches in Extreme Hills M
core.register_ore({
	ore_type = "blob",
	-- TODO: Should be grass block. But generating this as ore means grass blocks will spawn undeground. :-(
	ore = "mcl_core:dirt",
	wherein = {"mcl_core:gravel"},
	clust_scarcity = 5000,
	clust_num_ores = 12,
	clust_size = 4,
	y_min = vl_biomes.overworld_min,
	y_max = vl_biomes.overworld_max,
	noise_threshold = 0.2,
	noise_params = {
		offset = 0,
		scale = 5,
		spread = vector.new(250, 250, 250),
		seed = 64,
		octaves = 3,
		persist = 0.60
	},
	biomes = {"ExtremeHillsM"},
})

-- Large oaks
for i = 1, 4 do
	vl_biomes.register_decoration({
		biomes = {"ExtremeHillsM"},
		schematic = mod_mcl_core .. "/schematics/mcl_core_oak_large_" .. i .. ".mts",
		place_on = {"group:grass_block", "mcl_core:dirt", },
		noise_params = {
			offset = -0.0007,
			scale = 0.001,
			spread = vector.new(250, 250, 250),
			seed = 3,
			octaves = 3,
			persist = 0.6
		},
	})
end

-- Small “classic” oak (many biomes)
vl_biomes.register_decoration({
	biomes = {"ExtremeHillsM"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	place_on = {"group:grass_block", "mcl_core:dirt", },
	noise_params = {
		offset = 0.0,
		scale = 0.002,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.7
	},
})

vl_biomes.register_spruce_decoration(11000, 0.000025, "mcl_core_spruce_5.mts", {"ExtremeHillsM"})
vl_biomes.register_spruce_decoration(2500, 0.00005, "mcl_core_spruce_1.mts", {"ExtremeHillsM"})
vl_biomes.register_spruce_decoration(7000, 0.00005, "mcl_core_spruce_3.mts", {"ExtremeHillsM"})
vl_biomes.register_spruce_decoration(9000, 0.00005, "mcl_core_spruce_4.mts", {"ExtremeHillsM"})
