if minetest.get_modpath("unified_inventory") ~= nil then
	local S
	if minetest.get_modpath("intllib") then
		S = intllib.Getter()
	else
		S = function ( s ) return s end
	end

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
