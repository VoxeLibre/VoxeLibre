-- Nether Basalt Delta biome
vl_biomes.register_biome({
	name = "BasaltDelta",
	node_filler = "mcl_nether:netherrack",
	node_stone = "mcl_nether:netherrack",
	node_top = "mcl_blackstone:basalt",
	node_water = "air",
	node_river_water = "air",
	node_cave_liquid = "air",
	y_min = vl_biomes.nether_min,
	y_max = vl_biomes.nether_max + 80,
	heat_point = 27,
	humidity_point = 80,
	_vl_biome_type = "hot",
	_vl_grass_palette = "desert",
	_vl_foliage_palette = "savanna",
	_vl_water_palette = "plains",
	_vl_skycolor = vl_biomes.skycolor.nether,
	_mcl_fogcolor = "#685F70"
})

vl_biomes.register_decoration({
	biomes = {"BasaltDelta"},
	decoration = "mcl_blackstone:basalt",
	param2 = 0,
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	place_on = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_blackstone:nether_gold", "mcl_nether:quartz_ore", "mcl_core:gravel", "mcl_nether:soul_sand", "mcl_blackstone:blackstone", "mcl_nether:magma"},
	fill_ratio = 10, -- fill
	flags = "all_floors",
})

core.register_ore({
	ore_type = "blob",
	ore = "mcl_blackstone:blackstone",
	wherein = {"mcl_nether:netherrack", "mcl_nether:glowstone", "mcl_core:gravel"},
	clust_scarcity = 100,
	clust_num_ores = 400,
	clust_size = 20,
	biomes = {"BasaltDelta"},
	y_min = vl_biomes.lava_nether_max,
	y_max = vl_biomes.nether_deco_max,
	noise_params = {
		offset = 0,
		scale = 1,
		spread = vector.new(250, 250, 250),
		seed = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

vl_biomes.register_decoration({
	biomes = {"BasaltDelta"},
	decoration = "mcl_blackstone:basalt",
	height_max = 55,
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_deco_max - 50,
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	noise_params = {
		offset = -0.0085,
		scale = 0.002,
		spread = vector.new(25, 120, 25),
		seed = 2325,
		octaves = 5,
		persist = 2,
		lacunarity = 3.5,
		flags = "absvalue"
	},
	flags = "all_floors, all ceilings",
})

vl_biomes.register_decoration({
	biomes = {"BasaltDelta"},
	decoration = "mcl_blackstone:basalt",
	height_max = 15,
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_deco_max - 15,
	noise_params = {
		offset = -0.0085,
		scale = 0.004,
		spread = vector.new(25, 120, 25),
		seed = 235,
		octaves = 5,
		persist = 2.5,
		lacunarity = 3.5,
		flags = "absvalue"
	},
	flags = "all_floors, all ceilings",
})

vl_biomes.register_decoration({
	biomes = {"BasaltDelta"},
	decoration = "mcl_blackstone:basalt",
	height_max = 3,
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_deco_max - 15,
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	fill_ratio = 0.4,
	flags = "all_floors, all ceilings",
})

vl_biomes.register_decoration({
	biomes = {"BasaltDelta"},
	decoration = "mcl_nether:magma",
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	place_offset_y = -1,
	fill_ratio = 0.082323,
	y_min = vl_biomes.lava_nether_max + 1,
	flags = "all_floors, all ceilings",
})

vl_biomes.register_decoration({
	biomes = {"BasaltDelta"},
	decoration = "mcl_nether:nether_lava_source",
	place_on = {"mcl_blackstone:basalt", "mcl_nether:netherrack", "mcl_blackstone:blackstone"},
	place_offset_y = -1,
	spawn_by = {"mcl_blackstone:basalt", "mcl_blackstone:blackstone"},
	num_spawn_by = 14,
	fill_ratio = 4,
	y_min = vl_biomes.lava_nether_max + 1,
	y_max = vl_biomes.nether_max - 5,
	flags = "all_floors, force_placement",
})

local adjacents = {
	vector.new(1,0,0),
	vector.new(1,0,1),
	vector.new(1,0,-1),
	vector.new(-1,0,0),
	vector.new(-1,0,1),
	vector.new(-1,0,-1),
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(0,-1,0)
}

vl_structures.register_structure("basalt_column",{
	place_on = { "mcl_blackstone:blackstone", "mcl_blackstone:basalt" },
	terrain_feature = true,
	spawn_by = { "air" },
	num_spawn_by = 2,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = vector.new(250, 250, 250),
		seed = 72235213,
		octaves = 5,
		persist = 0.3,
		flags = "absvalue",
	},
	flags = "all_floors",
	y_max = mcl_vars.mg_nether_max - 20,
	y_min = mcl_vars.mg_lava_nether_max + 1,
	biomes = { "BasaltDelta" },
	place_func = function(pos, _, pr)
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-5,0,-5), vector.offset(pos,5,0,5),
			{ "air", "mcl_blackstone:basalt", "mcl_blackstone:blackstone" })
		table.sort(nn, function(a, b)
		   return vector.distance(pos, a) < vector.distance(pos, b)
		end)
		if #nn < 1 then return false end
		local basalt, magma = {}, {}
		for i = 1, pr:next(1,#nn) do
			if minetest.get_node(vector.offset(nn[i], 0, -1, 0)).name ~= "air" then
				local dst = vector.distance(pos, nn[i])
				for ii = 0, pr:next(1,14) - dst do
					if pr:next(1,25) == 1 then
						table.insert(magma, vector.offset(nn[i], 0, ii, 0))
					else
						table.insert(basalt, vector.offset(nn[i], 0, ii, 0))
					end
				end
			end
		end
		minetest.bulk_swap_node(magma, { name = "mcl_nether:magma" })
		minetest.bulk_swap_node(basalt, { name = "mcl_blackstone:basalt" })
		return true
	end
})

vl_structures.register_structure("basalt_pillar",{
	place_on = { "mcl_blackstone:blackstone", "mcl_blackstone:basalt" },
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.001,
		spread = vector.new(250, 250, 250),
		seed = 7113,
		octaves = 5,
		persist = 0.1,
		flags = "absvalue",
	},
	flags = "all_floors",
	y_max = mcl_vars.mg_nether_max - 40,
	y_min = mcl_vars.mg_lava_nether_max + 1,
	biomes = { "BasaltDelta" },
	place_func = function(pos, _, pr)
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-2,0,-2), vector.offset(pos,2,0,2),
			{ "air", "mcl_blackstone:basalt", "mcl_blackstone:blackstone" })
		table.sort(nn, function(a, b)
		   return vector.distance(pos, a) < vector.distance(pos, b)
		end)
		if #nn < 1 then return false end
		local basalt, magma = {}, {}
		for i = 1, pr:next(1,#nn) do
			if minetest.get_node(vector.offset(nn[i], 0, -1, 0)).name ~= "air" then
				local dst = vector.distance(pos, nn[i])
				for ii = 0, pr:next(19,35) - dst do
					if pr:next(1,20) == 1 then
						table.insert(magma, vector.offset(nn[i], 0, ii, 0))
					else
						table.insert(basalt, vector.offset(nn[i], 0, ii, 0))
					end
				end
			end
		end
		minetest.bulk_swap_node(basalt, { name = "mcl_blackstone:basalt" })
		minetest.bulk_swap_node(magma, { name = "mcl_nether:magma" })
		return true
	end
})

