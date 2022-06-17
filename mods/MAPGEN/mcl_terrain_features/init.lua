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

local function set_node_no_bedrock(pos,node)
	local n = minetest.get_node(pos)
	if n.name == "mcl_core:bedrock" then return end
	return minetest.set_node(pos,node)
end

local function airtower(pos)
	for i=0,55 do
		set_node_no_bedrock(vector.offset(pos,0,i,0),{name="air"})
	end
end

local function makelake(pos,size,liquid,placein,border,pr)
	local node_under = minetest.get_node(vector.offset(pos,0,1,0))
	local p1 = vector.offset(pos,-size,-size,-size)
	local p2 = vector.offset(pos,size,size,size)
	local nn = minetest.find_nodes_in_area(p1,p2,placein)
	table.sort(nn,function(a, b)
	   return vector.distance(vector.new(pos.x,0,pos.z), a) < vector.distance(vector.new(pos.x,0,pos.z), b)
	end)
	if not nn[1] then return end
	local y = pos.y + 1
	local lq = {}
	for i=1,pr:next(1,#nn) do
		if nn[i].y == y then
			set_node_no_bedrock(nn[i],{name=liquid})
			airtower(vector.offset(nn[i],0,1,0))
			table.insert(lq,nn[i])
		end
	end

	for k,v in pairs(lq) do
		for kk,vv in pairs(adjacents) do
			local pp = vector.add(v,vv)
			local an = minetest.get_node(pp)
			local un = minetest.get_node(vector.offset(pp,0,1,0))
			if not border then
				if minetest.get_item_group(an.name,"solid") > 0 then
					border = an.name
				elseif minetest.get_item_group(minetest.get_node(nn[1]).name,"solid") > 0 then
					border = minetest.get_node(nn[1]).name
				else
					border = "mcl_core:stone"
				end
				if border == "mcl_core:dirt" then border = "mcl_core:dirt_with_grass" end
			end
			if an.name ~= liquid then
				set_node_no_bedrock(pp,{name=border})
				if un.name ~= liquid then
					airtower(vector.offset(pp,0,1,0))
				end
			end
		end
	end
	return true
end

mcl_structures.register_structure("lavapool",{
	place_on = {"group:sand", "group:dirt", "group:stone"},
	noise_params = {
		offset = 0,
		scale = 0.0000022,
		spread = {x = 250, y = 250, z = 250},
		seed = 78375213,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "place_center_x, place_center_z, force_placement",
	y_max = mcl_vars.mg_overworld_max,
	y_min = minetest.get_mapgen_setting("water_level"),
	place_func = function(pos,def,pr)
		return makelake(pos,5,"mcl_core:lava_source","mcl_core:stone",{"group:material_stone", "group:sand", "group:dirt"},pr)
	end
})

mcl_structures.register_structure("water_lake",{
	place_on = {"group:dirt","group:stone"},
	noise_params = {
		offset = 0,
		scale = 0.000032,
		spread = {x = 250, y = 250, z = 250},
		seed = 734341353,
		octaves = 3,
		persist = 0.001,
		flags = "absvalue",
	},
	flags = "place_center_x, place_center_z, force_placement",
	y_max = mcl_vars.mg_overworld_max,
	y_min = minetest.get_mapgen_setting("water_level"),
	place_func = function(pos,def,pr)
		return makelake(pos,5,"mcl_core:water_source",{"group:material_stone", "group:sand", "group:dirt"},nil,pr)
	end
})


mcl_structures.register_structure("basalt_column",{
	place_on = {"mcl_blackstone:blackstone","mcl_blackstone:basalt"},
	spawn_by = {"air"},
	num_spawn_by = 2,
	noise_params = {
		offset = 0,
		scale = 0.01,
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
	place_func = function(pos,def,pr)
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-5,-1,-5),vector.offset(pos,5,-1,5),{"air","mcl_blackstone:basalt","mcl_blackstone:blackstone"})
		table.sort(nn,function(a, b)
		   return vector.distance(vector.new(pos.x,0,pos.z), a) < vector.distance(vector.new(pos.x,0,pos.z), b)
		end)
		if #nn < 1 then return false end
		for i=1,pr:next(1,#nn) do
			local dst=vector.distance(pos,nn[i])
			for ii=0,pr:next(1,15)-dst do
				set_node_no_bedrock(vector.new(nn[i].x,nn[i].y + ii,nn[i].z),{name="mcl_blackstone:basalt"})
			end
		end
		return true
	end
})

mcl_structures.register_structure("netherlavapool",{
	place_on = {"mcl_blackstone:blackstone","mcl_blackstone:basalt"},
	spawn_by = {"mcl_blackstone:basalt","mcl_blackstone:blackstone"},
	num_spawn_by = 2,
	noise_params = {
		offset = 0,
		scale = 0.01,
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
	place_func = function(pos,def,pr)
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-15,-1,-15),vector.offset(pos,15,-1,15),{"mcl_blackstone:basalt","mcl_blackstone:blackstone"})
		table.sort(nn,function(a, b)
		   return vector.distance(vector.new(pos.x,0,pos.z), a) < vector.distance(vector.new(pos.x,0,pos.z), b)
		end)
		if #nn < 1 then return false end
		local lava = {}
		for i=1,pr:next(1,#nn) do
			set_node_no_bedrock(nn[i],{name="mcl_nether:nether_lava_source"})
			table.insert(lava,nn[i])
		end
		for _,v in pairs(lava) do
			for _,vv in pairs(adjacents) do
				local p = vector.add(v,vv)
				if minetest.get_node(p).name ~= "mcl_nether:nether_lava_source" then
					set_node_no_bedrock(p,{name="mcl_blackstone:basalt"})
				end
			end
			if math.random(3) == 1 then
				set_node_no_bedrock(v,{name="mcl_nether:magma"})
			end
		end
		return true
	end
})
