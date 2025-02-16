local mg_name = core.get_mapgen_setting("mg_name")
local mg_seed = core.get_mapgen_setting("seed")

-- SHARED patterns across different variants of badlands/mesa for consistency
-- Bonus gold spawn in Mesa
if mg_name ~= "v6" then
	local stonelike = {"mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite"}
	core.register_ore({
		ore_type = "scatter",
		ore = "mcl_core:stone_with_gold",
		wherein = stonelike,
		clust_scarcity = 3333,
		clust_num_ores = 5,
		clust_size = 3,
		y_min = mcl_worlds.layer_to_y(32),
		y_max = mcl_worlds.layer_to_y(79),
		biomes = {"Mesa", "Mesa_sandlevel", "Mesa_ocean",
				  "MesaBryce", "MesaBryce_sandlevel", "MesaBryce_ocean",
				  "MesaPlateauF", "MesaPlateauF_sandlevel", "MesaPlateauF_ocean",
				  "MesaPlateauFM", "MesaPlateauFM_sandlevel", "MesaPlateauFM_ocean", },
	})
end

-- For a transition from stone to hardened clay in mesa biomes that is not perfectly flat
core.register_ore({
	ore_type = "stratum",
	ore = "mcl_core:stone",
	wherein = {"group:hardened_clay"},
	noise_params = {
		offset = -6,
		scale = 2,
		spread = vector.new(25, 25, 25),
		octaves = 1,
		persist = 0.60
	},
	stratum_thickness = 8,
	biomes = {
		"Mesa_sandlevel", "Mesa_ocean",
		"MesaBryce_sandlevel", "MesaBryce_ocean",
		"MesaPlateauF_sandlevel", "MesaPlateauF_ocean",
		"MesaPlateauFM_sandlevel", "MesaPlateauFM_ocean",
	},
	y_min = -4,
	y_max = 0,
})

-- Mesa strata (registered as sheet ores)

-- Helper function to create strata.
local function stratum(y_min, height, color, seed, is_perfect)
	height = height or 1
	seed = seed or 39
	local y_max = y_min + height - 1
	-- "perfect" means no erosion
	local perfect_biomes = is_perfect and {"MesaBryce", "Mesa", "MesaPlateauF", "MesaPlateauFM"} or {"MesaBryce"}
	-- Full, perfect stratum
	core.register_ore({
		ore_type = "stratum",
		ore = "mcl_colorblocks:hardened_clay_" .. color,
		-- Only paint uncolored so the biome can choose
		-- a color in advance.
		wherein = {"mcl_colorblocks:hardened_clay"},
		y_min = y_min,
		y_max = y_max,
		biomes = perfect_biomes,
	})
	if not is_perfect then
		-- Slightly eroded stratum, only minor imperfections
		core.register_ore({
			ore_type = "stratum",
			ore = "mcl_colorblocks:hardened_clay_" .. color,
			wherein = {"mcl_colorblocks:hardened_clay"},
			y_min = y_min,
			y_max = y_max,
			biomes = {"Mesa", "MesaPlateauF"},
			noise_params = {
				offset = y_min + (y_max - y_min) / 2,
				scale = 0,
				spread = vector.new(50, 50, 50),
				seed = seed + 4,
				octaves = 1,
				persist = 1.0
			},
			np_stratum_thickness = {
				offset = 1.28,
				scale = 1,
				spread = vector.new(18, 18, 18),
				seed = seed + 4,
				octaves = 3,
				persist = 0.8,
			},
		})
		-- Very eroded stratum, most of the color is gone
		core.register_ore({
			ore_type = "stratum",
			ore = "mcl_colorblocks:hardened_clay_" .. color,
			wherein = {"mcl_colorblocks:hardened_clay"},
			y_min = y_min,
			y_max = y_max,
			biomes = {"MesaPlateauFM"},
			noise_params = {
				offset = y_min + (y_max - y_min) / 2,
				scale = 0,
				spread = vector.new(50, 50, 50),
				seed = seed + 4,
				octaves = 1,
				persist = 1.0
			},
			np_stratum_thickness = {
				offset = 0.1,
				scale = 1,
				spread = vector.new(28, 28, 28),
				seed = seed + 4,
				octaves = 2,
				persist = 0.6,
			},
		})
	end
