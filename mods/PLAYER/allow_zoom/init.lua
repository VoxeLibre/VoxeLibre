minetest.register_on_joinplayer(function(player)
	local priv = minetest.setting_getbool("allow_zoom")
	if priv == nil then
		priv = true
	end
	if priv then
		local name = player:get_player_name()
		local privs = minetest.get_player_privs(name)
		privs.zoom = true
		minetest.set_player_privs(name, privs)
	end
end)
