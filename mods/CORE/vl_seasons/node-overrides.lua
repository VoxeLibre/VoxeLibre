-- Helper function to safely get existing groups of the node (if any) then add/update with multiple new custom group values
local function add_groups(node_name, group_table)
    local original_node = minetest.registered_nodes[node_name]
    if not original_node then
        minetest.log("error", "`vl_seasons.add_groups` Failed to find original node '" .. node_name .. "'")
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

-- Override Registry
core.override_item("mcl_core:dirt_with_grass", {
    groups = add_groups("mcl_core:dirt_with_grass", {oxidizable = 1,}),
    _mcl_oxidized_seasonal_variant = "mcl_core:snowblock",
    _mcl_oxidized_season_disallowed = {"spring", "summer", "fall"},
})

core.override_item("mcl_core:snowblock", {
    groups = add_groups("mcl_core:snowblock", {oxidizable = 1,}),
    _mcl_oxidized_seasonal_variant = "mcl_core:dirt_with_grass",
    _mcl_oxidized_season_disallowed = {"winter"},
})

core.override_item("mcl_core:ice", {
    groups = add_groups("mcl_core:ice", {oxidizable = 1,}),
    _mcl_oxidized_seasonal_variant = "mcl_core:water_source",
    _mcl_oxidized_season_disallowed = {"winter"},
})

core.override_item("mcl_core:water_source", {
   groups = add_groups("mcl_core:water_source", {oxidizable = 1,}),
   _mcl_oxidized_seasonal_variant = "mcl_core:ice",
   _mcl_oxidized_season_disallowed = {"spring", "summer","fall"},
})

-- Flower Overrides
core.override_item("mcl_flowers:poppy", {
   groups = add_groups("mcl_flowers:poppy", {oxidizable = 1,}),
   _mcl_oxidized_seasonal_variant = "vl_seasons:unbloomed_poppy",
   _mcl_oxidized_season_disallowed = {"spring", "summer"},
})
core.override_item("vl_seasons:unbloomed_poppy", {
   _mcl_oxidized_seasonal_variant = "mcl_flowers:poppy",
   _mcl_oxidized_season_disallowed = {"fall", "winter"},
})