function mobs:spawn_abm_check(pos, node, name)
	if (node.name == "air") then
		return true
	elseif (node.name == "mcl_core:mycelium" or node.name == "mcl_core:mycelium_snow") and minetest.registered_entities[name].type == "monster" then
		return false
	elseif minetest.get_item_group(node.name, "opaque") ~= 0 then
		return false
	end
	return true
end
