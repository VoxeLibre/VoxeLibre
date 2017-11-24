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
		player:set_pos(pos)
		return true
	end
end)

