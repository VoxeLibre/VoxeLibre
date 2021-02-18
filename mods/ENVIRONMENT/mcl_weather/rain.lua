local PARTICLES_COUNT_RAIN = 30
local PARTICLES_COUNT_THUNDER = 45

mcl_weather.rain = {
	-- max rain particles created at time
	particles_count = PARTICLES_COUNT_RAIN,

	-- flag to turn on/off extinguish fire for rain
	extinguish_fire = true,

	-- flag useful when mixing weathers
	raining = false,

	-- keeping last timeofday value (rounded).
	-- Defaulted to non-existing value for initial comparing.
	sky_last_update = -1,

	init_done = false,
}

mcl_weather.rain.sound_handler = function(player)
	return minetest.sound_play("weather_rain", {
		to_player = player:get_player_name(),
		loop = true,
	})
end

-- set skybox based on time (uses skycolor api)
mcl_weather.rain.set_sky_box = function()
	if mcl_weather.state == "rain" then
		mcl_weather.skycolor.add_layer(
			"weather-pack-rain-sky",
			{{r=0, g=0, b=0},
			{r=85, g=86, b=98},
			{r=135, g=135, b=151},
			{r=85, g=86, b=98},
			{r=0, g=0, b=0}})
		mcl_weather.skycolor.active = true
		for _, player in ipairs(minetest.get_connected_players()) do
			player:set_clouds({color="#5D5D5FE8"})
		end
	end
end

-- creating manually parctiles instead of particles spawner because of easier to control
-- spawn position.
mcl_weather.rain.add_rain_particles = function(player)

	mcl_weather.rain.last_rp_count = 0
	for i=mcl_weather.rain.particles_count, 1,-1 do
		local random_pos_x, random_pos_y, random_pos_z = mcl_weather.get_random_pos_by_player_look_dir(player)
		if mcl_weather.is_outdoor({x=random_pos_x, y=random_pos_y, z=random_pos_z}) then
			mcl_weather.rain.last_rp_count = mcl_weather.rain.last_rp_count + 1
			minetest.add_particle({
				pos = {x=random_pos_x, y=random_pos_y, z=random_pos_z},
				velocity = {x=0, y=-10, z=0},
				acceleration = {x=0, y=-30, z=0},
				expirationtime = 1.0,
				size = math.random(0.5, 3),
				collisiondetection = true,
				collision_removal = true,
				vertical = true,
				texture = mcl_weather.rain.get_texture(),
				playername = player:get_player_name()
			})
		end
	end
end

-- Simple random texture getter
mcl_weather.rain.get_texture = function()
	local texture_name
	local random_number = math.random()
	if random_number > 0.33 then
		texture_name = "weather_pack_rain_raindrop_1.png"
	elseif random_number > 0.66 then
		texture_name = "weather_pack_rain_raindrop_2.png"
	else
		texture_name = "weather_pack_rain_raindrop_3.png"
	end
	return texture_name;
end

-- register player for rain weather.
-- basically needs for origin sky reference and rain sound controls.
mcl_weather.rain.add_player = function(player)
	if mcl_weather.players[player:get_player_name()] == nil then
		local player_meta = {}
		player_meta.origin_sky = {player:get_sky()}
		mcl_weather.players[player:get_player_name()] = player_meta
	end
end

-- remove player from player list effected by rain.
-- be sure to remove sound before removing player otherwise soundhandler reference will be lost.
mcl_weather.rain.remove_player = function(player)
	local player_meta = mcl_weather.players[player:get_player_name()]
	if player_meta ~= nil and player_meta.origin_sky ~= nil then
		player:set_clouds({color="#FFF0F0E5"})
		mcl_weather.players[player:get_player_name()] = nil
	end
end

mcl_worlds.register_on_dimension_change(function(player, dimension)
	if dimension ~= "overworld" and dimension ~= "void" then
		mcl_weather.rain.remove_sound(player)
		mcl_weather.rain.remove_player(player)
	elseif dimension == "overworld" then
		mcl_weather.rain.update_sound(player)
		if mcl_weather.rain.raining then
			mcl_weather.rain.add_rain_particles(player)
			mcl_weather.rain.add_player(player)
		end
	end
end)

-- adds and removes rain sound depending how much rain particles around player currently exist.
-- have few seconds delay before each check to avoid on/off sound too often
-- when player stay on 'edge' where sound should play and stop depending from random raindrop appearance.
mcl_weather.rain.update_sound = function(player)
	local player_meta = mcl_weather.players[player:get_player_name()]
	if player_meta ~= nil then
		if player_meta.sound_updated ~= nil and player_meta.sound_updated + 5 > minetest.get_gametime() then
			return false
		end

		if player_meta.sound_handler ~= nil then
			if mcl_weather.rain.last_rp_count == 0 then
				minetest.sound_fade(player_meta.sound_handler, -0.5, 0.0)
				player_meta.sound_handler = nil
			end
		elseif mcl_weather.rain.last_rp_count > 0 then
			player_meta.sound_handler = mcl_weather.rain.sound_handler(player)
		end

		player_meta.sound_updated = minetest.get_gametime()
	end
