local mcl_skins_enabled = minetest.global_exists("mcl_skins")

---This is a fake node that should never be placed in the world
---@type node_definition
local node_def = {
	use_texture_alpha = "opaque",
	paramtype = "light",
	drawtype = "mesh",
	node_placement_prediction = "",
	on_construct = function(pos)
		local name = minetest.get_node(pos).name
		local message = "[mcl_meshhand] Trying to construct " .. name .. " at " .. minetest.pos_to_string(pos)
		minetest.log("error", message)
		minetest.remove_node(pos)
	end,
	drop = "",
	on_drop = function(_, _, _) return ItemStack() end,
	groups = { dig_immediate = 3, not_in_creative_inventory = 1 },
	range = minetest.registered_items[""].range
}

if mcl_skins_enabled then
	-- Generate a node for every skin
	local list = mcl_skins.get_skin_list()
	for _, skin in pairs(list) do
		if skin.slim_arms then
			local female = table.copy(node_def)
			female._mcl_hand_id = skin.id
			female.mesh = "mcl_meshhand_female.b3d"
			female.tiles = { skin.texture }
			minetest.register_node("mcl_meshhand:" .. skin.id, female)
		else
			local male = table.copy(node_def)
			male._mcl_hand_id = skin.id
			male.mesh = "mcl_meshhand.b3d"
			male.tiles = { skin.texture }
			minetest.register_node("mcl_meshhand:" .. skin.id, male)
		end
	end
else
	node_def._mcl_hand_id = "hand"
	node_def.mesh = "mcl_meshhand.b3d"
	node_def.tiles = { "character.png" }
	minetest.register_node("mcl_meshhand:hand", node_def)
end

if mcl_skins_enabled then
	-- Change the player's hand to their skin
	mcl_player.register_on_visual_change(function(player)
		local node_id = mcl_skins.get_node_id_by_player(player)
		player:get_inventory():set_stack("hand", 1, "mcl_meshhand:" .. node_id)
	end)
else
	minetest.register_on_joinplayer(function(player)
		player:get_inventory():set_stack("hand", 1, ItemStack("mcl_meshhand:hand"))
	end)
end
