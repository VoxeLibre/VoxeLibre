vl_death_screen = {}

local modname = core.get_current_modname()
local S = core.get_translator(modname)
local FE = core.formspec_escape

local mod_xp = core.get_modpath("mcl_experience")

local function form_pos_to_string(pos)
	return tostring(pos.x) .. "," .. tostring(pos.y)
end

local function form_size_to_string(size)
	return tostring(size.w) .. "," .. tostring(size.h)
end

local formspec_confirm_clear_spawn = table.concat({
	"formspec_version[4]",
	"size[6,4.1]",
	"set_focus[no;true]",
	"hypertext[0.5,0.5;5,0.8;;" ..
		FE("<center><style color=black>" .. S("Are you sure you want to reset your spawn point?") .. "</style></center>") .. "]",
	"button_exit[0.5,1.8;5,0.8;yes;" .. S("Yes") .. "]",
	"button_exit[0.5,2.8;5,0.8;no;" .. S("No") .. "]",
})

function vl_death_screen.show_death_screen(player)
	local pos, size = {x = 0.5, y = 0.5}, {w = 10, h = 0.5}
	local formspec = {
		"formspec_version[4]",
		"allow_close[false]",
		"set_focus[respawn;true]",
	}

	table.insert(formspec, "hypertext[" .. form_pos_to_string(pos) .. ";9,0.8;;" ..
		FE("<center><style color=black>" .. S("You died!") .. "</style></center>") .. "]")
	pos.y, size.h = pos.y + 0.8, size.h + 0.8

	if mod_xp then
		local player_xp = player:get_meta():get_int("vl_death_screen:last_xp")
		pos.y, size.h = pos.y + 0.1, size.h + 0.1
		table.insert(formspec, "hypertext[" .. form_pos_to_string(pos) .. ";9,0.8;;" ..
			FE("<center><style color=black>" .. S("Score: ") .. tostring(player_xp) .. "</style></center>") .. "]")
		pos.y, size.h = pos.y + 0.8, size.h + 0.8
	end

	pos.y, size.h = pos.y + 0.5, size.h + 0.5
	table.insert(formspec, "button_exit[" .. form_pos_to_string(pos) .. ";9,0.8;respawn;" .. S("Respawn") .. "]")
	pos.y, size.h = pos.y + 0.8, size.h + 0.8

	pos.y, size.h = pos.y + 0.2, size.h + 0.2
	table.insert(formspec, "button_exit[" .. form_pos_to_string(pos) .. ";9,0.8;exit_to_menu;" .. S("Exit to Menu") .. "]")
	pos.y, size.h = pos.y + 0.8, size.h + 0.8

	if core.check_player_privs(player, {setspawn = true}) then
		local spawn_pos = mcl_spawn.get_player_spawnpoint(player)
		if spawn_pos then
			pos.y, size.h = pos.y + 0.5, size.h + 0.5
			table.insert(formspec, "button[" .. form_pos_to_string(pos) .. ";9,0.8;clear_spawn;" .. S("Reset Spawn Point") .. "]")
			pos.y, size.h = pos.y + 0.8, size.h + 0.8
		end
	end

	-- Bottom edge
	size.h = size.h + 0.5

	table.insert(formspec, 2, "size[" .. form_size_to_string(size) .. "]")
	core.show_formspec(player:get_player_name(), "vl_death_screen:main", table.concat(formspec))
end

-- Override engine's built-in death screen
core.show_death_screen = function(player, reason)
	if mod_xp then
		local player_xp = mcl_experience.get_xp(player)
		player:get_meta():set_int("vl_death_screen:last_xp", player_xp)
	end

	vl_death_screen.show_death_screen(player)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "vl_death_screen:main" then
		if fields.respawn then
			player:respawn()
		elseif fields.exit_to_menu then
			player:respawn() -- This is suboptimal, but still better than not to respawn
			core.disconnect_player(player:get_player_name(), S("You left the game"), false)
		elseif fields.clear_spawn then
			core.show_formspec(player:get_player_name(), "vl_death_screen:confirm_clear_spawn", formspec_confirm_clear_spawn)
		end
	elseif formname == "vl_death_screen:confirm_clear_spawn" then
		if fields.yes then
			mcl_spawn.set_player_spawn_pos(player, nil, false, true)
		end

		-- Go back to the death screen
		vl_death_screen.show_death_screen(player)
	end
end)
