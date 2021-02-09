local function is_forbidden_node(pos, node)
	node = node or minetest.get_node(pos)
	return minetest.get_item_group(node.name, "stair") > 0 or minetest.get_item_group(node.name, "slab") > 0 or minetest.get_item_group(node.name, "carpet") > 0
end

function mobs:spawn_abm_check(pos, node, name)
	-- Don't spawn monsters on mycelium
	if (node.name == "mcl_core:mycelium" or node.name == "mcl_core:mycelium_snow") and minetest.registered_entities[name].type == "monster" then
		return true
    --Don't Spawn mobs on stairs, slabs, or carpets
	elseif is_forbidden_node(pos, node) or is_forbidden_node(vector.add(pos, vector.new(0, 1, 0))) then
		return true
	-- Spawn on opaque or liquid nodes
	elseif minetest.get_item_group(node.name, "opaque") ~= 0 or minetest.registered_nodes[node.name].liquidtype ~= "none" or node.name == "mcl_core:grass_path" then
		return false
	end

	-- Reject everything else
	return true
end
