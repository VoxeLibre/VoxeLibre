local S = minetest.get_translator("mcl_beds")
local F = minetest.formspec_escape

local pi = math.pi
local player_in_bed = 0
local is_sp = minetest.is_singleplayer()
local weather_mod = minetest.get_modpath("mcl_weather") ~= nil
local explosions_mod = minetest.get_modpath("mcl_explosions") ~= nil

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

-- These monsters do not prevent sleep
local monster_exceptions = {
	["mobs_mc:ghast"] = true,
	["mobs_mc:enderdragon"] = true,
	["mobs_mc:killer_bunny"] = true,
	["mobs_mc:slime_big"] = true,
	["mobs_mc:slime_small"] = true,
	["mobs_mc:slime_tiny"] = true,
	["mobs_mc:magma_cube_big"] = true,
	["mobs_mc:magma_cube_small"] = true,
	["mobs_mc:magma_cube_tiny"] = true,
	["mobs_mc:shulker"] = true,
}

local function lay_down(player, pos, bed_pos, state, skip)
	local name = player:get_player_name()
	local hud_flags = player:hud_get_flags()

	if not player or not name then
		return false
	end

	if bed_pos then
		-- No sleeping if too far away
		if vector.distance(bed_pos, pos) > 2 then
			minetest.chat_send_player(name, S("You can't sleep, the bed's too far away!"))
			return false
		end

		for _, other_pos in pairs(mcl_beds.bed_pos) do
			if vector.distance(bed_pos, other_pos) < 0.1 then
				minetest.chat_send_player(name, S("This bed is already occupied!"))
				return false
			end
		end

		-- No sleeping while moving. Slightly different behaviour than in MC.
		-- FIXME: Velocity threshold should be 0.01 but Minetest 5.3.0
		-- sometimes reports incorrect Y speed. A velocity threshold
		-- of 0.125 still seems good enough.
		if vector.length(player:get_player_velocity()) > 0.125 then
			minetest.chat_send_player(name, S("You have to stop moving before going to bed!"))
			return false
		end

		-- No sleeping if monsters nearby.
		-- The exceptions above apply.
		-- Zombie pigmen only prevent sleep while they are hostle.
		local objs = minetest.get_objects_inside_radius(bed_pos, 8)
		for _, obj in ipairs(objs) do
			if obj ~= nil and not obj:is_player() then
				local ent = obj:get_luaentity()
				local mobname = ent.name
				local def = minetest.registered_entities[mobname]
				-- Approximation of monster detection range
				if def._cmi_is_mob and ((mobname ~= "mobs_mc:pigman" and def.type == "monster" and not monster_exceptions[mobname]) or (mobname == "mobs_mc:pigman" and ent.state == "attack")) then
					if math.abs(bed_pos.y - obj:get_pos().y) <= 5 then
						minetest.chat_send_player(name, S("You can't sleep now, monsters are nearby!"))
					end
					return false
				end
			end
		end
	end

	-- stand up
	if state ~= nil and not state then
		local p = mcl_beds.pos[name] or nil
		if mcl_beds.player[name] ~= nil then
			mcl_beds.player[name] = nil
			player_in_bed = player_in_bed - 1
		end
		mcl_beds.pos[name] = nil
		mcl_beds.bed_pos[name] = nil
		if p then
			player:set_pos(p)
		end

		-- skip here to prevent sending player specific changes (used for leaving players)
		if skip then
			return false
		end

		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = 0, z = 0}, {x = 0, y = 0, z = 0})
		if player:get_look_vertical() > 0 then
			player:set_look_vertical(0)
		end
		mcl_player.player_attached[name] = false
		playerphysics.remove_physics_factor(player, "speed", "mcl_beds:sleeping")
		playerphysics.remove_physics_factor(player, "jump", "mcl_beds:sleeping")
		player:get_meta():set_string("mcl_beds:sleeping", "false")
		hud_flags.wielditem = true
		mcl_player.player_set_animation(player, "stand" , 30)

	-- lay down
	else
		local yaw, param2 = get_look_yaw(bed_pos)
		local dir = minetest.facedir_to_dir(param2)
		local p = {x = bed_pos.x - dir.x/2, y = bed_pos.y, z = bed_pos.z - dir.z/2}
		local n1 = minetest.get_node({x=bed_pos.x, y=bed_pos.y+1, z=bed_pos.z})
		local n2 = minetest.get_node({x=bed_pos.x, y=bed_pos.y+2, z=bed_pos.z})
		local def1 = minetest.registered_nodes[n1.name]
		local def2 = minetest.registered_nodes[n2.name]
		if def1.walkable or def2.walkable then
			minetest.chat_send_player(name, S("You can't sleep, the bed is obstructed!"))
			return false
		elseif (def1.damage_per_second ~= nil and def1.damage_per_second > 0) or (def2.damage_per_second ~= nil and def2.damage_per_second > 0) then
			minetest.chat_send_player(name, S("It's too dangerous to sleep here!"))
			return false
		end

		local spawn_changed = false
		if minetest.get_modpath("mcl_spawn") then
			local spos = table.copy(bed_pos)
			spos.y = spos.y + 0.1
			spawn_changed = mcl_spawn.set_spawn_pos(player, spos) -- save respawn position when entering bed
		end

		-- Check day of time and weather
		local tod = minetest.get_timeofday() * 24000
		-- Values taken from Minecraft Wiki with offset of +6000
		if tod < 18541 and tod > 5458 and (not weather_mod or (mcl_weather.get_weather() ~= "thunder")) then
			if spawn_changed then
				minetest.chat_send_player(name, S("New respawn position set! But you can only sleep at night or during a thunderstorm."))
			else
				minetest.chat_send_player(name, S("You can only sleep at night or during a thunderstorm."))
			end
			return false
		end
		if spawn_changed then
			minetest.chat_send_player(name, S("New respawn position set!"))
		end

		mcl_beds.player[name] = 1
		mcl_beds.pos[name] = pos
		mcl_beds.bed_pos[name] = bed_pos
		player_in_bed = player_in_bed + 1
		-- physics, eye_offset, etc
		player:set_eye_offset({x = 0, y = -13, z = 0}, {x = 0, y = 0, z = 0})
		player:set_look_horizontal(yaw)
		player:set_look_vertical(-(math.pi/2))

		player:get_meta():set_string("mcl_beds:sleeping", "true")
		playerphysics.add_physics_factor(player, "speed", "mcl_beds:sleeping", 0)
		playerphysics.add_physics_factor(player, "jump", "mcl_beds:sleeping", 0)
		player:set_pos(p)
		mcl_player.player_attached[name] = true
		hud_flags.wielditem = false
		mcl_player.player_set_animation(player, "lay" , 0)
	end

	player:hud_set_flags(hud_flags)
	return true
