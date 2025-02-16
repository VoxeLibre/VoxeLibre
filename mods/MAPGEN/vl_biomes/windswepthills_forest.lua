local mod_mcl_core = core.get_modpath("mcl_core")

-- Extreme Hills+ aka Windswept Forest
-- This biome is near-identical to Extreme Hills on the surface but has snow-covered mountains with spruce/oak
-- forests above a certain height.
vl_biomes.register_biome({
	name = "ExtremeHills+",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 4,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 4,
	y_min = 1,
	y_max = 41,
	humidity_point = 24,
	heat_point = 25,
	vertical_blend = 6,
	_mcl_biome_type = "cold",
	_mcl_water_temp = "cold",
	_mcl_grass_palette_index = 8,
	_mcl_foliage_palette_index = 11,
	_mcl_water_palette_index = 4,
	_mcl_skycolor = vl_biomes.skycolor.taiga,
	_vl_subbiomes = {
		snowtop = {
			node_dust = "mcl_core:snow",
			node_top = "mcl_core:dirt_with_grass_snow",
			depth_top = 1,
			node_river_water = "mcl_core:ice",
			y_min = 42,
			y_max = vl_biomes.overworld_max,
		},
		ocean = {
			node_top = "mcl_core:gravel",
			depth_top = 1,
			node_filler = "mcl_core:gravel",
			depth_filler = 4,
		},
	}
})

-- Large oaks
for i = 1, 4 do
	vl_biomes.register_decoration({
		biomes = {"ExtremeHills+", "ExtremeHills+_snowtop"},
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
	biomes = {"ExtremeHills+", "ExtremeHills+_snowtop"},
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

vl_biomes.register_decoration({
	biomes = {"ExtremeHills+", "ExtremeHills+_snowtop"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_classic.mts",
	y_min = 50,
	place_on = {"group:grass_block", "mcl_core:dirt"},
	noise_params = {
		offset = 0.006,
		scale = 0.002,
		spread = vector.new(250, 250, 250),
		seed = 2,
		octaves = 3,
		persist = 0.7
	},
})

-- Spruce
vl_biomes.register_spruce_decoration(11000, 0.001, "mcl_core_spruce_5.mts", {"ExtremeHills+", "ExtremeHills+_snowtop"}, 50)
vl_biomes.register_spruce_decoration(2500, 0.002, "mcl_core_spruce_1.mts", {"ExtremeHills+", "ExtremeHills+_snowtop"}, 50)
vl_biomes.register_spruce_decoration(7000, 0.003, "mcl_core_spruce_3.mts", {"ExtremeHills+", "ExtremeHills+_snowtop"}, 50)
vl_biomes.register_spruce_decoration(9000, 0.002, "mcl_core_spruce_4.mts", {"ExtremeHills+", "ExtremeHills+_snowtop"}, 50)

--  Place tall grass on snow in Extreme Hills+
vl_biomes.register_decoration({
	biomes = {"ExtremeHills+_snowtop"},
	schematic = {
		size = vector.new(1, 2, 1),
		data = {
			{name = "mcl_core:dirt_with_grass", force_place = true, param2 = 8 },
			{name = "mcl_flowers:tallgrass", param2 = 8},
		},
	},
	place_on = {"group:grass_block"},
	noise_params = {
		offset = 0.0,
		scale = 0.09,
		spread = vector.new(15, 15, 15),
		seed = 420,
		octaves = 3,
		persist = 0.6,
	},
	rank = 1500,
})
