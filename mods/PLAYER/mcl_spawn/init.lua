mcl_spawn = {}

local S = minetest.get_translator("mcl_spawn")
local mg_name = minetest.get_mapgen_setting("mg_name")

local node_search_list =
	{
	--[[1]]	{x =  0, y = 0, z = -1},	--
	--[[2]]	{x = -1, y = 0, z =  0},	--
	--[[3]]	{x = -1, y = 0, z =  1},	--
	--[[4]]	{x =  0, y = 0, z =  2},	-- z^ 8 4 9
	--[[5]]	{x =  1, y = 0, z =  1},	--  | 3   5
	--[[6]]	{x =  1, y = 0, z =  0},	--  | 2 * 6
	--[[7]]	{x = -1, y = 0, z = -1},	--  | 7 1 A
	--[[8]]	{x = -1, y = 0, z =  2},	--  +----->
	--[[9]]	{x =  1, y = 0, z =  2},	--	x
	--[[A]]	{x =  1, y = 0, z = -1},	--
	--[[B]]	{x =  0, y = 1, z =  0},	--
	--[[C]]	{x =  0, y = 1, z =  1},	--
	}

local cached_world_spawn

mcl_spawn.get_world_spawn_pos = function()
	local spawn
	spawn = minetest.setting_get_pos("static_spawnpoint")
	if spawn then
		return spawn
	end
	if cached_world_spawn then
		return cached_world_spawn
	end
	-- 32 attempts to find a suitable spawn point
	spawn = { x=math.random(-16, 16), y=8, z=math.random(-16, 16) }
	for i=1, 32 do
		local y = minetest.get_spawn_level(spawn.x, spawn.z)
		if y then
			spawn.y = y
			cached_world_spawn = spawn
			minetest.log("action", "[mcl_spawn] Dynamic world spawn determined to be "..minetest.pos_to_string(spawn))
			return spawn
		end
		-- Random walk
		spawn.x = spawn.x + math.random(-64, 64)
		spawn.z = spawn.z + math.random(-64, 64)
	end
	minetest.log("action", "[mcl_spawn] Failed to determine dynamic world spawn!")
	-- Use dummy position if nothing found
	return { x=math.random(-16, 16), y=8, z=math.random(-16, 16) }
end

-- Returns a spawn position of player.
-- If player is nil or not a player, a world spawn point is returned.
-- The second return value is true if returned spawn point is player-chosen,
-- false otherwise.
mcl_spawn.get_spawn_pos = function(player)
	local spawn, custom_spawn = nil, false
	if player ~= nil and player:is_player() then
		local attr = player:get_meta():get_string("mcl_beds:spawn")
		if attr ~= nil and attr ~= "" then
			spawn = minetest.string_to_pos(attr)
			custom_spawn = true
		end
	end
	if not spawn or spawn == "" then
		spawn = mcl_spawn.get_world_spawn_pos()
		custom_spawn = false
	end
	return spawn, custom_spawn
end

-- Sets the player's spawn position to pos.
-- Set pos to nil to clear the spawn position.
-- If message is set, informs the player with a chat message when the spawn position
-- changed.
mcl_spawn.set_spawn_pos = function(player, pos, message)
	local spawn_changed = false
	local meta = player:get_meta()
	if pos == nil then
		if meta:get_string("mcl_beds:spawn") ~= "" then
			spawn_changed = true
			if message then
				minetest.chat_send_player(player:get_player_name(), S("Respawn position cleared!"))
			end
		end
		meta:set_string("mcl_beds:spawn", "")
	else
		local oldpos = minetest.string_to_pos(meta:get_string("mcl_beds:spawn"))
		meta:set_string("mcl_beds:spawn", minetest.pos_to_string(pos))
		if oldpos then
			-- We don't bother sending a message if the new spawn pos is basically the same
			spawn_changed = vector.distance(pos, oldpos) > 0.1
		else
			-- If it wasn't set and now it will be set, it means it is changed
			spawn_changed = true
		end
		if spawn_changed and message then
			minetest.chat_send_player(player:get_player_name(), S("New respawn position set!"))
		end
	end
	return spawn_changed
end

local function get_far_node(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then
		return node
	end
	minetest.get_voxel_manip():read_from_map(pos, pos)
	return minetest.get_node(pos)
end

local function good_for_respawn(pos)
	local node0 = get_far_node({x = pos.x, y = pos.y - 1, z = pos.z})
	local node1 = get_far_node({x = pos.x, y = pos.y, z = pos.z})
	local node2 = get_far_node({x = pos.x, y = pos.y + 1, z = pos.z})
	local def0 = minetest.registered_nodes[node0.name]
	local def1 = minetest.registered_nodes[node1.name]
	local def2 = minetest.registered_nodes[node2.name]
	return def0.walkable and (not def1.walkable) and (not def2.walkable) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0)
end

-- Respawn player at specified respawn position
minetest.register_on_respawnplayer(function(player)
	local pos, custom_spawn = mcl_spawn.get_spawn_pos(player)
	if pos and custom_spawn then
		-- Check if bed is still there
		local node_bed = get_far_node(pos)
		local bgroup = minetest.get_item_group(node_bed.name, "bed")
		if bgroup ~= 1 and bgroup ~= 2 then
			-- Bed is destroyed:
			if player ~= nil and player:is_player() then
				player:get_meta():set_string("mcl_beds:spawn", "")
			end
			minetest.chat_send_player(player:get_player_name(), S("Your spawn bed was missing or blocked."))
			return false
		end

		-- Find spawning position on/near the bed free of solid or damaging blocks iterating a square spiral 15x15:

		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		local offset
		for _, o in ipairs(node_search_list) do
			if dir.z == -1 then
				offset = {x =  o.x, y = o.y,  z =  o.z}
			elseif dir.z == 1 then
				offset = {x = -o.x, y = o.y,  z = -o.z}
			elseif dir.x == -1 then
				offset = {x =  o.z, y = o.y,  z = -o.x}
			else -- dir.x == 1
				offset = {x = -o.z, y = o.y,  z =  o.x}
			end
			local spawn_pos = vector.add(pos, offset)
			if good_for_respawn(spawn_pos) then
				player:set_pos(spawn_pos)
				return true
			end
		end

		-- We here if we didn't find suitable place for respawn:
		return false
	end
end)

