local mods_loaded = false
local NIGHT_VISION_RATIO = 0.45

mcl_weather.skycolor = {
	-- Should be activated before do any effect.
	active = true,

	-- To skip update interval
	force_update = true,

	-- Update interval.
	update_interval = 15,

	-- Main sky colors: starts from midnight to midnight. 
	-- Please do not set directly. Use add_layer instead.
	colors = {},

	-- min value which will be used in color gradient, usualy its first user given color in 'pure' color.
	min_val = 0,

	-- number of colors while constructing gradient of user given colors
	max_val = 1000,

	-- Table for tracking layer order
	layer_names = {},

	-- To layer to colors table
	add_layer = function(layer_name, layer_color, instant_update)
		mcl_weather.skycolor.colors[layer_name] = layer_color
		table.insert(mcl_weather.skycolor.layer_names, layer_name)
		mcl_weather.skycolor.force_update = true
	end,

	current_layer_name = function()
		return mcl_weather.skycolor.layer_names[#mcl_weather.skycolor.layer_names]
	end,

	-- Retrieve layer from colors table
	retrieve_layer = function()
		local last_layer = mcl_weather.skycolor.current_layer_name()
		return mcl_weather.skycolor.colors[last_layer]
	end,

	-- Remove layer from colors table
	remove_layer = function(layer_name)
		for k, name in pairs(mcl_weather.skycolor.layer_names) do
			if name == layer_name then
				table.remove(mcl_weather.skycolor.layer_names, k)
				mcl_weather.skycolor.force_update = true
				return
			end
		end
	end,

	-- Wrapper for updating day/night ratio that respects night vision
	override_day_night_ratio = function(player, ratio)
		local meta = player:get_meta()
		local has_night_vision = meta:get_int("night_vision") == 1
		local arg
		-- Apply night vision only for dark sky
		local is_dark = minetest.get_timeofday() > 0.8 or minetest.get_timeofday() < 0.2 or mcl_weather.state ~= "none"
		local pos = player:get_pos()
		local dim = mcl_worlds.pos_to_dimension(pos)
		if has_night_vision and is_dark and dim ~= "nether" and dim ~= "end" then
			if ratio == nil then
				arg = NIGHT_VISION_RATIO
			else
				arg = math.max(ratio, NIGHT_VISION_RATIO)
			end
		else
			arg = ratio
		end
		player:override_day_night_ratio(arg)
	end,

	-- Update sky color. If players not specified update sky for all players.
	update_sky_color = function(players)
		-- Override day/night ratio as well
		players = mcl_weather.skycolor.utils.get_players(players)
		for _, player in ipairs(players) do
			local pos = player:get_pos()
			local dim = mcl_worlds.pos_to_dimension(pos)
			if dim == "overworld" then
				if (mcl_weather.state == "none") then
					-- Clear weather
					player:set_sky({
						type = "regular",
						sky_color = {
							day_sky = "#92B9FF",
							day_horizon = "#B4D0FF",
							dawn_sky = "#B4BAFA",
							dawn_horizon = "#BAC1F0",
							night_sky = "#006AFF",
							night_horizon = "#4090FF",
						},
						clouds = true,
					})
					player:set_sun({visible = true, sunrise_visible = true})
					player:set_moon({visible = true})
					player:set_stars({visible = true})
					mcl_weather.skycolor.override_day_night_ratio(player, nil)
				else
					-- Weather skies
					local day_color = mcl_weather.skycolor.get_sky_layer_color(0.5)
					local dawn_color = mcl_weather.skycolor.get_sky_layer_color(0.75)
					local night_color = mcl_weather.skycolor.get_sky_layer_color(0)
					player:set_sky({ type = "regular",
						sky_color = {
							day_sky = day_color,
							day_horizon = day_color,
							dawn_sky = dawn_color,
							dawn_horizon = dawn_color,
							night_sky = night_color,
							night_horizon = night_color,
						},
						clouds = true,
					})
					player:set_sun({visible = false, sunrise_visible = false})
					player:set_moon({visible = false})
					player:set_stars({visible = false})

					local lf = mcl_weather.get_current_light_factor()
					if mcl_weather.skycolor.current_layer_name() == "lightning" then
						mcl_weather.skycolor.override_day_night_ratio(player, 1)
					elseif lf then
						local w = minetest.get_timeofday()
						local light = (w * (lf*2))
						if light > 1 then
							light = 1 - (light - 1)
						end
						light = (light * lf) + 0.15
						mcl_weather.skycolor.override_day_night_ratio(player, light)
					else
						mcl_weather.skycolor.override_day_night_ratio(player, nil)
					end
				end
			elseif dim == "end" then
				local t = "mcl_playerplus_end_sky.png"
				player:set_sky({ type = "skybox",
					base_color = "#000000",
					textures = {t,t,t,t,t,t},
					clouds = false,
				})
				player:set_sun({visible = false , sunrise_visible = false})
				player:set_moon({visible = false})
				player:set_stars({visible = false})
				mcl_weather.skycolor.override_day_night_ratio(player, 0.5)
			elseif dim == "nether" then
				player:set_sky({ type = "plain",
					base_color = "#300808",
					clouds = false,
				})
				player:set_sun({visible = false , sunrise_visible = false})
				player:set_moon({visible = false})
				player:set_stars({visible = false})
				mcl_weather.skycolor.override_day_night_ratio(player, nil)
			elseif dim == "void" then
				player:set_sky({ type = "plain",
					base_color = "#000000",
					clouds = false,
				})
				player:set_sun({visible = false, sunrise_visible = false})
				player:set_moon({visible = false})
				player:set_stars({visible = false})
			end
		end
	end,

	-- Returns current layer color in {r, g, b} format
	get_sky_layer_color = function(timeofday)
		if #mcl_weather.skycolor.layer_names == 0 then
			return nil
		end

		-- min timeofday value 0; max timeofday value 1. So sky color gradient range will be between 0 and 1 * mcl_weather.skycolor.max_val.
		local rounded_time = math.floor(timeofday * mcl_weather.skycolor.max_val)
		local color = mcl_weather.skycolor.utils.convert_to_rgb(mcl_weather.skycolor.min_val, mcl_weather.skycolor.max_val, rounded_time, mcl_weather.skycolor.retrieve_layer())
		return color
	end,

	utils = {
		convert_to_rgb = function(minval, maxval, current_val, colors)
			local max_index = #colors - 1
			local val = (current_val-minval) / (maxval-minval) * max_index + 1.0
			local index1 = math.floor(val)
			local index2 = math.min(math.floor(val)+1, max_index + 1)
			local f = val - index1
			local c1 = colors[index1]
			local c2 = colors[index2]
			return {r=math.floor(c1.r + f*(c2.r - c1.r)), g=math.floor(c1.g + f*(c2.g-c1.g)), b=math.floor(c1.b + f*(c2.b - c1.b))}
		end,

		-- Simply getter. Ether returns user given players list or get all connected players if none provided
		get_players = function(players)
			if players == nil or #players == 0 then
				if mods_loaded then
					players = minetest.get_connected_players()
				elseif players == nil then
					players = {}
				end
			end
			return players
		end,

		-- Returns first player sky color. I assume that all players are in same color layout.
		get_current_bg_color = function()
			local players = mcl_weather.skycolor.utils.get_players(nil)
			for _, player in ipairs(players) do
				return player:get_sky()
			end
			return nil
		end
	},

}

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

local initsky = function(player)
	if (mcl_weather.skycolor.active) then
		mcl_weather.skycolor.force_update = true
	end

	-- MC-style clouds: Layer 127, thickness 4, fly to the “West”
	player:set_clouds({height=mcl_worlds.layer_to_y(127), speed={x=-2, z=0}, thickness=4, color="#FFF0FEF"})
end

minetest.register_on_joinplayer(initsky)
minetest.register_on_respawnplayer(initsky)

mcl_worlds.register_on_dimension_change(function(player)
	mcl_weather.skycolor.update_sky_color({player})
end)

minetest.register_on_mods_loaded(function()
	mods_loaded = true
end)
