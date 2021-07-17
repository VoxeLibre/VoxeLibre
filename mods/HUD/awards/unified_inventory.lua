if minetest.get_modpath("unified_inventory") then
	local S = minetest.get_translator(minetest.get_current_modname())
	unified_inventory.register_button("awards", {
		type = "image",
		image = "awards_ui_icon.png",
		tooltip = S("Awards"),
		action = function(player)
			local name = player:get_player_name()
			awards.show_to(name, name, nil, false)
		end,
	})
end
