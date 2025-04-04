local modpath = minetest.get_modpath(minetest.get_current_modname())

mcl_weather = {}

-- If not located then embeded skycolor mod version will be loaded.
if minetest.get_modpath("skycolor") == nil then
	dofile(modpath.."/skycolor.lua")
end

dofile(modpath.."/weather_core.lua")
dofile(modpath.."/snow.lua")
dofile(modpath.."/rain.lua")
dofile(modpath.."/nether_dust.lua")

core.register_globalstep(function(dtime)
	local weather = mcl_weather[mcl_weather.state]
	if not (weather and weather.step) then return end

	weather.step(dtime)
end)

if minetest.get_modpath("lightning") then
	dofile(modpath.."/thunder.lua")
end
