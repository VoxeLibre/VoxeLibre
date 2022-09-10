local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local modpath = minetest.get_modpath(modname)


mcl_structures.register_structure("end_spawn_obsidian_platform",{
	static_pos ={mcl_vars.mg_end_platform_pos},
	place_func = function(pos,def,pr)
		local nn = minetest.find_nodes_in_area(vector.offset(pos,-2,0,-2),vector.offset(pos,2,0,2),{"air","mcl_end:end_stone"})
		minetest.bulk_set_node(nn,{name="mcl_core:obsidian"})
		return true
	end,
})

mcl_structures.register_structure("end_exit_portal",{
	static_pos = { mcl_vars.mg_end_exit_portal_pos },
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
	after_place = function(pos,def,pr)
		local p1 = vector.offset(pos,-5,-5,-5)
		local p2 = vector.offset(pos,5,5,5)
		minetest.emerge_area(p1, p2, function(blockpos, action, calls_remaining, param)
			if calls_remaining ~= 0 then return end
			local nn = minetest.find_nodes_in_area(p1,p2,{"mcl_portals:portal_end"})
			minetest.bulk_set_node(nn,{name="air"})
		end)
	end
})
mcl_structures.register_structure("end_exit_portal_open",{
	--static_pos = { mcl_vars.mg_end_exit_portal_pos },
	filenames = {
		modpath.."/schematics/mcl_structures_end_exit_portal.mts"
	},
})

local function get_tower(p,h,tbl)
	for i = 1,h do
		table.insert(tbl,vector.offset(p,0,i,0))
	end
end

local function make_endspike(pos,width,height)
	local nn = minetest.find_nodes_in_area(vector.offset(pos,-width/2,0,-width/2),vector.offset(pos,width/2,0,width/2),{"air","group:solid"})
	table.sort(nn,function(a, b)
		return vector.distance(pos, a) < vector.distance(pos, b)
	end)
	local nodes = {}
	for i = 1,math.ceil(#nn*0.55) do
		get_tower(nn[i],height,nodes)
	end
	minetest.bulk_set_node(nodes,{ name="mcl_core:obsidian"} )
	return vector.offset(pos,0,height,0)
end

local function get_points_on_circle(pos,r,n)
	local rt = {}
	for i=1, n do
		table.insert(rt,vector.offset(pos,r * math.cos(((i-1)/n) * (2*math.pi)),0,  r* math.sin(((i-1)/n) * (2*math.pi)) ))
	end
	return rt
end

mcl_structures.register_structure("end_spike",{
	static_pos =get_points_on_circle(vector.offset(mcl_vars.mg_end_exit_portal_pos,0,-20,0),43,10),
	place_func = function(pos,def,pr)
		local d = pr:next(6,12)
		local h = d * pr:next(4,6)
		local p1 = vector.add(pos,-d/2,0,-d/2)
		local p2 = vector.add(pos,d/2,h+5,d/2)
		minetest.emerge_area(p1, p2, function(blockpos, action, calls_remaining, param)
			if calls_remaining ~= 0 then return end
			local s = make_endspike(pos,d,h)
			minetest.set_node(vector.offset(s,0,1,0),{name="mcl_core:bedrock"})
			minetest.add_entity(vector.offset(s,0,2,0),"mcl_end:crystal")
		end)
	end,
})
