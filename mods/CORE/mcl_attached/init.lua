local original_function = minetest.check_single_for_falling

minetest.check_single_for_falling = function(pos)
	local ret_o = original_function(pos)

	local ret = false
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "attached_node_facedir") ~= 0 then
		local dir = minetest.facedir_to_dir(node.param2)
		if dir then
			local cpos = vector.add(pos, dir)
			local cnode = minetest.get_node(cpos)
			if minetest.get_item_group(cnode.name, "solid") == 0 then
				minetest.remove_node(pos)
				local drops = minetest.get_node_drops(node.name, "")
				for dr=1, #drops do
					minetest.add_item(pos, drops[dr])
				end
				ret = true
			end
		end
	end

	return ret_o or ret
end

