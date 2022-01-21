local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local pianowtune  = "diminixed-pianowtune01"
local end_tune    = "diminixed-ambientwip"
local nether_tune = "horizonchris96-traitor"

local dimension_to_base_track = {
	["overworld"] = pianowtune,
	["nether"]    = nether_tune,
	["end"]       = end_tune,
}

local listeners = {}

local weather_state

local function stop_music_for_listener_name(listener_name)
	if not listener_name then return end
	local listener = listeners[listener_name]
	if not listener then return end
	local handle = listener.handle
	if not handle then return end
	minetest.sound_stop(handle)
	listeners[listener_name].handle = nil
end

local function stop()
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		stop_music_for_listener_name(player_name)
	end
end

local function play()
	local new_weather_state = mcl_weather.get_weather()
	local was_good_weather = weather_state == "none" or weather_state == "clear"
	weather_state = new_weather_state
	local is_good_weather = weather_state == "none" or weather_state == "clear"
	local is_weather_changed = weather_state ~= new_weather_state
	local time = minetest.get_timeofday()
	if time < 0.25 or time >= 0.75 then
		stop()
		minetest.after(10, play)
		return
	end
	local day_count = minetest.get_day_count()
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local hp          = player:get_hp()
		local pos         = player:get_pos()
		local dimension   = mcl_worlds.pos_to_dimension(pos)

		local listener      = listeners[player_name]
		local old_hp        = listener and listener.hp
		local old_dimension = listener and listener.dimension

		local is_dimension_changed = old_dimension and (old_dimension ~= dimension) or false
		local is_hp_changed = old_hp and (math.abs(old_hp - hp) > 0.00001) or false
		local handle = listener and listener.handle

		local track = dimension_to_base_track[dimension]

		if is_hp_changed
			or is_dimension_changed
			or (dimension == "overworld" and (is_weather_changed or not is_good_weather))
			or not track
			or (listener and (listener.day_count == day_count))
			then
			minetest.chat_send_all("here! dc = "..tostring(is_dimension_changed))
			stop_music_for_listener_name(player_name)
			if not listeners[player_name] then
				listeners[player_name] = {}
			end
			listeners[player_name].hp = hp
			listeners[player_name].dimension = dimension
		elseif not handle then
			local spec = {
				name  = track,
				gain  = 0.3,
				pitch = 1.0,
			}
			local parameters = {
				to_player = player_name,
				gain      = 1.0,
				fade      = 0.0,
				pitch     = 1.0,
			}

			handle = minetest.sound_play(spec, parameters, false)
			listeners[player_name] = {
				spec       = spec,
				parameters = parameters,
				handle     = handle,
				hp         = hp,
				dimension  = dimension,
				day_count  = day_count,
			}
		end
	end

	minetest.after(7, play)
end

minetest.after(15, play)

minetest.register_on_joinplayer(function(player, last_login)
	local player_name = player:get_player_name()
	stop_music_for_listener_name(player_name)
end)

minetest.register_on_respawnplayer(function(player)
	local player_name = player:get_player_name()
	stop_music_for_listener_name(player_name)
end)

