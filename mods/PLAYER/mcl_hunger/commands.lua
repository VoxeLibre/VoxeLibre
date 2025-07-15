local S = minetest.get_translator(minetest.get_current_modname())

minetest.register_chatcommand("hunger", {
	params = S("[on|off]"),
	description = S("Toggle hunger and starvation mechanics"),
	privs = { server = true },
	func = function(name, params)
		local ps = {}
		local i = 0
		for s in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			ps[i] = string.lower(s)
		end

		local flag = minetest.settings:get_bool("mcl_enable_hunger", true)

		if not ps[1] then
			if flag then
				return true, S("Hunger is currently enabled.")
			end
			return true, S("Hunger is currently disabled.")
		elseif ps[1] == "on" then
			if flag then
				return false, S("Hunger is already on.")
			end
			minetest.settings:set_bool("mcl_enable_hunger", true)
			return true, S("Hunger enabled.")
		elseif ps[1] == "off" then
			if not flag then
				return false, S("Hunger is already off.")
			end
			minetest.settings:set_bool("mcl_enable_hunger", false)
			return true, S("Hunger disabled.")
		else
			return false, S("Invalid parameter.")
		end
	end
})

minetest.register_chatcommand("hunger_debug", {
	params = S("[show|hide]"),
	description = S("Toggle hunger and starvation debug information"),
	privs = { server = true },
	func = function(name, params)
		local ps = {}
		local i = 0
		for s in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			ps[i] = string.lower(s)
		end

		local flag = minetest.settings:get_bool("mcl_hunger_debug", false)

		if not ps[1] then
			if flag then
				return true, S("Hunger debug information is currently enabled.")
			end
			return true, S("Hunger debug information is currently disabled.")
		elseif ps[1] == "show" then
			if flag then
				return false, S("Hunger debug information is already shown.")
			end
			minetest.settings:set_bool("mcl_hunger_debug", true)
			return true, S("Hunger debug information shown.")
		elseif ps[1] == "hide" then
			if not flag then
				return false, S("Hunger debug information is already hidden.")
			end
			minetest.settings:set_bool("mcl_hunger_debug", false)
			return true, S("Hunger debug information hidden.")
		else
			return false, S("Invalid parameter.")
		end
	end
})