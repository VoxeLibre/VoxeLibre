local minecraftaliases = true

local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s,a,...)a={a,...}return s:gsub("@(%d+)",function(n)return a[tonumber(n)]end)end
end

local function handle_clear_command(giver, receiver)
	local receiverref = minetest.get_player_by_name(receiver)
	if receiverref == nil then
		return false, S("Player @1 does not exist.", receiver)
	end
	if receiverref:get_inventory():is_empty("main") then
		if giver == receiver then
			return false, S("Your inventory is already clear.")
		else
			return false, S("@1's inventory is already clear.", receiver)
		end
	end
	if not giver == receiver then
		minetest.log("action", S("@1 cleared @2's inventory", giver, receiver))
	end
	for i=0,receiverref:get_inventory():get_size("main") do
		receiverref:get_inventory():set_stack("main", i, nil)
	end
	if giver == receiver then
		return true, S("Your inventory was cleared.")
	else
		minetest.chat_send_player(receiver, S("Your inventory was cleared."))
		return true, S("@1's inventory was cleared.", receiver)
	end
end

local function handle_kill_command(suspect, victim)
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
	if not suspect == victim then
		minetest.log("action", S("@1 killed @2", suspect, victim))
	end
	victimref:set_hp(0)
end

minetest.register_privilege("clear", {
	description = S("Can use /clear"),
	give_to_singleplayer = false
})
minetest.register_privilege("kill", {
	description = S("Can use /kill"),
	give_to_singleplayer = false,
})
minetest.register_privilege("announce", {
	description = S("Can use /say"),
	give_to_singleplayer = false,
})

minetest.register_chatcommand("clear", {
	params = S("<name>"),
	description = S("Clear inventory of player"),
	privs = {clear=true},
	func = function(name, param)
		return handle_clear_command(name, param)
	end,
})

minetest.register_chatcommand("kill", {
	params = S("[<name>]"),
	description = S("Kill player"),
	privs = {kill=true},
	func = function(name, param)
		if(param == "") then
			-- Selfkill
			return handle_kill_command(name, name)
		else
			return handle_kill_command(name, param)
		end
	end,
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

minetest.register_chatcommand("setnode", {
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
		return false, S("Invalid parameters (see /help setnode)")
	end,
})

local function register_chatcommand_alias(alias, cmd)
	local def = minetest.chatcommands[cmd]
	minetest.register_chatcommand(alias, def)
end

if minecraftaliases then
	register_chatcommand_alias("?", "help")
	register_chatcommand_alias("list", "status")
	register_chatcommand_alias("pardon", "unban")
	register_chatcommand_alias("setblock", "setnode")
	register_chatcommand_alias("stop", "shutdown")
	register_chatcommand_alias("summon", "spawnentity")
	register_chatcommand_alias("tell", "msg")
	register_chatcommand_alias("w", "msg")
	register_chatcommand_alias("tp", "teleport")

	minetest.register_chatcommand("banlist", {
		description = S("List bans"),
		privs = minetest.chatcommands["ban"].privs,
		func = function(name)
			return true, S("Ban list: @1", core.get_ban_list())
		end,
	})
end
