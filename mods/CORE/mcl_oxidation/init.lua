minetest.register_abm({
	label = "Oxidatize Nodes",
	nodenames = { "group:oxidizable" },
	interval = 500,
	chance = 3,
	action = function(pos, node)
		local def = minetest.registered_nodes[node.name]
		if def and def._mcl_oxidized_variant then
			minetest.set_node(pos, { name = def._mcl_oxidized_variant, param2 = node.param2 })
		end
	end,
})
