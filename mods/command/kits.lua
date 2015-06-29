minetest.register_chatcommand("kit", {
    params = "",
    description = "Add a Kit to player",
    privs = {},
    func = function(name, param)
		if param == "" then
			minetest.chat_send_player(name, "No kit selected use ... Aviable : noob , pvp")
		end
		local receiverref = core.get_player_by_name(name)
		if param == "noob" then
			receiverref:get_inventory():add_item('main', 'default:pick_steel')
			receiverref:get_inventory():add_item('main', 'default:shovel_steel')
			receiverref:get_inventory():add_item('main', 'default:torch 16')
			receiverref:get_inventory():add_item('main', 'default:axe_steel')
			receiverref:get_inventory():add_item('main', 'default:cobble 64')
		end
		if param == "pvp" then
			receiverref:get_inventory():add_item('main', 'default:sword_diamond')
			receiverref:get_inventory():add_item('main', 'default:apple_gold 64')
			receiverref:get_inventory():add_item('main', '3d_armor:helmet_diamond')
			receiverref:get_inventory():add_item('main', '3d_armor:chestplate_diamond')
			receiverref:get_inventory():add_item('main', '3d_armor:leggings_diamond')
			receiverref:get_inventory():add_item('main', '3d_armor:boots_diamond')
		end
    end
})