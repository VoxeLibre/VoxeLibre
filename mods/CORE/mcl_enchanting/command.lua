minetest.register_chatcommand("enchant", {
	description = "Enchant an item.",
	params = "<player> <enchantment> [<level>]",
	privs = {give = true},
	func = function(_, param)
		local sparam = param:split(" ")
		local target_name = sparam[1]
		local enchantment = sparam[2]
		local level_str = sparam[3]
		local level = tonumber(level_str or "1")
		if not target_name or not enchantment then
			return false, "Usage: /enchant <player> <enchantment> [<level>]"
		end
		local target = minetest.get_player_by_name(target_name)
		if not target then
			return false, "Player '" .. target_name .. "' cannot be found"
		end
		local itemstack = target:get_wielded_item()
		local can_enchant, errorstring, extra_info = mcl_enchanting.can_enchant(itemstack, enchantment, level)
		if not can_enchant then
			if errorstring == "enchantment invalid" then
				return false, "There is no such enchantment '" .. enchantment .. "'"
			elseif errorstring == "item missing" then
				return false, "The target doesn't hold an item"
			elseif errorstring == "item not supported" then
				return false, "The selected enchantment can't be added to the target item"
			elseif errorstring == "level invalid" then
				return false, "'" .. level_str .. "' is not a valid number"
			elseif errorstring == "level too high" then
				return false, "The number you have entered (" .. level_str .. ") is too big, it must be at most " .. extra_info
			elseif errorstring == "level too small" then
				return false, "The number you have entered (" .. level_str .. ") is too small, it must be at least " .. extra_info
			elseif errorstring == "incompatible" then
				return false, mcl_enchanting.get_enchantment_description(enchantment, level) .. " can't be combined with " .. extra_info
			end
		else
			target:set_wielded_item(mcl_enchanting.enchant(itemstack, enchantment, level))
			return true, "Enchanting succeded"
		end
	end
})
