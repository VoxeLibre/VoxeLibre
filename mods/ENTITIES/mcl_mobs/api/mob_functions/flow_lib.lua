--this is from https://github.com/HybridDog/builtin_item/blob/e6dfd9dce86503b3cbd1474257eca5f6f6ca71c2/init.lua#L50
local
pairs, minetest_get_node, vector_subtract, minetest_registered_nodes
=
pairs, minetest.get_node, vector.subtract, minetest.registered_nodes

local function get_nodes(pos)
	local x, y, z = pos.x, pos.y, pos.z
	local node1, node2, node3, node4 =
		{x = x - 1, y = y, z = z    },
		{x = x,     y = y, z = z - 1},
		{x = x + 1, y = y, z = z    },
		{x = x,     y = y, z = z + 1}
	local nodes = {
		 {node1, minetest_get_node(node1)},
		 {node2, minetest_get_node(node2)},
		 {node3, minetest_get_node(node3)},
		 {node4, minetest_get_node(node4)}
	}
	return nodes
end

local data
local param2
local nd
local par2
local name
local tmp
local c_node
function mobs.get_flowing_dir(pos)
	c_node = minetest_get_node(pos).name
	if c_node ~= "mcl_core:water_flowing" and c_node ~= "mcl_core:water" then
		return nil
	end
	data = get_nodes(pos)
	param2 = minetest_get_node(pos).param2
	if param2 > 7 then
		return nil
	end
	if c_node == "mcl_core:water" then
		for _,i in pairs(data) do
			nd = i[2]
			name = nd.name
			par2 = nd.param2
			if name == "mcl_core:water_flowing" and par2 == 7 then
				return(vector_subtract(i[1],pos))
			end
		end
	end
	for _,i in pairs(data) do
		nd = i[2]
		name = nd.name
		par2 = nd.param2
		if name == "mcl_core:water_flowing" and par2 < param2 then
			return(vector_subtract(i[1],pos))
		end
	end
	for _,i in pairs(data) do
		nd = i[2]
		name = nd.name
		par2 = nd.param2
		if name == "mcl_core:water_flowing" and par2 >= 11 then
			return(vector_subtract(i[1],pos))
		end
	end
	for _,i in pairs(data) do
		nd = i[2]
		name = nd.name
		par2 = nd.param2
		tmp = minetest_registered_nodes[name]
		if tmp and not tmp.walkable and name ~= "mcl_core:water_flowing" and name ~= "mcl_core:water" then
			return(vector_subtract(i[1],pos))
		end
	end

	return nil
end
