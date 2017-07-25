
local function initialize_data(meta)
	local commands = minetest.formspec_escape(meta:get_string("commands"))
end

local function construct(pos)
	local meta = minetest.get_meta(pos)

	meta:set_string("commands", "")
	initialize_data(meta)
end

local function after_place(pos, placer)
	if placer then
		local meta = minetest.get_meta(pos)
		initialize_data(meta)
	end
end

local function resolve_commands(commands, pos)
	local players = minetest.get_connected_players()

	-- No players online: remove all commands containing
	-- @nearest, @farthest and @random
	if #players == 0 then
		commands = commands:gsub("[^\r\n]+", function (line)
			if line:find("@nearest") then return "" end
			if line:find("@farthest") then return "" end
			if line:find("@random") then return "" end
			return line
		end)
		return commands
	end

	local nearest, farthest = nil, nil
	local min_distance, max_distance = math.huge, -1
	for index, player in pairs(players) do
		local distance = vector.distance(pos, player:getpos())
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
	commands = commands:gsub("@nearest", nearest)
	commands = commands:gsub("@farthest", farthest)
	commands = commands:gsub("@random", random)
	return commands
end

local function check_commands(commands)
	for _, command in pairs(commands:split("\n")) do
		local pos = command:find(" ")
		local cmd, param = command, ""
		if pos then
			cmd = command:sub(1, pos - 1)
		end
		local cmddef = minetest.chatcommands[cmd]
		if not cmddef then
			-- Invalid chat command
			return false, cmd
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
		local pos = command:find(" ")
		local cmd, param = command, ""
		if pos then
			cmd = command:sub(1, pos - 1)
			param = command:sub(pos + 1)
		end
		local cmddef = minetest.chatcommands[cmd]
		if not cmddef then
			-- Invalid chat command
			return
		end
		local dummy_player = ""
		cmddef.func(dummy_player, param)
	end
end

local function commandblock_action_off(pos, node)
	if node.name == "mesecons_commandblock:commandblock_on" then
		minetest.swap_node(pos, {name = "mesecons_commandblock:commandblock_off"})
	end
end

local on_rightclick = function(pos, node, player, itemstack, pointed_thing)
	-- Only allow access in Creative Mode
	if not minetest.setting_getbool("creative_mode") then
		return
	end

	local meta = minetest.get_meta(pos)
	local commands = meta:get_string("commands")
	local formspec = "invsize[9,5;]" ..
	"textarea[0.5,0.5;8.5,4;commands;Commands;"..commands.."]" ..
	"label[1,3.8;@nearest, @farthest, and @random are replaced by the respective player names]" ..
	"button_exit[3.3,4.5;2,1;submit;Submit]" ..
	"image_button[8,4.5;1,1;doc_button_icon_lores.png;doc;]" ..
	"tooltip[doc;Help]"
	minetest.show_formspec(player:get_player_name(), "commandblock_"..pos.x.."_"..pos.y.."_"..pos.z, formspec)
end

minetest.register_node("mesecons_commandblock:commandblock_off", {
	description = "Command Block",

	_doc_items_longdesc =
"Command blocks are mighty redstone components which are able to alter reality itself. In other words, they cause the server to execute server commands when they are supplied with redstone power.",
	_doc_items_usagehelp =
[[Using a command block which someone already placed and set up properly is easy: Just supply it with redstone power and see what happens. This will execute the commands once. To execute the commands again, turn the redstone power off and on again.

Changing the commands or breaking the command block is only possible in Creative Mode. Directly after placing, a command block does not have any commands and does nothing. Rightclick the command block (in Creative Mode!) to edit its commands. Refer to the help entry about server commands to understand how they work. Each line contains a single command, the commands will be executed from top to bottom. The commands DO NOT require a leading slash.

You can optionally use the following placeholders in your commands:
• “@nearest” is replaced by the name of the player nearest to the command block
• “@farthest” is replaced by the name of the player farthest away from the command block
• “@random” is replaced by the name of a random player currently connected]],

	tiles = {{name="jeija_commandblock_off.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=2}}},
	groups = {creative_breakable=1, mesecon_effector_off=1, not_in_creative_inventory=1},
	drop = "",
	on_blast = function() end,
	on_construct = construct,
	is_ground_content = false,
	after_place_node = after_place,
	on_rightclick = on_rightclick,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_on = commandblock_action_on
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
	after_place_node = after_place,
	on_rightclick = on_rightclick,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {effector = {
		action_off = commandblock_action_off
	}},
	_mcl_blast_resistance = 18000000,
	_mcl_hardness = -1,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 13) == "commandblock_" then
		if not fields.submit and not fields.doc then
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
			if not minetest.setting_getbool("creative_mode") then
				minetest.chat_send_player(player:get_player_name(), "Editing the command block has failed! You can only change the command block in Creative Mode!")
				return
			end
			local check, bad_command = check_commands(fields.commands)
			if check == false then
				local msg
				if bad_command ~= nil and bad_command ~= "" then
					msg = "Warning: The command “"..bad_command.."” does not exist; your command block won't do anything. See the help command for a list of available commands."
					if string.sub(bad_command, 1, 1) == "/" then
						msg = msg .. " Hint: Try to remove the trailing slash"
					end
				else
					msg = "Warning: You have entered an unknown command; your command block won't do anything.. See the help command for a list of available commands."
				end
				minetest.chat_send_player(player:get_player_name(), msg)
			end

			meta:set_string("commands", fields.commands)
			initialize_data(meta)
		else
			minetest.chat_send_player(player:get_player_name(), "Editing the command block has failed! The command block is gone.")
		end
	end
end)

-- Add entry alias for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_commandblock:commandblock_off", "nodes", "mesecons_commandblock:commandblock_on")
end
