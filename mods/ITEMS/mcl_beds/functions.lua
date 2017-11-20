local pi = math.pi
local player_in_bed = 0
local is_sp = minetest.is_singleplayer()
local enable_respawn = minetest.settings:get_bool("enable_bed_respawn")
if enable_respawn == nil then
	enable_respawn = true
end
local weather_mod = minetest.get_modpath("weather_pack") ~= nil

-- Helper functions

local function get_look_yaw(pos)
	local n = minetest.get_node(pos)
	if n.param2 == 1 then
		return pi / 2, n.param2
	elseif n.param2 == 3 then
		return -pi / 2, n.param2
	elseif n.param2 == 0 then
		return pi, n.param2
	else
		return 0, n.param2
	end
end

local function is_night_skip_enabled()
	local enable_night_skip = minetest.settings:get_bool("enable_bed_night_skip")
	if enable_night_skip == nil then
		enable_night_skip = true
	end
	return enable_night_skip
end

local function check_in_beds(players)
	local in_bed = mcl_beds.player
	if not players then
		players = minetest.get_connected_players()
	end

	for n, player in ipairs(players) do
		local name = player:get_player_name()
		if not in_bed[name] then
			return false
		end
	end

	return #players > 0
end

local function lay_down(player, pos, bed_pos, state, skip)
	local name = player:get_player_name()
	local hud_flags = player:hud_get_flags()

	if not player or not name then
		return
	end

	-- stand up
	if state ~= nil and not state then
		local p = mcl_beds.pos[name] or nil
		if mcl_beds.player[name] ~= nil then
			mcl_beds.player[name] = nil
			player_in_bed = player_in_bed - 1
		end
		-- skip here to prevent sending player specific changes (used for leaving players)
		if skip then
			return
		end
		if p then
			player:setpos(p)
		end

		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
		player:set_look_horizontal(math.random(1, 180) / 100)
		mcl_player.player_attached[name] = false
		player:set_physics_override(1, 1, 1)
		player:set_attribute("mcl_beds:sleeping", "false")
		hud_flags.wielditem = true
		mcl_player.player_set_animation(player, "stand" , 30)

	-- lay down
	else
		mcl_beds.player[name] = 1
		mcl_beds.pos[name] = pos
		player_in_bed = player_in_bed + 1

		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = -13, z = 0}, {x = 0, y = 0, z = 0})
		local yaw, param2 = get_look_yaw(bed_pos)
		player:set_look_horizontal(yaw)
		local dir = minetest.facedir_to_dir(param2)
		local p = {x = bed_pos.x + dir.x / 2, y = bed_pos.y, z = bed_pos.z + dir.z / 2}
		-- Set player attribute so other mods know they should not touch set_physics_override
		player:set_attribute("mcl_beds:sleeping", "true")
		player:set_physics_override(0, 0, 0)
		player:setpos(p)
		mcl_player.player_attached[name] = true
		hud_flags.wielditem = false
		mcl_player.player_set_animation(player, "lay" , 0)
	end

	player:hud_set_flags(hud_flags)
end

local function update_formspecs(finished)
	local ges = #minetest.get_connected_players()
	local form_n
	local all_in_bed = ges == player_in_bed

	if finished then
		form_n = mcl_beds.formspec .. "label[2.7,11; Good morning.]"
	else
		form_n = mcl_beds.formspec .. "label[2.2,11;" .. tostring(player_in_bed) ..
			" of " .. tostring(ges) .. " players are in bed]"
		if all_in_bed and is_night_skip_enabled() then
			form_n = form_n .. "button_exit[2,8;4,0.75;force;Force night skip]"
		end
	end

	for name,_ in pairs(mcl_beds.player) do
		minetest.show_formspec(name, "mcl_beds_form", form_n)
	end
end

-- Public functions

-- Handle environment stuff related to sleeping: skip night and thunderstorm
function mcl_beds.sleep()
	local storm_skipped = mcl_beds.skip_thunderstorm()
	if is_night_skip_enabled() then
		if not storm_skipped then
			mcl_beds.skip_night()
		end
		mcl_beds.kick_players()
	end
end

function mcl_beds.kick_players()
	for name, _ in pairs(mcl_beds.player) do
		local player = minetest.get_player_by_name(name)
		lay_down(player, nil, nil, false)
	end
end

function mcl_beds.skip_night()
	minetest.set_timeofday(0.25) -- tod = 6000
end

function mcl_beds.skip_thunderstorm()
	-- Skip thunderstorm
	if weather_mod and weather.get_weather() == "thunder" then
		weather.change_weather("none")
		-- Sleep for a half day (=minimum thunderstorm duration)
		minetest.set_timeofday((minetest.get_timeofday() + 0.5) % 1)
		return true
	end
	return false
end

function mcl_beds.on_rightclick(pos, player)
	if minetest.get_modpath("mcl_init") then
		local _, dim = mcl_util.y_to_layer(pos.y)
		if dim == "nether" or dim == "end" then
			-- Bed goes BOOM in the Nether or End.
			minetest.remove_node(pos)
			if minetest.get_modpath("mcl_tnt") then
				tnt.boom(pos, {radius = 4, damage_radius = 4})
			end
			return
		end
	end
	local name = player:get_player_name()
	local ppos = player:getpos()
	local tod = minetest.get_timeofday() * 24000

	-- Values taken from Minecraft Wiki with offset of +6000
	if tod < 18541 and tod > 5458 and (not weather_mod or (weather.get_weather() ~= "thunder")) then
		if mcl_beds.player[name] then
			lay_down(player, nil, nil, false)
		end
		minetest.chat_send_player(name, "You can only sleep at night or during a thunderstorm.")
		return
	end

	-- move to bed
	if not mcl_beds.player[name] then
		lay_down(player, ppos, pos)
		player:set_attribute("mcl_beds:spawn", minetest.pos_to_string(player:getpos())) -- save respawn position when entering bed
	else
		lay_down(player, nil, nil, false)
	end

	if not is_sp then
		update_formspecs(false)
	end

	-- skip the night and let all players stand up
	if check_in_beds() then
		minetest.after(2, function()
			if not is_sp then
				update_formspecs(is_night_skip_enabled())
			end
			mcl_beds.sleep()
		end)
	end
end


-- Callbacks
-- Only register respawn callback if respawn enabled
if enable_respawn then
	-- respawn player at bed if enabled and valid position is found
	minetest.register_on_respawnplayer(function(player)
		local pos = minetest.string_to_pos(player:get_attribute("mcl_beds:spawn"))
		if pos then
			player:setpos(pos)
			return true
		end
	end)
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	lay_down(player, nil, nil, false, true)
	mcl_beds.player[name] = nil
	if check_in_beds() then
		minetest.after(2, function()
			update_formspecs(is_night_skip_enabled())
			mcl_beds.sleep()
		end)
	end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mcl_beds_form" then
		return
	end
	if fields.quit or fields.leave then
		lay_down(player, nil, nil, false)
		update_formspecs(false)
	end

	if fields.force then
		update_formspecs(is_night_skip_enabled())
		mcl_beds.sleep()
	end
end)
