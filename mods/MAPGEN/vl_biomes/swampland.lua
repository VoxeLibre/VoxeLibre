local mod_mcl_core = core.get_modpath("mcl_core")

-- Swampland
vl_biomes.register_biome({
	name = "Swampland",
	node_top = "mcl_core:dirt_with_grass",
	depth_top = 1,
	node_filler = "mcl_core:dirt",
	depth_filler = 3,
	node_riverbed = "mcl_core:dirt",
	depth_riverbed = 2,
	y_min = 1,
	y_max = 23, -- Note: Limited in height!
	weight = mcl_vars.biome_weights and 0.75 or 1.0, -- Luanti 5.11+
	humidity_point = 90,
	heat_point = 50,
	_vl_biome_type = "medium",
	_vl_water_temp = "ocean",
	_vl_grass_palette = "swampland",
	_vl_foliage_palette = "swampland",
	_vl_water_palette = "swampland",
	_vl_water_fogcolor = "#232317", -- was "#617B64",
	_vl_skycolor = vl_biomes.skycolor.beach,
	_vl_subbiomes = {
		shore = {
			node_top = "mcl_core:dirt",
			depth_top = 1,
			y_min = -5,
			y_max = 0,
		},
		ocean = {
			node_top = "mcl_core:dirt",
			depth_top = 1,
			node_filler = "mcl_core:dirt",
			depth_filler = 3,
			node_riverbed = "mcl_core:gravel",
			depth_riverbed = 2,
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
	place_offset_y = 1,
	y_min = -2,
	noise_params = {
		offset = 0.0055,
		scale = 0.0011,
		spread = vector.new(50, 50, 50),
		seed = 5005,
		octaves = 5,
		persist = 0.6,
	},
	_vl_foliage_palette = "swampland",
})

-- Lily pads in shallow water at ocean level in Swampland.
local lily_schem = {{name = "mcl_core:water_source", param2 = 1}, {name = "mcl_flowers:waterlily"}}
for d = 1, 4 do
	local height = d + 2
	local y = 1 - d
	table.insert(lily_schem, 1, {name = "ignore", prob = 0})

	vl_biomes.register_decoration({
		name = "lily:"..tostring(d),
		biomes = {"Swampland_shore"},
		schematic = {
			size = vector.new(1, height, 1),
			data = table.copy(lily_schem),
		},
		sidelen = 8,
		place_on = {"mcl_core:dirt", "mcl_mud:mud"},
		place_offset_y = 0,
		noise_params = {
			offset = 0.4 - 0.15 * d, -- more when shallow
			scale = 0.2,
			spread = vector.new(50, 50, 50),
			seed = 503,
			octaves = 4,
			persist = 0.7,
		},
		y_min = y,
		y_max = y,
	})
end

-- additional reeds in swamps
vl_biomes.register_decoration({
	biomes = {"Swampland", "Swampland_shore"},
	decoration = "mcl_core:reeds",
	param2 = 28, -- Swampland grass palette index
	height = 1,
	height_max = 3,
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
	spawn_by = {"mcl_core:water_source", "group:frosted_ice"},
	num_spawn_by = 1,
	noise_params = {
		offset = 0.2,
		scale = 0.4,
		spread = vector.new(50, 50, 50),
		seed = 3,
		octaves = 3,
		persist = 0.7,
	},
})

-- more clay
core.register_ore({
	ore_type = "puff",
	ore = "mcl_core:clay",
	wherein = {"mcl_core:dirt", "mcl_core:sand"},
	clust_scarcity = 10*10*10,
	clust_num_ores = 20,
	clust_size = 5,
	y_min = -5,
	y_max = 0,
	biomes = { "Swampland", "Swampland_shore", "Swampland_ocean" },
	noise_params = {
		offset  = -0.2,
		scale   = 0.5,
		spread  = {x=25, y=25, z=25},
		seed    = 24521,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- Also some mud
core.register_ore({
	ore_type = "puff",
	ore = "mcl_mud:mud",
	wherein = {"mcl_core:dirt", "mcl_core:sand"},
	clust_scarcity = 10*10*10,
	clust_num_ores = 20,
	clust_size = 5,
	y_min = -5,
	y_max = 0,
	biomes = { "Swampland", "Swampland_shore", "Swampland_ocean" },
	noise_params = {
		offset  = -0.2,
		scale   = 0.5,
		spread  = {x=25, y=25, z=25},
		seed    = 24522,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})
