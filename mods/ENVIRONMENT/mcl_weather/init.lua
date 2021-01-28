local modpath = minetest.get_modpath("mcl_weather")

mcl_weather = {}

-- If not located then embeded skycolor mod version will be loaded.
if minetest.get_modpath("skycolor") == nil then
	dofile(modpath.."/skycolor.lua")
end

dofile(modpath.."/weather_core.lua")
dofile(modpath.."/snow.lua")
dofile(modpath.."/rain.lua")
dofile(modpath.."/nether_dust.lua")

if minetest.get_modpath("lightning") ~= nil then
	dofile(modpath.."/thunder.lua")
end
