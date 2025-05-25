-- Helper function to safely get existing groups of the node (if any) and merge with new ones (adding `oxidation = 1` in this case)
local function add_oxidizable_group(node_name)
    local original_node = minetest.registered_nodes[node_name]
    if not original_node then
        minetest.log("error", "[MODNAME] Failed to find original node '" .. node_name .. "'")
        return {}
    end

    -- Copy existing groups into a new table
    local merged_groups = {}
    for k, v in pairs(original_node.groups or {}) do
        merged_groups[k] = v
    end

    -- Add the new group
    merged_groups.oxidizable = 1

    return merged_groups
end

-- Override Registry
core.override_item("mcl_core:dirt_with_grass", {
    groups = add_oxidizable_group("mcl_core:dirt_with_grass"),
    _mcl_oxidized_seasonal_variant = "mcl_core:snowblock",
    _mcl_oxidized_season_disallowed = {"spring", "summer", "fall"},
})

core.override_item("mcl_core:snowblock", {
    groups = add_oxidizable_group("mcl_core:snowblock"),
    _mcl_oxidized_seasonal_variant = "mcl_core:dirt_with_grass",
    _mcl_oxidized_season_disallowed = {"winter"},
})

core.override_item("mcl_core:ice", {
    groups = add_oxidizable_group("mcl_core:ice"),
    _mcl_oxidized_seasonal_variant = "mcl_core:water_source",
    _mcl_oxidized_season_disallowed = {"winter"},
})

core.override_item("mcl_core:water_source", {
    groups = add_oxidizable_group("mcl_core:water_source"),
   _mcl_oxidized_seasonal_variant = "mcl_core:ice",
   _mcl_oxidized_season_disallowed = {"spring", "summer","fall"},
})