end

-- rain sound removed from player.
mcl_weather.rain.remove_sound = function(player)
	local player_meta = mcl_weather.players[player:get_player_name()]
	if player_meta ~= nil and player_meta.sound_handler ~= nil then
		minetest.sound_fade(player_meta.sound_handler, -0.5, 0.0)
		player_meta.sound_handler = nil
		player_meta.sound_updated = nil
	end
end

-- callback function for removing rain
mcl_weather.rain.clear = function()
	mcl_weather.rain.raining = false
	mcl_weather.rain.sky_last_update = -1
	mcl_weather.rain.init_done = false
	mcl_weather.rain.set_particles_mode("rain")
	mcl_weather.skycolor.remove_layer("weather-pack-rain-sky")
	for _, player in ipairs(minetest.get_connected_players()) do
		mcl_weather.rain.remove_sound(player)
		mcl_weather.rain.remove_player(player)
	end
end

minetest.register_globalstep(function(dtime)
	if mcl_weather.state ~= "rain" then
		return false
	end

	mcl_weather.rain.make_weather()
end)

mcl_weather.rain.make_weather = function()
	if mcl_weather.rain.init_done == false then
		mcl_weather.rain.raining = true
		mcl_weather.rain.set_sky_box()
		mcl_weather.rain.set_particles_mode(mcl_weather.mode)
		mcl_weather.rain.init_done = true
	end

	for _, player in ipairs(minetest.get_connected_players()) do
		if (mcl_weather.is_underwater(player) or not mcl_worlds.has_weather(player:get_pos())) then
			mcl_weather.rain.remove_sound(player)
			return false
		end
		mcl_weather.rain.add_player(player)
		mcl_weather.rain.add_rain_particles(player)
		mcl_weather.rain.update_sound(player)
	end
end

-- Switch the number of raindrops: "thunder" for many raindrops, otherwise for normal raindrops
mcl_weather.rain.set_particles_mode = function(mode)
	if mode == "thunder" then
		mcl_weather.rain.particles_count = PARTICLES_COUNT_THUNDER
	else
		mcl_weather.rain.particles_count = PARTICLES_COUNT_RAIN
	end
end

if mcl_weather.allow_abm then
	-- ABM for extinguish fire
	minetest.register_abm({
		label = "Rain extinguishes fire",
		nodenames = {"mcl_fire:fire"},
		interval = 2.0,
		chance = 2,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- Fire is extinguished if in rain or one of 4 neighbors is in rain
			if mcl_weather.rain.raining and mcl_weather.rain.extinguish_fire then
				local around = {
					{ x = 0, y = 0, z = 0 },
					{ x = -1, y = 0, z = 0 },
					{ x = 1, y = 0, z = 0 },
					{ x = 0, y = 0, z = -1 },
					{ x = 0, y = 0, z = 1 },
				}
				for a=1, #around do
					local apos = vector.add(pos, around[a])
					if mcl_weather.is_outdoor(apos) then
						minetest.remove_node(pos)
						minetest.sound_play("fire_extinguish_flame", {pos = pos, max_hear_distance = 8, gain = 0.1}, true)
						return
					end
				end
			end
		end,
	})

	-- Slowly fill up cauldrons
	minetest.register_abm({
		label = "Rain fills cauldrons with water",
		nodenames = {"mcl_cauldrons:cauldron", "mcl_cauldrons:cauldron_1", "mcl_cauldrons:cauldron_2"},
		interval = 56.0,
		chance = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- Rain is equivalent to a water bottle
			if mcl_weather.rain.raining and mcl_weather.is_outdoor(pos) then
				if node.name == "mcl_cauldrons:cauldron" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_1"})
				elseif node.name == "mcl_cauldrons:cauldron_1" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_2"})
				elseif node.name == "mcl_cauldrons:cauldron_2" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_3"})
				elseif node.name == "mcl_cauldrons:cauldron_1r" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_2r"})
				elseif node.name == "mcl_cauldrons:cauldron_2r" then
					minetest.set_node(pos, {name="mcl_cauldrons:cauldron_3r"})
				end
			end
		end
  	})

	-- Wetten the soil
	minetest.register_abm({
		label = "Rain hydrates farmland",
		nodenames = {"mcl_farming:soil"},
		interval = 22.0,
		chance = 3,
		action = function(pos, node, active_object_count, active_object_count_wider)
			if mcl_weather.rain.raining and mcl_weather.is_outdoor(pos) then
				if node.name == "mcl_farming:soil" then
					minetest.set_node(pos, {name="mcl_farming:soil_wet"})
				end
			end
		end
  	})
end

if mcl_weather.reg_weathers.rain == nil then
	mcl_weather.reg_weathers.rain = {
		clear = mcl_weather.rain.clear,
		light_factor = 0.6,
		-- 10min - 20min
		min_duration = 600,
		max_duration = 1200,
		transitions = {
			[65] = "none",
			[70] = "snow",
			[100] = "thunder",
		}
	}
end
