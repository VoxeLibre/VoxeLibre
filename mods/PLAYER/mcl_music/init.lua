local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

local S = core.get_translator(modname)

local music_enabled = core.settings:get_bool("mcl_game_music", true)

local pianowtune  = "diminixed-pianowtune02"
local end_tune    = "diminixed-ambientwip02"
local never_grow_up = "diminixed-nevergrowup04"
local nether_tune = "DarkReaven-traitor"
local odd_block = "Jester-0dd-BL0ck"
local flock_of_one = "Jester-Flock-of-One"
local gift = "Jester-Gift"
local hailing_forest = "Jester-Hailing_Forest"
local lonely_blossom = "exhale_and_tim_unwin-lonely_blossom"
local valley_of_ghosts = "exhale_and_tim_unwin-valley_of_ghosts"
local farmer = "exhale_and_tim_unwin-farmer"
local wildhome = "Herowl-Home_in_the_Wilderness"
local memories = "DarkReaven-memories_from_bellow"
local maintheme = "DarkReaven-calmed_cube"
local alttheme = "DarkReaven-calmed_cube_in_space"
local cube_beat = "DarkReaven-cube_beat"
local cube_waltz = "DarkReaven-cube_waltz"
local cube_waltz2 = "DarkReaven-cube_waltz_2"
local genna = "DarkReaven-genna"
local kuru = "DarkReaven-kuru"
local magic_of_forest = "DarkReaven-magic_of_the_forest"
local nostalgic = "DarkReaven-nostalgic_block"
local slow_in_cubic = "DarkReaven-slow_in_cubic_mode"
local piano_cubico = "DarkReaven-slow_piano_cubico"
local starry_sky = "DarkReaven-starry_sky_at_winter"
local sweet_piano = "DarkReaven-sweet_piano_8bit"
local what_will_we = "DarkReaven-what_we_will_buid_next"
local nightfall_beat = "DarkReaven-beat_at_nightfall"
local deep_mining = "DarkReaven-deep_mining"
local watchful = "DarkReaven-watchful"

local scenario_to_base_track = {
	["overworld"]	= {
		pianowtune, never_grow_up, flock_of_one, gift, hailing_forest,
		lonely_blossom, farmer, wildhome, maintheme, alttheme, cube_beat,
		cube_waltz, cube_waltz2, genna, kuru, magic_of_forest, nostalgic,
		slow_in_cubic, piano_cubico, starry_sky, sweet_piano, what_will_we
	},
	["nether"]	= {nether_tune, valley_of_ghosts, memories},
	["end"]		= {end_tune},
	["mining"]	= {odd_block, nightfall_beat, deep_mining, watchful},
}

local min_scenario_change_music_time = 5 * 60 -- Seconds

local listeners = {}

