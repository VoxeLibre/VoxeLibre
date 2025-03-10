local mushrooms = {"mcl_mushrooms:mushroom_brown","mcl_mushrooms:mushroom_red"}

local function get_fallen_tree_schematic(pos,pr)
	local tree = minetest.find_node_near(pos,15,{"group:tree"})
	if not tree then return end
	tree = minetest.get_node(tree).name
	local maxlen = 8
	local minlen = 2
	local vprob = 120
	local mprob = 160
	local len = pr:next(minlen,maxlen)
	local schem = {
		size = {x = len + 2, y = 2, z = 3},
		data = {
			{name = "air", prob=0},
			{name = "air", prob=0},
		}
	}
	for i = 1,len do
		table.insert(schem.data,{name = "mcl_core:vine",param2=4, prob=vprob})
	end
	table.insert(schem.data,{name = "air", prob=0})
	table.insert(schem.data,{name = "air", prob=0})
	for i = 1,len do
		table.insert(schem.data,{name = "air", prob=0})
	end

	table.insert(schem.data,{name = tree, param2 = 0})
	table.insert(schem.data,{name = "air", prob=0})
	for i = 1,len do
		table.insert(schem.data,{name = tree, param2 = 12})
	end
	table.insert(schem.data,{name = "air", prob=0})
	table.insert(schem.data,{name = "air", prob=0})
	for i = 1,len do
		table.insert(schem.data,{name =  mushrooms[pr:next(1,#mushrooms)], param2 = 12, prob=mprob})
	end

	table.insert(schem.data,{name = "air", prob=0})
	table.insert(schem.data,{name = "air", prob=0})
	for i = 1,len do
		table.insert(schem.data,{name = "mcl_core:vine",param2=5, prob=vprob})
	end
	table.insert(schem.data,{name = "air", prob=0})
	table.insert(schem.data,{name = "air", prob=0})
	for i = 1,len do
		table.insert(schem.data,{name = "air", prob=0})
	end

	return schem
end

mcl_structures.register_structure("fallen_tree",{
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
	sidelen = 18,
	solid_ground = true,
	y_max = mcl_vars.mg_overworld_max,
	y_min = minetest.get_mapgen_setting("water_level"),
	on_place = function(pos,def,pr)
		local air_p1 = vector.offset(pos,-def.sidelen/2,1,-def.sidelen/2)
		local air_p2 = vector.offset(air_p1,def.sidelen-1,0,def.sidelen-1)
		local air = minetest.find_nodes_in_area(air_p1,air_p2,{"air"})
		return #air >= (def.sidelen * def.sidelen) / 2
	end,
	place_func = function(pos,def,pr)
		local schem=get_fallen_tree_schematic(pos,pr)
		if not schem then return end
		return minetest.place_schematic(vector.offset(pos, 0, 1, 0), schem, "random")
	end
})
