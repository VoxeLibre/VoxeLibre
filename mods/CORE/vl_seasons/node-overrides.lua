-- Helper function to safely get existing groups of the node (if any) then add/update with multiple new custom group values
local function add_groups(node_name, group_table)
    local original_node = minetest.registered_nodes[node_name]
    if not original_node then
        minetest.log("error", "`seasons.add_groups` Failed to find original node '" .. node_name .. "'")
        return {}
    end

    -- Copy existing groups into a new table
    local merged_groups = {}
    for k, v in pairs(original_node.groups or {}) do
        merged_groups[k] = v
    end

    -- Update/add specified groups from the input table
    for group_key, group_value in pairs(group_table) do
        merged_groups[group_key] = group_value
    end

    return merged_groups
end

-- Generalized seasonal variant helper
local function get_seasonal_variant(season_variants, current_season, pos, node, def)
 local current_season = seasons.get_season()
    local variant = season_variants[current_season]
    
    if type(variant) == "function" then
        return variant(pos, node, def)
    else
        return variant or def.name
    end
end

-- Registry
core.override_item("mcl_core:dirt_with_grass", {
    groups = add_groups("mcl_core:dirt_with_grass", {oxidizable = 1,}),
    _mcl_oxidized_variant = function(pos, node, def)
        local variants = {
            winter = function()             -- example of how to make more complex function by adding  randomness
                return math.random() < 0.5 and "mcl_core:snowblock" or "mcl_core:ice" -- half of grass will turn to snow, half ice.come winter.
            end,
        }
        return get_seasonal_variant(variants, current_season, pos, node, def)
    end,
})

core.override_item("mcl_core:snowblock", {
    groups = add_groups("mcl_core:snowblock", {oxidizable = 1,}),
    _mcl_oxidized_variant = function(pos, node, def)
        local variants = {spring = "mcl_core:dirt_with_grass",}
        return get_seasonal_variant(variants, current_season, pos, node, def)
    end,
})

core.override_item("mcl_core:ice", {
    groups = add_groups("mcl_core:ice", {oxidizable = 1,}),
    _mcl_oxidized_variant = function(pos, node, def)
        local variants = { spring = "mcl_core:water_source", summer = "mcl_core:water_source",}
        return get_seasonal_variant(variants, current_season, pos, node, def)
    end,
})

core.override_item("mcl_core:water_source", {
    groups = add_groups("mcl_core:water_source", {oxidizable = 1,}),
    _mcl_oxidized_variant = function(pos, node, def)
        local variants = {winter = "mcl_core:ice",}
        return get_seasonal_variant(variants, current_season, pos, node, def)
    end,
})

-- Flower Overrides
core.override_item("mcl_flowers:poppy", {
    groups = add_groups("mcl_flowers:poppy", {oxidizable = 1,}),
    _mcl_oxidized_variant = function(pos, node, def)
        local variants = {fall = "vl_seasons:unbloomed_poppy", winter = "vl_seasons:unbloomed_poppy",}
        return get_seasonal_variant(variants, current_season, pos, node, def)
    end,
})

core.override_item("vl_seasons:unbloomed_poppy", {
    _mcl_oxidized_variant = function(pos, node, def)
        local variants = {spring = "mcl_flowers:poppy", summer = "mcl_flowers:poppy",}
        return get_seasonal_variant(variants, current_season, pos, node, def)
    end,
})

--Flower Pot Overrides
core.override_item("mcl_flowerpots:flower_pot_poppy", {
    groups = add_groups("mcl_flowerpots:flower_pot_poppy", {oxidizable = 1,}),
    _mcl_oxidized_variant = function(pos, node, def)
        local variants = {fall = "mcl_flowerpots:flower_pot_unbloomed_poppy", winter = "mcl_flowerpots:flower_pot_unbloomed_poppy",}
        return get_seasonal_variant(variants, current_season, pos, node, def)
    end,
})
core.override_item("mcl_flowerpots:flower_pot_unbloomed_poppy", {
    groups = add_groups("mcl_flowerpots:flower_pot_unbloomed_poppy", {oxidizable = 1,}),
    _mcl_oxidized_variant = function(pos, node, def)
        local variants = {spring = "mcl_flowerpots:flower_pot_poppy", summer = "mcl_flowerpots:flower_pot_poppy",}
        return get_seasonal_variant(variants, current_season, pos, node, def)
    end,
})