end

local function update_formspecs(finished, ges)
	local ges = ges or #minetest.get_connected_players()
	local form_n = "size[6,5;true]"
	local all_in_bed = ges == player_in_bed
	local night_skip = is_night_skip_enabled()
	local button_leave = "button_exit[1,3;4,0.75;leave;"..F(S("Leave bed")).."]"
	local button_abort = "button_exit[1,3;4,0.75;leave;"..F(S("Abort sleep")).."]"
	local bg_presleep = "bgcolor[#00000080;true]"
	local bg_sleep = "bgcolor[#000000FF;true]"

	if finished then
		for name,_ in pairs(mcl_beds.player) do
			minetest.close_formspec(name, "mcl_beds_form")
		end
		return
	elseif not is_sp then
		local text = S("Players in bed: @1/@2", player_in_bed, ges)
		if not night_skip then
			text = text .. "\n" .. S("Note: Night skip is disabled.")
			form_n = form_n .. bg_presleep
			form_n = form_n .. button_leave
		elseif all_in_bed then
			text = text .. "\n" .. S("You're sleeping.")
			form_n = form_n .. bg_sleep
			form_n = form_n .. button_abort
		else
			text = text .. "\n" .. S("You will fall asleep when all players are in bed.")
			form_n = form_n .. bg_presleep
			form_n = form_n .. button_leave
		end
		form_n = form_n .. "label[1,1;"..F(text).."]"
	else
		local text
		if night_skip then
			text = S("You're sleeping.")
			form_n = form_n .. bg_sleep
			form_n = form_n .. button_abort
		else
			text = S("You're in bed.") .. "\n" .. S("Note: Night skip is disabled.")
			form_n = form_n .. bg_presleep
			form_n = form_n .. button_leave
		end
		form_n = form_n .. "label[1,1;"..F(text).."]"
	end

	for name,_ in pairs(mcl_beds.player) do
		minetest.show_formspec(name, "mcl_beds_form", form_n)
	end
