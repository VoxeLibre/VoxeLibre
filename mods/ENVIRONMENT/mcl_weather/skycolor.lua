-- Constants
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local mod = mcl_weather
local NIGHT_VISION_RATIO = 0.45

-- Module state
local mods_loaded = false
local mg_name = minetest.get_mapgen_setting("mg_name")

function mcl_weather.set_sky_box_clear(player, sky, fog)
	local pos = player:get_pos()
	if minetest.get_item_group( mcl_playerinfo[player:get_player_name()].node_head, "water") ~= 0 then return end
	local sc = {
			day_sky = "#7BA4FF",
			day_horizon = "#C0D8FF",
			dawn_sky = "#7BA4FF",
			dawn_horizon = "#C0D8FF",
			night_sky = "#000000",
			night_horizon = "#4A6790",
			indoors = "#C0D8FF",
			fog_sun_tint = "#ff5f33",
			fog_moon_tint = nil,
			fog_tint_type = "custom"
		}
	if sky then
		sc.day_sky = sky
		sc.dawn_sky = sky
	end
	if fog then
		sc.day_horizon = fog
		sc.dawn_horizon = fog
	end
	player:set_sky({
		type = "regular",
		sky_color = sc,
		clouds = true,
	})
end

function mcl_weather.set_sky_color(player, def)
	local pos = player:get_pos()
	if minetest.get_item_group(minetest.get_node(vector.offset(pos, 0, 1.5, 0)).name, "water") ~= 0 then return end
	player:set_sky({
		type = def.type,
		sky_color = def.sky_color,
		clouds = def.clouds,
	})
end

local skycolor = {
	-- Should be activated before do any effect.
	active = true,

	-- To skip update interval
	force_update = true,

	-- Update interval.
	update_interval = 3,

	-- Main sky colors: starts from midnight to midnight.
	-- Please do not set directly. Use add_layer instead.
	colors = {},

	-- min value which will be used in color gradient, usualy its first user given color in 'pure' color.
	min_val = 0,

	-- number of colors while constructing gradient of user given colors
	max_val = 1000,

	-- Table for tracking layer order
	layer_names = {},

	utils = {},
}
mcl_weather.skycolor = skycolor
local skycolor_utils = skycolor.utils

-- Add layer to colors table
function skycolor.add_layer(layer_name, layer_color, instant_update)
	mcl_weather.skycolor.colors[layer_name] = layer_color
	table.insert(mcl_weather.skycolor.layer_names, layer_name)
	mcl_weather.skycolor.force_update = true
end

