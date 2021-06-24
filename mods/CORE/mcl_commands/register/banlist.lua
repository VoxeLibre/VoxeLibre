local S = minetest.get_translator(minetest.get_current_modname())

--[[minetest.register_chatcommand("banlist", {
	description = S("List bans"),
	privs = minetest.registered_chatcommands["ban"].privs,
	func = function(name)
		return true, S("Ban list: @1", minetest.get_ban_list())
	end,
})]]

mcl_commands.register_basic_command("banlist", {
	description = S("List bans"),
	func = function(name)
		return true, S("Ban list: @1", minetest.get_ban_list())
	end,
})