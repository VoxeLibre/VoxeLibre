mcl_weather = {
  -- weather states, 'none' is default, other states depends from active mods
  state = "none",
  
  -- player list for saving player meta info
  players = {},
  
  -- default weather recalculation interval
  check_interval = 300,
  
  -- weather min duration
  min_duration = 600,
  
  -- weather max duration
  max_duration = 9000,
  
  -- weather calculated end time
  end_time = nil,
  
  -- registered weathers
  reg_weathers = {},

  -- automaticly calculates intervals and swap weathers 
  auto_mode = true,
  
  -- global flag to disable/enable ABM logic. 
  allow_abm = true,
}

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

mcl_weather.get_rand_end_time = function(min_duration, max_duration)
  local r
  if min_duration ~= nil and max_duration ~= nil then
    r = math.random(min_duration, max_duration);
  else
    r = math.random(mcl_weather.min_duration, mcl_weather.max_duration);
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
    local ppos = player:getpos()
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
  local player_pos = player:getpos()

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

  random_pos_y = math.random() + math.random(player_pos.y + 1, player_pos.y + 3)
  return random_pos_x, random_pos_y, random_pos_z
end

minetest.register_globalstep(function(dtime)
  if mcl_weather.auto_mode == false then
    return 0
  end

  if mcl_weather.end_time == nil then
    mcl_weather.end_time = mcl_weather.get_rand_end_time()
  end
  -- recalculate weather
  if mcl_weather.end_time <= minetest.get_gametime() then
    mcl_weather.set_random_weather(mcl_weather.state, mcl_weather.reg_weathers[mcl_weather.state])
  end
end)

-- Sets random weather (which could be 'none' (no weather)).
mcl_weather.set_random_weather = function(weather_name, weather_meta)
  if (weather_meta ~= nil) then
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
end

mcl_weather.change_weather = function(new_weather)
  if (mcl_weather.reg_weathers ~= nil and mcl_weather.reg_weathers[new_weather] ~= nil) then
    if (mcl_weather.state ~= nil and mcl_weather.reg_weathers[mcl_weather.state] ~= nil) then
      mcl_weather.reg_weathers[mcl_weather.state].clear()
    end
    mcl_weather.state = new_weather
    local weather_meta = mcl_weather.reg_weathers[mcl_weather.state]
    mcl_weather.end_time = mcl_weather.get_rand_end_time(weather_meta.min_duration, weather_meta.max_duration)
    mcl_weather.skycolor.update_sky_color()
    return true
  end
  return false
end

mcl_weather.get_weather = function()
  return mcl_weather.state
end

minetest.register_privilege("weather_manager", {
  description = "Gives ability to control weather",
  give_to_singleplayer = false
})

-- Weather command definition. Set 
minetest.register_chatcommand("weather", {
  params = "clear | rain | snow | thunder",
  description = "Changes the weather to the specified parameter.",
  privs = {weather_manager = true},
  func = function(name, param)
    if (param == "") then
      return false, "Error: No weather specified."
    end
    local new_weather
    if param == "clear" then
        new_weather = "none"
    else
        new_weather = param
    end
    local success = mcl_weather.change_weather(new_weather)
    if success then
      return true
    else
      return false, "Error: Invalid weather specified. Use “clear”, “rain”, “snow” or “thunder”."
    end
  end
})

minetest.register_chatcommand("toggledownfall", {
  params = "",
  description = "Toggles between clear weather and weather with downfall (randomly rain, thunderstorm or snow)",
  privs = {weather_manager = true},
  func = function(name, param)
    -- Currently rain/thunder/snow: Set weather to clear
    if mcl_weather.state ~= "none" then
       return mcl_weather.change_weather("none")

    -- Currently clear: Set weather randomly to rain/thunder/snow
    else
       local new = { "rain", "thunder", "snow" }
       local r = math.random(1, #new)
       return mcl_weather.change_weather(new[r])
    end
  end
})

-- Configuration setting which allows user to disable ABM for weathers (if they use it).
-- Weather mods expected to be use this flag before registering ABM.
local weather_allow_abm = minetest.settings:get_bool("weather_allow_abm")
if weather_allow_abm ~= nil and weather_allow_abm == false then
  mcl_weather.allow_abm = false
end 
