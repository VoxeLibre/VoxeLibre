local S = minetest.get_translator(minetest.get_current_modname())

--[[
minetest.register_chatcommand("list", {
	description = S("Show who is logged on"),
	params = "",
	privs = {},
	func = function(name)
		--local players = ""
		--for _, player in ipairs(minetest.get_connected_players()) do
		--	players = players..player:get_player_name().."\n"
		--end
		--minetest.chat_send_player(name, players)
		local player_list = minetest.get_connected_players()
		local header = S("There are @1/@2 players online:", #player_list, minetest.settings:get("max_users") or "unknown").."\n"
		local players = {}
		for _, player in ipairs(player_list) do
			table.insert(players, player:get_player_name())
		end
		return true, header..table.concat(players, ", ")
	end
})
]]

local max_users = minetest.settings:get("max_users") or "unknown" --TODO: check if the setting is dynamic in mc
local playersstring = ""

local function generate_player_list()
	local player_list = minetest.get_connected_players()
	local header = S("There are @1/@2 players online:", #player_list, max_users).."\n"
	local players = {}
	for _, player in ipairs(player_list) do
		table.insert(players, player:get_player_name())
	end
	playersstring = header..table.concat(players, ", ")
end

minetest.register_on_joinplayer(function(player)
	generate_player_list()
end)

minetest.register_on_leaveplayer(function(player)
	generate_player_list()
end)

mcl_commands.register_basic_command("list", {
	description = S("Show who is logged on"),
	params = nil,
	func = function(name)
		return true, playersstring
	end,
})