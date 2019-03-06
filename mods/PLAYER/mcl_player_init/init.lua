minetest.register_on_joinplayer(function(player)
	-- Settable hand
	player:get_inventory():set_size("hand", 1)
end)
