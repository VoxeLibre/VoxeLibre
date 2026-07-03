local player_settings = {}
vl_tuning.registered_player_settings = player_settings

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
function vl_tuning.player_setting(name, p_type, def)
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

core.register_on_joinplayer(function(player)
	for _, setting in pairs(player_settings) do
		local hook = setting.on_change
		if hook then
			hook(setting, player, setting:get(player))
		end
	end
end)
