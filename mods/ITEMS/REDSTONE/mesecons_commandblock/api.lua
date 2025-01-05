mesecon = mesecon or {}
local mod = {}
mesecon.commandblock = mod

local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape
local color_red = mcl_colors.RED

mod.initialize = function(meta)
	meta:set_string("commands", "")
	meta:set_string("commander", "")
end

mod.place = function(meta, placer)
	if not placer then return end

	meta:set_string("commander", placer:get_player_name())
end

mod.resolve_commands = function(commands, meta, pos)
	local players = minetest.get_connected_players()
	local commander = meta:get_string("commander")

	-- A non-printable character used while replacing “@@”.
	local SUBSTITUTE_CHARACTER = "\26" -- ASCII SUB

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
local resolve_commands = mod.resolve_commands

mod.check_commands = function(commands, player_name)
	for _, command in pairs(commands:split("\n")) do
		local pos = command:find(" ")
		local cmd = command
		if pos then
			cmd = command:sub(1, pos - 1)
		end
		local cmddef = minetest.chatcommands[cmd]
		if not cmddef then
			-- Invalid chat command
			local msg = S("Error: The command “@1” does not exist; your command block has not been changed. Use the “help” chat command for a list of available commands.", cmd)
			if string.sub(cmd, 1, 1) == "/" then
				msg = S("Error: The command “@1” does not exist; your command block has not been changed. Use the “help” chat command for a list of available commands. Hint: Try to remove the leading slash.", cmd)
			end
			return false, minetest.colorize(color_red, msg)
		end
		if player_name then
			local player_privs = minetest.get_player_privs(player_name)

			for cmd_priv, _ in pairs(cmddef.privs) do
				if player_privs[cmd_priv] ~= true then
					local msg = S("Error: You have insufficient privileges to use the command “@1” (missing privilege: @2)! The command block has not been changed.", cmd, cmd_priv)
					return false, minetest.colorize(color_red, msg)
				end
			end
		end
	end
	return true
end
local check_commands = mod.check_commands

mod.action_on = function(meta, pos)
	local commander = meta:get_string("commander")
	local commands = resolve_commands(meta:get_string("commands"), meta, pos)
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
		cmddef.func(commander, param)
	end
end

local formspec_metas = {}

mod.handle_rightclick = function(meta, player, pos)
	local can_edit = true
	-- Only allow write access in Creative Mode
	if not minetest.is_creative_enabled(player:get_player_name()) then
		can_edit = false
	end
	local pname = player:get_player_name()
	if minetest.is_protected(pos, pname) then
		can_edit = false
	end
	local privs = minetest.get_player_privs(pname)
	if not privs.maphack then
		can_edit = false
	end

	local commands = meta:get_string("commands")
	if not commands then
		commands = ""
	end
	local commander = meta:get_string("commander")
	local commanderstr
	if commander == "" or commander == nil then
		commanderstr = S("Error: No commander! Block must be replaced.")
	else
		commanderstr = S("Commander: @1", commander)
	end
	local textarea_name, submit, textarea
	-- If editing is not allowed, only allow read-only access.
	-- Player can still view the contents of the command block.
	if can_edit then
		textarea_name = "commands"
		submit = "button_exit[3.3,4.4;2,1;submit;"..F(S("Submit")).."]"
	else
		textarea_name = ""
		submit = ""
	end
	if not can_edit and commands == "" then
		textarea = "label[0.5,0.5;"..F(S("No commands.")).."]"
	else
		textarea = "textarea[0.5,0.5;8.5,4;"..textarea_name..";"..F(S("Commands:"))..";"..F(commands).."]"
	end
	local formspec = "size[9,5;]" ..
	textarea ..
	submit ..
	"image_button[8,4.4;1,1;doc_button_icon_lores.png;doc;]" ..
	"tooltip[doc;"..F(S("Help")).."]" ..
	"label[0,4;"..F(commanderstr).."]"

	-- Store the metadata object for later use
	local fs_id = #formspec_metas + 1
	formspec_metas[fs_id] = meta
	print("using fs_id="..tostring(fs_id)..",meta="..tostring(meta)..",formspec_metas[fs_id]="..tostring(formspec_metas[fs_id]))

	minetest.show_formspec(pname, "commandblock_"..tostring(fs_id), formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 13) == "commandblock_" then
		-- Show documentation
		if fields.doc and minetest.get_modpath("doc") then
			doc.show_entry(player:get_player_name(), "nodes", "mesecons_commandblock:commandblock_off", true)
			return
		end

		-- Validate form fields
		if (not fields.submit and not fields.key_enter) or (not fields.commands) then
			return
		end

		-- Check privileges
		local privs = minetest.get_player_privs(player:get_player_name())
		if not privs.maphack then
			minetest.chat_send_player(player:get_player_name(), S("Access denied. You need the “maphack” privilege to edit command blocks."))
			return
		end

		-- Check game mode
		if not minetest.is_creative_enabled(player:get_player_name()) then
			minetest.chat_send_player(player:get_player_name(),
				S("Editing the command block has failed! You can only change the command block in Creative Mode!")
			)
			return
		end

		-- Retrieve the metadata object this formspec data belongs to
		local index, _, fs_id = string.find(formname, "commandblock_(-?%d+)")
		fs_id = tonumber(fs_id)
		if not index or not fs_id or not formspec_metas[fs_id] then
			print("index="..tostring(index)..", fs_id="..tostring(fs_id).."formspec_metas[fs_id]="..tostring(formspec_metas[fs_id]))
			minetest.chat_send_player(player:get_player_name(), S("Editing the command block has failed! The command block is gone."))
			return
		end
		local meta = formspec_metas[fs_id]
		formspec_metas[fs_id] = nil

		-- Verify the command
		local check, error_message = check_commands(fields.commands, player:get_player_name())
		if check == false then
			-- Command block rejected
			minetest.chat_send_player(player:get_player_name(), error_message)
			return
		end

		-- Update the command in the metadata
		meta:set_string("commands", fields.commands)
	end
end)