vl_structures.register_structure("lavadelta",{
	place_on = { "mcl_blackstone:blackstone", "mcl_blackstone:basalt" },
	spawn_by = { "mcl_blackstone:basalt", "mcl_blackstone:blackstone" },
	num_spawn_by = 2,
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.005,
		spread = vector.new(250, 250, 250),
		seed = 78375213,
		octaves = 5,
		persist = 0.1,
		flags = "absvalue",
	},
	flags = "all_floors",
	y_max = mcl_vars.mg_nether_max,
	y_min = mcl_vars.mg_lava_nether_max + 1,
	biomes = { "BasaltDelta" },
	place_func = function(pos, _, pr)
		local nn = minetest.find_nodes_in_area_under_air(vector.offset(pos,-10,0,-10), vector.offset(pos,10,-1,10),
			{ "mcl_blackstone:basalt", "mcl_blackstone:blackstone", "mcl_nether:netherrack" })
		table.sort(nn, function(a, b)
		   return vector.distance(pos, a) < vector.distance(pos, b)
		end)
		if #nn < 1 then return false end
		local lava = {}
		for i=1, pr:next(1,#nn) do table.insert(lava,nn[i]) end
		minetest.bulk_swap_node(lava, { name = "mcl_nether:nether_lava_source" })
		local basalt, magma = {}, {}
		for _, v in pairs(lava) do
			for _, vv in pairs(adjacents) do
				local p = vector.add(v, vv)
				if minetest.get_node(p).name ~= "mcl_nether:nether_lava_source" then
					table.insert(basalt,p)
				end
			end
			if math.random(3) == 1 then
				table.insert(magma,v)
			end
		end
		minetest.bulk_swap_node(basalt, { name = "mcl_blackstone:basalt" })
		minetest.bulk_swap_node(magma, { name = "mcl_nether:magma" })
		return true
	end
})
