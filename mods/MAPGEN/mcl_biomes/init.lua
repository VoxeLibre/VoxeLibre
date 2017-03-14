
--
-- Register biomes for mapgens other than v6
-- EXPERIMENTAL!
--

local function register_classic_superflat_biome()
	-- Classic Superflat: bedrock (not part of biome), 2 dirt, 1 grass block
	minetest.register_biome({
		name = "flat",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 2,
		y_min = 1,
		y_max = 31000,
		heat_point = 50,
		humidity_point = 50,
	})
end

-- All mapgens except mgv6, flat and singlenode
local function register_biomes()

	minetest.register_biome({
		name = "ice_plains",
		node_dust = "mcl_core:snow",
		node_top = "mcl_core:dirt",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:dirt",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 31000,
		heat_point = 5,
		humidity_point = 50,
	})

	minetest.register_biome({
		name = "ice_plains2",
		node_top = "mcl_core:snowblock",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:dirt",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 31000,
		heat_point = 0,
		humidity_point = 50,
	})

	minetest.register_biome({
		name = "plains",
		node_top = "mcl_core:dirt_with_grass",
		depth_top = 1,
		node_filler = "mcl_core:dirt",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 31000,
		heat_point = 40,
		humidity_point = 50,
	})

	minetest.register_biome({
		name = "beach",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		y_min = 1,
		y_max = 5,
		heat_point = 40,
		humidity_point = 50,
	})

	minetest.register_biome({
		name = "desert",
		node_top = "mcl_core:sand",
		depth_top = 1,
		node_filler = "mcl_core:sand",
		depth_filler = 3,
		node_riverbed = "mcl_core:sand",
		depth_riverbed = 2,
		node_stone = "mcl_core:sandstone",
		y_min = 1,
		y_max = 31000,
		heat_point = 100,
		humidity_point = 50,
	})

	minetest.register_biome({
		name = "mesa",
		node_top = "mcl_core:redsand",
		depth_top = 1,
		node_filler = "mcl_core:hardened_clay",
		depth_filler = 3,
		node_riverbed = "mcl_core:redsand",
		depth_riverbed = 2,
		node_stone = "mcl_core:hardened_clay",
		y_min = 1,
		y_max = 5,
		heat_point = 100,
		humidity_point = 50,
	})

	minetest.register_biome({
		name = "mesa2",
		node_top = "mcl_colorblocks:hardened_clay",
		depth_top = 1,
		node_filler = "mcl_colorblocks:hardened_clay_orange",
		depth_filler = 1,
		node_riverbed = "mcl_core:redsand",
		depth_riverbed = 2,
		node_stone = "mcl_core:hardened_clay",
		y_min = 1,
		y_max = 5,
		heat_point = 100,
		humidity_point = 50,
	})


	minetest.register_biome({
		name = "underground",
		y_min = -31000,
		y_max = -113,
		heat_point = 50,
		humidity_point = 50,
	})
end


-- All mapgens except mgv6

local function register_grass_decoration(offset, scale)
	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = offset,
			scale = scale,
			spread = {x = 200, y = 200, z = 200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"plains"},
		y_min = 1,
		y_max = 31000,
		decoration = "mcl_flowers:tallgrass",
	})
end

local function register_decorations()

	-- Cactus

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:sand", "mcl_oore:redsand"},
		sidelen = 16,
		noise_params = {
			offset = -0.0003,
			scale = 0.0009,
			spread = {x = 200, y = 200, z = 200},
			seed = 230,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert"},
		y_min = 5,
		y_max = 31000,
		decoration = "mcl_core:cactus",
		height = 1,
		height_max = 3,
	})

	-- Papyrus

	minetest.register_decoration({
		deco_type = "schematic",
		place_on = {"mcl_core:dirt", "mcl_core:dirt_with_grass"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = {x = 200, y = 200, z = 200},
			seed = 354,
			octaves = 3,
			persist = 0.7
		},
		biomes = {"plains", "beach", "desert"},
		y_min = 0,
		y_max = 0,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
	})

	-- Grasses

	register_grass_decoration(-0.03,  0.09)
	register_grass_decoration(-0.015, 0.075)
	register_grass_decoration(0,      0.06)
	register_grass_decoration(0.015,  0.045)
	register_grass_decoration(0.03,   0.03)
	register_grass_decoration(0.01, 0.05)
	register_grass_decoration(0.03, 0.03)
	register_grass_decoration(0.05, 0.01)
	register_grass_decoration(0.07, -0.01)
	register_grass_decoration(0.09, -0.03)

	-- Dead bushes

	minetest.register_decoration({
		deco_type = "simple",
		place_on = {"mcl_core:sand", "mcl_core:redsand"},
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.02,
			spread = {x = 200, y = 200, z = 200},
			seed = 329,
			octaves = 3,
			persist = 0.6
		},
		biomes = {"desert"},
		y_min = 2,
		y_max = 31000,
		decoration = "mcl_core:deadbush",
		height = 1,
	})

end


--
-- Detect mapgen to select functions
--
local mg_name = minetest.get_mapgen_setting("mg_name")
if mg_name ~= "v6" and mg_name ~= "flat" then
	register_biomes()
	register_decorations()
elseif mg_name == "flat" then
	-- Implementation of Minecraft's Superflat mapgen, classic style
	minetest.clear_registered_biomes()
	minetest.clear_registered_decorations()
	minetest.clear_registered_schematics()
	register_classic_superflat_biome()
end
