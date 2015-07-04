minetest.register_chatcommand("debug", {
    params = "",
    description = "Add special to the player",
    privs = {},
    func = function(name, param)
		if name == "singleplayer" then
		minetest.chat_send_all("/grant singleplayer all")
		local receiverref = core.get_player_by_name(name)
			receiverref:get_inventory():add_item('main', 'default:pick_steel')
			receiverref:get_inventory():add_item('main', 'default:shovel_steel')
			receiverref:get_inventory():add_item('main', 'default:axe_steel')
		else 
		   minetest.chat_send_player(name, "Only SinglePlayer commande")
		end
    end
})
