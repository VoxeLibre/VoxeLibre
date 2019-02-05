function mobs:spawn_abm_check(pos, node, name)
	-- Don't spawn monsters on mycelium
	if (node.name == "mcl_core:mycelium" or node.name == "mcl_core:mycelium_snow") and minetest.registered_entities[name].type == "monster" then
		return true
	-- Spawn on opaque or liquid nodes
	elseif minetest.get_item_group(node.name, "opaque") ~= 0 or minetest.registered_nodes[node.name].liquidtype ~= "none" then
		return false
	end
	-- Reject everything else
	return true
end
