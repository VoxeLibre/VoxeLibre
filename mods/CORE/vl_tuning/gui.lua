local modname = "vl_tuning"
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)
local F = function(f) return core.formspec_escape(S(f)) end
local FE = core.formspec_escape
local mod = vl_tuning

local function bool_to_string(value)
	if value then return "true" end
	return "false"
end

local function formspec_for_setting(y, name)
	local setting = mod.registered_settings[name]
	if not setting then return "" end

	local setting_type = setting.setting_type
	local default = setting.default
	if not default then
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

function vl_tuning.show_formspec(player_name, tab)
	if not tab then tab = "1" end

	local settings = {}
	local y = 0.5
	for name,_ in pairs(vl_tuning.registered_settings) do
		if name:sub(0,#"gamerule:") == "gamerule:" then
			if tab == "1" then
				local fs,dy = formspec_for_setting(y, name)
				table.insert(settings, fs)
				y = y + dy
			end
		else
			if tab == "2" then
				local fs,dy = formspec_for_setting(y,name)
				table.insert(settings, fs)
				y = y + dy
			end
		end
	end

	local formspec = table.concat({
		"formspec_version[4]",
		"size[20,10.5,true]",
		"tabheader[0,0;tab;"..
			F("Game Rules")..","..
			F("Settings")..
		";"..tab..";false;false]",
		"field[0,0;0,0;old_tab;;"..tab.."]",

		"scroll_container[1,0.5;18,9.25;settings;vertical;]",
		table.concat(settings),
		"scroll_container_end[]",
		"scrollbaroptions[min=0;max="..tostring(10 * math.max(y - 9, 0))..";smallstep=1;largestep=1]",
		"scrollbar[18.75,0.75;0.75,9.25;vertical;settings;0]",
		})

	core.show_formspec(player_name, "vl_tuning:settings", formspec)
end
core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "vl_tuning:settings" then return end
	if not core.check_player_privs(player, "server") then return end

	for k,value in pairs(fields) do
		local setting = mod.registered_settings[k]
		if setting then
			setting:set(value)
		end
	end

	if fields.quit or (not fields.tab or fields.old_tab == fields.tab) then return end

	mod.show_formspec(player:get_player_name(), fields.tab)
end)

core.register_chatcommand("settings",{
	privs = {
		server = true,
	},
	func = function(player_name, _)
		mod.show_formspec(player_name)
	end
})
core.register_on_player_receive_fields(function(player, formname, fields)
	if not fields.__vl_tuning then return end
	if not core.check_player_privs(player, {server = true}) then return end

	local player_name = player:get_player_name()

	mod.show_formspec(player_name)
end)

