--[[
Copyright (C) 2019 - Auke Kok <sofar@foo-projects.org>
Copyright (C) 2022 - MysticTempest

"mcl_hardcore" is a fork of "yolo", is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as
published by the Free Software Foundation; either version 2.1
of the license, or (at your option) any later version.

--]]

-- Spectator mode:
--	Players are unable to interact with the world, invisible, have fast, fly & noclip, are immortal and their health/hunger hudbars are hidden.
--
--

mcl_hardcore = {}

-- Write Hardcore mode state to world.
function mcl_hardcore.save()
	local file = io.open(minetest.get_worldpath().."/hardcore_mode.txt", "w")
	if file then
		file:write("Enabled")
		file:close()
	end
	hardcore_world = true
end


-- Spectator mode
function mcl_hardcore.spectator_mode(player)
	local meta = player:get_meta()
	local player_name = player:get_player_name()

	meta:set_int("mcl_privs:interact_revoked", 1)
	player:set_armor_groups({immortal=1})
	minetest.set_player_privs(player_name, {fly=true,fast=true,noclip=true,interact=nil})

	-- Have to wait since mcl_potions clears old effects on startup.
	minetest.after(3, function(player)
		mcl_potions._reset_player_effects(player) -- Fix some cases of not clearing.
		mcl_potions.invisiblility_func(player, null, 86400) -- Invisible for 24 hours.
		hb.hide_hudbar(player, "hunger")
		hb.change_hudbar(player, "health", nil, nil,  "blank.png", nil, "hudbars_bar_health.png")
		mcl_experience.remove_hud(player)
	end, player)
	if meta:get_string("gamemode") ~= "spectator" then
		meta:set_string("gamemode","spectator")
	end
end

function mcl_hardcore.spectator_mode_disabled(player)
	local meta = player:get_meta()
	local player_name = player:get_player_name()
	local privs = minetest.get_player_privs(player_name)


	if meta:get_int("dead") == 1 and hardcore_world==true then
		meta:set_string("gamemode","spectator")
		minetest.chat_send_player(player_name, "You died in hardcore mode; spectator mode not disabled.")
		return
	else
		minetest.after(3, function(player) -- Fix startup crash conflict by waiting slightly.
			mcl_potions._reset_player_effects(player)
			mcl_potions.invisiblility_func(player, null, 0)
			hb.unhide_hudbar(player, "hunger")
			meta:set_int("mcl_privs:interact_revoked", 0)
			player:set_armor_groups({immortal=0})

			-- Try to preserve privs somewhat
			if meta:get_string("gamemode") == "spectator" then
				meta:set_string("gamemode","")
			elseif meta:get_string("gamemode") == "creative" then
				privs.fast = nil
				privs.noclip = nil
				privs.fly = true
				privs.interact = true
				minetest.set_player_privs(player_name, privs)
			else -- survival; only basic privs
				minetest.set_player_privs(player_name, {basic_privs=true})
			end
		end, player)
	end
end


-- Hardcore mode
function mcl_hardcore.hardcore_mode(player)
	local meta = player:get_meta()
	local player_name = player:get_player_name()
	if meta:get_int("dead") == 1 then
		mcl_hardcore.spectator_mode(player)
		minetest.chat_send_player(player_name, "You died in hardcore mode; rejoining as a spectator.")
	end

	minetest.register_on_dieplayer(function(player, reason)
		local name = player:get_player_name()
		local meta = player:get_meta()
		meta:set_int("dead", 1)
	end)

	-- Make player a spectator on respawn in hardcore mode.
	minetest.register_on_respawnplayer(function(player)
		local meta = player:get_meta()
		local player_name = player:get_player_name()
		if meta:get_int("dead") == 1 then
			mcl_hardcore.spectator_mode(player)
			minetest.chat_send_player(player_name, "You died in hardcore mode; respawning as a spectator.")
		end
	end)
end


local hardcore_mode = minetest.settings:get_bool("enable_hardcore_mode", false)
--Set world state:
minetest.register_on_joinplayer(function(player)
	if minetest.get_gametime() <= 5 and hardcore_mode then
		mcl_hardcore.save()
	else
		local file = io.open(minetest.get_worldpath().."/hardcore_mode.txt", "r")
		if file ~= nil then
			hardcore_world = true
		end
	end
	if hardcore_world then
		mcl_hardcore.hardcore_mode(player)
	end

end)
