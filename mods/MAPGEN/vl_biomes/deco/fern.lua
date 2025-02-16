-- Template to register a grass or fern decoration
local function register_fern_decoration(offset, scale, biomes)
	for _, b in pairs(biomes) do
		local biome = core.registered_biomes[b]
		if biome then -- ignore unknown biomes
			local param2 = biome._mcl_grass_palette_index
			vl_biomes.register_decoration({
				biomes = {b},
				decoration = "mcl_flowers:fern",
				param2 = param2,
				y_min = 1,
				y_max = vl_biomes.overworld_max,
				place_on = {"group:grass_block_no_snow", "mcl_core:podzol", "mcl_mud:mud"},
				noise_params = {
					offset = offset,
					scale = scale,
					spread = vector.new(200, 200, 200),
					seed = 333,
					octaves = 3,
					persist = 0.6
				},
				rank = 1600, -- even after tall variants
			})
		end
	end
end

local fern_minimal = {"Jungle", "JungleM", "JungleEdge", "JungleEdgeM", "Taiga", "MegaTaiga", "MegaSpruceTaiga", "ColdTaiga", "MangroveSwamp"}
local fern_low = {"Jungle", "JungleM", "JungleEdge", "JungleEdgeM", "Taiga", "MegaTaiga", "MegaSpruceTaiga"}
local fern_Jungle = {"Jungle", "JungleM", "JungleEdge", "JungleEdgeM"}
--local fern_JungleM = { "JungleM" },

-- FIXME: register once per biome only, with appropriate parameters?
register_fern_decoration(-0.03, 0.09, fern_minimal)
register_fern_decoration(-0.015, 0.075, fern_minimal)
register_fern_decoration(0, 0.06, fern_minimal)
register_fern_decoration(0.015, 0.045, fern_low)
register_fern_decoration(0.03, 0.03, fern_low)
register_fern_decoration(0.01, 0.05, fern_Jungle)
register_fern_decoration(0.03, 0.03, fern_Jungle)
register_fern_decoration(0.05, 0.01, fern_Jungle)
register_fern_decoration(0.07, -0.01, fern_Jungle)
register_fern_decoration(0.09, -0.03, fern_Jungle)
register_fern_decoration(0.12, -0.03, {"JungleM"})

-- Large ferns
local function register_double_fern(offset, scale, biomes)
	for _, b in pairs(biomes) do
		local biome = core.registered_biomes[b]
		if biome then -- ignore unknown biomes
			local param2 = biome._mcl_grass_palette_index
			vl_biomes.register_decoration({
				biomes = {b},
				schematic = {
					size = vector.new(1, 2, 1),
					data = {
						{name = "mcl_flowers:double_fern", param1 = 255, param2 = param2},
						{name = "mcl_flowers:double_fern_top", param1 = 255, param2 = param2},
					},
				},
				y_min = 1,
				y_max = vl_biomes.overworld_max,
				place_on = {"group:grass_block_no_snow", "mcl_core:podzol"},
				place_offset_y = 1,
				flags = "all_floors, force_placement",
				noise_params = {
					offset = offset,
					scale = scale,
					spread = vector.new(250, 250, 250),
					seed = 333,
					octaves = 2,
					persist = 0.66,
				},
				rank = 1500, -- before regular fern
			})
		end
	end
end

register_double_fern(0.01, 0.03, {"Jungle", "JungleM", "JungleEdge", "JungleEdgeM", "Taiga", "ColdTaiga", "MegaTaiga", "MegaSpruceTaiga", "BambooJungle", "BambooJungleM", "BambooJungleEdge", "BambooJungleEdgeM", })
register_double_fern(0.15, 0.1, {"JungleM", "BambooJungleM", "BambooJungle"})
