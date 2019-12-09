minetest.register_on_joinplayer(function(player)
	player:set_formspec_prepend(mcl_vars.gui_nonbg)
end)
