local S = minetest.get_translator("mcl_maps")

-- Turn empty map into filled map by rightclick
local make_filled_map = function(itemstack, placer, pointed_thing)
	local new_map = ItemStack("mcl_maps:filled_map")
	itemstack:take_item()
	if itemstack:is_empty() then
		return new_map
	else
		local inv = placer:get_inventory()
		if inv:room_for_item("main", new_map) then
			inv:add_item("main", new_map)
		else
			minetest.add_item(placer:get_pos(), new_map)
		end
		return itemstack
	end
end

minetest.register_craftitem("mcl_maps:empty_map", {
	description = S("Empty Map"),
	_doc_items_longdesc = S("Empty maps are not useful as maps, but they can be stacked and turned to maps which can be used."),
	_doc_items_usagehelp = S("Rightclick to start using the map (which can't be stacked anymore)."),
	inventory_image = "mcl_maps_map_empty.png",
	groups = { not_in_creative_inventory = 1 },
	on_place = make_filled_map,
	on_secondary_use = make_filled_map,
	stack_max = 64,
})

mcl_wip.register_wip_item("mcl_maps:empty_map")

local function has_item_in_hotbar(player, item)
	-- Requirement: player carries the tool in the hotbar
	local inv = player:get_inventory()
	local hotbar = player:hud_get_hotbar_itemcount()
	for i=1, hotbar do
		if inv:get_stack("main", i):get_name() == item then
			return true
		end
	end
	return false
end

-- Checks if player is still allowed to display the minimap
local function update_minimap(player)
	local creative = minetest.is_creative_enabled(player:get_player_name())
	if creative then
		player:hud_set_flags({minimap=true, minimap_radar = true})
	else
		if has_item_in_hotbar(player, "mcl_maps:filled_map") then
			player:hud_set_flags({minimap = true, minimap_radar = false})
		else
			player:hud_set_flags({minimap = false, minimap_radar = false})
		end
	end
end

-- Remind player how to use the minimap correctly
local function use_minimap(itemstack, player, pointed_thing)
	if player and player:is_player() then
		update_minimap(player)
		minetest.chat_send_player(player:get_player_name(), S("Use the minimap key to show the map."))
	end
end

-- Enables minimap if carried in hotbar.
-- If this item is NOT in the hotbar, the minimap is unavailable
-- Note: This is not at all like Minecraft right now. Minetest's minimap is pretty overpowered, it
-- has a very greatly zoomed-out version and even a radar mode
minetest.register_craftitem("mcl_maps:filled_map", {
	description = S("Map"),
	_tt_help = S("Enables minimap"),
	_doc_items_longdesc = S("Maps show your surroundings as you explore the world."),
	_doc_items_usagehelp = S("Hold the map in any of the hotbar slots. This allows you to access the minimap by pressing the minimap key (see controls settings).").."\n"..
			S("In Creative Mode, you don't need this item; the minimap is always available."),
	groups = { tool = 1 },
	inventory_image = "mcl_maps_map_filled.png^(mcl_maps_map_filled_markings.png^[colorize:#000000)",
	stack_max = 1,

	on_use = use_minimap,
	on_secondary_use = use_minimap,
})

minetest.register_craft({
	output = "mcl_maps:filled_map",
	recipe = {
		{ "mcl_core:paper", "mcl_core:paper", "mcl_core:paper" },
		{ "mcl_core:paper", "group:compass", "mcl_core:paper" },
		{ "mcl_core:paper", "mcl_core:paper", "mcl_core:paper" },
	}
})

minetest.register_on_joinplayer(function(player)
	update_minimap(player)
end)

local updatetimer = 0
if not minetest.is_creative_enabled("") then
	minetest.register_globalstep(function(dtime)
		updatetimer = updatetimer + dtime
		if updatetimer > 0.1 then
			local players = minetest.get_connected_players()
			for i=1, #players do
				update_minimap(players[i])
			end
			updatetimer = updatetimer - dtime
		end
	end)
end
