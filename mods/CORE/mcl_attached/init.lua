local vector = vector

local facedir_to_dir = minetest.facedir_to_dir
local get_item_group = minetest.get_item_group
local remove_node = minetest.remove_node
local get_node = minetest.get_node

local original_function = minetest.check_single_for_falling

function minetest.check_single_for_falling(pos)
	local ret_o = original_function(pos)
	local ret = false
	local node = minetest.get_node(pos)
	if get_item_group(node.name, "attached_node_facedir") ~= 0 then
		local dir = facedir_to_dir(node.param2)
		if dir then
			if get_item_group(get_node(vector.add(pos, dir)).name, "solid") == 0 then
				remove_node(pos)
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

