local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local mod = {}
vl_tuning = mod

local tunables = {}

function mod.register_tunable(name, default, setting, setting_type)
	local tunable = {
		[1] = default,
		setting = setting,
		setting_type = setting_type,
	}
	if setting then
		if setting_type == "bool" then
			tunable[1] = minetest.settings:get_bool(.setting)
		else
			tunable[1] = minetest.settings:get(setting)
		end
	end
end

minetest.register_chatcommand("tune", {
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
	end
})

