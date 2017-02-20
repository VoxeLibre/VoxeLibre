weather = {
  -- weather states, 'none' is default, other states depends from active mods
  state = "none",
  
  -- player list for saving player meta info
  players = {},
  
  -- time when weather should be re-calculated
  next_check = 0,
  
  -- default weather recalculation interval
  check_interval = 300,
  
  -- weather min duration
  min_duration = 240,
  
  -- weather max duration
  max_duration = 3600,
  
  -- weather calculated end time
  end_time = nil,
  
  -- registered weathers
  reg_weathers = {},

  -- automaticly calculates intervals and swap weathers 
  auto_mode = true,
  
  -- global flag to disable/enable ABM logic. 
  allow_abm = true,
}

weather.get_rand_end_time = function(min_duration, max_duration)
  if min_duration ~= nil and max_duration ~= nil then
    return os.time() + math.random(min_duration, max_duration);
  else
    return os.time() + math.random(weather.min_duration, weather.max_duration);
  end 
end

weather.is_outdoor = function(pos)
  if minetest.get_node_light({x=pos.x, y=pos.y + 1, z=pos.z}, 0.5) == 15 then
    return true
  end
  return false
end

-- checks if player is undewater. This is needed in order to
-- turn off weather particles generation.
weather.is_underwater = function(player)
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
weather.get_random_pos_by_player_look_dir = function(player)
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
  if weather.auto_mode == false then
    return 0
  end

  -- recalculate weather only when there aren't currently any
  if (weather.state ~= "none") then
    if (weather.end_time ~= nil and weather.end_time <= os.time()) then
      weather.reg_weathers[weather.state].clear()
      weather.state = "none"
    end
  elseif (weather.next_check <= os.time()) then
    for weather_name, weather_meta in pairs(weather.reg_weathers) do 
      weather.set_random_weather(weather_name, weather_meta)
    end
    -- fallback next_check set, weather 'none' will be. 
    weather.next_check = os.time() + weather.check_interval
  end
end)

-- sets random weather (which could be 'regular' (no weather)).
weather.set_random_weather = function(weather_name, weather_meta)
  if weather.next_check > os.time() then return 0 end

  if (weather_meta ~= nil and weather_meta.chance ~= nil) then
    local random_roll = math.random(0,100)
    if (random_roll <= weather_meta.chance) then
      weather.state = weather_name
      weather.end_time = weather.get_rand_end_time(weather_meta.min_duration, weather_meta.max_duration)
      weather.next_check = os.time() + weather.check_interval
    end
  end
end

minetest.register_privilege("weather_manager", {
  description = "Gives ability to control weather",
  give_to_singleplayer = false
})

-- Weather command definition. Set 
minetest.register_chatcommand("set_weather", {
  params = "<weather>",
  description = "Changes weather by given param, parameter none will remove weather.",
  privs = {weather_manager = true},
  func = function(name, param)
    if (param == "none") then
      if (weather.state ~= nil and weather.reg_weathers[weather.state] ~= nil) then
        weather.reg_weathers[weather.state].clear()
        weather.state = param
      end
      weather.state = "none"
    end
  
    if (weather.reg_weathers ~= nil and weather.reg_weathers[param] ~= nil) then
      if (weather.state ~= nil and weather.state ~= "none" and weather.reg_weathers[weather.state] ~= nil) then
        weather.reg_weathers[weather.state].clear()
      end
      weather.state = param
    end
  end
})

-- Configuration setting which allows user to disable ABM for weathers (if they use it).
-- Weather mods expected to be use this flag before registering ABM.
local weather_allow_abm = minetest.setting_getbool("weather_allow_abm")
if weather_allow_abm ~= nil and weather_allow_abm == false then
  weather.allow_abm = false
end 

-- Overrides nodes 'sunlight_propagates' attribute for efficient indoor check (e.g. for glass roof).
-- Controlled from minetest.conf setting and by default it is disabled.
-- To enable set weather_allow_override_nodes to true. 
-- Only new nodes will be effected (glass roof needs to be rebuilded).
if minetest.setting_getbool("weather_allow_override_nodes") then
  if minetest.registered_nodes["default:glass"] then
    minetest.override_item("default:glass", {sunlight_propagates = false})
  end
  if minetest.registered_nodes["default:meselamp"] then
    minetest.override_item("default:meselamp", {sunlight_propagates = false})
  end
end