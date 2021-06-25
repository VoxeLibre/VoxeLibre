local S = minetest.get_translator(minetest.get_current_modname())
local C = minetest.colorize

--TODO: like mc error message
--TODO: complex command handling
--TODO: mc like help system

mcl_commands.types = {
	bool = {
		lengh = 1,
		msg = S("Invalid boolean"),
		func = function(word)
			if word == "true" then
				return true, true
			elseif world == "false" then
				return true, false
			else
				return false, nil
			end
		end,
	},
	int = {
		lengh = 1,
		msg = S("Invalid integer"),
		func = function(int)
			if tonumber(int) and tonumber(int) == math.round(int) then
				return true, tonumber(int)
			else
				return false, nil
			end
		end,
	},
	float = {
		lengh = 1,
		msg = S("Invalid integer"),
		func = function(float)
			if tonumber(float) then
				return true, tonumber(float)
			else
				return false, nil
			end
		end,
	},
	word = {
		lengh = 1,
		msg = S("Invalid word"),
		func = function(word)
			if word then
				return true, word
			else
				return false, nil
			end
		end,
	},
	text = {},
	pos = {
		lengh = 3,
		msg = S("Invalid position"),
		func = function(x, y, z)
			--FIXME
			if true then
				return true, nil
			else
				return false, nil
			end
		end,
	},
	target = {
		lengh = 1,
		msg = S("Invalid target selector"),
		func = function(target)
			--mcl_commands.get_target_selector(target_selector)
			if minetest.player_exists(target) then
				return true, target
			else
				return false, nil
			end
		end,
	},
	playername = {
		lengh = 1,
		msg = S("Invalid player name"),
		func = function(name)
			if minetest.player_exists(name) then
				return true, name
			else
				return false, nil
			end
		end,
	},
}

function mcl_commands.match_param(table, index, type, params)
	local typedef = mcl_commands.types[type]
	if typedef.lengh > 1 then
		return
	else
		local params = {}
		typedef.func()
	end
end

mcl_commands.registered_commands = {}

function mcl_commands.register_complex_command()
end

--aims to avoid complexity for basic commands while keeping proper messages and privs management
function mcl_commands.register_basic_command(name, def)
	local func
	if def.params then
		func = function(name, param)
			local funcparams = {}
			local i = 0
			for str in string.gmatch(params, "([^ ]+)") do
				i = i + 1
				funcparams[i] = str
			end
			for _,type in pairs(def.params) do
				mcl_commands.match_param(funcparams, index, type, params)
			end
		end
	else
		mcl_commands.registered_commands[name] = {type = "basic", description = def.desc, privs = def.privs}
		func = function(name, param)
			if param == "" then
				local out, msg = def.func(name)
				if out then
					return true, C(mcl_colors.GRAY, msg) or C(mcl_colors.GRAY, S("succesful"))
				else
					return false, C(mcl_colors.RED, msg) or C(mcl_colors.RED, S("failed"))
				end
			else
				return false, C(mcl_colors.RED, S("Invalid command usage"))
			end
		end
	end
	minetest.register_chatcommand(name, {
		description = def.desc,
		privs = def.privs,
		func = func,
	})
end

--[[
mcl_commands.register_basic_command("test", {
	description = S("testing command"),
	params = nil,
	func = function(name)
	end,
})
]]

mcl_commands.register_basic_command("testb", {
	description = S("testing command"),
	params = {
		{type="bool"},
		{type="int", params={min=1, max=10}}
	},
	func = function(name, bool, int)
		return true, "test: "..int
	end,
})

function mcl_commands.alias_command(alias, original_name, bypass_setting)
	if minetest.settings:get_bool("mcl_builtin_commands_overide", true) or bypass_setting then
		local def = minetest.registered_chatcommands[original_name]
		minetest.register_chatcommand(alias, def)
		minetest.log("action", string.format("[mcl_commands] Aliasing [%s] command to [%s]", original_name, alias))
	else
		minetest.log("action", string.format("[mcl_commands] Aliasing [%s] command to [%s] skipped according to setting", original_name, alias))
	end
end

function mcl_commands.rename_command(new_name, original_name, bypass_setting)
	if minetest.settings:get_bool("mcl_builtin_commands_overide", true) or bypass_setting then
		local def = minetest.registered_chatcommands[original_name]
		minetest.register_chatcommand(new_name, def)
		minetest.unregister_chatcommand(original_name)
		minetest.log("action", string.format("[mcl_commands] Renaming [%s] command to [%s]", original_name, new_name))
	else
		minetest.log("action", string.format("[mcl_commands] Renaming [%s] command to [%s] skipped according to setting", original_name, new_name))
	end
end


--0: succesfull, table
--1: not connected player, nil
--2: invalid target selector, nil
function mcl_commands.get_target_selector(target_selector)
	if minetest.player_exists(target_selector) then
		local obj = minetest.get_player_by_name(target_selector)
		if obj then
			return 0, {obj}
		else
			return 1, nil
		end
	else
		return 0, {}
	end
end