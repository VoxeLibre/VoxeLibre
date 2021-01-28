mcl_weather.nether_dust = {}
mcl_weather.nether_dust.particles_count = 99

-- calculates coordinates and draw particles for Nether dust
mcl_weather.nether_dust.add_dust_particles = function(player)
	for i=mcl_weather.nether_dust.particles_count, 1,-1 do
		local rpx, rpy, rpz = mcl_weather.get_random_pos_by_player_look_dir(player)
		minetest.add_particle({
			pos = {x = rpx, y = rpy - math.random(6, 18), z = rpz},
			velocity = {x = math.random(-30,30)*0.01, y = math.random(-15,15)*0.01, z = math.random(-30,30)*0.01},
			acceleration = {x = math.random(-50,50)*0.02, y = math.random(-20,20)*0.02, z = math.random(-50,50)*0.02},
			expirationtime = 3,
			size = math.random(6,20)*0.01,
			collisiondetection = false,
			object_collision = false,
			vertical = false,
			glow = math.random(0,minetest.LIGHT_MAX),
			texture = "mcl_particles_nether_dust"..tostring(i%3+1)..".png",
			playername = player:get_player_name()
		})
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 0.7 then return end
	timer = 0

	for _, player in ipairs(minetest.get_connected_players()) do
		if not mcl_worlds.has_dust(player:get_pos()) then
			return false
		end
		mcl_weather.nether_dust.add_dust_particles(player)
	end
end)
