-- Player state for public API
mcl_playerinfo = {}

local storage = core.get_mod_storage()
local player_mod_metadata = {}

local vector_copy = vector.copy
local get_node_name = mcl_vars.get_node_name
local get_node_name_raw = mcl_vars.get_node_name_raw
local registered_nodes = core.registered_nodes

local IGNORE = { name = "ignore", groups = {} } -- pseudo node definition

local time = 0
core.register_globalstep(function(dtime)
	-- Run the rest of the code about every 0.5 seconds
	time = time + dtime
	if time < 0.5 then return end
	time = 0

	-- check players
	for _,player in pairs(core.get_connected_players()) do
		local name = player:get_player_name()
		local pos = player:get_pos()
		local playerinfo = mcl_playerinfo[name]

		local tmp = vector_copy(pos)
		-- Standing on
		playerinfo.stand_on   = registered_nodes[get_node_name_raw(pos.x, pos.y - 0.1, pos.z)] or IGNORE
		-- One further below
		-- TODO: drop this? currently only used in jump hack and soul sand
		playerinfo.stand_over = registered_nodes[get_node_name_raw(pos.x, pos.y - 1.1, pos.z)] or IGNORE
		-- Head level (eye height 1.6?)
		-- TODO: if flying or swimming, this is not the actual head position
		playerinfo.head_in    = registered_nodes[get_node_name_raw(pos.x, pos.y + 1.4, pos.z)] or IGNORE
		-- Top of head level, at collision box height
		playerinfo.head_top   = registered_nodes[get_node_name_raw(pos.x, pos.y + 1.9, pos.z)] or IGNORE
		-- Feet level
		playerinfo.feet_in    = registered_nodes[get_node_name_raw(pos.x, pos.y + 0.2, pos.z)] or IGNORE

		-- compatibility layer for mods
		playerinfo.node_stand = playerinfo.stand_on.name
		playerinfo.node_stand_below = playerinfo.stand_over.name
		playerinfo.node_head = playerinfo.head_in.name
		playerinfo.node_head_top = playerinfo.head_top.name
		playerinfo.node_feet = playerinfo.feet_in.name
	end
end)

function mcl_playerinfo.get_mod_meta(player_name, modname)
	-- Load the player's metadata
	local meta = player_mod_metadata[player_name]
	meta = meta or core.deserialize(storage:get_string(player_name)) or {}
	player_mod_metadata[player_name] = meta

	-- Get the requested module's section of the metadata
	local mod_meta = meta[modname] or {}
	meta[modname] = mod_meta
	return mod_meta
end

-- Initialize on join
core.register_on_joinplayer(function(player)
	mcl_playerinfo[player:get_player_name()] = {
		stand_on   = IGNORE,
		stand_over = IGNORE,
		head_in    = IGNORE,
		head_top   = IGNORE,
		feet_in    = IGNORE,
	}
end)

-- clear when player leaves
core.register_on_leaveplayer(function(player)
	mcl_playerinfo[player:get_player_name()] = nil
end)

core.register_on_shutdown(function()
	for name,data in pairs(player_mod_metadata) do
		storage:set_string(name, core.serialize(data))
	end
end)
