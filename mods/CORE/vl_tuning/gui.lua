local modname = "vl_tuning"
local S = core.get_translator(modname)
local F = function(f) return core.formspec_escape(S(f)) end
local FE = core.formspec_escape
local mod = vl_tuning
local player_formspec_targets = {}

local function bool_to_string(value)
	if value then return "true" end
	return "false"
end

local function formspec_for_setting(y, name)
	local setting = mod.registered_settings[name]
	if not setting then return "", 0 end

	local setting_type = setting.setting_type
	local default = setting.default
	if default == nil then
		if setting_type == "bool" then
			default = "false"
		elseif setting_type == "number" then
			default = "0"
		elseif setting_type == "string" then
			default = "\"\""
		end
	else
		default = tostring(default)
	end

	local desc_height = (setting.formspec_desc_lines or 1) * 0.435
	local fs = {}
	table.insert(fs, "label[0,"..(y+0.15)..";"..FE(name).." (Default: "..default..")]")
	table.insert(fs, "hypertext[0.15,"..(y+0.25)..";14.85,"..desc_height..";;"..FE("<style color=black>"..setting.description.."</style>").."]")

	if setting_type == "bool" then
		table.insert(fs, "checkbox[17,"..(y+0.375)..";"..FE(name)..";;"..bool_to_string(setting.getter()).."]")
	elseif setting_type == "number" then
		table.insert(fs, "field[15,"..y..";2.5,0.75;"..FE(name)..";;"..string.format("%.4g", setting.getter()).."]")
		table.insert(fs, "field_close_on_enter["..FE(name)..";false]")
	elseif setting_type == "string" then
	end

	return table.concat(fs), desc_height + 0.35
end

local function formspec_for_player_setting(y, name, player)
	local setting = mod.registered_player_settings[name]
	if not setting then return "", 0 end

	local setting_type = setting.setting_type
	local default = setting.default
	if default == nil then
		if setting_type == "bool" then
			default = "false"
		elseif setting_type == "number" then
			default = "0"
		elseif setting_type == "string" then
			default = "\"\""
		end
	else
		default = tostring(default)
	end

	local desc_height = (setting.formspec_desc_lines or 1) * 0.435
	local fs = {}
	table.insert(fs, "label[0,"..(y+0.15)..";"..FE(name).." (Default: "..default..")]")
	table.insert(fs, "hypertext[0.15,"..(y+0.25)..";14.85,"..desc_height..";;"..FE("<style color=black>"..setting.description.."</style>").."]")

	if setting_type == "bool" then
		table.insert(fs, "checkbox[17,"..(y+0.375)..";"..FE(name)..";;"..bool_to_string(setting:get(player)).."]")
	elseif setting_type == "number" then
		table.insert(fs, "field[15,"..y..";2.5,0.75;"..FE(name)..";;"..string.format("%.4g", setting:get(player)).."]")
		table.insert(fs, "field_close_on_enter["..FE(name)..";false]")
	elseif setting_type == "string" then
		table.insert(fs, "field[15,"..y..";2.5,0.75;"..FE(name)..";;"..FE(setting:get(player)).."]")
		table.insert(fs, "field_close_on_enter["..FE(name)..";false]")
	end

	return table.concat(fs), desc_height + 0.35
end

