local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local storage = minetest.get_mod_storage()
local mod = {}
vl_tuning = mod

-- All registered tunable parameters
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
		local new_value = self_type.from_string(value)
		if new_value == nil then new_value = self.default end

		minetest.log("action","new_value="..dump(new_value))
		self[1] = new_value
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

function mod.setting(setting, setting_type, def )
	-- return the existing setting if it was previously registered. Don't update the definition
	local tunable = tunables[setting]
	if tunable then return tunable end

	-- Setup the tunable data
	tunable = table.copy(def)
	tunable.setting = setting
	tunable.type = tunable_types[setting_type]
	tunable[1] = tunable.default
	setmetatable(tunable, {__index=tunable_class})

	-- Load the setting value from mod storage
	local setting_value = storage:get_string(setting)
	if setting_value and setting_value ~= "" then
		tunable:set(setting_value)
	end

	-- Add to the list of all available settings
	tunables[setting] = tunable

	-- Provide it so that the current value in [1] can be accessed without having to call into this API again
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
		if not tunable then
			return false, S("Setting @1 doesn't exist", params[1])
		end

		minetest.log("action", "[vl_tuning] "..name.." set ".. params[1] .." to "..params[2])
		tunable:set(params[2])
		return true
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

minetest.register_chatcommand("gamerule", {
	description = S("Display or set customizable options"),
	params = S("<rule> [<value>]"),
	privs = { server = true },
	func = function(name, params_raw)
		-- Split apart the params
		local params = {}
		for str in string.gmatch(params_raw, "([^ ]+)") do
			params[#params + 1] = str
		end

		if #params < 1 or #params > 2 then
			return false, S("Usage: /gamerule <rule> [<value>]")
		end

		local tunable = tunables["gamerule:"..params[1]]
		if not tunable then
			return false, S("Game rule @1 doesn't exist", params[1])
		end

		local value = params[2]
		if value then
			minetest.log("action", "[vl_tuning] Setting game rule "..params[1].." to "..params[2])
			tunable:set(params[2])
			return true
		else
			return true, tunable:get_string()
		end
	end
})

