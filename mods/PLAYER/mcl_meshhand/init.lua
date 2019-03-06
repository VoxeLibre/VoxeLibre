local has_mcl_skins = minetest.get_modpath("mcl_skins") ~= nil

-- mcl_skins is enabled
if has_mcl_skins == true then
	--generate a node for every skin
	for _,texture in pairs(mcl_skins.list) do
		minetest.register_node("mcl_meshhand:"..texture, {
			description = "",
			tiles = {texture..".png"},
			inventory_image = "blank.png",
			visual_scale = 1,
			wield_scale = {x=1,y=1,z=1},
			paramtype = "light",
			drawtype = "mesh",
			mesh = "mcl_meshhand.b3d",
			node_placement_prediction = "",
		})
	end
	--change the player's hand to their skin
	mcl_skins.register_on_set_skin(function(player, skin)
		local name = player:get_player_name()
		player:get_inventory():set_stack("hand", 1, "mcl_meshhand:"..skin)
	end)
	
--do default skin if no skin mod installed
else
	minetest.register_node("mcl_meshhand:hand", {
		description = "",
		tiles = {"character.png"},
		inventory_image = "blank.png",
		visual_scale = 1,
		wield_scale = {x=1,y=1,z=1},
		paramtype = "light",
		drawtype = "mesh",
		mesh = "mcl_meshhand.b3d",
		node_placement_prediction = "",
	})

	minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_stack("hand", 1, "mcl_meshhand:hand")
	end)
end
