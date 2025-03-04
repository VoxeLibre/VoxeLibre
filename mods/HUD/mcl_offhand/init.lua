local minetest, math = minetest, math
mcl_offhand = {}

local max_offhand_px = 128
-- only supports up to 128px textures

function mcl_offhand.get_offhand(player)
	return player:get_inventory():get_stack("offhand", 1)
end

local function offhand_get_wear(player)
	return mcl_offhand.get_offhand(player):get_wear()
end

local function offhand_get_count(player)
	return mcl_offhand.get_offhand(player):get_count()
end

local function get_offhand(player)
	-- Get offhand data if it already exists
	local offhand = mcl_offhand[player]
	if offhand then return offhand end

	-- Otherwise initialize it
	offhand = {
		hud = {},
		last_wear = offhand_get_wear(player),
		last_count = offhand_get_count(player),
	}
	mcl_offhand[player] = offhand
	return offhand
end

minetest.register_on_joinplayer(function(player, last_login)
	get_offhand(player)
end)

local function remove_hud(player, hud)
	local offhand = get_offhand(player)
	local offhand_hud = offhand.hud[hud]
	if offhand_hud then
		player:hud_remove(offhand_hud)
		offhand.hud[hud] = nil
	end
end

function rgb_to_hex(r, g, b)
	return string.format("%02x%02x%02x", r, g, b)
end

local function update_wear_bar(player, itemstack)
	local wear_bar_percent = (65535 - offhand_get_wear(player)) / 65535

	local color = {255, 255, 255}
	local wear = itemstack:get_wear() / 65535;
	local wear_i = math.min(math.floor(wear * 600), 511);
	wear_i = math.min(wear_i + 10, 511);
	if wear_i <= 255 then
		color = {wear_i, 255, 0}
	else
		color = {255, 511 - wear_i, 0}
	end
	local offhand = get_offhand(player)
	local wear_bar = offhand.hud.wear_bar
	player:hud_change(wear_bar, "text", "mcl_wear_bar.png^[colorize:#" .. rgb_to_hex(color[1], color[2], color[3]))
	player:hud_change(wear_bar, "scale", {x = 40 * wear_bar_percent, y = 3})
	player:hud_change(wear_bar, "offset", {x = -320 - (20 - player:hud_get(wear_bar).scale.x / 2), y = -13})
end

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local itemstack = mcl_offhand.get_offhand(player)
		local offhand_item = itemstack:get_name()
		local offhand = get_offhand(player)
		local offhand_hud = offhand.hud
		local item = minetest.registered_items[offhand_item]
		if offhand_item ~= "" and item then
			local item_texture = item.inventory_image .. "^[resize:" .. max_offhand_px .. "x" .. max_offhand_px
			local position = {x = 0.5, y = 1}
			local offset = {x = -320, y = -32}

			if not offhand_hud.slot then
				offhand_hud.slot = player:hud_add({
					[mcl_vars.hud_type_field] = "image",
					position = position,
					offset = offset,
					scale = {x = 0.46875, y = 0.46875},
					text = "mcl_offhand_slot.png" .. "^[resize:" .. max_offhand_px .. "x" .. max_offhand_px,
					z_index = 0,
				})
			end
			if not offhand_hud.item then
				offhand_hud.item = player:hud_add({
					[mcl_vars.hud_type_field] = "image",
					position = position,
					offset = offset,
					scale = {x = 0.375, y = 0.375},
					text = item_texture,
					z_index = 1,
				})
			else
				player:hud_change(offhand_hud.item, "text", item_texture)
			end
			if not offhand_hud.wear_bar_bg and minetest.registered_tools[offhand_item] then
				if offhand_get_wear(player) > 0 then
					local texture = "mcl_wear_bar.png^[colorize:#000000"
					offhand_hud.wear_bar_bg = player:hud_add({
						[mcl_vars.hud_type_field] = "image",
						position = {x = 0.5, y = 1},
						offset = {x = -320, y = -13},
						scale = {x = 40, y = 3},
						text = texture,
						z_index = 2,
					})
					offhand_hud.wear_bar = player:hud_add({
						[mcl_vars.hud_type_field] = "image",
						position = {x = 0.5, y = 1},
						offset = {x = -320, y = -13},
						scale = {x = 10, y = 3},
						text = texture,
						z_index = 3,
					})
					update_wear_bar(player, itemstack)
				end
			end

			if not offhand_hud.item_count and offhand_get_count(player) > 1 then
				offhand_hud.item_count = player:hud_add({
					[mcl_vars.hud_type_field] = "text",
					position = {x = 0.5, y = 1},
					offset = {x = -298, y = -18},
					scale = {x = 1, y = 1},
					alignment = {x = -1, y = 0},
					text = offhand_get_count(player),
					z_index = 4,
					number = 0xFFFFFF,
				})
			end

			if offhand_hud.wear_bar then
				if offhand_hud.last_wear ~= offhand_get_wear(player) then
					update_wear_bar(player, itemstack)
					offhand_hud.last_wear = offhand_get_wear(player)
				end
				if offhand_get_wear(player) <= 0 or not minetest.registered_tools[offhand_item] then
					remove_hud(player, "wear_bar_bg")
					remove_hud(player, "wear_bar")
				end
			end

			if offhand_hud.item_count then
				if offhand_hud.last_count ~= offhand_get_count(player) then
					player:hud_change(offhand_hud.item_count, "text", offhand_get_count(player))
					offhand_hud.last_count = offhand_get_count(player)
				end
				if offhand_get_count(player) <= 1 then
					remove_hud(player, "item_count")
				end
			end

		elseif offhand_hud.slot then
			local offhand = get_offhand(player)
			for index, _ in pairs(offhand.hud) do
				remove_hud(player, index)
			end
		end
	end
end)

minetest.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if action == "move" and inventory_info.to_list == "offhand" then
		local itemstack = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
		if not (minetest.get_item_group(itemstack:get_name(), "offhand_item") > 0)  then
			return 0
		else
			return itemstack:get_stack_max()
		end
	end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	local from_offhand = inventory_info.from_list == "offhand"
	local to_offhand = inventory_info.to_list == "offhand"
	if action == "move" and from_offhand or to_offhand then
		mcl_inventory.update_inventory_formspec(player)
	end
end)
