local S = minetest.get_translator("mcl_weather")

-- weather states, 'none' is default, other states depends from active mods
mcl_weather.state = "none"
  
-- player list for saving player meta info
mcl_weather.players = {}
  
-- default weather check interval for global step
mcl_weather.check_interval = 5
  
-- weather min duration
mcl_weather.min_duration = 600
  
-- weather max duration
mcl_weather.max_duration = 9000

-- weather calculated end time
mcl_weather.end_time = nil
  
-- registered weathers
mcl_weather.reg_weathers = {}

-- global flag to disable/enable ABM logic. 
mcl_weather.allow_abm = true

mcl_weather.reg_weathers["none"] = {
	min_duration = mcl_weather.min_duration,
	max_duration = mcl_weather.max_duration,
	light_factor = nil,
	transitions = {
		[50] = "rain",
		[100] = "snow",
	},
	clear = function() end,
}

local storage = minetest.get_mod_storage()
-- Save weather into mod storage, so it can be loaded after restarting the server
local save_weather = function()
	if not mcl_weather.end_time then return end
	storage:set_string("mcl_weather_state", mcl_weather.state)
	storage:set_int("mcl_weather_end_time", mcl_weather.end_time)
	minetest.log("verbose", "[mcl_weather] Weather data saved: state="..mcl_weather.state.." end_time="..mcl_weather.end_time)
end
minetest.register_on_shutdown(save_weather)

mcl_weather.get_rand_end_time = function(min_duration, max_duration)
	local r
	if min_duration ~= nil and max_duration ~= nil then
		r = math.random(min_duration, max_duration)
	else
		r = math.random(mcl_weather.min_duration, mcl_weather.max_duration)
	end 
	return minetest.get_gametime() + r
end

mcl_weather.get_current_light_factor = function()
	if mcl_weather.state == "none" then
		return nil
	else
		return mcl_weather.reg_weathers[mcl_weather.state].light_factor
	end
end

-- Returns true if pos is outdoor.
-- Outdoor is defined as any node in the Overworld under open sky.
-- FIXME: Nodes below glass also count as “outdoor”, this should not be the case.
mcl_weather.is_outdoor = function(pos)
	local cpos = {x=pos.x, y=pos.y+1, z=pos.z}
	local dim = mcl_worlds.pos_to_dimension(cpos)
	if minetest.get_node_light(cpos, 0.5) == 15 and dim == "overworld" then
		return true
	end
	return false
end

-- checks if player is undewater. This is needed in order to
-- turn off weather particles generation.
mcl_weather.is_underwater = function(player)
	local ppos = player:get_pos()
	local offset = player:get_eye_offset()
	local player_eye_pos = {x = ppos.x + offset.x, 
				y = ppos.y + offset.y + 1.5, 
				z = ppos.z + offset.z}
	local node_level = minetest.get_node_level(player_eye_pos)
	if node_level == 8 or node_level == 7 then
		return true
	end
	return false
end

-- trying to locate position for particles by player look direction for performance reason.
-- it is costly to generate many particles around player so goal is focus mainly on front view.  
mcl_weather.get_random_pos_by_player_look_dir = function(player)
	local look_dir = player:get_look_dir()
	local player_pos = player:get_pos()

	local random_pos_x = 0
	local random_pos_y = 0
	local random_pos_z = 0

	if look_dir.x > 0 then
		if look_dir.z > 0 then
			random_pos_x = math.random() + math.random(player_pos.x - 2.5, player_pos.x + 5)
			random_pos_z = math.random() + math.random(player_pos.z - 2.5, player_pos.z + 5)
		else
			random_pos_x = math.random() + math.random(player_pos.x - 2.5, player_pos.x + 5)
			random_pos_z = math.random() + math.random(player_pos.z - 5, player_pos.z + 2.5)
		end
	else
		if look_dir.z > 0 then
			random_pos_x = math.random() + math.random(player_pos.x - 5, player_pos.x + 2.5)
			random_pos_z = math.random() + math.random(player_pos.z - 2.5, player_pos.z + 5)
		else
			random_pos_x = math.random() + math.random(player_pos.x - 5, player_pos.x + 2.5)
			random_pos_z = math.random() + math.random(player_pos.z - 5, player_pos.z + 2.5)
		end
	end

	random_pos_y = math.random() + math.random(player_pos.y + 10, player_pos.y + 15)
	return random_pos_x, random_pos_y, random_pos_z
end

local t, wci = 0, mcl_weather.check_interval
minetest.register_globalstep(function(dtime)
	t = t + dtime
	if t < wci then return end
	t = 0

	if mcl_weather.end_time == nil then
		mcl_weather.end_time = mcl_weather.get_rand_end_time()
	end
	-- recalculate weather
	if mcl_weather.end_time <= minetest.get_gametime() then
		local changeWeather = minetest.settings:get_bool("mcl_doWeatherCycle")
		if changeWeather == nil then
			changeWeather = true
		end
		if changeWeather then
			mcl_weather.set_random_weather(mcl_weather.state, mcl_weather.reg_weathers[mcl_weather.state])
		else
			mcl_weather.end_time = mcl_weather.get_rand_end_time()
		end
	end
end)

