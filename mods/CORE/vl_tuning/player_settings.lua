local modname = "vl_tuning"
local S = core.get_translator(modname)
local F = core.formspec_escape
local mod = vl_tuning

local player_settings = {}
mod.registered_player_settings = player_settings
local player_formspec_targets = {}

local function bool_to_string(value)
	if value then return "true" end
	return "false"
end

local function player_setting_meta_key(name)
	return "vl_tuning:player_setting:" .. name
end

---@class vl_tuning.PlayerSettingDef
---@field default? vl_tuning.Value
---@field description? string
---@field formspec_desc_lines? number
---@field on_change? fun(self: vl_tuning.PlayerSetting, player: ObjectRef, value: vl_tuning.Value)

---@class (exact) vl_tuning.PlayerSetting
---@field name string
---@field setting_type "string"|"number"|"bool"
---@field description string
---@field default vl_tuning.Value
---@field from_string fun(value : string) : vl_tuning.Value
---@field to_string fun(value : vl_tuning.Value)
---@field formspec_desc_lines? number
---@field on_change? fun(self: vl_tuning.PlayerSetting, player: ObjectRef, value: vl_tuning.Value)
---@field get fun(self: vl_tuning.PlayerSetting, player: ObjectRef) : vl_tuning.Value
---@field set fun(self: vl_tuning.PlayerSetting, player: ObjectRef, value: vl_tuning.Value, no_hook : boolean?)
---@field get_string fun(self: vl_tuning.PlayerSetting, player: ObjectRef) : string
local player_setting_class = {}

---@param self vl_tuning.PlayerSetting
---@param player ObjectRef
---@return vl_tuning.Value
function player_setting_class:get(player)
	local raw = player:get_meta():get_string(player_setting_meta_key(self.name))
	if raw == "" then
		return self.default
	end

	local value = self.from_string(raw)
	if value == nil then
		return self.default
	end

	return value
end

---@param self vl_tuning.PlayerSetting
---@param player ObjectRef
---@param value vl_tuning.Value
---@param no_hook? boolean
function player_setting_class:set(player, value, no_hook)
	if type(value) == "string" then
		local new_value = self.from_string(value)
		if new_value == nil then
			value = self.default
		else
			value = new_value
		end
	end

	player:get_meta():set_string(player_setting_meta_key(self.name), self.to_string(value))

	if not no_hook then
		local hook = self.on_change
		if hook then hook(self, player, value) end
	end
end

---@param self vl_tuning.PlayerSetting
---@param player ObjectRef
---@return string
function player_setting_class:get_string(player)
	return self.to_string(self:get(player))
end

---@param name string
---@param p_type? "bool"|"number"|"string"
---@param def? vl_tuning.PlayerSettingDef
---@return vl_tuning.PlayerSetting
function mod.player_setting(name, p_type, def)
	local setting = player_settings[name]
	if setting then return setting end

	assert(p_type)
	def = def or {}

	local setting_type = assert(vl_tuning.tunable_types[p_type], "Unsupported per-player setting type")
	---@type vl_tuning.PlayerSetting
	setting = {
		name = name,
		setting_type = p_type,
		description = def.description or "",
		default = def.default ~= nil and def.default or setting_type.default,
		from_string = setting_type.from_string,
		to_string = setting_type.to_string,
		formspec_desc_lines = def.formspec_desc_lines,
		on_change = def.on_change,
		get = player_setting_class.get,
		set = player_setting_class.set,
		get_string = player_setting_class.get_string,
	}

	setmetatable(setting, { __index = player_setting_class })
	player_settings[name] = setting
	return setting
end

