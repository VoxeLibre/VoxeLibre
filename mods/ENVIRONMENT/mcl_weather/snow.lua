local get_connected_players = minetest.get_connected_players

mcl_weather.snow = {}

mcl_weather.snow.particles_count = 15
mcl_weather.snow.init_done = false

local psdef= {
	amount = 99,
	time = 0, --stay on til we turn it off
	minpos = vector.new(-15,-5,-15),
	maxpos =vector.new(15,10,15),
	minvel = vector.new(0,-1,0),
	maxvel = vector.new(0,-4,0),
	minacc = vector.new(0,-1,0),
	maxacc = vector.new(0,-4,0),
	minexptime = 1,
	maxexptime = 1,
	minsize = 0.5,
	maxsize = 5,
	collisiondetection = true,
	collision_removal = true,
	object_collision = true,
	vertical = true,
	glow = 1
}

-- calculates coordinates and draw particles for snow weather
function mcl_weather.snow.add_snow_particles(player)
	mcl_weather.rain.last_rp_count = 0
	for i=mcl_weather.snow.particles_count, 1,-1 do
		local random_pos_x, _, random_pos_z = mcl_weather.get_random_pos_by_player_look_dir(player)
		local random_pos_y = math.random() + math.random(player:get_pos().y - 1, player:get_pos().y + 7)
		if minetest.get_node_light({x=random_pos_x, y=random_pos_y, z=random_pos_z}, 0.5) == 15 then
			mcl_weather.rain.last_rp_count = mcl_weather.rain.last_rp_count + 1
			minetest.add_particle({
				pos = {x=random_pos_x, y=random_pos_y, z=random_pos_z},
				velocity = {x = math.random(-100,100)*0.001, y = math.random(-300,-100)*0.004, z = math.random(-100,100)*0.001},
				acceleration = {x = 0, y=0, z = 0},
				expirationtime = 8.0,
				size = 1,
				collisiondetection = true,
				collision_removal = true,
				object_collision = false,
				vertical = false,
				texture = mcl_weather.snow.get_texture(),
				playername = player:get_player_name()
			})
		end
	end
end

function mcl_weather.snow.set_sky_box()
	mcl_weather.skycolor.add_layer(
		"weather-pack-snow-sky",
		{{r=0, g=0, b=0},
		{r=85, g=86, b=86},
		{r=135, g=135, b=135},
		{r=85, g=86, b=86},
		{r=0, g=0, b=0}})
	mcl_weather.skycolor.active = true
	for _, player in pairs(get_connected_players()) do
		player:set_clouds({color="#ADADADE8"})
	end
	mcl_weather.skycolor.active = true
end

function mcl_weather.snow.clear()
	mcl_weather.skycolor.remove_layer("weather-pack-snow-sky")
	mcl_weather.snow.init_done = false
end

-- Simple random texture getter
function mcl_weather.snow.get_texture()
	return "weather_pack_snow_snowflake"..math.random(1,2)..".png"
end

local timer = 0
minetest.register_globalstep(function(dtime)
	if mcl_weather.state ~= "snow" then
		return false
	end

	timer = timer + dtime;
	if timer >= 0.5 then
		timer = 0
	else
		return
	end

	if mcl_weather.snow.init_done == false then
		mcl_weather.snow.set_sky_box()
		mcl_weather.snow.init_done = true
	end

	for _, player in pairs(get_connected_players()) do
		if (mcl_weather.is_underwater(player) or not mcl_worlds.has_weather(player:get_pos())) then
			mcl_weather.remove_spawners_player(player)
			return false
		end
		for i=1,2 do
			psdef.texture="weather_pack_snow_snowflake"..i..".png"
			mcl_weather.add_spawner_player(player,"snow"..i,psdef)
		end
	end
end)

-- register snow weather
if mcl_weather.reg_weathers.snow == nil then
	mcl_weather.reg_weathers.snow = {
		clear = mcl_weather.snow.clear,
		light_factor = 0.6,
		-- 10min - 20min
		min_duration = 600,
		max_duration = 1200,
		transitions = {
			[65] = "none",
			[80] = "rain",
			[100] = "thunder",
		}
	}
end
