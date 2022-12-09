mcl_player_csm = {}

---@type table<string, boolean>
local activated = {}

---Return whatever player with specified name have official CSM enabled
---@param name string
---@return boolean? # `nil` if player not found, boolean overwise
function mcl_player_csm.is_enabled(name)
	return activated[name]
end

minetest.mod_channel_join("mcl_player_csm:activate")

minetest.register_on_modchannel_message(function(channel_name, sender, message)
	if channel_name == "mcl_player_csm:activate" and message == "activated" then
		activated[sender] = true
	end
end)

minetest.register_on_joinplayer(function(player, last_login)
	activated[player:get_player_name()] = false
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	activated[player:get_player_name()] = nil
end)

minetest.register_chatcommand("have_csm", {
	description = "Show whatever player have official CSM enabled",
	params = "[<name>]",
	privs = {debug = true},
	func = function(name, param)
		local pname = param ~= "" and param or name
		return true, "Player [" .. pname .. "]: " .. tostring(activated[pname])
	end
})
