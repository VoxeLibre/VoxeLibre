-- Declare module-level local variable to track warning state so warning only displays once in log in case of seasons not found as optional dependency.
local seasons_warning_logged = false

-- oxidation ABM. Primary mechanism is responsible for swapping nodes occasionally. Optional checks and node definitions are layered in to fine-tune when, where, and how. 
minetest.register_abm({
	label = "Oxidize Nodes",
	nodenames = { "group:oxidizable" },
	interval = 0.1,
	chance = 100,
	action = function(pos, node)
		local def = minetest.registered_nodes[node.name]
		if def and def._mcl_oxidized_variant then
			local allowed = true
            local seasons_mod_available = false

			-- wrapping the mod dependency checks in a pcall (protected call) provides better error handling in the case that seasons isn't found. It suppresses unneeded 'undeclared global variable' warnings in the logs. _G calls for the value of global variable and rawget ensures it bypasses any fallback tables that may be part of seasons. 
            pcall(function()
                seasons_mod_available = rawget(_G, "seasons") and
                    type(seasons) == "table" and
                    type(seasons.get_season) == "function"
            end)

			-- Seasons mod has been found, the expected table really is a table and the expected function really is a function, begin optional seasons.get_season() table check to create a blacklist filter for if a node is allowed to be oxidized based on its node definition.
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

				-- Else, if Seasons mod not detected or invalid. This means we then throw the error log and continue oxidation as usual.
				if not seasons_warning_logged then
					minetest.log("warning", "[Oxidation] Seasons mod not detected. Oxidation proceeding without seasonal checks.")
					seasons_warning_logged = true
				end
			end
			-- Finally, oxidation checks all pass, its allowed to be swapped.
			if allowed then
				minetest.set_node(pos, {name = def._mcl_oxidized_variant, param2=node.param2})
			end
		end
	end,
})