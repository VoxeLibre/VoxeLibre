local minetest, math = minetest, math
mcl_offhand = {}

local hud_ids = {}

function mcl_offhand.get_offhand(player)
	return player:get_inventory():get_stack("offhand", 1)
end

core.register_globalstep(function(dtime)
	for _, player in pairs(core.get_connected_players()) do
		local p_name = player:get_player_name()
		local itemstack = mcl_offhand.get_offhand(player)
		local offhand_item = itemstack:get_name()
		local offhand_hud = hud_ids[p_name]
		local item = core.registered_items[offhand_item]
		if offhand_item ~= "" and item then
			if not offhand_hud then
				hud_ids[p_name] = player:hud_add({
					[mcl_vars.hud_type_field] = "inventory",
					text = "offhand",
					text2 = "mcl_offhand_slot.png",
					number = 1,
					item = 1,
					position = {x = 0.5, y = 1},
					alignment = {x = 0, y = -1},
					offset = {x = -320, y = -4},
					z_index = 0
				})
			end
		elseif offhand_hud then
			player:hud_remove(offhand_hud)
			hud_ids[p_name] = nil
		end
	end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	local from_offhand = inventory_info.from_list == "offhand"
	local to_offhand = inventory_info.to_list == "offhand"
	if from_offhand or to_offhand then
		mcl_inventory.update_inventory_formspec(player)
	end
end)
