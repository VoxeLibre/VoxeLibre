local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local pianowtune = "diminixed-pianowtune01"

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
	local spec = {
		name  = pianowtune,
		gain  = 0.3,
		pitch = 1.0,
	}
	local new_weather_state = mcl_weather.get_weather()
	local was_good_weather = weather_state == "none" or weather_state == "clear"
	weather_state = new_weather_state
	local is_good_weather = weather_state == "none" or weather_state == "clear"
	local is_weather_changed = weather_state ~= new_weather_state
	if is_weather_changed or not is_good_weather then
		stop()
		minetest.after(20, play)
		return
	end
	local time = minetest.get_timeofday()
	if time < 0.25 or time >= 0.75 then
		stop()
		minetest.after(10, play)
		return
	end
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local hp          = player:get_hp()
		local pos         = player:get_pos()
		local listener    = listeners[player_name]
		local old_hp      = listener and listener.hp
		local dimension   = mcl_worlds.pos_to_dimension(pos)
		local is_hp_changed = old_hp and math.abs(old_hp - hp) > 0.00001
		local handle = listener and listener.handle
		if is_hp_changed then
			stop_music_for_listener_name(player_name)
			listeners[player_name].hp = hp
		elseif dimension ~= "overworld" then
			stop_music_for_listener_name(player_name)
		elseif not handle then
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

