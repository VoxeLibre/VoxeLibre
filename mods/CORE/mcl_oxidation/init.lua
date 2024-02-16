minetest.register_abm({
	label = "Oxidatize Nodes",
	nodenames = { "group:oxidizable" },
	interval = 500,
	chance = 3,
	action = function(pos, node)
		local def = minetest.registered_nodes[node.name]
		if def and def._mcl_oxidized_variant then
			if def.groups.door == 1 then
				if node.name:find("_b_") then
					local top_pos = { x = pos.x, y = pos.y + 1, z = pos.z }
					minetest.set_node(top_pos, { name = def._mcl_oxidized_variant:gsub("_b_", "_t_"), param2 = node.param2 })
				elseif node.name:find("_t_") then
					local bot_pos = { x = pos.x, y = pos.y - 1, z = pos.z }
					minetest.set_node(bot_pos, { name = def._mcl_oxidized_variant:gsub("_t_", "_b_"), param2 = node.param2 })
				end
			end
			minetest.set_node(pos, { name = def._mcl_oxidized_variant, param2 = node.param2 })
		end
	end,
})
