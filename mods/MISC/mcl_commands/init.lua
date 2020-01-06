local minecraftaliases = true

local S = minetest.get_translator("mcl_commands")

local mod_death_messages = minetest.get_modpath("mcl_death_messages")

local function handle_kill_command(suspect, victim)
	if minetest.settings:get_bool("enable_damage") == false then
		return false, S("Players can't be killed right now, damage has been disabled.")
	end
	local victimref = minetest.get_player_by_name(victim)
	if victimref == nil then
		return false, S("Player @1 does not exist.", victim)
	elseif victimref:get_hp() <= 0 then
		if suspect == victim then
			return false, S("You are already dead")
		else
			return false, S("@1 is already dead", victim)
		end
	end
	-- If player holds a totem of undying, destroy it before killing,
	-- so it doesn't rescue the player.
	local wield = victimref:get_wielded_item()
	if wield:get_name() == "mobs_mc:totem" then
		victimref:set_wielded_item("")
	end
	if mod_death_messages then
		local msg
		if suspect == victim then
			msg = S("@1 committed suicide.", victim)
		else
			msg = S("@1 was killed by @2.", victim, suspect)
		end
		mcl_death_messages.player_damage(victimref, msg)
	end
	-- DIE!
	victimref:set_hp(0)
	-- Log
	if not suspect == victim then
		minetest.log("action", string.format("%s killed %s using /kill", suspect, victim))
	else
		minetest.log("action", string.format("%s committed suicide using /kill", victim))
	end
	return true
end

if minetest.registered_chatcommands["kill"] then
	minetest.unregister_chatcommand("kill")
end
minetest.register_chatcommand("kill", {
	params = S("[<name>]"),
	description = S("Kill player or yourself"),
	privs = {server=true},
	func = function(name, param)
		if(param == "") then
			-- Selfkill
			return handle_kill_command(name, name)
		else
			return handle_kill_command(name, param)
		end
	end,
})

minetest.register_privilege("announce", {
	description = S("Can use /say"),
	give_to_singleplayer = false,
})
minetest.register_chatcommand("say", {
	params = S("<message>"),
	description = S("Send a message to every player"),
	privs = {announce=true},
	func = function(name, param)
		if not param then
			return false, S("Invalid usage, see /help say.")
		end
		minetest.chat_send_all(("["..name.."] "..param))
		return true
	end,
})

minetest.register_chatcommand("setblock", {
	params = S("<X>,<Y>,<Z> <NodeString>"),
	description = S("Set node at given position"),
	privs = {give=true, interact=true},
	func = function(name, param)
		local p = {}
		local nodestring = nil
		p.x, p.y, p.z, nodestring = param:match("^([%d.-]+)[, ] *([%d.-]+)[, ] *([%d.-]+) +(.+)$")
		p.x, p.y, p.z = tonumber(p.x), tonumber(p.y), tonumber(p.z)
		if p.x and p.y and p.z and nodestring then
			local itemstack = ItemStack(nodestring)
			if itemstack:is_empty() or not minetest.registered_nodes[itemstack:get_name()] then
				return false, S("Invalid node")
			end
			minetest.set_node(p, {name=nodestring})
			return true, S("@1 spawned.", nodestring)
		end
		return false, S("Invalid parameters (see /help setblock)")
	end,
})

minetest.register_chatcommand("list", {
	description = S("Show who is logged on"),
	params = "",
	privs = {},
	func = function(name)
		local players = ""
		for _, player in ipairs(minetest.get_connected_players()) do
			players = players..player:get_player_name().."\n"
		end
		minetest.chat_send_player(name, players)
	end
})

minetest.register_chatcommand("seed", {
	description = S("Displays the world seed"),
	params = "",
	privs = {},
	func = function(name)
		minetest.chat_send_player(name, minetest.get_mapgen_setting("seed"))
	end
})

local function register_chatcommand_alias(alias, cmd)
	local def = minetest.chatcommands[cmd]
	minetest.register_chatcommand(alias, def)
end

-- Replace spawnentity cmd to disallow spawning of hostile mobs if disabled
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
minetest.register_chatcommand("spawnentity", cmd)

if minecraftaliases then
	register_chatcommand_alias("?", "help")
	register_chatcommand_alias("who", "list")
	register_chatcommand_alias("pardon", "unban")
	register_chatcommand_alias("stop", "shutdown")
	register_chatcommand_alias("summon", "spawnentity")
	register_chatcommand_alias("tell", "msg")
	register_chatcommand_alias("w", "msg")
	register_chatcommand_alias("tp", "teleport")
	register_chatcommand_alias("clear", "clearinv")

	minetest.register_chatcommand("banlist", {
		description = S("List bans"),
		privs = minetest.chatcommands["ban"].privs,
		func = function(name)
			return true, S("Ban list: @1", minetest.get_ban_list())
		end,
	})
end

