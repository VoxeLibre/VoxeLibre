local table = table

local storage = minetest.get_mod_storage()

-- Player state for public API
mcl_playerinfo = {}
local player_mod_metadata = {}

-- Get node but use fallback for nil or unknown
local function node_ok(pos, fallback)

	fallback = fallback or "air"

	local node = minetest.get_node_or_nil(pos)

	if not node then
		return fallback
	end

	if minetest.registered_nodes[node.name] then
		return node.name
	end

	return fallback
end

local function get_player_nodes(player_pos)
	local work_pos = table.copy(player_pos)

	-- what is around me?
	work_pos.y = work_pos.y - 0.1 -- standing on
	local node_stand = node_ok(work_pos)
	local node_stand_below = node_ok({x=work_pos.x, y=work_pos.y-1, z=work_pos.z})

	work_pos.y = work_pos.y + 1.5 -- head level
	local node_head = node_ok(work_pos)
	work_pos.y = work_pos.y + 0.5 -- top of head level, at collision box height
	local node_head_top = node_ok(work_pos)
	work_pos.y = work_pos.y - 0.5

	work_pos.y = work_pos.y - 1.2 -- feet level
	local node_feet = node_ok(work_pos)

	return node_stand, node_stand_below, node_head, node_feet, node_head_top
end

local time = 0
minetest.register_globalstep(function(dtime)
	-- Run the rest of the code every 0.5 seconds
	time = time + dtime
	if time < 0.5 then
		return
	end

	-- reset time for next check
	-- FIXME: Make sure a regular check interval applies
	time = 0

	-- check players
	for _,player in pairs(minetest.get_connected_players()) do
		-- who am I?
		local name = player:get_player_name()

		-- where am I?
		local pos = player:get_pos()

		-- what is around me?
		local node_stand, node_stand_below, node_head, node_feet, node_head_top = get_player_nodes(pos)
		mcl_playerinfo[name].node_stand = node_stand
		mcl_playerinfo[name].node_stand_below = node_stand_below
		mcl_playerinfo[name].node_head = node_head
		mcl_playerinfo[name].node_feet = node_feet
		mcl_playerinfo[name].node_head_top = node_head_top

	end

end)

function mcl_playerinfo.get_mod_meta(player_name, modname)
	-- Load the player's metadata
	local meta = player_mod_metadata[player_name]
	if not meta then
		meta = minetest.deserialize(storage:get_string(player_name))
	end
	if not meta then
		meta = {}
	end
	player_mod_metadata[player_name] = meta

	-- Get the requested module's section of the metadata
	local mod_meta = meta[modname] or {}
	meta[modname] = mod_meta
	return mod_meta
end

-- set to blank on join (for 3rd party mods)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	mcl_playerinfo[name] = {
		node_head = "",
		node_feet = "",
		node_stand = "",
		node_stand_below = "",
		node_head_top = "",
	}
end)

-- clear when player leaves
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	mcl_playerinfo[name] = nil
end)

minetest.register_on_shutdown(function()
	for name,data in pairs(player_mod_metadata) do
		storage:set_string(name, minetest.serialize(data))
	end
end)
