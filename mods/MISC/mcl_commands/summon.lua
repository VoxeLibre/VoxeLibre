local S = minetest.get_translator("mcl_commands")

local orig_func = minetest.registered_chatcommands["spawnentity"].func
local cmd = table.copy(minetest.registered_chatcommands["spawnentity"])
cmd.func = function(name, param)
	local ent = minetest.registered_entities[param]
	if minetest.settings:get_bool("only_peaceful_mobs", false) and ent and ent._cmi_is_mob and ent.type == "monster" then
		return false, S("Only peaceful mobs allowed!")
	else
		local bool, msg = orig_func(name, param)
		return bool, msg
	end
end
minetest.unregister_chatcommand("spawnentity")
minetest.register_chatcommand("summon", cmd)