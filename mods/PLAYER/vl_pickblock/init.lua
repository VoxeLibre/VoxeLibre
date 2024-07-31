minetest.override_item("", {
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.is_creative_enabled(placer:get_player_name()) then
			local node = minetest.get_node_or_nil(pointed_thing.under)
			if not node then return end

			local def = minetest.registered_nodes[node.name]
			if not def then return end

			local rnode
			-- if this is an 'illegal' node and there's an explicit `_vl_pickblock` field, then return it
			-- if the node isn't 'illegal', return it as-is
			-- (and if it's 'illegal' and no `_vl_pickblock` is defined, well, bad luck)
			if def.groups.not_in_creative_inventory and def.groups.not_in_creative_inventory ~= 0 then
				if def._vl_pickblock then
					rnode = def._vl_pickblock
				end
			else
				rnode = node.name
			end

			return {name = rnode}
		end
	end
})
