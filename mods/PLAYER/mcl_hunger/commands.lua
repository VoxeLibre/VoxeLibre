local S = core.get_translator(core.get_current_modname())

core.register_chatcommand("hunger", {
	params = S("[on|off]"),
	description = S("Toggle hunger and starvation mechanics"),
	privs = { server = true },
	func = function(name, params)
		local ps = string.split(string.lower(params), " ")
		local flag = mcl_hunger.get_active()

		if not ps[1] then
			if flag then
				return true, S("Hunger is currently enabled.")
			end
			return true, S("Hunger is currently disabled.")
		elseif ps[1] == "on" then
			if flag then
				return false, S("Hunger is already on.")
			end
			mcl_hunger.set_active(true)
			return true, S("Hunger enabled.")
		elseif ps[1] == "off" then
			if not flag then
				return false, S("Hunger is already off.")
			end
			mcl_hunger.set_active(false)
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
		local ps = string.split(string.lower(params), " ")
		local flag = mcl_hunger.get_debug()

		if not ps[1] then
			if flag then
				return true, S("Hunger debug information is currently enabled.")
			end
			return true, S("Hunger debug information is currently disabled.")
		elseif ps[1] == "show" then
			if flag then
				return false, S("Hunger debug information is already shown.")
			end
			mcl_hunger.set_debug(true)
			return true, S("Hunger debug information shown.")
		elseif ps[1] == "hide" then
			if not flag then
				return false, S("Hunger debug information is already hidden.")
			end
			mcl_hunger.set_debug(false)
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
	params      = S("[player] [0-20]"),
	description = S("Set a player's hunger level."),
	privs       = { hunger = true },
	func        = function(name, params)
		local ps = {}
		local i = 0
		for s in string.gmatch(params, "([^ ]+)") do
			i = i + 1
			ps[i] = string.lower(s)
		end

		local pname, plevel --- @type string?, string?
		if #ps == 0 then
			return false, S("Player name and/or hunger level is required.")
		elseif #ps == 1 then
			pname, plevel = name, ps[1]
		elseif #ps > 1 then
			pname, plevel = ps[1], ps[2]
		end
		-- Validate player parameter
		--

		local player = core.get_player_by_name(pname)
		if not player then
			return false, S("Player not found.")
		end

		-- Validate hunger parameter
		--
		if plevel == nil then
			return false, S("Hunger level is required.")
		end
		local level = tonumber(plevel)
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