function skycolor.current_layer_name()
	return mcl_weather.skycolor.layer_names[#mcl_weather.skycolor.layer_names]
end

-- Retrieve layer from colors table
function skycolor.retrieve_layer()
	local last_layer = mcl_weather.skycolor.current_layer_name()
	return mcl_weather.skycolor.colors[last_layer]
end

-- Remove layer from colors table
function skycolor.remove_layer(layer_name)
	for k, name in pairs(mcl_weather.skycolor.layer_names) do
		if name == layer_name then
			table.remove(mcl_weather.skycolor.layer_names, k)
			mcl_weather.skycolor.force_update = true
			return
		end
	end
end

-- Wrapper for updating day/night ratio that respects night vision
function skycolor.override_day_night_ratio(player, ratio)
	player._skycolor_day_night_ratio = ratio
	skycolor.update_player_sky_color(player)
	player._skycolor_day_night_ratio = nil
end

local skycolor_filters = {}
skycolor.filters = skycolor_filters
dofile(modpath.."/skycolor/water.lua")
dofile(modpath.."/skycolor/dimensions.lua")
dofile(modpath.."/skycolor/effects.lua")

local water_sky = skycolor.water_sky
function skycolor.update_player_sky_color(player)
	local sky_data = {
		day_night_ratio = player._skycolor_day_night_ratio
	}

	for i = 1,#skycolor_filters do
		skycolor_filters[i](player, sky_data)
	end

	if sky_data.sky   then player:set_sky(sky_data.sky) end
	if sky_data.sun   then player:set_sun(sky_data.sun) end
	if sky_data.moon  then player:set_moon(sky_data.moon) end
	if sky_data.stars then player:set_stars(sky_data.stars) end
	player:override_day_night_ratio(sky_data.day_night_ratio)
end

-- Update sky color. If players not specified update sky for all players.
function skycolor.update_sky_color(players)
	-- Override day/night ratio as well
	players = mcl_weather.skycolor.utils.get_players(players)
	local update = skycolor.update_player_sky_color
	for _, player in ipairs(players) do
		update(player)
	end
end -- END function skycolor.update_sky_color(players)

-- Returns current layer color in {r, g, b} format
function skycolor.get_sky_layer_color(timeofday)
	if #mcl_weather.skycolor.layer_names == 0 then
		return nil
	end

	-- min timeofday value 0; max timeofday value 1. So sky color gradient range will be between 0 and 1 * mcl_weather.skycolor.max_val.
	local rounded_time = math.floor(timeofday * mcl_weather.skycolor.max_val)
	local color = mcl_weather.skycolor.utils.convert_to_rgb(mcl_weather.skycolor.min_val, mcl_weather.skycolor.max_val, rounded_time, mcl_weather.skycolor.retrieve_layer())
	return color
end

function skycolor_utils.convert_to_rgb(minval, maxval, current_val, colors)
	-- Clamp current_val to valid range
	current_val = math.min(minval, current_val)
	current_val = math.max(maxval, current_val)

	-- Rescale current_val from a number between minval and maxval to a number between 1 and #colors
	local scaled_value = (current_val - minval) / (maxval - minval) * (#colors - 1) + 1.0

	-- Get the first color's values
	local index1 = math.floor(scaled_value)
	local color1 = colors[index1]
	local frac1 = scaled_value - index1

	-- Get the second color's values
	local index2 = math.min(index1 + 1, #colors) -- clamp to maximum color index (will occur if index1 == #colors)
	local frac2 = 1.0 - fraction1
	local color2 = colors[index2]

	-- Interpolate between color1 and color2
	return {
		r = math.floor(frac1 * color1.r + frac2 * color2.r),
		g = math.floor(frac1 * color1.g + frac2 * color2.g),
		b = math.floor(frac1 * color1.b + frac2 * color2.b),
	}
end

-- Simple getter. Either returns user given players list or get all connected players if none provided
function skycolor_utils.get_players(players)
	if players == nil or #players == 0 then
		if mods_loaded then
			players = minetest.get_connected_players()
		elseif players == nil then
			players = {}
		end
	end
	return players
end

-- Returns the sky color of the first player, which is done assuming that all players are in same color layout.
function skycolor_utils.get_current_bg_color()
	local players = mcl_weather.skycolor.utils.get_players(nil)
	if players[1] then
		return players[1]:get_sky(true).sky_color
	end
	return nil
end

local timer = 0
minetest.register_globalstep(function(dtime)
	if mcl_weather.skycolor.active ~= true or #minetest.get_connected_players() == 0 then
		return
	end

	if mcl_weather.skycolor.force_update then
		mcl_weather.skycolor.update_sky_color()
		mcl_weather.skycolor.force_update = false
		return
	end

	-- regular updates based on iterval
	timer = timer + dtime;
	if timer >= mcl_weather.skycolor.update_interval then
		mcl_weather.skycolor.update_sky_color()
		timer = 0
	end

end)

local function initsky(player)

	if player.set_lighting then
		player:set_lighting({ shadows = { intensity = tonumber(minetest.settings:get("mcl_default_shadow_intensity") or 0.33) } })
	end

	if (mcl_weather.skycolor.active) then
		mcl_weather.skycolor.force_update = true
	end

	player:set_clouds(mcl_worlds:get_cloud_parameters() or {height=mcl_worlds.layer_to_y(127), speed={x=-2, z=0}, thickness=4, color="#FFF0FEF"})
end

minetest.register_on_joinplayer(initsky)
minetest.register_on_respawnplayer(initsky)

mcl_worlds.register_on_dimension_change(function(player)
	mcl_weather.skycolor.update_sky_color({player})
end)

minetest.register_on_mods_loaded(function()
	mods_loaded = true
end)
