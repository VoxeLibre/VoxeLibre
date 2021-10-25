local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_privilege("maphack", {
	description = S("Can place and use advanced blocks like mob spawners, command blocks and barriers."),
})

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local meta = player:get_meta()
	if meta:get_int("fly_changed") == 1 then return end

	local fly = nil
	if minetest.is_creative_enabled(name) then
		fly = true
	end
	local player_privs = minetest.get_player_privs(name)
	player_privs.fly = fly
	minetest.set_player_privs(name, player_privs)
end)

for _, action in pairs({"grant", "revoke"}) do
	minetest["register_on_priv_" .. action](function(name, _, priv)
		if priv == "fly" then
			local player = minetest.get_player_by_name(name)
			local meta = player:get_meta()
			meta:set_int("fly_changed", 1)
		end
	end)
end