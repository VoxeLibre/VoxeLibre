local S = minetest.get_translator("vl_pickblock")

minetest.override_item("", {
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.is_creative_enabled(placer:get_player_name()) then
			mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)

			local node = minetest.get_node_or_nil(pointed_thing.under)
			if not node then return end

			local def = minetest.registered_nodes[node.name]
			if not def then return end

			local rnode = {}
			-- if this is an 'illegal' node and there's an explicit `_vl_pickblock` field, then return it
			-- if the node isn't 'illegal', return it as-is
			-- (and if it's 'illegal' and no `_vl_pickblock` is defined, well, bad luck)
			if def.groups.not_in_creative_inventory and def.groups.not_in_creative_inventory ~= 0 then
				if def._vl_pickblock then
					rnode.name = def._vl_pickblock
				end
			else
				rnode = node
			end

			local inv = placer:get_inventory()
			for i=1,placer:hud_get_hotbar_itemcount() do
				local stack = inv:get_stack("main", i)
				if stack:get_name() == rnode.name then
					local msg = S("@1 is on slot @2", stack:get_short_description(), i)
					mcl_title.set(placer, "actionbar", {text = msg, stay = 30})
					return
				end
			end

			return rnode
		end
	end
})
