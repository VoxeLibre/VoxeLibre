mcl_spawn = {}

local S = minetest.get_translator("mcl_spawn")
local mg_name = minetest.get_mapgen_setting("mg_name")

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
		if oldpos then
			-- We don't bother sending a message if the new spawn pos is basically the same
			if vector.distance(pos, oldpos) > 0.1 then
				spawn_changed = true
				if message then
					minetest.chat_send_player(player:get_player_name(), S("New respawn position set!"))
				end
			end
		end
		meta:set_string("mcl_beds:spawn", minetest.pos_to_string(pos))
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

-- Respawn player at specified respawn position
minetest.register_on_respawnplayer(function(player)
	local pos, custom_spawn = mcl_spawn.get_spawn_pos(player)
	if pos and custom_spawn then
		-- Check if bed is still there
		-- and the spawning position is free of solid or damaging blocks.
		local node_bed = get_far_node(pos)
		local node_up1 = get_far_node({x=pos.x,y=pos.y+1,z=pos.z})
		local node_up2 = get_far_node({x=pos.x,y=pos.y+2,z=pos.z})
		local bgroup = minetest.get_item_group(node_bed.name, "bed")
		local def1 = minetest.registered_nodes[node_up1.name]
		local def2 = minetest.registered_nodes[node_up2.name]
		if (bgroup == 1 or bgroup == 2) and
				(not def1.walkable) and (not def2.walkable) and
				(def1.damage_per_second == nil or def2.damage_per_second <= 0) and
				(def1.damage_per_second == nil or def2.damage_per_second <= 0) then
			player:set_pos(pos)
			return true
		else
			-- Forget spawn if bed was missing
			if (bgroup ~= 1 and bgroup ~= 2) then
				mcl_spawn.set_spawn_pos(player, nil)
			end
			minetest.chat_send_player(player:get_player_name(), S("Your spawn bed was missing or blocked."))
		end
	end
end)