local function formspec_for_player_setting(y, name, player)
	local setting = player_settings[name]
	if not setting then return "" end

	local default = setting.default
	if default == nil then
		if setting.setting_type == "bool" then
			default = "false"
		elseif setting.setting_type == "number" then
			default = "0"
		else
			default = "\"\""
		end
	else
		default = tostring(default)
	end

	local desc_height = (setting.formspec_desc_lines or 1) * 0.435
	local fs = {}
	table.insert(fs, "label[0," .. (y + 0.15) .. ";" .. F(name) .. " (Default: " .. default .. ")]")
	table.insert(fs, "hypertext[0.15," .. (y + 0.25) .. ";14.85," .. desc_height .. ";;" .. F("<style color=black>" .. setting.description .. "</style>") .. "]")

	if setting.setting_type == "bool" then
		table.insert(fs, "checkbox[17," .. (y + 0.375) .. ";" .. F(name) .. ";;" .. bool_to_string(setting:get(player)) .. "]")
	elseif setting.setting_type == "number" then
		table.insert(fs, "field[15," .. y .. ";2.5,0.75;" .. F(name) .. ";;" .. string.format("%.4g", setting:get(player)) .. "]")
		table.insert(fs, "field_close_on_enter[" .. F(name) .. ";false]")
	end

	return table.concat(fs), desc_height + 0.35
end

---@param viewer_name string
---@param target_name? string
function mod.show_player_formspec(viewer_name, target_name)
	target_name = target_name or viewer_name

	local target = core.get_player_by_name(target_name)
	if not target then return false, S("Player @1 is not online.", target_name) end

	player_formspec_targets[viewer_name] = target_name

	local settings_sort = {}
	for name, _ in pairs(player_settings) do
		table.insert(settings_sort, name)
	end
	table.sort(settings_sort)

	local settings_forms = {}
	local y = 0.5
	for _, name in ipairs(settings_sort) do
		local fs, dy = formspec_for_player_setting(y, name, target)
		table.insert(settings_forms, fs)
		y = y + dy
	end

	if #settings_sort == 0 then
		table.insert(settings_forms, "label[0,0.5;" .. F(S("No player settings registered.")) .. "]")
	end

	local formspec = table.concat({
		"formspec_version[4]",
		"size[20,10.5,true]",
		"label[0.5,0.55;" .. F(S("Player Settings <@1>", target_name)) .. "]",
		"scroll_container[1,0.5;18,9.25;settings;vertical;]",
		table.concat(settings_forms),
		"scroll_container_end[]",
		"scrollbaroptions[min=0;max=" .. tostring(10 * math.max(y - 9, 0)) .. ";smallstep=1;largestep=1]",
		"scrollbar[18.75,0.75;0.75,9.25;vertical;settings;0]",
	})

	core.show_formspec(viewer_name, "vl_tuning:player_settings", formspec)
	return true
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "vl_tuning:player_settings" then return end

	local viewer_name = player:get_player_name()
	local target_name = player_formspec_targets[viewer_name] or viewer_name
	local target = core.get_player_by_name(target_name)
	if not target then
		core.chat_send_player(viewer_name, S("Player @1 is not online.", target_name))
		player_formspec_targets[viewer_name] = nil
		return
	end

	if target_name ~= viewer_name and not core.check_player_privs(player, { server = true }) then
		core.chat_send_player(viewer_name, S("You need the server privilege to edit other players' settings."))
		player_formspec_targets[viewer_name] = nil
		return
	end

	for key, value in pairs(fields) do
		local setting = player_settings[key]
		if setting then
			setting:set(target, value)
		end
	end

	if fields.quit then
		player_formspec_targets[viewer_name] = nil
	end
end)

core.register_on_joinplayer(function(player)
	for _, setting in pairs(player_settings) do
		local hook = setting.on_change
		if hook then
			hook(setting, player, setting:get(player))
		end
	end
end)

core.register_on_leaveplayer(function(player)
	player_formspec_targets[player:get_player_name()] = nil
end)

core.register_chatcommand("player_settings", {
	description = S("Open personal settings, or another player's settings if you have the server privilege"),
	params = S("[player]"),
	func = function(player_name, param)
		local target_name = param ~= "" and param or player_name
		if target_name ~= player_name and not core.check_player_privs(player_name, { server = true }) then
			return false, S("You need the server privilege to edit other players' settings.")
		end

		return mod.show_player_formspec(player_name, target_name)
	end,
})
