-- Large flowers
local function register_large_flower(name, biomes, seed, offset)
	local ndef = core.registered_nodes["mcl_flowers:"..name]
	local has_param2 = ndef and ndef.groups.grass_palette
	local tdef = core.registered_nodes["mcl_flowers:"..name]
	local thas_param2 = tdef and tdef.groups.grass_palette
	if has_param2 then
		for _, b in pairs(biomes) do
			local biome = core.registered_biomes[b]
			if biome then -- ignore unknown biomes
				local param2 = biome._mcl_grass_palette_index or 0
				local tparam2 = thas_param2 and param2 or nil
				vl_biomes.register_decoration({
					biomes = {b},
					schematic = {
						size = vector.new(1, 2, 1),
						data = {
							{name = "mcl_flowers:" .. name, param2 = param2 },
							{name = "mcl_flowers:" .. name .. "_top", param2 = tparam2 },
						},
					},
					y_min = 1,
					y_max = vl_biomes.overworld_max,
					place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
					place_offset_y = 1,
					noise_params = {
						offset = offset,
						scale = 0.01,
						spread = vector.new(300, 300, 300),
						seed = seed,
						octaves = 5,
						persist = 0.62,
					},
				})
			end
		end
	else
		vl_biomes.register_decoration({
			biomes = biomes,
			schematic = {
				size = vector.new(1, 2, 1),
				data = {
					{name = "mcl_flowers:" .. name },
					{name = "mcl_flowers:" .. name .. "_top" },
				},
			},
			y_min = 1,
			y_max = vl_biomes.overworld_max,
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
			place_offset_y = 1,
			noise_params = {
				offset = offset,
				scale = 0.01,
				spread = vector.new(300, 300, 300),
				seed = seed,
				octaves = 5,
				persist = 0.62,
			},
		})
	end
end

register_large_flower("rose_bush", {"Forest"}, 9350, -0.008)
register_large_flower("rose_bush", {"FlowerForest"}, 9350, 0.003)
register_large_flower("peony", {"Forest"}, 10450, -0.008)
register_large_flower("peony", {"FlowerForest"}, 10450, 0.003)
register_large_flower("lilac", {"Forest"}, 10600, -0.007)
register_large_flower("lilac", {"FlowerForest"}, 10600, 0.003)
register_large_flower("sunflower", {"SunflowerPlains"}, 2940, 0.01)

local function register_flower(name, biomes, seed, offset)
	local ndef = core.registered_nodes["mcl_flowers:"..name]
	local has_param2 = ndef and ndef.groups.grass_palette
	if has_param2 then
		for _, b in pairs(biomes) do
			local biome = core.registered_biomes[b]
			if biome then -- ignore unknown biomes
				local param2 = biome._mcl_grass_palette_index or 0
				vl_biomes.register_decoration({
					biomes = {b},
					decoration = "mcl_flowers:" .. name,
					param2 = param2,
					y_min = 1,
					y_max = vl_biomes.overworld_max,
					place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
					noise_params = {
						offset = offset,
						scale = 0.006,
						spread = vector.new(100, 100, 100),
						seed = seed,
						octaves = 3,
						persist = 0.6
					},
				})
			end
		end
	else
		vl_biomes.register_decoration({
			biomes = biomes,
			decoration = "mcl_flowers:" .. name,
			y_min = 1,
			y_max = vl_biomes.overworld_max,
			place_on = {"group:grass_block_no_snow", "mcl_core:dirt"},
			noise_params = {
				offset = offset,
				scale = 0.006,
				spread = vector.new(100, 100, 100),
				seed = seed,
				octaves = 3,
				persist = 0.6
			},
		})
	end
end

local flower_biomes1 = {"Plains", "SunflowerPlains", "RoofedForest", "Forest", "BirchForest", "BirchForestM", "Taiga", "ColdTaiga", "Jungle", "JungleM", "JungleEdge", "JungleEdgeM", "Savanna", "SavannaM", "ExtremeHills", "ExtremeHillsM", "ExtremeHills+", "ExtremeHills+_snowtop"}

register_flower("dandelion", flower_biomes1, 8, 0.0008)
register_flower("dandelion", {"FlowerForest"}, 8, 0.032)
register_flower("poppy", flower_biomes1, 9439, 0.0008)
register_flower("poppy", {"FlowerForest"}, 9439, 0.032)
register_flower("clover", flower_biomes1, 3, 0.0408) -- not in Flower Forest
register_flower("fourleaf_clover", flower_biomes1, 13, -0.0012) -- not in Flower Forest

local flower_biomes2 = {"Plains", "SunflowerPlains"}
register_flower("tulip_red", flower_biomes2, 436, 0.0008)
register_flower("tulip_red", {"FlowerForest"}, 436, 0.032)
register_flower("tulip_orange", flower_biomes2, 536, 0.0008)
register_flower("tulip_orange", {"FlowerForest"}, 536, 0.032)
register_flower("tulip_pink", flower_biomes2, 636, 0.0008)
register_flower("tulip_pink", {"FlowerForest"}, 636, 0.032)
register_flower("tulip_white", flower_biomes2, 736, 0.0008)
register_flower("tulip_white", {"FlowerForest"}, 736, 0.032)
register_flower("azure_bluet", flower_biomes2, 800, 0.0008)
register_flower("azure_bluet", {"FlowerForest"}, 800, 0.032)
register_flower("oxeye_daisy", flower_biomes2, 3490, 0.0008)
register_flower("oxeye_daisy", {"FlowerForest"}, 3490, 0.032)
register_flower("cornflower", flower_biomes2, 486, 0.0008)
register_flower("cornflower", {"FlowerForest"}, 486, 0.032)

register_flower("lily_of_the_valley", {"Forest", "BirchForest", "BirchForestM", "RoofedForest"}, 325, 0.0008)
register_flower("lily_of_the_valley", {"FlowerForest"}, 325, 0.032)

register_flower("allium", {"FlowerForest"}, 836, 0.04008) -- Flower Forest only, until we have Meadows
register_flower("blue_orchid", {"Swampland"}, 64500, 0.0008) -- Swamp only
