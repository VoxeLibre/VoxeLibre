mcl_inventory = {}

dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/creative.lua")
dofile(minetest.get_modpath(minetest.get_current_modname()) .. "/survival.lua")

---@param player mt.PlayerObjectRef
---@param armor_change_only? boolean
local function set_inventory(player, armor_change_only)
	if minetest.is_creative_enabled(player:get_player_name()) then
		if armor_change_only then
			-- Stay on survival inventory plage if only the armor has been changed
			mcl_inventory.set_creative_formspec(player, 0, 0, nil, nil, "inv")
		else
			mcl_inventory.set_creative_formspec(player, 0, 1)
		end
		return
	end

	player:set_inventory_formspec(mcl_inventory.build_survival_formspec(player))
end

-- Drop items in craft grid and reset inventory on closing
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if fields.quit then
		mcl_util.move_player_list(player, "craft")
		mcl_util.move_player_list(player, "enchanting_lapis")
		mcl_util.move_player_list(player, "enchanting_item")
		if not minetest.is_creative_enabled(player:get_player_name()) and (formname == "" or formname == "main") then
			set_inventory(player)
		end
	end
end)


function mcl_inventory.update_inventory_formspec(player)
	set_inventory(player)
end

-- Drop crafting grid items on leaving
minetest.register_on_leaveplayer(function(player)
	mcl_util.move_player_list(player, "craft")
	mcl_util.move_player_list(player, "enchanting_lapis")
	mcl_util.move_player_list(player, "enchanting_item")
end)

minetest.register_on_joinplayer(function(player)
	--init inventory
	local inv = player:get_inventory()

	inv:set_width("main", 9)
	inv:set_size("main", 36)
	inv:set_size("offhand", 1)

	--set hotbar size
	player:hud_set_hotbar_itemcount(9)
	--add hotbar images
	player:hud_set_hotbar_image("mcl_inventory_hotbar.png")
	player:hud_set_hotbar_selected_image("mcl_inventory_hotbar_selected.png")

	-- In Creative Mode, the initial inventory setup is handled in creative.lua
	if not minetest.is_creative_enabled(player:get_player_name()) then
		set_inventory(player)
	end

	--[[ Make sure the crafting grid is empty. Why? Because the player might have
	items remaining in the crafting grid from the previous join; this is likely
	when the server has been shutdown and the server didn't clean up the player
	inventories. ]]
	mcl_util.move_player_list(player, "craft")
	mcl_util.move_player_list(player, "enchanting_lapis")
	mcl_util.move_player_list(player, "enchanting_item")
end)

---@param player mt.PlayerObjectRef
function mcl_inventory.update_inventory(player)
	local player_gamemode = mcl_gamemode.get_gamemode(player)
	if player_gamemode == "creative" then
		mcl_inventory.set_creative_formspec(player)
	elseif player_gamemode == "survival" then
		player:set_inventory_formspec(mcl_inventory.build_survival_formspec(player))
	end
end

mcl_gamemode.register_on_gamemode_change(function(player, old_gamemode, new_gamemode)
	set_inventory(player)
end)

mcl_player.register_on_visual_change(mcl_inventory.update_inventory_formspec)
