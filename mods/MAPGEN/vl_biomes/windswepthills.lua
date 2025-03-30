local mod_mcl_core = core.get_modpath("mcl_core")

-- Extreme Hills aka Windswept Hills
-- Sparsely populated grasslands with little tallgras and trees.
vl_biomes.register_biome({
	name = "ExtremeHills",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 4,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 4,
	y_min = 4,
	y_max = vl_biomes.overworld_max,
	humidity_point = 10,
	heat_point = 45,
	_vl_biome_type = "cold",
	_vl_water_temp = "cold",
	_vl_grass_palette = "windswepthills",
	_vl_foliage_palette = "stonebeach",
	_vl_water_palette = "taiga",
	_vl_skycolor = vl_biomes.skycolor.taiga,
	_vl_subbiomes = {
		beach = {
			node_top = "mcl_core:sand",
			depth_top = 2,
			node_filler = "mcl_core:sandstone",
			depth_filler = 3,
			y_min = -4,
			y_max = 3,
			_vl_foliage_palette = "plains", -- FIXME: remove?
		},
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 4,
			y_max = -5,
			vertical_blend = 1,
		},
	}
})

-- Large oaks
for i = 1, 4 do
	vl_biomes.register_decoration({
		biomes = {"ExtremeHills"},
		schematic = mod_mcl_core .. "/schematics/mcl_core_oak_large_" .. i .. ".mts",
		place_on = {"group:grass_block", "mcl_core:dirt", },
		place_offset_y = 1,
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
	biomes = {"ExtremeHills"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	place_on = {"group:grass_block", "mcl_core:dirt", },
	place_offset_y = 1,
	noise_params = {
		offset = 0.0,
		scale = 0.002,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.7
	},
})

-- Spruce
vl_biomes.register_spruce_decoration(11000, 0.000025, "mcl_core_spruce_5.mts", {"ExtremeHills"})
vl_biomes.register_spruce_decoration(2500, 0.00005, "mcl_core_spruce_1.mts", {"ExtremeHills"})
vl_biomes.register_spruce_decoration(7000, 0.00005, "mcl_core_spruce_3.mts", {"ExtremeHills"})
vl_biomes.register_spruce_decoration(9000, 0.00005, "mcl_core_spruce_4.mts", {"ExtremeHills"})
