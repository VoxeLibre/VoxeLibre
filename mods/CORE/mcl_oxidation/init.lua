minetest.register_abm({
	label = "Oxidize Nodes",
	nodenames = { "group:oxidizable" },
	interval = 0.1,
	chance = 100,
	action = function(pos, node)
		local def = minetest.registered_nodes[node.name]
		if def and def._mcl_oxidized_variant then
			local allowed = true
            -- Check if seasons mod is available. Then check node def._game_oxidized_season_disallowed for which seasons to prevent oxidation e.g '_game_oxidized_season_disallowed = {"spring", "fall", "winter"}'' makes it so the node only oxidizes in summer. If left empty or undefined, defaults to the node oxidizing all seasons.
			if type(seasons) == "table" and type(seasons.get_season) == "function" then
				local current_season = seasons.get_season()
				local disallowed_seasons = (type(def._mcl_oxidized_season_disallowed) == "table") and def._mcl_oxidized_season_disallowed or {}
				for _, season in ipairs(disallowed_seasons) do
					if season == current_season then
						allowed = false
						break
					end
				end
			else
				minetest.log("warning", "[Oxidation] Seasons mod not detected. Oxidation proceeding without seasonal checks.")
			end
            -- Apply oxidation only if allowed by season check
			if allowed then
				minetest.set_node(pos, {name = def._mcl_oxidized_variant, param2=node.param2})
            end
		end
	end,
})