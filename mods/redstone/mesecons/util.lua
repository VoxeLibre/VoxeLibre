function mesecon:swap_node(pos, name)
	local node = minetest.get_node(pos)
	local data = minetest.get_meta(pos):to_table()
	node.name = name
	minetest.add_node(pos, node)
	minetest.get_meta(pos):from_table(data)
end

function mesecon:move_node(pos, newpos)
	local node = minetest.get_node(pos)
	local meta = minetest.get_meta(pos):to_table()
	minetest.remove_node(pos)
	minetest.add_node(newpos, node)
	minetest.get_meta(pos):from_table(meta)
end


function mesecon:addPosRule(p, r)
	return {x = p.x + r.x, y = p.y + r.y, z = p.z + r.z}
end

function mesecon:cmpPos(p1, p2)
	return (p1.x == p2.x and p1.y == p2.y and p1.z == p2.z)
end
