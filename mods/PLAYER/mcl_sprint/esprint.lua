--[[
Sprint mod for Minetest by GunshipPenguin

To the extent possible under law, the author(s)
have dedicated all copyright and related and neighboring rights 
to this software to the public domain worldwide. This software is
distributed without any warranty. 
]]

local players = {}

minetest.register_on_joinplayer(function(player)
	local playerName = player:get_player_name()

	players[playerName] = {
		sprinting = false,
		timeOut = 0, 
		shouldSprint = false,
	}
end)
minetest.register_on_leaveplayer(function(player)
	local playerName = player:get_player_name()
	players[playerName] = nil
end)
minetest.register_globalstep(function(dtime)
	--Get the gametime
	local gameTime = minetest.get_gametime()

	--Loop through all connected players
	for playerName,playerInfo in pairs(players) do
		local player = minetest.get_player_by_name(playerName)
		if player ~= nil then
			--Check if the player should be sprinting
			if player:get_player_control()["aux1"] and player:get_player_control()["up"] then
				players[playerName]["shouldSprint"] = true
			else
				players[playerName]["shouldSprint"] = false
			end
			
			--If the player is sprinting, create particles behind him/her 
			if playerInfo["sprinting"] == true and gameTime % 0.1 == 0 then
				local numParticles = math.random(1, 2)
				local playerPos = player:getpos()
				local playerNode = minetest.get_node({x=playerPos["x"], y=playerPos["y"]-1, z=playerPos["z"]})
				if playerNode["name"] ~= "air" then
					for i=1, numParticles, 1 do
						minetest.add_particle({
							pos = {x=playerPos["x"]+math.random(-1,1)*math.random()/2,y=playerPos["y"]+0.1,z=playerPos["z"]+math.random(-1,1)*math.random()/2},
							vel = {x=0, y=5, z=0},
							acc = {x=0, y=-13, z=0},
							expirationtime = math.random(),
							size = math.random()+0.5,
							collisiondetection = true,
							vertical = false,
							texture = "default_dirt.png",
						})
					end
				end
			end

			--Adjust player states
			if players[playerName]["shouldSprint"] == true then --Stopped
				local sprinting
				-- Prevent sprinting if standing on soul sand or hungry
				if playerplus[playerName].nod_stand == "mcl_nether:soul_sand" or (mcl_hunger and mcl_hunger.get_hunger(player) <= 6) then
					sprinting = false
				else
					sprinting = true
				end
				setSprinting(playerName, sprinting)
			elseif players[playerName]["shouldSprint"] == false then
				setSprinting(playerName, false)
			end
			
		end
	end
end)

function setSprinting(playerName, sprinting) --Sets the state of a player (0=stopped/moving, 1=sprinting)
	local player = minetest.get_player_by_name(playerName)
	if players[playerName] then
		players[playerName]["sprinting"] = sprinting
		-- Don't overwrite physics when standing on soul sand
		if playerplus[playerName].nod_stand ~= "mcl_nether:soul_sand" then
			if sprinting == true then
				player:set_physics_override({speed=mcl_sprint.SPEED})
			elseif sprinting == false then
				player:set_physics_override({speed=1.0})
			end
			return true
		end
	end
	return false
end
