local S = minetest.get_translator(minetest.get_current_modname())

--TODO: like mc error message
--TODO: complex command handling

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
	float = {},
	word = {},
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
	target = {},
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

function mcl_commands.register_complex_command()
end

function mcl_commands.register_basic_command(name, def)
end

function mcl_commands.alias_command(alias, original_name, bypass_setting)
	if minetest.settings:get_bool("mcl_builtin_commands_overide", true) or bypass_setting then
		local def = minetest.registered_chatcommands[cmd]
		minetest.register_chatcommand(alias, def)
		minetest.log("action", string.format("[mcl_commands] Aliasing [%s] command to [%s]", original_name, alias))
	else
		minetest.log("action", string.format("[mcl_commands] Aliasing [%s] command to [%s] skipped according to setting", original_name, alias))
	end
end

function mcl_commands.rename_command(new_name, original_name, bypass_setting)
	if minetest.settings:get_bool("mcl_builtin_commands_overide", true) or bypass_setting then
		local def = minetest.registered_chatcommands[cmd]
		minetest.register_chatcommand(newname, def)
		minetest.unregister_chatcommand(cmd)
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