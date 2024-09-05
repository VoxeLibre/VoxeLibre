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

local function airtower(pos,tbl,h)
	for i=1,h do
		table.insert(tbl,vector.offset(pos,0,i,0))
	end
end

local function makelake(pos,size,liquid,placein,border,pr,noair)
	local p1, p2 = vector.offset(pos,-size,-1,-size), vector.offset(pos,size,-1,size)
	local e1, e2 = vector.offset(pos,-size,-2,-size), vector.offset(pos,size,15,size)
	minetest.emerge_area(e1, e2, function(_, _, calls_remaining)
		if calls_remaining ~= 0 then return end
		local nn = minetest.find_nodes_in_area(p1,p2,placein)
		if not nn[1] then return end
		table.sort(nn,function(a, b)
		   return vector.distance(pos, a) < vector.distance(pos, b)
		end)
		local y = pos.y - 1
		local lq, air = {}, {}
		local r = pr:next(1,#nn)
		for i=1,r do
			airtower(nn[i],air,20)
			table.insert(lq,nn[i])
		end
		minetest.bulk_swap_node(lq,{name=liquid})
		minetest.bulk_swap_node(air,{name="air"})
		air = {}
		local br = {}
		for k,v in pairs(lq) do
			for kk,vv in pairs(adjacents) do
				local pp = vector.add(v,vv)
				local an = minetest.get_node(pp)
				if not border then
					if minetest.get_item_group(an.name,"solid") > 0 then
						border = an.name
					elseif minetest.get_item_group(minetest.get_node(nn[1]).name,"solid") > 0 then
						border = minetest.get_node_or_nil(nn[1]).name
					else
						border = "mcl_core:stone"
					end
					if border == nil or border == "mcl_core:dirt" then border = "mcl_core:dirt_with_grass" end
				end
				if not noair and an.name ~= liquid then
					table.insert(br,pp)
					--[[ no need to have air above border:
					local un = minetest.get_node(vector.offset(pp,0,1,0))
					if un.name ~= liquid then
						airtower(pp,air,20)
					end]]--
				end
			end
		end
		minetest.bulk_swap_node(br,{name=border})
		minetest.bulk_swap_node(air,{name="air"})
		return true
	end)
	return true
end

local mushrooms = {"mcl_mushrooms:mushroom_brown","mcl_mushrooms:mushroom_red"}

local function place_tree(pos,def,pr)
	local tree = minetest.find_node_near(pos,15,{"group:tree"})
	if not tree then return end
	tree = minetest.get_node(tree).name
	local minlen, maxlen = 3, 9
	local vrate, mrate = 120, 160
	local len = pr:next(minlen,maxlen)
	local dir = pr:next(0,3)
	local dx, dy, dz, param2, w1, w2
	if dir == 0 then
		dx, dy, dz, param2, w1, w2 = 1, 0, 0, 12, 5, 4
	elseif dir == 1 then
		dx, dy, dz, param2, w1, w2 = -1, 0, 0, 12, 4, 5
	elseif dir == 2 then
		dx, dy, dz, param2, w1, w2 = 0, 0, 1, 6, 3, 2
	else -- if dir == 3 then
		dx, dy, dz, param2, w1, w2 = 0, 0, -1, 6, 2, 3
	end
	-- TODO: port this to voxel manipulators
	-- ensure we have room for the tree
	local minsupport, maxsupport = 99, 1
	for i = 1,len do
		-- check below
		local n = minetest.get_node(vector.offset(pos, dx * i, -1, dz * i)).name
		local nd = minetest.registered_nodes[n]
		if n ~= "air" and nd.groups and nd.groups.solid and i > 2 then
			if i < minsupport then minsupport = i end
			maxsupport = i
		end
		-- check space
		local n = minetest.get_node(vector.offset(pos, dx * i, 0, dz * i)).name
		local nd = minetest.registered_nodes[n]
		if n ~= "air" and nd.groups and not nd.groups.plant then
			if i < minlen or pr:next(1,maxsupport) == 1 then return end
			len = i
			break
		end
	end
	if maxsupport - minsupport < minlen then return end
	len = math.min(len, maxsupport - 1)
	if len < minlen then return end
	-- place the tree
	minetest.swap_node(pos, {name = tree, param2 = 0})
	for i = 2,len do
		minetest.swap_node(vector.offset(pos, dx * i, 0, dz * i), {name = tree, param2 = param2})
		if pr:next(0,255) < vrate then
			local side = vector.offset(pos, dx * i + dz, 0, dz * i + dx)
			local n = minetest.get_node(side).name
			if n == "air" then
				minetest.swap_node(side, {name="mcl_core:vine", param2=w1})
			end
		end
		if pr:next(0,255) < vrate then
			local side = vector.offset(pos, dx * i - dz, 0, dz * i - dx)
			local n = minetest.get_node(side).name
			if n == "air" then
				minetest.swap_node(side, {name="mcl_core:vine", param2=w2})
			end
		end
		if pr:next(0,255) < mrate then
			local top = vector.offset(pos, dx * i, 1, dz * i)
			local n = minetest.get_node(top).name
			if n == "air" then
				minetest.swap_node(top, {name = mushrooms[pr:next(1,#mushrooms)], param2 = 12})
			end
		end
	end
end

vl_structures.register_structure("fallen_tree",{
	rank = 1100, -- after regular trees
	place_on = {"group:grass_block"},
	terrain_feature = true,
	noise_params = {
		offset = 0.00018,
		scale = 0.01011,
		spread = {x = 250, y = 250, z = 250},
		seed = 24533,
		octaves = 3,
		persist = 0.66
	},
	flags = "place_center_x, place_center_z",
	solid_ground = true,
	y_max = mcl_vars.mg_overworld_max,
	y_min = minetest.get_mapgen_setting("water_level"),
	place_func = place_tree
})

vl_structures.register_structure("lavapool",{
	place_on = {"group:sand", "group:dirt", "group:stone"},
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.0000022,
		spread = {x = 250, y = 250, z = 250},
		seed = 78375213,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "place_center_x, place_center_z, all_floors",
	y_max = mcl_vars.mg_overworld_max,
	y_min = minetest.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos,5,"mcl_core:lava_source",{"group:material_stone", "group:sand", "group:dirt"},"mcl_core:stone",pr)
	end
})

vl_structures.register_structure("water_lake",{
	place_on = {"group:dirt","group:stone"},
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.000032,
		spread = {x = 250, y = 250, z = 250},
		seed = 756641353,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "place_center_x, place_center_z, all_floors",
	y_max = mcl_vars.mg_overworld_max,
	y_min = minetest.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos,5,"mcl_core:water_source",{"group:material_stone", "group:sand", "group:dirt","group:grass_block"},"mcl_core:dirt_with_grass",pr)
	end
})

vl_structures.register_structure("water_lake_mangrove_swamp",{
	place_on = {"mcl_mud:mud"},
	biomes = { "MangroveSwamp" },
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.0032,
		spread = {x = 250, y = 250, z = 250},
		seed = 6343241353,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "place_center_x, place_center_z, all_floors",
	y_max = mcl_vars.mg_overworld_max,
	y_min = minetest.get_mapgen_setting("water_level"),
	place_func = function(pos, _, pr)
		return makelake(pos,3,"mcl_core:water_source",{"group:material_stone", "group:sand", "group:dirt","group:grass_block","mcl_mud:mud"},"mcl_mud:mud",pr,true)
	end
})

vl_structures.register_structure("basalt_column",{
	place_on = {"mcl_blackstone:blackstone","mcl_blackstone:basalt"},
	terrain_feature = true,
	spawn_by = {"air"},
	num_spawn_by = 2,
	noise_params = {
		offset = 0,
		scale = 0.003,
		spread = {x = 250, y = 250, z = 250},
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
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-5,-1,-5),vector.offset(pos,5,-1,5),{"air","mcl_blackstone:basalt","mcl_blackstone:blackstone"})
		table.sort(nn,function(a, b)
		   return vector.distance(vector.new(pos.x,0,pos.z), a) < vector.distance(vector.new(pos.x,0,pos.z), b)
		end)
		if #nn < 1 then return false end
		local basalt = {}
		local magma = {}
		for i=1,pr:next(1,#nn) do
			if minetest.get_node(vector.offset(nn[i],0,-1,0)).name ~= "air" then
				local dst=vector.distance(pos,nn[i])
				local r = pr:next(1,14)-dst
				for ii=0,r do
					if pr:next(1,25) == 1 then
						table.insert(magma,vector.new(nn[i].x,nn[i].y + ii,nn[i].z))
					else
						table.insert(basalt,vector.new(nn[i].x,nn[i].y + ii,nn[i].z))
					end
				end
			end
		end
		minetest.bulk_swap_node(magma,{name="mcl_nether:magma"})
		minetest.bulk_swap_node(basalt,{name="mcl_blackstone:basalt"})
		return true
	end
})
vl_structures.register_structure("basalt_pillar",{
	place_on = {"mcl_blackstone:blackstone","mcl_blackstone:basalt"},
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.001,
		spread = {x = 250, y = 250, z = 250},
		seed = 7113,
		octaves = 5,
		persist = 0.1,
		flags = "absvalue",
	},
	flags = "all_floors",
	y_max = mcl_vars.mg_nether_max-40,
	y_min = mcl_vars.mg_lava_nether_max + 1,
	biomes = { "BasaltDelta" },
	place_func = function(pos, _, pr)
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-2,-1,-2),vector.offset(pos,2,-1,2),{"air","mcl_blackstone:basalt","mcl_blackstone:blackstone"})
		table.sort(nn,function(a, b)
		   return vector.distance(vector.new(pos.x,0,pos.z), a) < vector.distance(vector.new(pos.x,0,pos.z), b)
		end)
		if #nn < 1 then return false end
		local basalt = {}
		local magma = {}
		for i=1,pr:next(1,#nn) do
			if minetest.get_node(vector.offset(nn[i],0,-1,0)).name ~= "air" then
				local dst=vector.distance(pos,nn[i])
				for ii=0,pr:next(19,35)-dst do
					if pr:next(1,20) == 1 then
						table.insert(magma,vector.new(nn[i].x,nn[i].y + ii,nn[i].z))
					else
						table.insert(basalt,vector.new(nn[i].x,nn[i].y + ii,nn[i].z))
					end
				end
			end
		end
		minetest.bulk_swap_node(basalt,{name="mcl_blackstone:basalt"})
		minetest.bulk_swap_node(magma,{name="mcl_nether:magma"})
		return true
	end
})

vl_structures.register_structure("lavadelta",{
	place_on = {"mcl_blackstone:blackstone","mcl_blackstone:basalt"},
	spawn_by = {"mcl_blackstone:basalt","mcl_blackstone:blackstone"},
	num_spawn_by = 2,
	terrain_feature = true,
	noise_params = {
		offset = 0,
		scale = 0.005,
		spread = {x = 250, y = 250, z = 250},
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
		local nn = minetest.find_nodes_in_area_under_air(vector.offset(pos,-10,-1,-10),vector.offset(pos,10,-2,10),{"mcl_blackstone:basalt","mcl_blackstone:blackstone","mcl_nether:netherrack"})
		table.sort(nn,function(a, b)
		   return vector.distance(vector.new(pos.x,0,pos.z), a) < vector.distance(vector.new(pos.x,0,pos.z), b)
		end)
		if #nn < 1 then return false end
		local lava = {}
		for i=1,pr:next(1,#nn) do
			table.insert(lava,nn[i])
		end
		minetest.bulk_swap_node(lava,{name="mcl_nether:nether_lava_source"})
		local basalt = {}
		local magma = {}
		for _,v in pairs(lava) do
			for _,vv in pairs(adjacents) do
				local p = vector.add(v,vv)
				if minetest.get_node(p).name ~= "mcl_nether:nether_lava_source" then
					table.insert(basalt,p)

				end
			end
			if math.random(3) == 1 then
				table.insert(magma,v)
			end
		end
		minetest.bulk_swap_node(basalt,{name="mcl_blackstone:basalt"})
		minetest.bulk_swap_node(magma,{name="mcl_nether:magma"})
		return true
	end
})
