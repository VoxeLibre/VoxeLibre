local S = minetest.get_translator("mcl_commands")

minetest.register_chatcommand("seed", {
	description = S("Displays the world seed"),
	params = "",
	privs = {},
	func = function(name)
		minetest.chat_send_player(name, "Seed: "..minetest.get_mapgen_setting("seed"))
	end
})