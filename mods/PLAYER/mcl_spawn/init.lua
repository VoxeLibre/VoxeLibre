mcl_spawn = {}

local S = minetest.get_translator(minetest.get_current_modname())
local storage = minetest.get_mod_storage()

local function mcl_log (message)
	mcl_util.mcl_log (message, "[Spawn]")
end

-- Resolution of search grid in nodes.
local res = 64
local half_res = 32 -- for emerge areas around the position
local alt_min = -10
local alt_max = 200
-- Number of points checked in the square search grid (edge * edge).
local checks = 128 * 128
-- Starting point for biome checks. This also sets the y co-ordinate for all
-- points checked, so the suitable biomes must be active at this y.
local start_pos = minetest.setting_get_pos("static_spawnpoint") or {x = 0, y = 8, z = 0}

-- Bed spawning offsets
local node_search_list =
	{
	--[[1]]	{x =  0, y = 0, z = -1},	--
	--[[2]]	{x = -1, y = 0, z =  0},	--
	--[[3]]	{x = -1, y = 0, z =  1},	--
	--[[4]]	{x =  0, y = 0, z =  2},	-- z^ 8 4 9
	--[[5]]	{x =  1, y = 0, z =  1},	--  | 3   5
	--[[6]]	{x =  1, y = 0, z =  0},	--  | 2 * 6
	--[[7]]	{x = -1, y = 0, z = -1},	--  | 7 1 A
	--[[8]]	{x = -1, y = 0, z =  2},	--  +----->
	--[[9]]	{x =  1, y = 0, z =  2},	--	x
	--[[A]]	{x =  1, y = 0, z = -1},	--
	--[[B]]	{x =  0, y = 1, z =  0},	--
	--[[C]]	{x =  0, y = 1, z =  1},	--
	}

-- End of parameters
--------------------


-- Initial variables

local return_spawn = minetest.settings:get_bool("mcl_return_spawn", true)
local wsp = minetest.string_to_pos(storage:get_string("mcl_spawn_world_spawn_point")) or nil -- world spawn position


local function get_far_node(pos)
	local node = minetest.get_node(pos)
	if node.name ~= "ignore" then
		return node
	end
	minetest.get_voxel_manip():read_from_map(pos, pos)
	return minetest.get_node(pos)
end

local function good_for_respawn(pos, player)
	local pos0 = {x = pos.x, y = pos.y - 1, z = pos.z}
	local pos1 = {x = pos.x, y = pos.y, z = pos.z}
	local pos2 = {x = pos.x, y = pos.y + 1, z = pos.z}
	local node0 = get_far_node(pos0)
	local node1 = get_far_node(pos1)
	local node2 = get_far_node(pos2)

	local nn0, nn1, nn2 = node0.name, node1.name, node2.name
	if	   minetest.get_item_group(nn0, "destroys_items") ~=0
		or minetest.get_item_group(nn1, "destroys_items") ~=0
		or minetest.get_item_group(nn2, "destroys_items") ~=0
		or minetest.get_item_group(nn0, "portal") ~=0
		or minetest.get_item_group(nn1, "portal") ~=0
		or minetest.get_item_group(nn2, "portal") ~=0
		or minetest.is_protected(pos0, player or "")
		or minetest.is_protected(pos1, player or "")
		or minetest.is_protected(pos2, player or "")
		or (not player and minetest.get_node_light(pos1, 0.5) < 8)
		or (not player and minetest.get_node_light(pos2, 0.5) < 8)
		or nn0 == "ignore"
		or nn1 == "ignore"
		or nn2 == "ignore"
		   then
			return false
	end

	local def0 = minetest.registered_nodes[nn0]
	local def1 = minetest.registered_nodes[nn1]
	local def2 = minetest.registered_nodes[nn2]
	return def0.walkable and (not def1.walkable) and (not def2.walkable) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0) and
		(def1.damage_per_second == nil or def2.damage_per_second <= 0)
end


function mcl_spawn.get_world_spawn_pos()
	local ssp = minetest.setting_get_pos("static_spawnpoint")
	return ssp or wsp or start_pos
end

-- Returns a spawn position of player.
-- If player is nil or not a player, a world spawn point is returned.
-- The second return value is true if returned spawn point is player-chosen,
-- false otherwise.
function mcl_spawn.get_bed_spawn_pos(player)
	local spawn, custom_spawn = nil, false
	if player and player:is_player() then
		local attr = player:get_meta():get_string("mcl_beds:spawn")
		if attr and attr ~= "" then
			spawn = minetest.string_to_pos(attr)
			custom_spawn = true
		end
	end
	if not spawn or spawn == "" then
		spawn = mcl_spawn.get_world_spawn_pos()
		custom_spawn = false
	end
	return spawn, custom_spawn
end

