local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
	vector.new(0,1,0),
	vector.new(0,-1,0)
}

local function makegeode(pos,pr)
	local size = pr:next(3,18)
	local p1 = vector.offset(pos,-size,-size,-size)
	local p2 = vector.offset(pos,size,size,size)
	local nn = minetest.find_nodes_in_area(p1,p2,{"group:material_stone"})
	table.sort(nn,function(a, b)
		   return vector.distance(pos, a) < vector.distance(pos, b)
	end)
	if not nn[1] then return end
	for i=1,math.random(#nn) do
		minetest.set_node(nn[i],{name="mcl_amethyst:amethyst_block"})
	end
	local nnn = minetest.find_nodes_in_area(p1,p2,{"mcl_amethyst:amethyst_block"})
	for k,v in pairs(nnn) do
		local all_amethyst = true
		for kk,vv in pairs(adjacents) do
			local pp = vector.add(v,vv)
			local an = minetest.get_node(pp)
			if an.name ~= "mcl_amethyst:amethyst_block" then
				if minetest.get_item_group(an.name,"material_stone") > 0 then
					minetest.set_node(pp,{name="mcl_amethyst:calcite"})
					if pr:next(1,5) == 1 then
						minetest.set_node(v,{name="mcl_amethyst:budding_amethyst_block"})
					end
					all_amethyst = false
				elseif an.name ~= "mcl_amethyst:amethyst_block" and an.name ~= "air" then
					all_amethyst = false
				end
			end
		end
		if all_amethyst then minetest.set_node(v,{name="air"}) end
	end

	local nnnn = minetest.find_nodes_in_area_under_air(p1,p2,{"mcl_amethyst:amethyst_block"})
	for k,v in pairs(nnnn) do
		local r = pr:next(1,50)
		if r < 10 then
			minetest.set_node(vector.offset(v,0,1,0),{name="mcl_amethyst:amethyst_cluster",param2=1})
		end
	end
end

mcl_structures.register_structure("geodes",{
	place_on = {"mcl_core:stone"},
	spawn_by = {"air"},
	num_spawn_by = 2,
	fill_ratio = 0.002,
	flags = "place_center_x, place_center_z, force_placement",
	biomes = ocean_biomes,
	y_max = mcl_vars.mg_overworld_max,
	y_min = mcl_vars.mg_overworld_min,
	filenames = schems,
	y_offset = function(pr) return pr:next(-4,-2) end,
	place_func = function(pos,def,pr)
		local p = vector.new(pos.x + pr:next(-30,30),pos.y,pos.z + pr:next(-30,30))
		makegeode(pos,pr)
	end,
})

minetest.register_chatcommand("makegeode",{
	privs = { debug = true },
	func=function(n,p)
		local pos = pl:get_pos()
		makegeode(pos,PseudoRandom(minetest.get_mapgen_setting("seed")))
	end
})
