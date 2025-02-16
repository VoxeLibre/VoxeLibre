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
	vl_biomes.register_decoration({
		biomes = bs,
		decoration = "mcl_core:reeds",
		param2 = param2,
		height = 1,
		height_max = 3,
		y_min = 1,
		y_max = vl_biomes.overworld_max,
		place_on = {"mcl_core:dirt", "mcl_core:coarse_dirt", "group:grass_block_no_snow", "group:sand", "mcl_core:podzol", "mcl_core:reeds"},
		spawn_by = {"mcl_core:water_source", "mclx_core:river_water_source", "group:frosted_ice"},
		num_spawn_by = 1,
		noise_params = {
			offset = -0.3,
			scale = 0.7,
			spread = vector.new(200, 200, 200),
			seed = 2,
			octaves = 3,
			persist = 0.7
		},
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
		offset = 0.1,
		scale = 0.5,
		spread = vector.new(100, 100, 100),
		seed = 3,
		octaves = 3,
		persist = 0.7,
	},
})
