minetest.register_on_dieplayer(function(player)
	local keep = minetest.settings:get_bool("mcl_keepInventory", false)
	if keep == false then
		-- Drop inventory, crafting grid and armor
		local inv = player:get_inventory()
		local pos = player:get_pos()
		local name, player_armor_inv, armor_armor_inv, pos = armor:get_valid_player(player, "[on_dieplayer]")
		-- No item drop if in deep void
		local void, void_deadly = mcl_worlds.is_in_void(pos)
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
					if not void_deadly and drop and not mcl_enchanting.has_enchantment(stack, "curse_of_vanishing") then
						local def = minetest.registered_items[stack:get_name()]
						if def and def.on_drop then
							stack = def.on_drop(stack, player, pos)
						end
						minetest.add_item(pos, stack)
					end
					pos.x = pos.x - x
					pos.z = pos.z - z
				end
				inv:set_list(listname, {})
			end
		end
		armor:set_player_armor(player)
		armor:update_inventory(player)
	end
end)
