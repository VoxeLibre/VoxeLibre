-- Sugar canes
local biomes = vl_biomes.overworld_biomes
local bmap = {}
-- note: this assumes decorations run after all biomes!
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
		place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
		sidelen = 16,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = vector.new(200, 200, 200),
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
		y_min = 1,
		y_max = vl_biomes.overworld_max,
		decoration = "mcl_core:reeds",
		height = 1,
		height_max = 3,
		spawn_by = {"mcl_core:water_source", "mclx_core:river_water_source", "group:frosted_ice"},
		num_spawn_by = 1,
		biomes = bs,
		param2 = param2
	})
end

-- additional reeds in swamps
mcl_mapgen_core.register_decoration({
	deco_type = "simple",
	place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
	sidelen = 16,
	noise_params = {
		offset = 0.1,
		scale = 0.5,
		spread = vector.new(100, 100, 100),
		seed = 3,
		octaves = 3,
		persist = 0.7,
	},
	biomes = {"Swampland", "Swampland_shore"},
	y_min = 1,
	y_max = vl_biomes.overworld_max,
	decoration = "mcl_core:reeds",
	height = 1,
	height_max = 3,
	spawn_by = {"mcl_core:water_source", "group:frosted_ice"},
	num_spawn_by = 1,
	param2 = 28 -- Swampland grass palette index
})
