local S = minetest.get_translator("mcl_commands")

local mod_death_messages = minetest.get_modpath("mcl_death_messages")

local modpath = minetest.get_modpath(minetest.get_current_modname())

dofile(modpath.."/kill.lua")
dofile(modpath.."/setblock.lua")
dofile(modpath.."/seed.lua")
dofile(modpath.."/summon.lua")
dofile(modpath.."/say.lua")

dofile(modpath.."/alias.lua")


minetest.register_chatcommand("list", {
	description = S("Show who is logged on"),
	params = "",
	privs = {},
	func = function(name)
		local players = ""
		for _, player in ipairs(minetest.get_connected_players()) do
			players = players..player:get_player_name().."\n"
		end
		minetest.chat_send_player(name, players)
	end
})