local function pick_track(scenario)
	local scenario_tracks = scenario_to_base_track[scenario]

	if scenario_tracks and #scenario_tracks >= 1 then
		local index = 1
		if #scenario_tracks > 1 then
			index = math.random(1, #scenario_tracks)
		end

		local chosen_track = scenario_tracks[index]
		core.log("action", "[mcl_music] Playing track: " .. chosen_track .. ", for scenario: " .. scenario)

		return chosen_track
	else
		core.log("warning", "[mcl_music] No tracks found for this scenario!")
	end

	return nil
end

local function stop_music_for_listener(player_name)

	if not listeners or not listeners[player_name] then return end
	local handle = listeners[player_name].handle

	if handle then
		core.log(dump(handle))
		core.log("action", "[mcl_music] Stopping music")
		core.sound_fade(handle, .25, 0)
		listeners[player_name].handle = nil
	end
end

local function stop_music_for_all()
	for _, player in pairs(core.get_connected_players()) do
		local player_name = player:get_player_name()
		stop_music_for_listener_name(player_name)
	end
end

local function initialize_listener(player_name)
	listeners[player_name] = {
		handle    = nil,
		scenario  = nil,
		sc_time   = -1,
		day_count = -1,
	}
end

local function remove_listener(player_name)
	listeners[player_name] = nil
end

local function play_song(player_name, track)
	local spec = {
		name  = track,
		gain  = 30,
		pitch = 1.0,
	}
	local parameters = {
		to_player = player_name,
		gain      = 1.0,
		fade      = 0.0,
		pitch     = 1.0,
	}

	if not listeners or not listeners[player_name] then return end
	listeners[player_name].handle = core.sound_play(spec, parameters, false)
	core.log(dump(listeners[player_name].handle))
end

function vl_play_song(player_name, track)
	stop_music_for_listener(player_name)
	play_song(player_name, track)
end

local function play()
	local time = core.get_timeofday()
	local day_count = core.get_day_count()

	for _, player in pairs(core.get_connected_players()) do
		core.log(player:get_player_name())
		repeat
		if not player:get_meta():get("mcl_music:disable") then

			local player_name = player:get_player_name()
			local pos         = player:get_pos()
			local dimension   = mcl_worlds.pos_to_dimension(pos)

			-- Find current scenario
			local scenario = dimension
			if (dimension == "overworld") then

				-- Underground
				if (pos and pos.y < 0) then
					scenario = "mining"
				-- Night time
				elseif time < 0.25 or time >= 0.75 then
					stop_music_for_listener(player_name)
					break
				end
			end

			local listener = listeners[player_name]

			-- Scenario changed
			if listener.scenario and scenario ~= listener.scenario then

				stop_music_for_listener(player_name)

				local sc_time = core.get_us_time() / 1e6 -- Microseconds to seconds

				-- Only play new music if scenario change was a little while ago
				if (sc_time - listener.sc_time) > min_scenario_change_music_time then
					local track = pick_track(scenario)
					if track then
						core.after(15, function(player_name, track)
							stop_music_for_listener(player_name) -- For when scenario change is repeated quickly
							play_song(player_name, track)
						end, player_name, track)
					end
					listeners[player_name].scenario = scenario
					listeners[player_name].sc_time  = sc_time
				end

			-- Scenario is the same, play music once a day
			elseif day_count ~= listener.day_count then

				listeners[player_name].scenario  = scenario -- To set scenario initially

				stop_music_for_listener(player_name)

				local track = pick_track(scenario)
				if track then
					core.after(15, function(player_name, track)
						stop_music_for_listener(player_name) -- For when time changed is repeated quickly
						play_song(player_name, track)
					end, player_name, track)
				end
				listeners[player_name].day_count = day_count
			end
		end
		until true
	end

	core.after(5, play)
end

if music_enabled then
	core.log("action", "[mcl_music] In-game music is activated")
	core.after(5, play)

	core.register_on_joinplayer(function(player, last_login)
		initialize_listener(player:get_player_name())
	end)

	core.register_on_leaveplayer(function(player, timed_out)
		remove_listener(player:get_player_name())
	end)

	core.register_on_respawnplayer(function(player)
		stop_music_for_listener(player:get_player_name())
	end)
else
	core.log("action", "[mcl_music] In-game music is deactivated")
end

core.register_chatcommand("music", {
	params = "[on|off|invert [<player name>]]",
	description = S("Turn music for yourself or another player on or off."),
	func = function(sender_name, params)
		local argtable = {}
		for str in string.gmatch(params, "([^%s]+)") do
			table.insert(argtable, str)
		end

		local action = argtable[1]
		local playername = argtable[2]

		local sender = core.get_player_by_name(sender_name)
		local target_player = nil

		if not action or action == "" then action = "invert" end

		if not playername or playername == "" or sender_name == playername then
			target_player = sender
			playername =sender_name
		elseif not core.check_player_privs(sender, "debug") then -- Self-use handled above
			core.chat_send_player(sender_name, S("You need the debug privilege in order to turn in-game music on or off for somebody else!"))
			return
		else -- Admin
			target_player = core.get_player_by_name(playername)
		end

		if not target_player then
			core.chat_send_player(sender_name, S("Could not find player @1!", playername))
			return
		end

		local meta = target_player:get_meta()
		local display_new_state = "unknown" -- Should never be displayed -> no translation

		if action == "invert" then
			if not meta:get("mcl_music:disable") then
				meta:set_int("mcl_music:disable", 1)
				display_new_state = S("off")
			else
				meta:set_string("mcl_music:disable", "") -- This deletes the meta value!
				display_new_state = S("on")
			end
		elseif action == "on" then
			meta:set_string("mcl_music:disable", "") -- Delete
			display_new_state = S("on")
		else
			meta:set_int("mcl_music:disable", 1)
			display_new_state = S("off")
		end

		stop_music_for_listener(playername)
		core.chat_send_player(sender_name, S("Set music for @1 to: @2", playername, display_new_state))
	end,
})