end

-- Hardcoded orange strata near sea level.
-- For MesaBryce, since it has no sand at these heights
stratum(4, 1, "orange", nil, true)
stratum(7, 2, "orange", nil, true)

-- 3-level stratum above the sandlevel (all mesa biomes)
stratum(11, 3, "orange", nil, true)

-- Create random strata for up to Y = 256.
--[[

------ DANGER ZONE! ------

The following code is sensitive to changes; changing any number may break
mapgen consistency when the mapgen generates new mapchunks in existing
worlds because the random generator will yield different results and the strata
suddenly don't match up anymore. ]]

-- These strata are calculated based on the world seed and are global.
-- They are thus different per-world.
local mesapr = PcgRandom(mg_seed)

-- Available Mesa colors:
local mesa_stratum_colors = {"silver", "brown", "orange", "red", "yellow", "white"}

-- Start level
local y = 17
-- Generate stratas
while y <= 256 do
	-- Each stratum has a color (duh!)
	local colorid = mesapr:next(1, #mesa_stratum_colors)

	-- … and a random thickness
	local heightrandom = mesapr:next(1, 12)
	local h = heightrandom == 12 and 4 or heightrandom >= 10 and 3 or heightrandom >= 8 and 2 or 1
	-- Small built-in bias: Only thin strata up to this Y level
	if y < 45 then h = math.min(h, 2) end

	-- Register stratum
	stratum(y, h, mesa_stratum_colors[colorid])

	-- Skip a random amount of layers (which won't get painted)
	local skiprandom = mesapr:next(1, 12)
	local skip = skiprandom == 12 and 4 or skiprandom >= 10 and 3 or skiprandom >= 5 and 2 or skiprandom >= 2 and 1 or 0

	-- Get height of next stratum or finish
	y = y + h + skip
end
--[[ END OF DANGER ZONE ]]

-- Dead bushes
vl_biomes.register_decoration({
	biomes = {"Mesa", "Mesa_sandlevel", "MesaPlateauF", "MesaPlateauF_sandlevel", "MesaPlateauF_grasstop", "MesaBryce"},
	decoration = "mcl_core:deadbush",
	y_min = 4,
	place_on = {"group:sand", "mcl_core:podzol", "mcl_core:dirt", "mcl_core:dirt_with_grass", "mcl_core:coarse_dirt", "group:hardened_clay"},
	noise_params = {
		offset = 0.01,
		scale = 0.06,
		spread = vector.new(100, 100, 100),
		seed = 1972,
		octaves = 3,
		persist = 0.6
	},
	rank = 1500,
})
vl_biomes.register_decoration({
	biomes = {"MesaPlateauFM_grasstop"},
	decoration = "mcl_core:deadbush",
	y_min = 4,
	place_on = {"group:sand", "mcl_core:dirt", "mcl_core:dirt_with_grass", "mcl_core:coarse_dirt"},
	noise_params = {
		offset = 0.01,
		scale = 0.06,
		spread = vector.new(100, 100, 100),
		seed = 1972,
		octaves = 3,
		persist = 0.6
	},
	rank = 1500,
})
vl_biomes.register_decoration({
	biomes = {"MesaPlateauFM", "MesaPlateauFM_sandlevel"},
	decoration = "mcl_core:deadbush",
	y_min = 4,
	place_on = {"group:sand"},
	noise_params = {
		offset = 0.01,
		scale = 0.06,
		spread = vector.new(100, 100, 100),
		seed = 1972,
		octaves = 3,
		persist = 0.6
	},
	rank = 1500,
})
vl_biomes.register_decoration({
	biomes = {"MesaPlateauFM", "MesaPlateauFM_sandlevel", "MesaPlateauFM_grasstop"},
	decoration = "mcl_core:deadbush",
	y_min = 4,
	place_on = {"group:hardened_clay"},
	noise_params = {
		offset = 0.01,
		scale = 0.06,
		spread = vector.new(100, 100, 100),
		seed = 1972,
		octaves = 3,
		persist = 0.6
	},
	rank = 1500,
})
