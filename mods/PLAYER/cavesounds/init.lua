local S = core.get_translator(core.get_current_modname())

local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

local cave_sounds_enabled = core.settings:get_bool("cavesounds", true)

-- Can be tweaked

local seconds_in_pitch_black_before_sound = 300      -- Seconds
local interval = 3 			             -- Seconds
local max_same_sound_for_other_players_distance = 50 -- Nodes

--

local max_light_lvl = 15
local max_fear_per_interval = seconds_in_pitch_black_before_sound / (seconds_in_pitch_black_before_sound / interval)
local slope = max_fear_per_interval / max_light_lvl

local sounds = {"cave1", "cave2", "cave3", "cave4", "cave5", "cave6"}

local listeners = {}

local function reset_fear(player_name)
	listeners[player_name] = { fear = 0 }
end

local function pick_sound()
	if sounds and #sounds >= 1 then
		local index = 1
		if #sounds > 1 then
			index = math.random(1, #sounds)
		end

		local chosen_sound = sounds[index]
		core.log("action", "[cavesounds] Playing cave sound: " .. chosen_sound)

		return chosen_sound
	else
		core.log("warning", "[cavesounds] No cave sounds found!")
	end

	return nil
end

local function play_sound(sound, player_name)

	local spec = {
		name  = sound,
		gain  = 0.3,
		pitch = 1.0,
	}
	local parameters = {
		to_player = player_name,
		gain      = 1.0,
		fade      = 0.0,
		pitch     = 1.0,
	}
	core.sound_play(spec, parameters, false)
end

local function play()
	local time = core.get_timeofday()

	for _, player1 in pairs(core.get_connected_players()) do
		if not player1:get_meta():get("cavesounds:disable") then

			local player1_name = player1:get_player_name()
			local pos1         = player1:get_pos()
			local dimension    = mcl_worlds.pos_to_dimension(pos1)

			if (dimension == "overworld") then

				-- Underground
				if pos1.y < 0 then
					local fear      = listeners[player1_name].fear
					local light_lvl = core.get_node_light(pos1)

					-- Mapping light level to extra fear
					new_fear = fear - slope * (light_lvl - max_light_lvl)

					if (new_fear < 0) then
						reset_fear(player1_name)

					elseif (new_fear >= seconds_in_pitch_black_before_sound) then
						reset_fear(player1_name)

						-- Play cave sound
						local sound = pick_sound()
						if sound then

							play_sound(sound, player1_name)

							-- Also play the same sound for nearby players
							for _, player2 in pairs(core.get_connected_players()) do
								if player2 == player1 then
									goto continue2
								end

								if not player2:get_meta():get("cavesounds:disable") then

									local player2_name = player2:get_player_name()
									local pos2         = player2:get_pos()

									if vector.distance(pos2, pos1) < max_same_sound_for_other_players_distance then
										reset_fear(player2_name)
										play_sound(sound, player2_name)
									end
								end

								::continue2::
							end
						end
					else
						-- Nothing special, just set new fear
						listeners[player1_name].fear = new_fear
					end
				end

				--core.chat_send_player(player1_name, listeners[player1_name].fear)
			end
		end
	end

	core.after(interval, play)
end

if cave_sounds_enabled then
	core.log("action", "[cavesounds] Cave sounds are activated")
	core.after(5, play)

	core.register_on_joinplayer(function(player, last_login)
		reset_fear(player:get_player_name())
	end)

	core.register_on_leaveplayer(function(player, timed_out)
		listeners[player:get_player_name()] = nil
	end)

	core.register_on_respawnplayer(function(player)
		reset_fear(player:get_player_name())
	end)
else
	core.log("action", "[cavesounds] Cave sounds are deactivated")
end

core.register_chatcommand("cavesounds", {
	params = "[on|off|invert [<player name>]]",
	description = S("Turn cave sounds for yourself or another player on or off."),
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
			core.chat_send_player(sender_name, S("You need the debug privilege in order to turn cave sounds on or off for somebody else!"))
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
			if not meta:get("cavesounds:disable") then
				meta:set_int("cavesounds:disable", 1)
				display_new_state = S("off")
			else
				meta:set_string("cavesounds:disable", "") -- This deletes the meta value!
				display_new_state = S("on")
			end
		elseif action == "on" then
			meta:set_string("cavesounds:disable", "") -- Delete
			display_new_state = S("on")
		else
			meta:set_int("cavesounds:disable", 1)
			display_new_state = S("off")
		end

		core.chat_send_player(sender_name, S("Set cave sounds for @1 to: @2", playername, display_new_state))
	end,
})
