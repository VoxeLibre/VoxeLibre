local mod_mcl_core = core.get_modpath("mcl_core")

-- Swampland
vl_biomes.register_biome({
	name = "Swampland",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:sand",
	depth_riverbed = 2,
	y_min = 1,
	y_max = 23, -- Note: Limited in height!
	humidity_point = 90,
	heat_point = 50,
	_vl_biome_type = "medium",
	_vl_water_temp = "ocean",
	_vl_grass_palette = "swampland",
	_vl_foliage_palette = "swampland",
	_vl_water_palette = "swampland",
	_vl_water_fogcolor = "#617B64",
	_vl_skycolor = vl_biomes.skycolor.beach,
	_vl_subbiomes = {
		shore = {
			node_top = "mcl_core:dirt",
			depth_top = 1,
			y_min = -5,
			y_max = 0,
		},
		ocean = {
			node_top = "mcl_core:sand",
			depth_top = 1,
			node_filler = "mcl_core:sand",
			depth_filler = 3,
			y_max = -6,
			vertical_blend = 1,
		},
	}
})

-- Swamp oak
vl_biomes.register_decoration({
	biomes = {"Swampland", "Swampland_shore"},
	schematic = mod_mcl_core .. "/schematics/mcl_core_oak_swamp.mts",
	place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
	noise_params = {
		offset = 0.0055,
		scale = 0.0011,
		spread = vector.new(250, 250, 250),
		seed = 5005,
		octaves = 5,
		persist = 0.6,
	},
})

-- Lily pads in shallow water at ocean level in Swampland.
local lily_schem = {{name = "mcl_core:water_source", param2 = 1}, {name = "mcl_flowers:waterlily"}}
for d = 1, 3 do
	local height = d + 2
	local y = 1 - d
	table.insert(lily_schem, 1, {name = "ignore", prob = 0})

	vl_biomes.register_decoration({
		name = "lily:"..tostring(d),
		biomes = {"Swampland_shore"},
		schematic = {
			size = vector.new(1, height, 1),
			data = lily_schem,
		},
		place_on = "mcl_core:dirt",
		noise_params = {
			offset = 0.3 - 0.2 * d, -- more when shallow
			scale = 0.3,
			spread = vector.new(100, 100, 100),
			seed = 503,
			octaves = 6,
			persist = 0.7,
		},
		y_min = y,
		y_max = y,
	})
end
