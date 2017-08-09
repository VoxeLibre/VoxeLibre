minetest.register_on_dieplayer(function(player)
	local keep = minetest.settings:get_bool("mcl_keepInventory") or false
	if keep == false then
		-- Drop inventory, crafting grid and armor
		local inv = player:get_inventory()
		local pos = player:getpos()
		local name, player_armor_inv, armor_armor_inv, pos = armor:get_valid_player(player, "[on_dieplayer]")
		local lists = {
			{ inv = inv, listname = "main", drop = true },
			{ inv = inv, listname = "craft", drop = true },
			{ inv = player_armor_inv, listname = "armor", drop = true },
			{ inv = armor_armor_inv, listname = "armor", drop = false },
		}
		for l=1,#lists do
			local inv = lists[l].inv
			local listname = lists[l].listname
			local drop = lists[l].drop
			if inv ~= nil then
				for i, stack in ipairs(inv:get_list(listname)) do
					local x = math.random(0, 9)/3
					local z = math.random(0, 9)/3
					pos.x = pos.x + x
					pos.z = pos.z + z
					if drop then
						minetest.add_item(pos, stack)
					end
					stack:clear()
					inv:set_stack(listname, i, stack)
					pos.x = pos.x - x
					pos.z = pos.z - z
				end
			end
		end
		armor:set_player_armor(player)
		armor:update_inventory(player)
	end
end)
