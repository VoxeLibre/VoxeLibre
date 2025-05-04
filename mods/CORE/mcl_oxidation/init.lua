-- Declare module-level local variable to track warning state so warning only displays once in log in case of seasons not found as optional dependency.
local seasons_warning_logged = false

minetest.register_abm({
    label = "Oxidize Nodes",
    nodenames = {"group:oxidizable"},
    interval = 0.1,
    chance = 100,
    action = function(pos, node)
        local def = minetest.registered_nodes[node.name]
        if not def then
            return -- Skip if no node definition
        end

        local allowed = true
        local variant = nil
        local seasons_mod_available = false

        -- Check if seasons mod is available
        pcall(function()
            seasons_mod_available = rawget(_G, "seasons") and
                type(seasons) == "table" and
                type(seasons.get_season) == "function"
        end)

        -- Try to find a valid variant based on seasons availability
        if seasons_mod_available then
            if def._mcl_oxidized_seasonal_variant and type(def._mcl_oxidized_seasonal_variant) == "string" then
                variant = def._mcl_oxidized_seasonal_variant
            else
                if def._mcl_oxidized_variant and type(def._mcl_oxidized_variant) == "string" then
                    variant = def._mcl_oxidized_variant
                else
                    return -- No variants found
                end
            end
        else
            if def._mcl_oxidized_variant and type(def._mcl_oxidized_variant) == "string" then
                variant = def._mcl_oxidized_variant
            else
                return -- No variants found
            end
        end

        -- Seasonal disallowed check
        if seasons_mod_available then
            local current_season = seasons.get_season()
            local disallowed_seasons = (type(def._mcl_oxidized_season_disallowed) == "table") and def._mcl_oxidized_season_disallowed or {}
            for _, season in ipairs(disallowed_seasons) do
                if season == current_season then
                    allowed = false
                    break
                end
            end
        else
            if not seasons_warning_logged then
                minetest.log("warning", "[Oxidation] Seasons mod not detected. Oxidation proceeding without seasonal checks.")
                seasons_warning_logged = true
            end
        end

        -- Apply oxidation if allowed
        if allowed then
            minetest.set_node(pos, {name = variant, param2 = node.param2})
        end
    end,
})