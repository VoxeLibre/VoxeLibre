local S = minetest.get_translator(minetest.get_current_modname())

local function register_chatcommand_alias(alias, cmd)
	local def = minetest.chatcommands[cmd]
	minetest.register_chatcommand(alias, def)
end

local function rename_chatcommand(newname, cmd)
	local def = minetest.chatcommands[cmd]
	minetest.register_chatcommand(newname, def)
	minetest.unregister_chatcommand(cmd)
end

if minetest.settings:get_bool("mcl_builtin_commands_overide", true) then
	register_chatcommand_alias("?", "help")
	register_chatcommand_alias("pardon", "unban")
	rename_chatcommand("stop", "shutdown")
	register_chatcommand_alias("tell", "msg")
	register_chatcommand_alias("w", "msg")
	register_chatcommand_alias("tp", "teleport")
	register_chatcommand_alias("clearinventory", "clearinv")

	minetest.register_chatcommand("banlist", {
		description = S("List bans"),
		privs = minetest.chatcommands["ban"].privs,
		func = function(name)
			return true, S("Ban list: @1", minetest.get_ban_list())
		end,
	})

	minetest.register_chatcommand("clear", {
		description = S("List clear commands"),
		func = function(name)
			return true, S("To clear inventory use /clearinv or /clearinventory").."\n"..
						 S("To clear mobs use /clearmobs").."\n"..
						 S("To clear the weather use /weather clear").."\n"..
						 S("Clearing the chat is not possible, you can hide the chat using \"Toggle chat log\" key (default F2) on PC or the chat icon on the mobile version")
		end,
	})
end
