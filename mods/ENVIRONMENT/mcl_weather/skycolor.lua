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

	-- Enables smooth transition between existing sky color and target.
	smooth_transitions = true,

	-- Transition between current sky color and new user given.
	transition_in_progress = false,

	-- Transition colors are generated automaticly during initialization.
	transition_colors = {},

	-- Time where transition between current color and user given will be done
	transition_time = 15,

	-- Tracks how much time passed during transition
	transition_timer = 0,

	-- Table for tracking layer order
	layer_names = {},

	-- To layer to colors table
	add_layer = function(layer_name, layer_color, instant_update)
		mcl_weather.skycolor.colors[layer_name] = layer_color
		table.insert(mcl_weather.skycolor.layer_names, layer_name)
		if (instant_update ~= true) then
			mcl_weather.skycolor.init_transition()
		end
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
		for k, name in ipairs(mcl_weather.skycolor.layer_names) do
			if name == layer_name then
				table.remove(mcl_weather.skycolor.layer_names, k)
				mcl_weather.skycolor.force_update = true
				return
			end
		end
	end,

	-- Update sky color. If players not specified update sky for all players.
	update_sky_color = function(players)
		local color = mcl_weather.skycolor.current_sky_layer_color()
		if (color == nil) then
			mcl_weather.skycolor.set_default_sky()
			return
		end

		-- Override day/night ratio as well
		players = mcl_weather.skycolor.utils.get_players(players)
		for _, player in ipairs(players) do
			local pos = player:get_pos()
			local _, dim = mcl_util.y_to_layer(pos.y)
			if dim == "overworld" then
				player:set_sky(color, "plain", nil, true)

				local lf = mcl_weather.get_current_light_factor()
				if mcl_weather.skycolor.current_layer_name() == "lightning" then
					player:override_day_night_ratio(1)
				elseif lf then
					local w = minetest.get_timeofday()
					local light = (w * (lf*2))
					if light > 1 then
						light = 1 - (light - 1)
					end

					light = (light * lf) + 0.15

					player:override_day_night_ratio(light)
				else
					player:override_day_night_ratio(nil)
				end
			end
			-- Other dimensions are handled in mcl_playerplus
		end
	end,

	-- Returns current layer color in {r, g, b} format
	current_sky_layer_color = function()
		if #mcl_weather.skycolor.layer_names == 0 then
			return nil
		end

		-- min timeofday value 0; max timeofday value 1. So sky color gradient range will be between 0 and 1 * mcl_weather.skycolor.max_val.
		local timeofday = minetest.get_timeofday()
		local rounded_time = math.floor(timeofday * mcl_weather.skycolor.max_val)
		local color = mcl_weather.skycolor.utils.convert_to_rgb(mcl_weather.skycolor.min_val, mcl_weather.skycolor.max_val, rounded_time, mcl_weather.skycolor.retrieve_layer())
		return color
	end,

	-- Initialy used only on 
	update_transition_sky_color = function()
		if #mcl_weather.skycolor.layer_names == 0 then
			mcl_weather.skycolor.set_default_sky()
			return
		end

		local multiplier = 100
		local rounded_time = math.floor(mcl_weather.skycolor.transition_timer * multiplier)
		if rounded_time >= mcl_weather.skycolor.transition_time * multiplier then
			mcl_weather.skycolor.stop_transition()
			return
		end

		local color = mcl_weather.skycolor.utils.convert_to_rgb(0, mcl_weather.skycolor.transition_time * multiplier, rounded_time, mcl_weather.skycolor.transition_colors)

		local players = mcl_weather.skycolor.utils.get_players(nil)
		for _, player in ipairs(players) do
			local pos = player:getpos()
			local _, dim = mcl_util.y_to_layer(pos.y)
			if dim == "overworld" then
				player:set_sky(color, "plain", nil, true)
			end
		end
	end,

	-- Reset sky color to game default. If players not specified update sky for all players.
	-- Could be sometimes useful but not recomended to use in general case as there may be other color layers
	-- which needs to preserve.
	set_default_sky = function(players)
		local players = mcl_weather.skycolor.utils.get_players(players)
		for _, player in ipairs(players) do
			local pos = player:getpos()
			local _, dim = mcl_util.y_to_layer(pos.y)
			if dim == "overworld" then
				player:set_sky(nil, "regular", nil, true)
				player:override_day_night_ratio(nil)
			end
		end
	end,

	init_transition = function()
		-- sadly default sky returns unpredictible colors so transition mode becomes usable only for user defined color layers
		-- Here '2' means that one color layer existed before new added and transition is posible.
		if #mcl_weather.skycolor.layer_names < 2 then
			return
		end

		local transition_start_color = mcl_weather.skycolor.utils.get_current_bg_color()
		if (transition_start_color == nil) then
			return
		end
		local transition_end_color = mcl_weather.skycolor.current_sky_layer_color()
		mcl_weather.skycolor.transition_colors = {transition_start_color, transition_end_color}
		mcl_weather.skycolor.transition_in_progress = true
	end,

	stop_transition = function()
		mcl_weather.skycolor.transition_in_progress = false
		mcl_weather.skycolor.transition_colors = {}
		mcl_weather.skycolor.transition_timer = 0
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
				players = minetest.get_connected_players()
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

	if mcl_weather.skycolor.smooth_transitions and mcl_weather.skycolor.transition_in_progress then
		mcl_weather.skycolor.transition_timer = mcl_weather.skycolor.transition_timer + dtime
		mcl_weather.skycolor.update_transition_sky_color()
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
	player:set_clouds({height=mcl_util.layer_to_y(127), speed={x=-2, y=0}, thickness=4, color="#FFF0FEF"})
end

minetest.register_on_joinplayer(initsky)
minetest.register_on_respawnplayer(initsky)