function mod.show_formspec(player_name, tab, target_name)
	if not tab then tab = "1" end
	local player = core.get_player_by_name(player_name)
	if not player then return end
	local has_server_priv = core.check_player_privs(player, { server = true })
	if not has_server_priv and tab ~= "1" then tab = "1" end

	target_name = target_name or player_name

	local target = core.get_player_by_name(target_name)
	if not target then
		player_formspec_targets[player_name] = nil
		return false, S("Player @1 is not online.", target_name)
	end

	if target_name ~= player_name and not has_server_priv then
		player_formspec_targets[player_name] = nil
		return false, S("You need the server privilege to edit other players' settings.")
	end

	player_formspec_targets[player_name] = target_name

	local settings_sort = {}
	if tab == "1" then
		for name, _ in pairs(mod.registered_player_settings) do
			table.insert(settings_sort, name)
		end
	else
		for name, _ in pairs(mod.registered_settings) do
			table.insert(settings_sort, name)
		end
	end
	table.sort(settings_sort)

	local settings_forms = {}
	local y = 0.5
	if tab == "1" and target_name ~= player_name then
		table.insert(settings_forms, "label[0," .. y .. ";" .. FE(S("Player: @1", target_name)) .. "]")
		y = y + 0.75
	end

	for _, name in ipairs(settings_sort) do
		if tab == "1" then
			local fs, dy = formspec_for_player_setting(y, name, target)
			table.insert(settings_forms, fs)
			y = y + dy
		elseif has_server_priv and name:sub(0,#"gamerule:") == "gamerule:" then
			if tab == "2" then
				local fs, dy = formspec_for_setting(y, name)
				table.insert(settings_forms, fs)
				y = y + dy
			end
		elseif has_server_priv and tab == "3" then
			local fs,dy = formspec_for_setting(y,name)
			table.insert(settings_forms, fs)
			y = y + dy
		end
	end

	local tabs = { F("Player Settings") }
	if has_server_priv then
		table.insert(tabs, F("Game Rules"))
		table.insert(tabs, F("Settings"))
	end

	local formspec = table.concat({
		"formspec_version[4]",
		"size[20,10.5,true]",
		"tabheader[0,0;tab;"..
			table.concat(tabs, ",")..
			";"..tab..";false;false]",
		"field[0,0;0,0;old_tab;;"..tab.."]",

		"scroll_container[1,0.5;18,9.25;settings;vertical;]",
		table.concat(settings_forms),
		"scroll_container_end[]",
		"scrollbaroptions[min=0;max="..tostring(10 * math.max(y - 9, 0))..";smallstep=1;largestep=1]",
		"scrollbar[18.75,0.75;0.75,9.25;vertical;settings;0]",
		})

	core.show_formspec(player_name, "vl_tuning:settings", formspec)
	return true
end
core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "vl_tuning:settings" then return end

	local player_name = player:get_player_name()
	local has_server_priv = core.check_player_privs(player, { server = true })
	local old_tab = fields.old_tab or "1"
	local target_name = player_formspec_targets[player_name] or player_name
	local target = core.get_player_by_name(target_name)
	if not target then
		core.chat_send_player(player_name, S("Player @1 is not online.", target_name))
		player_formspec_targets[player_name] = nil
		return
	end

	if target_name ~= player_name and not has_server_priv then
		core.chat_send_player(player_name, S("You need the server privilege to edit other players' settings."))
		player_formspec_targets[player_name] = nil
		return
	end

	if old_tab == "1" then
		local settings_changed = false
		for k, value in pairs(fields) do
			local setting = mod.registered_player_settings[k]
			if setting then
				local old_value = setting:get(target)
				setting:set(target, value)
				if setting:get(target) ~= old_value then
					settings_changed = true
				end
			end
		end
		if settings_changed and target_name ~= player_name then
			core.chat_send_player(target_name, S("Your player settings were changed by @1.", player_name))
		end
	elseif has_server_priv then
		for k,value in pairs(fields) do
			local setting = mod.registered_settings[k]
			if setting then
				setting:set(value)
			end
		end
	end

	if fields.quit then
		player_formspec_targets[player_name] = nil
		return
	end

	if not fields.tab or old_tab == fields.tab then return end

	mod.show_formspec(player_name, fields.tab, target_name)
end)

core.register_chatcommand("settings", {
	description = S("Open personal settings, or another player's settings if you have the server privilege"),
	params = S("[player_name]"),
	func = function(player_name, param)
		local target_name = param ~= "" and param or player_name
		if target_name ~= player_name and not core.check_player_privs(player_name, { server = true }) then
			return false, S("You need the server privilege to edit other players' settings.")
		end

		return mod.show_formspec(player_name, "1", target_name)
	end
})
core.register_on_player_receive_fields(function(player, formname, fields)
	if not fields.__vl_tuning then return end

	local player_name = player:get_player_name()

	mod.show_formspec(player_name)
end)

core.register_on_leaveplayer(function(player)
	player_formspec_targets[player:get_player_name()] = nil
end)
