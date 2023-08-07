mcl_lush_caves = {}
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(0,-1,0)
}

local function vector_distance_xz(a, b)
	return vector.distance(
		{ x=a.x, y=0, z=a.z },
		{ x=b.x, y=0, z=b.z }
	)
end

dofile(modpath.."/nodes.lua")
dofile(modpath.."/dripleaf.lua")

function mcl_lush_caves.makelake(pos,def,pr)
	local p1 = vector.offset(pos,-8,-4,-8)
	local p2 = vector.offset(pos,8,4,8)
	local nn = minetest.find_nodes_in_area_under_air(p1,p2,{"group:solid"})
	table.sort(nn,function(a, b)
		   return vector_distance_xz(pos, a) < vector_distance_xz(pos, b)
	end)
	if not nn[1] then return end
	local dripleaves = {}
	for i=1,pr:next(1,#nn) do
		minetest.set_node(nn[i],{name="mcl_core:water_source"})
		if pr:next(1,20) == 1 then
			table.insert(dripleaves,nn[i])
		end
	end
	local nnn = minetest.find_nodes_in_area(p1,p2,{"mcl_core:water_source"})
	for k,v in pairs(nnn) do
		for kk,vv in pairs(adjacents) do
			local pp = vector.add(v,vv)
			local an = minetest.get_node(pp)
			if an.name ~= "mcl_core:water_source" then
				minetest.set_node(pp,{name="mcl_core:clay"})
				if pr:next(1,20) == 1 then
					minetest.set_node(vector.offset(pp,0,1,0),{name="mcl_lush_caves:moss_carpet"})
				end
			end
		end
	end
	for _,d in pairs(dripleaves) do
		if minetest.get_item_group(minetest.get_node(d).name,"water") > 0 then
			minetest.set_node(vector.offset(d,0,-1,0),{name="mcl_lush_caves:dripleaf_big_waterroot"})
			minetest.registered_nodes["mcl_lush_caves:dripleaf_big_stem"].on_construct(d)
			for ii = 1, pr:next(1,4) do
				mcl_lush_caves.dripleaf_grow(d,{name = "mcl_lush_caves:dripleaf_big_stem"})
			end
		end
	end
	return true
end

function mcl_lush_caves.makeazalea(pos,def,pr)
	local airup = minetest.find_nodes_in_area_under_air(vector.offset(pos,0,40,0),pos,{"mcl_core:dirt_with_grass"})
	if #airup == 0 then
		return end
	local surface_pos = airup[1]
	local nn = minetest.find_nodes_in_area(vector.offset(pos,-4,0,-4),vector.offset(pos,4,40,4),{"group:material_stone","mcl_core:dirt","mcl_core:coarse_dirt"})
	table.sort(nn,function(a, b) return vector_distance_xz(surface_pos, a) < vector_distance_xz(surface_pos, b) end)
	minetest.set_node(pos,{name="mcl_lush_caves:rooted_dirt"})
	for i=1,math.random(1,#nn) do
		local below = vector.offset(nn[i],0,-1,0)
		minetest.set_node(nn[i],{name="mcl_lush_caves:rooted_dirt"})
		if minetest.get_node(below).name == "air" then
			minetest.set_node(below,{name = "mcl_lush_caves:hanging_roots"})
		end
	end
	for _,v in pairs(nn) do
		for _,a in pairs(adjacents) do
			local p = vector.add(v,a)
			if minetest.get_item_group(minetest.get_node(p).name,"material_stone") > 0 then
				if math.random(2) == 1 then minetest.set_node(p,{name="mcl_core:stone"}) end
			end
		end
	end
	minetest.place_schematic(vector.offset(surface_pos,-2,0,-2),modpath.."/schematics/azalea1.mts","random",nil,nil,"place_center_x place_center_z")
	minetest.log("action","[mcl_lush_caves] Azalea generated at "..minetest.pos_to_string(surface_pos))
	return true
end



local lushcaves = { "LushCaves", "LushCaves_underground", "LushCaves_ocean", "LushCaves_deep_ocean"}
minetest.register_abm({
	label = "Cave vines grow",
	nodenames = {"mcl_lush_caves:cave_vines_lit","mcl_lush_caves:cave_vines"},
	interval = 180,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local pu = vector.offset(pos,0,1,0)
		local pun = minetest.get_node(pu).name
		local pd = vector.offset(pos,0,-1,0)
		local pd2 = minetest.get_node(vector.offset(pos,0,-2,0)).name
		if pun ~= "mcl_lush_caves:cave_vines_lit" and pun ~= "mcl_lush_caves:cave_vines"  and pun ~= "mcl_lush_caves:moss" then
			minetest.set_node(pos,{name="air"})
			return
		end
		node.name = "mcl_lush_caves:cave_vines"
		if  math.random(5) == 1 then
			node.name="mcl_lush_caves:cave_vines_lit"
		end
		if minetest.get_node(pd).name == "air" and pd2 == "air" then
			minetest.swap_node(pd,node)
		else
			minetest.swap_node(pos,{name="mcl_lush_caves:cave_vines_lit"})
		end
	end
})



mcl_structures.register_structure("clay_pool",{
	place_on = {"group:material_stone","mcl_core:gravel","mcl_lush_caves:moss","mcl_core:clay"},
	spawn_by = {"air"},
	num_spawn_by = 1,
	fill_ratio = 0.01,
	terrain_feature = true,
	flags = "all_floors",
	y_max = -10,
	biomes = lushcaves,
	place_func = mcl_lush_caves.makelake,
})

local azaleas = {}
local az_limit = 500
mcl_structures.register_structure("azalea_tree",{
	place_on = {"group:material_stone","mcl_core:gravel","mcl_lush_caves:moss","mcl_core:clay"},
	spawn_by = {"air"},
	num_spawn_by = 1,
	fill_ratio = 0.15,
	flags = "all_ceilings",
	terrain_feature = true,
	y_max =0,
	y_min = mcl_vars.mg_overworld_min + 15,
	biomes = lushcaves,
	place_func = function(pos,def,pr)
		for _,a in pairs(azaleas) do
			if vector.distance(pos,a) < az_limit then
				return true
			end
		end
		if mcl_lush_caves.makeazalea(pos,def,pr) then
			table.insert(azaleas,pos)
			return true
		end
	end
})
--[[
minetest.set_gen_notify({cave_begin = true})
minetest.set_gen_notify({large_cave_begin = true})

mcl_mapgen_core.register_generator("lush_caves",nil, function(minp, maxp, blockseed)
	local gennotify = minetest.get_mapgen_object("gennotify")
	for _, pos in pairs(gennotify["large_cave_begin"] or {}) do
		--minetest.log("large cave at "..minetest.pos_to_string(pos))
	end
	for _, pos in pairs(gennotify["cave_begin"] or {}) do
		minetest.log("cave at "..minetest.pos_to_string(pos))
	end
end, 99999, true)
--]]
