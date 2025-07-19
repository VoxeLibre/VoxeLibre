local S = core.get_translator(core.get_current_modname())

core.register_chatcommand("hunger", {
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

		local flag = core.settings:get_bool("mcl_enable_hunger", true)

		if not ps[1] then
			if flag then
				return true, S("Hunger is currently enabled.")
			end
			return true, S("Hunger is currently disabled.")
		elseif ps[1] == "on" then
			if flag then
				return false, S("Hunger is already on.")
			end
			core.settings:set_bool("mcl_enable_hunger", true)
			return true, S("Hunger enabled.")
		elseif ps[1] == "off" then
			if not flag then
				return false, S("Hunger is already off.")
			end
			core.settings:set_bool("mcl_enable_hunger", false)
			return true, S("Hunger disabled.")
		else
			return false, S("Invalid parameter.")
		end
	end
})

core.register_chatcommand("hunger_debug", {
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

		local flag = core.settings:get_bool("mcl_hunger_debug", false)

		if not ps[1] then
			if flag then
				return true, S("Hunger debug information is currently enabled.")
			end
			return true, S("Hunger debug information is currently disabled.")
		elseif ps[1] == "show" then
			if flag then
				return false, S("Hunger debug information is already shown.")
			end
			core.settings:set_bool("mcl_hunger_debug", true)
			return true, S("Hunger debug information shown.")
		elseif ps[1] == "hide" then
			if not flag then
				return false, S("Hunger debug information is already hidden.")
			end
			core.settings:set_bool("mcl_hunger_debug", false)
			return true, S("Hunger debug information hidden.")
		else
			return false, S("Invalid parameter.")
		end
	end
})

core.register_privilege("hunger", {
	description          = S("Gives the ability to set player hunger level."),
	give_to_singleplayer = false
})

--- @param n number?
--- @return boolean
local function is_whole(n)
	if n == nil then
		return false
	end
	return n % 1 == 0
end
	

core.register_chatcommand("sethunger", {
	params      = S("<player> [0-20]"),
	description = S("Set a player's hunger level."),
	privs       = { hunger = true },
	func        = function(name, params)
		local ps = {}
		local i = 0
		for s in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			ps[i] = string.lower(s)
		end

		local pname  = ps[1] --- @type string?
		local plevel = ps[2] --- @type string?
		
		local player --- @type table?
		local level  --- @type number?

		-- Validate player parameter
		--
		if not pname then
			return false, S("A player name (or 'me') is required.")
		end
		if pname == "me" then
			player = core.get_player_by_name(name)
		else
			player = core.get_player_by_name(pname)
		end
		if not player then
			return false, S("Player not found.")
		end

		-- Validate hunger parameter
		--
		if plevel == nil then
			return false, S("Missing hunger parameter.")
		end
		level = tonumber(plevel)
		if level == nil or not is_whole(level) or level < 0 or level > 20 then
			return false, S("Hunger parameter must be a whole number from 0 to 20.")
		end

		-- All parameter validations passed.
		mcl_hunger.set_hunger(player, level, true)
		mcl_hunger.set_saturation(player, 0, true)
		mcl_hunger.set_exhaustion(player, 0, true)

		return true, S("Done!")
	end
})
