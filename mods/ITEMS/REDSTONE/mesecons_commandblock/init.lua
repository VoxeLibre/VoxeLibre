local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(minetest.get_current_modname())

-- Initialize API
dofile(modpath.."/api.lua")
local api = mesecon.commandblock

local command_blocks_activated = minetest.settings:get_bool("mcl_enable_commandblocks", true)
local msg_not_activated = S("Command blocks are not enabled on this server")

local function construct(pos)
	local meta = minetest.get_meta(pos)
	api.initialize(meta)
end

local function after_place(pos, placer)
	local meta = minetest.get_meta(pos)
	api.place(meta, placer)
end

local function resolve_commands(commands, pos)
	local meta = minetest.get_meta(pos)
	return api.resolve_commands(commands, meta)
end

local function commandblock_action_on(pos, node)
	if node.name ~= "mesecons_commandblock:commandblock_off" then
		return
	end

	local meta = minetest.get_meta(pos)

	if not command_blocks_activated then
		--minetest.chat_send_player(commander, msg_not_activated)
		return
	end
	minetest.swap_node(pos, {name = "mesecons_commandblock:commandblock_on"})

	api.action_on(meta, pos)
end

local function commandblock_action_off(pos, node)
	if node.name == "mesecons_commandblock:commandblock_on" then
		minetest.swap_node(pos, {name = "mesecons_commandblock:commandblock_off"})
	end
end

local function on_rightclick(pos, node, player, itemstack, pointed_thing)
	if not command_blocks_activated then
		minetest.chat_send_player(player:get_player_name(), msg_not_activated)
		return
	end

	local meta = minetest.get_meta(pos)
	api.handle_rightclick(meta, player, pos)
end

local function on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" then
		return itemstack
	end

	-- Use pointed node's on_rightclick function first, if present
	local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if new_stack then
		return new_stack
	end

	local privs = minetest.get_player_privs(placer:get_player_name())
	if not privs.maphack then
		minetest.chat_send_player(placer:get_player_name(), S("Placement denied. You need the “maphack” privilege to place command blocks."))
		return itemstack
	end

	return minetest.item_place_node(itemstack, placer, pointed_thing)
end

minetest.register_node("mesecons_commandblock:commandblock_off", {
	description = S("Command Block"),

	_tt_help = S("Executes server commands when powered by redstone power"),
	_doc_items_longdesc =
S("Command blocks are mighty redstone components which are able to alter reality itself. In other words, they cause the server to execute server commands when they are supplied with redstone power."),
	_doc_items_usagehelp =
S("Everyone can activate a command block and look at its commands, but not everyone can edit and place them.").."\n\n"..

S("To view the commands in a command block, use it. To activate the command block, just supply it with redstone power. This will execute the commands once. To execute the commands again, turn the redstone power off and on again.")..
"\n\n"..

S("To be able to place a command block and change the commands, you need to be in Creative Mode and must have the “maphack” privilege. A new command block does not have any commands and does nothing. Use the command block (in Creative Mode!) to edit its commands. Read the help entry “Advanced usage > Server Commands” to understand how commands work. Each line contains a single command. You enter them like you would in the console, but without the leading slash. The commands will be executed from top to bottom.").."\n\n"..

S("All commands will be executed on behalf of the player who placed the command block, as if the player typed in the commands. This player is said to be the “commander” of the block.").."\n\n"..

S("Command blocks support placeholders, insert one of these placeholders and they will be replaced by some other text:").."\n"..
S("• “@@c”: commander of this command block").."\n"..
S("• “@@n” or “@@p”: nearest player from the command block").."\n"..
S("• “@@f” farthest player from the command block").."\n"..
S("• “@@r”: random player currently in the world").."\n"..
S("• “@@@@”: literal “@@” sign").."\n\n"..

S("Example 1:\n    time 12000\nSets the game clock to 12:00").."\n\n"..

S("Example 2:\n    give @@n mcl_core:apple 5\nGives the nearest player 5 apples"),

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
	_mcl_blast_resistance = 3600000,
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
	_mcl_blast_resistance = 3600000,
	_mcl_hardness = -1,
})

-- Add entry alias for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_commandblock:commandblock_off", "nodes", "mesecons_commandblock:commandblock_on")
end
