
local function construct(pos)
	local meta = minetest.get_meta(pos)

	meta:set_string("commands", "")
	meta:set_string("commander", "")
end

local function after_place(pos, placer)
	if placer then
		local meta = minetest.get_meta(pos)
		meta:set_string("commander", placer:get_player_name())
	end
end

local function resolve_commands(commands, pos)
	local players = minetest.get_connected_players()

	local meta = minetest.get_meta(pos)
	local commander = meta:get_string("commander")

	-- A non-printable character used while replacing “@@”.
	local SUBSTITUTE_CHARACTER = '\26' -- ASCII SUB

	-- No players online: remove all commands containing
	-- problematic placeholders.
	if #players == 0 then
		commands = commands:gsub("[^\r\n]+", function (line)
			line = line:gsub("@@", SUBSTITUTE_CHARACTER)
			if line:find("@n") then return "" end
			if line:find("@p") then return "" end
			if line:find("@f") then return "" end
			if line:find("@r") then return "" end
			line = line:gsub("@c", commander)
			line = line:gsub(SUBSTITUTE_CHARACTER, "@")
			return line
		end)
		return commands
	end

	local nearest, farthest = nil, nil
	local min_distance, max_distance = math.huge, -1
	for index, player in pairs(players) do
		local distance = vector.distance(pos, player:get_pos())
		if distance < min_distance then
			min_distance = distance
			nearest = player:get_player_name()
		end
		if distance > max_distance then
			max_distance = distance
			farthest = player:get_player_name()
		end
	end
	local random = players[math.random(#players)]:get_player_name()
	commands = commands:gsub("@@", SUBSTITUTE_CHARACTER)
	commands = commands:gsub("@p", nearest)
	commands = commands:gsub("@n", nearest)
	commands = commands:gsub("@f", farthest)
	commands = commands:gsub("@r", random)
	commands = commands:gsub("@c", commander)
	commands = commands:gsub(SUBSTITUTE_CHARACTER, "@")
	return commands
end

local function check_commands(commands, player_name)
	for _, command in pairs(commands:split("\n")) do
		local pos = command:find(" ")
		local cmd, param = command, ""
		if pos then
			cmd = command:sub(1, pos - 1)
		end
		local cmddef = minetest.chatcommands[cmd]
		if not cmddef then
			-- Invalid chat command
			local msg = "Error: The command “"..cmd.."” does not exist; your command block has not been changed. Use the “help” chat command for a list of available commands."
			if string.sub(cmd, 1, 1) == "/" then
				msg = msg .. " Hint: Try to remove the trailing slash."
			end
			return false, minetest.colorize("#FF0000", msg)
		end
		if player_name then
			local player_privs = minetest.get_player_privs(player_name)

			for cmd_priv, _ in pairs(cmddef.privs) do
				if player_privs[cmd_priv] ~= true then
					local msg = "Error: You have insufficient privileges to use the command “"..cmd.."” (missing privilege: "..cmd_priv..")! The command block has not been changed."
					return false, minetest.colorize("#FF0000", msg)
				end
			end
		end
	end
	return true
end

local function commandblock_action_on(pos, node)
	if node.name ~= "mesecons_commandblock:commandblock_off" then
		return
	end

	minetest.swap_node(pos, {name = "mesecons_commandblock:commandblock_on"})

	local meta = minetest.get_meta(pos)

	local commands = resolve_commands(meta:get_string("commands"), pos)
	for _, command in pairs(commands:split("\n")) do
		local cpos = command:find(" ")
		local cmd, param = command, ""
		if cpos then
			cmd = command:sub(1, cpos - 1)
			param = command:sub(cpos + 1)
		end
		local cmddef = minetest.chatcommands[cmd]
		if not cmddef then
			-- Invalid chat command
			return
		end
		-- Execute command in the name of commander
		local commander = meta:get_string("commander")
		cmddef.func(commander, param)
	end
end

local function commandblock_action_off(pos, node)
	if node.name == "mesecons_commandblock:commandblock_on" then
		minetest.swap_node(pos, {name = "mesecons_commandblock:commandblock_off"})
	end
end

local on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	-- Only allow access in Creative Mode
	if not minetest.settings:get_bool("creative_mode") then
		return
	end
	local pname = player:get_player_name()
	if minetest.is_protected(pos, pname) then
		minetest.record_protection_violation(pos, pname)
		return
	end
	local privs = minetest.get_player_privs(pname)
	if not privs.maphack then
		minetest.chat_send_player(pname, "Access denied. You need the “maphack” privilege to edit command blocks.")
		return
	end

	local meta = minetest.get_meta(pos)
	local commands = meta:get_string("commands")
	local commander = meta:get_string("commander")
	local commanderstr
	if commander == "" or commander == nil then
		commanderstr = "Error: No commander! Block must be replaced."
	else
		commanderstr = "Commander: "..commander
	end
	local formspec = "invsize[9,5;]" ..
	"textarea[0.5,0.5;8.5,4;commands;Commands;"..commands.."]" ..
	"button_exit[3.3,4.5;2,1;submit;Submit]" ..
	"image_button[8,4.5;1,1;doc_button_icon_lores.png;doc;]" ..
	"label[0,4;"..minetest.formspec_escape(commanderstr).."]" ..
	"tooltip[doc;Help]"
	minetest.show_formspec(pname, "commandblock_"..pos.x.."_"..pos.y.."_"..pos.z, formspec)
end

local on_place = function(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end

	-- Use pointed node's on_rightclick function first, if present
	local node = minetest.get_node(pointed_thing.under)
	if placer and not placer:get_player_control().sneak then
		if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
			return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack) or itemstack
		end
	end

	local privs = minetest.get_player_privs(placer:get_player_name())
	if not privs.maphack then
		minetest.chat_send_player(placer:get_player_name(), "Placement denied. You need the “maphack” privilege to place command blocks.")
		return itemstack
	end

	return minetest.item_place_node(itemstack, placer, pointed_thing)
end

minetest.register_node("mesecons_commandblock:commandblock_off", {
	description = "Command Block",

	_doc_items_longdesc =
"Command blocks are mighty redstone components which are able to alter reality itself. In other words, they cause the server to execute server commands when they are supplied with redstone power.",
	_doc_items_usagehelp =
[[To use an already existing command block, just supply it with redstone power and see what happens. This will execute the commands once. To execute the commands again, turn the redstone power off and on again.

To place a command block and change the commands, you need to be in Creative Mode and must have the “maphack” privilege. A new command block does not have any commands and does nothing. Rightclick the command block (in Creative Mode!) to edit its commands. Read the help entry “Advanced topics > Server Commands” to understand how they work. Each line contains a single command. You enter them like you would in the console, but without the leading slash. The commands will be executed from top to bottom.

All commands will be executed on behalf of the player who placed the command block, as if the player typed in the commands. This player is said to be the “commander” of the block.

Command blocks support placeholders, insert one of these placerholders and they will be replaced by a player name:
• “@c”: commander of this command block
• “@n” or “@p”: nearest player from the command block
• “@f” farthest player from the command block
• “@r”: random player currently in the world
• “@@”: literal “@” sign

Example 1:
    time 12000

Sets the game clock to 12:00

Example 2:
    give @n mcl_core:apple 5

→ Gives the nearest player 5 apples]],

	tiles = {{name="jeija_commandblock_off.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=2}}},
	groups = {creative_breakable=1, mesecon_effector_off=1},
	drop = "",
	on_blast = function() end,
	on_construct = construct,
	is_ground_content = false,
	on_place = on_place,
	after_place_node = after_place,
	on_rightclick = on_rightclick,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = commandblock_action_on,
		rules = mesecon.rules.alldirs,
	}},
	_mcl_blast_resistance = 18000000,
	_mcl_hardness = -1,
})

minetest.register_node("mesecons_commandblock:commandblock_on", {
	tiles = {{name="jeija_commandblock_off.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=2}}},
	groups = {creative_breakable=1, mesecon_effector_on=1, not_in_creative_inventory=1},
	drop = "",
	on_blast = function() end,
	on_construct = construct,
	is_ground_content = false,
	on_place = on_place,
	after_place_node = after_place,
	on_rightclick = on_rightclick,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_off = commandblock_action_off,
		rules = mesecon.rules.alldirs,
	}},
	_mcl_blast_resistance = 18000000,
	_mcl_hardness = -1,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 13) == "commandblock_" then
		if not fields.submit and not fields.key_enter and not fields.doc then
			return
		end
		local privs = minetest.get_player_privs(player:get_player_name())
		if not privs.maphack then
			minetest.chat_send_player(player:get_player_name(), "Access denied. You need the “maphack” privilege to edit command blocks.")
			return
		end

		if fields.doc and minetest.get_modpath("doc") then
			doc.show_entry(player:get_player_name(), "nodes", "mesecons_commandblock:commandblock_off", true)
			return
		end
		local index, _, x, y, z = string.find(formname, "commandblock_(-?%d+)_(-?%d+)_(-?%d+)")
		if index ~= nil and x ~= nil and y ~= nil and z ~= nil then
			local pos = {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
			local meta = minetest.get_meta(pos)
			if not minetest.settings:get_bool("creative_mode") then
				minetest.chat_send_player(player:get_player_name(), "Editing the command block has failed! You can only change the command block in Creative Mode!")
				return
			end
			local check, error_message = check_commands(fields.commands, player:get_player_name())
			if check == false then
				-- Command block rejected
				minetest.chat_send_player(player:get_player_name(), error_message)
				return
			else
				meta:set_string("commands", fields.commands)
			end
		else
			minetest.chat_send_player(player:get_player_name(), "Editing the command block has failed! The command block is gone.")
		end
	end
end)

-- Add entry alias for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_commandblock:commandblock_off", "nodes", "mesecons_commandblock:commandblock_on")
end
