-- turn off lightning mod 'auto mode'
lightning.auto = false

thunder = {
  next_strike = 0,
  min_delay = 3,
  max_delay = 12,
  init_done = false,
}

minetest.register_globalstep(function(dtime)
  if weather.state ~= "thunder" then 
    return false
  end
  
  rain.set_particles_mode("thunder")
  rain.make_weather()

  if thunder.init_done == false then
    skycolor.add_layer(
      "weather-pack-thunder-sky",
      {{r=0, g=0, b=0},
      {r=40, g=40, b=40},
      {r=85, g=86, b=86},
      {r=40, g=40, b=40},
      {r=0, g=0, b=0}})
    skycolor.active = true
    for _, player in pairs(minetest.get_connected_players()) do
      player:set_clouds({color="#3D3D3FE8"})

    end
    thunder.init_done = true
  end
  
  if (thunder.next_strike <= minetest.get_gametime()) then
    lightning.strike()
    local delay = math.random(thunder.min_delay, thunder.max_delay)
    thunder.next_strike = minetest.get_gametime() + delay
  end

end)

thunder.clear = function()
  rain.clear()
  skycolor.remove_layer("weather-pack-thunder-sky")
  skycolor.remove_layer("lightning")
  thunder.init_done = false
end

-- register thunderstorm weather
if weather.reg_weathers.thunder == nil then
  weather.reg_weathers.thunder = {
    chance = 5,
    light_factor = 0.33333,
    clear = thunder.clear,
    min_duration = 120,
    max_duration = 600,
  }
end