-- Sets random weather (which could be 'none' (no weather)).
mcl_weather.set_random_weather = function(weather_name, weather_meta)
	if weather_meta == nil then return end
	local transitions = weather_meta.transitions
	local random_roll = math.random(0,100)
	local new_weather
	for v, weather in pairs(transitions) do
		if random_roll < v then
			new_weather = weather
			break
		end
	end
	if new_weather then
		mcl_weather.change_weather(new_weather)
	end
end

-- Change weather to new_weather.
-- * explicit_end_time is OPTIONAL. If specified, explicitly set the
--   gametime (minetest.get_gametime) in which the weather ends.
-- * changer is OPTIONAL, for logging purposes.
mcl_weather.change_weather = function(new_weather, explicit_end_time, changer_name)
	local changer_name = changer_name or debug.getinfo(2).name.."()"

	if (mcl_weather.reg_weathers ~= nil and mcl_weather.reg_weathers[new_weather] ~= nil) then
		if (mcl_weather.state ~= nil and mcl_weather.reg_weathers[mcl_weather.state] ~= nil) then
			mcl_weather.reg_weathers[mcl_weather.state].clear()
		end

		local old_weather = mcl_weather.state

		mcl_weather.state = new_weather

		if old_weather == "none" then
			old_weather = "clear"
		end
		if new_weather == "none" then
			new_weather = "clear"
		end
		minetest.log("action", "[mcl_weather] " .. changer_name .. " changed the weather from " .. old_weather .. " to " .. new_weather)

		local weather_meta = mcl_weather.reg_weathers[mcl_weather.state]
		if explicit_end_time then
			mcl_weather.end_time = explicit_end_time
		else
			mcl_weather.end_time = mcl_weather.get_rand_end_time(weather_meta.min_duration, weather_meta.max_duration)
		end
		mcl_weather.skycolor.update_sky_color()
		save_weather()
		return true
	end
	return false
end

mcl_weather.get_weather = function()
	return mcl_weather.state
end

minetest.register_privilege("weather_manager", {
	description = S("Gives ability to control weather"),
	give_to_singleplayer = false
})

-- Weather command definition. Set 
minetest.register_chatcommand("weather", {
	params = "(clear | rain | snow | thunder) [<duration>]",
	description = S("Changes the weather to the specified parameter."),
	privs = {weather_manager = true},
	func = function(name, param)
		if (param == "") then
			return false, S("Error: No weather specified.")
		end
		local new_weather, end_time
		local parse1, parse2 = string.match(param, "(%w+) ?(%d*)")
		if parse1 then
			if parse1 == "clear" then
				new_weather = "none"
			else
				new_weather = parse1
			end
		else
			return false, S("Error: Invalid parameters.")
		end
		if parse2 then
			if type(tonumber(parse2)) == "number" then
				local duration = tonumber(parse2)
				if duration < 1 then
					return false, S("Error: Duration can't be less than 1 second.")
				end
				end_time = minetest.get_gametime() + duration
			end
		end

		local success = mcl_weather.change_weather(new_weather, end_time, name)
		if success then
			return true
		else
			return false, S("Error: Invalid weather specified. Use “clear”, “rain”, “snow” or “thunder”.")
		end
	end
})

minetest.register_chatcommand("toggledownfall", {
	params = "",
	description = S("Toggles between clear weather and weather with downfall (randomly rain, thunderstorm or snow)"),
	privs = {weather_manager = true},
	func = function(name, param)
		-- Currently rain/thunder/snow: Set weather to clear
		if mcl_weather.state ~= "none" then
			return mcl_weather.change_weather("none", nil, name)

		-- Currently clear: Set weather randomly to rain/thunder/snow
		else
			local new = { "rain", "thunder", "snow" }
			local r = math.random(1, #new)
			return mcl_weather.change_weather(new[r], nil, name)
		end
	end
})

-- Configuration setting which allows user to disable ABM for weathers (if they use it).
-- Weather mods expected to be use this flag before registering ABM.
local weather_allow_abm = minetest.settings:get_bool("weather_allow_abm")
if weather_allow_abm ~= nil and weather_allow_abm == false then
	mcl_weather.allow_abm = false
end 


local load_weather = function()
	local weather = storage:get_string("mcl_weather_state")
	if weather and weather ~= "" then
		mcl_weather.state = weather
		mcl_weather.end_time = storage:get_int("mcl_weather_end_time")
		mcl_weather.change_weather(weather, mcl_weather.end_time)
		if type(mcl_weather.end_time) ~= "number" then
			-- Fallback in case of corrupted end time
			mcl_weather.end_time = mcl_weather.min_duration
		end
		minetest.log("action", "[mcl_weather] Weather restored.")
	else
		minetest.log("action", "[mcl_weather] No weather data found. Starting with clear weather.")
	end
end

load_weather()
