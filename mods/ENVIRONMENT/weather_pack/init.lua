local modpath = minetest.get_modpath("weather_pack");
dofile(modpath.."/weather_core.lua")
dofile(modpath.."/snow.lua")
dofile(modpath.."/rain.lua")

if minetest.get_modpath("lightning") ~= nil then
  dofile(modpath.."/thunder.lua")
end

-- If not located then embeded skycolor mod version will be loaded.
if minetest.get_modpath("skycolor") == nil then
  dofile(modpath.."/skycolor.lua")
end