-- Sets the player's spawn position to pos.
-- Set pos to nil to clear the spawn position.
-- If message is set, informs the player with a chat message when the spawn position
-- changed.
function mcl_spawn.set_spawn_pos(player, pos, message)
	local spawn_changed = false
	local meta = player:get_meta()
	if pos == nil then
		if meta:get_string("mcl_beds:spawn") ~= "" then
			spawn_changed = true
			if message then
				minetest.chat_send_player(player:get_player_name(), S("Respawn position cleared!"))
			end
		end
		meta:set_string("mcl_beds:spawn", "")
	else
		local oldpos = minetest.string_to_pos(meta:get_string("mcl_beds:spawn"))
		meta:set_string("mcl_beds:spawn", minetest.pos_to_string(pos))

		-- Set player ownership on bed
		local bed_node = minetest.get_node(pos)
		local bed_meta = minetest.get_meta(pos)

		local bed_bottom = mcl_beds.get_bed_bottom (pos)
		local bed_bottom_meta = minetest.get_meta(bed_bottom)

		if bed_meta then
			if bed_node then
				mcl_log("Bed name: " .. bed_node.name)
			end

			mcl_log("Setting bed meta: " .. player:get_player_name())
			bed_meta:set_string("player", player:get_player_name())

			-- Pass in villager as arg. Shouldn't know about villagers
			if bed_bottom_meta then
				mcl_log("Removing villager from bed bottom meta")
				bed_bottom_meta:set_string("villager", "")
			else
				mcl_log("Cannot remove villager from bed bottom meta")
			end



			if oldpos and oldpos ~= pos then
				local old_bed_meta = minetest.get_meta(oldpos)
				if old_bed_meta then
					mcl_log("Removing old bed meta")
					old_bed_meta:set_string("player", "")
				end
			else
				mcl_log("No old bed meta to remove or same as current")
			end
		end

		if oldpos then
			-- We don't bother sending a message if the new spawn pos is basically the same
			spawn_changed = vector.distance(pos, oldpos) > 0.1
		else
			-- If it wasn't set and now it will be set, it means it is changed
			spawn_changed = true
		end
		if spawn_changed and message then
			minetest.chat_send_player(player:get_player_name(), S("New respawn position set!"))
		end
	end
	return spawn_changed
end

function mcl_spawn.get_player_spawn_pos(player)
	local pos, custom_spawn = mcl_spawn.get_bed_spawn_pos(player)
	if pos and custom_spawn then
		-- Check if bed is still there
		local node_bed = get_far_node(pos)
		local bgroup = minetest.get_item_group(node_bed.name, "bed")
		if bgroup ~= 1 and bgroup ~= 2 then
			-- Bed is destroyed:
			if player and player:is_player() then
				local checkpos = minetest.string_to_pos(player:get_meta():get_string("mcl_beds:spawn"))
				local checknode = minetest.get_node(checkpos)

				if(string.match(checknode.name, "mcl_beds:respawn_anchor_charged_")) then
					local charge_level = tonumber(string.sub(checknode.name, -1))
					if not charge_level and return_spawn then
						minetest.log("warning","could not get level of players respawn anchor, sending him back to spawn!")
						player:get_meta():set_string("mcl_beds:spawn", "")
						minetest.chat_send_player(player:get_player_name(), S("Couldn't get level of your respawn anchor!"))
						return mcl_spawn.get_world_spawn_pos(), false
					elseif charge_level ~= 1 then
						minetest.set_node(checkpos, {name="mcl_beds:respawn_anchor_charged_".. charge_level-1})
						return checkpos, false
					else
						minetest.set_node(checkpos, {name="mcl_beds:respawn_anchor"})
						return checkpos, false
					end
				elseif return_spawn then
					player:get_meta():set_string("mcl_beds:spawn", "")
					minetest.chat_send_player(player:get_player_name(), S("Your spawn bed was missing or blocked, and you had no charged respawn anchor!"))
					return mcl_spawn.get_world_spawn_pos(), false
				else
					return checkpos, false
				end
			end
		end



		-- Find spawning position on/near the bed free of solid or damaging blocks iterating a square spiral 15x15:

		local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
		local offset
		for _, o in ipairs(node_search_list) do
			if dir.z == -1 then
				offset = {x =  o.x, y = o.y,  z =  o.z}
			elseif dir.z == 1 then
				offset = {x = -o.x, y = o.y,  z = -o.z}
			elseif dir.x == -1 then
				offset = {x =  o.z, y = o.y,  z = -o.x}
			else -- dir.x == 1
				offset = {x = -o.z, y = o.y,  z =  o.x}
			end
			local player_spawn_pos = vector.add(pos, offset)
			if good_for_respawn(player_spawn_pos, player:get_player_name()) then
				return player_spawn_pos, true
			end
		end
		-- We here if we didn't find suitable place for respawn
	end
	return mcl_spawn.get_world_spawn_pos(), false
end

function mcl_spawn.spawn(player)
	local pos, in_bed = mcl_spawn.get_player_spawn_pos(player)
	if in_bed then player:set_pos(pos) end
	return in_bed
end

-- Respawn player at specified respawn position
minetest.register_on_respawnplayer(mcl_spawn.spawn)
