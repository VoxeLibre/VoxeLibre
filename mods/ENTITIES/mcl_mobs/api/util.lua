function mcl_mobs.util.scale_difficulty(value, default, min, special)
	if (not value) or (value == default) or (value == special) then
		return default
	else
		return math.max(min, value * difficulty)
	end
end

function mcl_mobs.util.scale_size(tbl, size)
	for k, v in pairs(tbl) do
		tbl[k] = v * size
	end
end

function mcl_mobs.util.rgb_to_hex(rgb)
	local hexadecimal = "#"

	for key, value in pairs(rgb) do
		local hex = ""

		while value > 0 do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub("0123456789ABCDEF", index, index) .. hex
		end

		local len = string.len(hex)

		if len == 0 then
			hex = "00"
		elseif len == 1 then
			hex = "0" .. hex
		end

		hexadecimal = hexadecimal .. hex
	end

	return hexadecimal
end

function mcl_mobs.util.color_from_hue(hue)
	local h = hue / 60
	local c = 255
	local x = (1 - math.abs(h % 2 - 1)) * 255

	local i = math.floor(h)
	if i == 0 then
		return mcl_mobs.util.rgb_to_hex({c, x, 0})
	elseif i == 1 then
		return mcl_mobs.util.rgb_to_hex({x, c, 0})
	elseif i == 2 then
		return mcl_mobs.util.rgb_to_hex({0, c, x})
	elseif i == 3 then
		return mcl_mobs.util.rgb_to_hex({0, x, c})
	elseif i == 4 then
		return mcl_mobs.util.rgb_to_hex({x, 0, c})
	else
		return mcl_mobs.util.rgb_to_hex({c, 0, x})
	end
end

function mcl_mobs.util.take_item(player, itemstack)
	if not minetest.is_creative_enabled(player:get_player_name()) then
		itemstack:take_item()
		return true
	end
end

function mcl_mobs.util.get_eye_height(obj)
	if obj:is_player() then
		return obj:get_properties().eye_height
	else
		return obj:get_luaentity().eye_height or 0
	end
end

function mcl_mobs.util.list_to_set(list)
	local set = {}

	if list then
		for k, v in pairs(list) do
			set[v] = true
		end
	end

	return set
end

function mcl_mobs.util.within_map_limits(pos, radius)
	return pos
		and (pos.x - radius) > mcl_vars.mapgen_edge_min and (pos.x + radius) < mcl_vars.mapgen_edge_max
		and (pos.y - radius) > mcl_vars.mapgen_edge_min and (pos.y + radius) < mcl_vars.mapgen_edge_max
		and (pos.z - radius) > mcl_vars.mapgen_edge_min and (pos.z + radius) < mcl_vars.mapgen_edge_max
end

function mcl_mobs.util.get_collision_data(obj)
	local collisionbox = obj:get_properties().collisionbox
	local pos = obj:get_pos()
	pos.y = pos.y + collisionbox[2]
	return collisionbox, pos, collisionbox[4]
end

function mcl_mobs.util.get_node_type(pos)
	local node = minetest.get_node(pos).name

	return nil
		or node == "air" and "air"
		or (minetest.registered_nodes[node] or {walkable = true}).walkable and "solid"
		or node == "ignore" and "ignore"
		or node == "mcl_core:cobweb" and "cobweb"
		or minetest.get_item_group(node, "water") > 0 and "water"
		or minetest.get_item_group(node, "lava") > 0 and "lava"
		or "air"
end
