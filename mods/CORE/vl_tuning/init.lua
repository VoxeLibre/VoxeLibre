local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local storage = minetest.get_mod_storage()
local mod = {}
vl_tuning = mod

--
local tunables = {}

-- Supported variable types
local tunable_types = {
	bool = {
		to_string = tostring,
		from_string = function(value)
			return (value == "true")
		end
	},
	number = {
		to_string = tostring,
		from_string = tonumber,
	},
	string = {
		to_string = function(v) return v end,
		from_string = function(v) return v end,
	},
}

-- Tunable metatable functions
local tunable_class = {}
function tunable_class:set(value)
	local self_type = self.type
	if type(value) == "string" then
		self[1] = self_type.from_string(value) or self.default
	else
		self[1] = value
	end

	local setting = self.setting
	if setting then
		storage:set_string(setting,self_type.to_string(self[1]))
	end
end
function tunable_class:get_string()
	print(dump(self))
	return self.type.to_string(self[1])
end

function mod.get_server_setting(name, description, default, setting, setting_type, options )
	local tunable = tunables[name]
	if tunable then return tunable end

	tunable = {
		name = name,
		default = default,
		setting = setting,
		description = description,
		type = tunable_types[setting_type],
		options = options,
	}
	tunable[1] = default
	print(dump(tunable))
	setmetatable(tunable, {__index=tunable_class})
	if setting then
		local setting_value = storage:get_string(setting)
		if setting_value and setting_value ~= "" then
			tunable:set(setting_value)
		end
	end
	print(dump(tunable))
	tunables[name] = tunable
	return tunable
end

minetest.register_chatcommand("set_setting", {
	description = S("Admin tool to tune settings and game rules"),
	params = S("<setting> <value>"),
	privs = { debug = true },
	func = function(name, params_raw)
		-- Split apart the params
		local params = {}
		for str in string.gmatch(params_raw, "([^ ]+)") do
			params[#params + 1] = str
		end

		if #params ~= 2 then
			return false, S("Usage: /tune <setting> <value>")
		end

		local tunable = tunables[params[1]]
		if tunable then
			minetest.log("action", "[vl_tuning] "..name.." set ".. params[1] .." to "..params[2])
			tunable:set(params[2])
			return true
		else
			return false, S("Setting @1 doesn't exist", params[1])
		end
	end
})
minetest.register_chatcommand("get_setting", {
	description = S("Admin tool to view settings and game rules"),
	params = S("<setting>"),
	privs = { debug = true },
	func = function(name, param)
		local tunable = tunables[param]
		if tunable then
			return true, tunable:get_string()
		else
			return false, S("Setting @1 doesn't exist", param)
		end
	end
})

