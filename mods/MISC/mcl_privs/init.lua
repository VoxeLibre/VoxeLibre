local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_privilege("maphack", {
	description = S("Can place and use advanced blocks like mob spawners, command blocks and barriers."),
})

minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()

	local fly = nil
	if minetest.is_creative_enabled(name) then
		fly = true
	end
	minetest.set_player_privs(name, {
		fly = fly,
	})
end)