end

-- Public functions

-- Handle environment stuff related to sleeping: skip night and thunderstorm
function mcl_beds.sleep()
	local storm_skipped = mcl_beds.skip_thunderstorm()
	-- Always clear weather
	if weather_mod then
		mcl_weather.change_weather("none")
	end
	if is_night_skip_enabled() then
		if not storm_skipped then
			mcl_beds.skip_night()
		end
		mcl_beds.kick_players()
	end
end

-- Throw all players out of bed
function mcl_beds.kick_players()
	for name, _ in pairs(mcl_beds.player) do
		local player = minetest.get_player_by_name(name)
		lay_down(player, nil, nil, false)
	end
	update_formspecs(false)
end

-- Throw a player out of bed
function mcl_beds.kick_player(player)
	local name = player:get_player_name()
	if mcl_beds.player[name] ~= nil then
		lay_down(player, nil, nil, false)
		update_formspecs(false)
		minetest.close_formspec(name, "mcl_beds_form")
	end
end

function mcl_beds.skip_night()
	minetest.set_timeofday(0.25) -- tod = 6000
end

function mcl_beds.skip_thunderstorm()
	-- Skip thunderstorm
	if weather_mod and mcl_weather.get_weather() == "thunder" then
		-- Sleep for a half day (=minimum thunderstorm duration)
		minetest.set_timeofday((minetest.get_timeofday() + 0.5) % 1)
		return true
	end
	return false
end

function mcl_beds.on_rightclick(pos, player, is_top)
	-- Anti-Inception: Don't allow to sleep while you're sleeping
	if player:get_meta():get_string("mcl_beds:sleeping") == "true" then
		return
	end
	if minetest.get_modpath("mcl_worlds") then
		local dim = mcl_worlds.pos_to_dimension(pos)
		if dim == "nether" or dim == "end" then
			-- Bed goes BOOM in the Nether or End.
			minetest.remove_node(pos)
			if explosions_mod then
				mcl_explosions.explode(pos, 5, {drop_chance = 1.0, fire = true})
			end
			return
		end
	end
	local name = player:get_player_name()
	local ppos = player:get_pos()

	-- move to bed
	if not mcl_beds.player[name] then
		if is_top then
			lay_down(player, ppos, pos)
		else
			local node = minetest.get_node(pos)
			local dir = minetest.facedir_to_dir(node.param2)
			local other = vector.add(pos, dir)
			lay_down(player, ppos, other)
		end
	else
		lay_down(player, nil, nil, false)
	end

	update_formspecs(false)

	-- skip the night and let all players stand up
	if check_in_beds() then
		minetest.after(5, function()
			if check_in_beds() then
				update_formspecs(is_night_skip_enabled())
				mcl_beds.sleep()
			end
		end)
	end
end


-- Callbacks
minetest.register_on_joinplayer(function(player)
	local meta = player:get_meta()
	if meta:get_string("mcl_beds:sleeping") == "true" then
		-- Make player awake on joining server
		meta:set_string("mcl_beds:sleeping", "false")
	end
	playerphysics.remove_physics_factor(player, "speed", "mcl_beds:sleeping")
	playerphysics.remove_physics_factor(player, "jump", "mcl_beds:sleeping")
	update_formspecs(false)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	lay_down(player, nil, nil, false, true)
	players = minetest.get_connected_players()
	for n, player in ipairs(players) do
		if player:get_player_name() == name then
			players[n] = nil
			break
		end
	end
	if check_in_beds(players) then
		minetest.after(5, function()
			if check_in_beds() then
				update_formspecs(is_night_skip_enabled())
				mcl_beds.sleep()
			end
		end)
	end
	update_formspecs(false, #players)
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

minetest.register_on_player_hpchange(function(player, hp_change)
	if hp_change < 0 then
		mcl_beds.kick_player(player)
	end
end)
