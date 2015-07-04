INFO_BLANK = "To find out more about certain items type the command '/info' with the params 'update', 'version', 'creative', 'suprise'"
INFO_VERSION = "0.24"
INFO_UPDATE = "I think finish the struct system"
INFO_CREATIVE = "Type the command '/gamemode ' and use the params '0' or 's' for survival and '1' or 'c' for creative"


minetest.register_chatcommand("info", {
	params = "(blank) | update | version | creative",
	description = "To get info on stuff.",
	func = function(name, param)
		if param == "" then
			minetest.chat_send_player(name, INFO_BLANK)
		end
		if param == "update" then
			minetest.chat_send_player(name, INFO_UPDATE)
		end
		if param == "version" then
			minetest.chat_send_player(name, INFO_VERSION)
		end
		if param == "creative" then
			minetest.chat_send_player(name, INFO_CREATIVE)
		end
	end
})
