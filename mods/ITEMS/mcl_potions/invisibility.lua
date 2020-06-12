-- invisibility function
invisibility = {}

-- reset player invisibility if they go offline
minetest.register_on_leaveplayer(function(player)

	local name = player:get_player_name()
	if invisibility[name] then
		invisibility[name] = nil
	end

end)

invisible = function(player, toggle)

	if not player then return false end

	invisibility[player:get_player_name()] = toggle

	if toggle then -- hide player
		player:set_properties({visual_size = {x = 0, y = 0}})
		player:set_nametag_attributes({color = {a = 0}})
	else -- show player
		player:set_properties({visual_size = {x = 1, y = 1}})
		player:set_nametag_attributes({color = {a = 255}})
	end

end
