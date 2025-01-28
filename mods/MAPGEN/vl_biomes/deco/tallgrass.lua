-- Template to register a grass decoration
local function register_grass_decoration(offset, scale, biomes)
	local bmap = {}
	for _, b in pairs(biomes) do
		local biome = core.registered_biomes[b]
		if biome then -- ignore unknown biomes
			local param2 = biome._mcl_grass_palette_index or 0
			if not bmap[param2] then bmap[param2] = {} end
			table.insert(bmap[param2], b)
		end
	end
	for param2, bs in pairs(bmap) do
		mcl_mapgen_core.register_decoration({
			deco_type = "simple",
			rank = 1600, -- after double grass
			place_on = {"group:grass_block_no_snow", "mcl_mud:mud"},
			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = scale,
				spread = vector.new(200, 200, 200),
				seed = 420,
				octaves = 3,
				persist = 0.6
			},
			biomes = bs,
			y_min = 1,
			y_max = vl_biomes.overworld_max,
			decoration = "mcl_flowers:tallgrass",
			param2 = param2,
		})
	end
end

local grass_forest = {"Plains", "Taiga", "Forest", "FlowerForest", "BirchForest", "BirchForestM", "RoofedForest", "Swampland", }
local grass_mpf = {"MesaPlateauF_grasstop"}
local grass_plains = {"Plains", "SunflowerPlains", "JungleEdge", "JungleEdgeM", "MangroveSwamp"}
local grass_savanna = {"Savanna", "SavannaM"}
local grass_sparse = {"ExtremeHills", "ExtremeHills+", "ExtremeHills+_snowtop", "ExtremeHillsM", "Jungle"}
local grass_mpfm = {"MesaPlateauFM_grasstop"}

-- TODO: register only once for each biome, with better parameters?
register_grass_decoration(-0.03, 0.09, grass_forest)
register_grass_decoration(-0.015, 0.075, grass_forest)
register_grass_decoration(0, 0.06, grass_forest)
register_grass_decoration(0.015, 0.045, grass_forest)
register_grass_decoration(0.03, 0.03, grass_forest)
register_grass_decoration(-0.03, 0.09, grass_mpf)
register_grass_decoration(-0.015, 0.075, grass_mpf)
register_grass_decoration(0, 0.06, grass_mpf)
register_grass_decoration(0.01, 0.045, grass_mpf)
register_grass_decoration(0.01, 0.05, grass_forest)
register_grass_decoration(0.03, 0.03, grass_plains)
register_grass_decoration(0.05, 0.01, grass_plains)
register_grass_decoration(0.07, -0.01, grass_plains)
register_grass_decoration(0.09, -0.03, grass_plains)
register_grass_decoration(0.18, -0.03, grass_savanna)
register_grass_decoration(0.05, -0.03, grass_sparse)
register_grass_decoration(0.05, 0.05, grass_mpfm)
register_grass_decoration(-0.03, 1, {"BambooJungle", "BambooJungleM", "BambooJungleEdge"})
register_grass_decoration(0.18, 0.03, {"Swampland"})

-- Doubletall grass registration helper
local function register_doubletall_grass(offset, scale, biomes)
	local bmap = {}
	for _, b in pairs(biomes) do
		local biome = core.registered_biomes[b]
		if biome then -- ignore unknown biomes
			local param2 = biome._mcl_grass_palette_index or 0
			if not bmap[param2] then bmap[param2] = {} end
			table.insert(bmap[param2], b)
		end
	end
	for param2, bs in pairs(bmap) do
		mcl_mapgen_core.register_decoration({
			deco_type = "schematic",
			rank = 1500, -- run before regular grass
			schematic = {
				size = vector.new(1, 2, 1),
				data = {
					{name = "mcl_flowers:double_grass", param1 = 255, param2 = param2},
					{name = "mcl_flowers:double_grass_top", param1 = 255, param2 = param2},
				},
			},
			flags = "all_floors, force_placement",
			place_on = {"group:grass_block_no_snow"},
			place_offset_y = 1,
			sidelen = 16,
			noise_params = {
				offset = offset,
				scale = scale,
				spread = vector.new(200, 200, 200),
				seed = 420,
				octaves = 3,
				persist = 0.6,
			},
			y_min = 1,
			y_max = vl_biomes.overworld_max,
			biomes = bs,
		})
	end
end

register_doubletall_grass(-0.0005, -0.3, {"BambooJungle", "BambooJungleM", "BambooJungleEdge"})
register_doubletall_grass(-0.01, 0.03, {"Forest", "FlowerForest", "BirchForest", "BirchForestM", "RoofedForest", "Taiga"})
register_doubletall_grass(-0.002, 0.03, {"Plains", "SunflowerPlains"})
register_doubletall_grass(-0.0005, -0.03, {"Savanna", "SavannaM"})
