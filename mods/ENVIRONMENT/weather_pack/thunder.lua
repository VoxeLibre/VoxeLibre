-- turn off lightning mod 'auto mode'
lightning.auto = false

thunder = {
  next_strike = 0,
  min_delay = 3,
  max_delay = 12,
}

minetest.register_globalstep(function(dtime)
  if weather.state ~= "thunder" then 
    return false
  end
  
  rain.make_weather()
  
  if (thunder.next_strike <= os.time()) then
    lightning.strike()
    local delay = math.random(thunder.min_delay, thunder.max_delay)
    thunder.next_strike = os.time() + delay
  end

end)

thunder.clear = function()
  rain.clear()
end

-- register thunderstorm weather
if weather.reg_weathers.thunder == nil then
  weather.reg_weathers.thunder = {
    chance = 5,
    clear = thunder.clear,
    min_duration = 120,
    max_duration = 600,
  }
end