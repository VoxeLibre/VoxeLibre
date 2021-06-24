mcl_commands.types = {
	bool = {},
	int = {},
	float = {},
	word = {},
	text = {},
	pos = {},
	target = {},
	playername = {},
}

function mcl_commands.register_complex_command()
end

function mcl_commands.register_basic_command()
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

function mcl_commands.get_target_selector(target_selector)
end