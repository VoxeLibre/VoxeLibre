mcl_spawn = {}

-- Returns current spawn position of player.
-- If player is nil or not a player, the default spawn point is returned.
mcl_spawn.get_spawn_pos = function(player)
	local spawn
	if player ~= nil and player:is_player() then
		spawn = minetest.string_to_pos(player:get_attribute("mcl_beds:spawn"))
	end
	if not spawn or spawn == "" then
		spawn = minetest.setting_get_pos("static_spawnpoint")
	end
	if not spawn then
		spawn = { x=0, y=0, z=0 }
		if mg_name == "flat" then
			spawn.y = mcl_vars.mg_bedrock_overworld_max + 5
		end
	end
	return spawn
end

-- Sets the player's spawn position to pos.
-- Set pos to nil to clear the spawn position.
mcl_spawn.set_spawn_pos = function(player, pos)
	if pos == nil then
		player:set_attribute("mcl_beds:spawn", "")
	else
		player:set_attribute("mcl_beds:spawn", minetest.pos_to_string(pos))
	end
end

-- Respawn player at specified respawn position
minetest.register_on_respawnplayer(function(player)
	local pos = mcl_spawn.get_spawn_pos(player)
	if pos then
		-- Check if bed is still there
		-- and the spawning position is free of solid or damaging blocks.
		local node_bed = minetest.get_node(pos)
		local node_up1 = minetest.get_node({x=pos.x,y=pos.y+1,z=pos.z})
		local node_up2 = minetest.get_node({x=pos.x,y=pos.y+2,z=pos.z})
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
			minetest.chat_send_player(player:get_player_name(), "Your spawn bed was missing or blocked.")
		end
	end
end)

minetest.register_on_newplayer(function(player)
	mcl_spawn.set_spawn_pos(player, player:get_pos())
end)
