skycolor = {
	-- Should be activated before do any effect.
	active = false,

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
		skycolor.colors[layer_name] = layer_color
		table.insert(skycolor.layer_names, layer_name)
		if (instant_update ~= true) then
			skycolor.init_transition()
		end
		skycolor.force_update = true
	end,

	-- Retrieve layer from colors table
	retrieve_layer = function()
		local last_layer = skycolor.layer_names[#skycolor.layer_names]
		return skycolor.colors[last_layer]
	end,

	-- Remove layer from colors table
	remove_layer = function(layer_name)
		for k, name in ipairs(skycolor.layer_names) do
			if name == layer_name then
				table.remove(skycolor.layer_names, k)
				skycolor.force_update = true
				return
			end
		end
	end,

	-- Update sky color. If players not specified update sky for all players.
	update_sky_color = function(players)
		local color = skycolor.current_sky_layer_color()
		if (color == nil) then
			skycolor.active = false
			skycolor.set_default_sky()
			return
		end

		players = skycolor.utils.get_players(players)
		for _, player in ipairs(players) do
			player:set_sky(color, "plain", nil)
		end
	end,

	-- Returns current layer color in {r, g, b} format
	current_sky_layer_color = function()
		if #skycolor.layer_names == 0 then
			return nil
		end

		-- min timeofday value 0; max timeofday value 1. So sky color gradient range will be between 0 and 1 * skycolor.max_value.
		local timeofday = minetest.get_timeofday()
		local rounded_time = math.floor(timeofday * skycolor.max_val)
		local color = skycolor.utils.convert_to_rgb(skycolor.min_val, skycolor.max_val, rounded_time, skycolor.retrieve_layer())
		return color
	end,

	-- Initialy used only on 
	update_transition_sky_color = function()
		if #skycolor.layer_names == 0 then
			skycolor.active = false
			skycolor.set_default_sky()
			return
		end

		local multiplier = 100
		local rounded_time = math.floor(skycolor.transition_timer * multiplier)
		if rounded_time >= skycolor.transition_time * multiplier then
			skycolor.stop_transition()
			return
		end

		local color = skycolor.utils.convert_to_rgb(0, skycolor.transition_time * multiplier, rounded_time, skycolor.transition_colors)

		local players = skycolor.utils.get_players(nil)
		for _, player in ipairs(players) do
			player:set_sky(color, "plain", nil)
		end
	end,

	-- Reset sky color to game default. If players not specified update sky for all players.
	-- Could be sometimes useful but not recomended to use in general case as there may be other color layers
	-- which needs to preserve.
	set_default_sky = function(players)
		local players = skycolor.utils.get_players(players)
		for _, player in ipairs(players) do
			player:set_sky(nil, "regular", nil)
		end
	end,

	init_transition = function()
		-- sadly default sky returns unpredictible colors so transition mode becomes usable only for user defined color layers
		-- Here '2' means that one color layer existed before new added and transition is posible.
		if #skycolor.layer_names < 2 then
			return
		end

		local transition_start_color = skycolor.utils.get_current_bg_color()
		if (transition_start_color == nil) then
			return
		end
		local transition_end_color = skycolor.current_sky_layer_color()
		skycolor.transition_colors = {transition_start_color, transition_end_color}
		skycolor.transition_in_progress = true
	end,

	stop_transition = function()
		skycolor.transition_in_progress = false
		skycolor.transition_colors = {}
		skycolor.transition_timer = 0
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
			local players = skycolor.utils.get_players(nil)
			for _, player in ipairs(players) do
				return player:get_sky()
			end	
			return nil
		end
	},

}

local timer = 0
minetest.register_globalstep(function(dtime)
	if skycolor.active ~= true or #minetest.get_connected_players() == 0 then
		return
	end

	if skycolor.smooth_transitions and skycolor.transition_in_progress then
		skycolor.transition_timer = skycolor.transition_timer + dtime
		skycolor.update_transition_sky_color()
		return
	end

	if skycolor.force_update then
		skycolor.update_sky_color()
		skycolor.force_update = false
		return
	end

	-- regular updates based on iterval
	timer = timer + dtime;
	if timer >= skycolor.update_interval then
		skycolor.update_sky_color()
		timer = 0
	end

end)

minetest.register_on_joinplayer(function(player)
	if (skycolor.active) then
		skycolor.update_sky_color({player})
	end
end)