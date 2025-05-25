minetest.register_abm({
    label = "Oxidize Nodes",
    nodenames = {"group:oxidizable"},
    interval = 0.1,
    chance = 100,
    action = function(pos, node)
        local def = minetest.registered_nodes[node.name]
        if not def then return end

        local variant_func = def._mcl_oxidized_variant
        if type(variant_func) == "function" then
            local variant = variant_func(pos, node, def)
            if variant then
                minetest.set_node(pos, {name = variant, param2 = node.param2})
            end
        else
            if type(def._mcl_oxidized_variant) == "string" then
                minetest.set_node(pos, {name = def._mcl_oxidized_variant, param2 = node.param2})
            end
        end
    end,
})