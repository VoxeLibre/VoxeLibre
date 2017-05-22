--[[
	PlayerPlus by TenPlus1
]]

-- Player state for public API
playerplus = {}

-- Internal player state
local playerplus_internal = {}

-- get node but use fallback for nil or unknown
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

local armor_mod = minetest.get_modpath("3d_armor")
local def = {}
local time = 0

local get_player_nodes = function(player_pos)
	local work_pos = table.copy(player_pos)

	-- what is around me?
	work_pos.y = work_pos.y - 0.1 -- standing on
	local nod_stand = node_ok(work_pos)
	local nod_stand_below = node_ok({x=work_pos.x, y=work_pos.y-1, z=work_pos.z})

	work_pos.y = work_pos.y + 1.5 -- head level
	local nod_head = node_ok(work_pos)

	work_pos.y = work_pos.y - 1.2 -- feet level
	local nod_feet = node_ok(work_pos)

	return nod_stand, nod_stand_below, nod_head, nod_feet
end

minetest.register_globalstep(function(dtime)

	time = time + dtime

	-- Update jump status immediately since we need this info in real time.
	-- WARNING: This section is HACKY as hell since it is all just based on heuristics.
	for _,player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		if playerplus_internal[name].jump_cooldown > 0 then
			playerplus_internal[name].jump_cooldown = playerplus_internal[name].jump_cooldown - dtime
		end
		if player:get_player_control().jump and playerplus_internal[name].jump_cooldown <= 0 then

			local pos = player:getpos()

			local nod_stand, nod_stand_below, nod_head, nod_feet = get_player_nodes(pos)

			-- Cause buggy exhaustion for jumping

			--[[ Checklist we check to know the player *actually* jumped:
				* Not on or in liquid
				* Not on or at climbable
				* On walkable
				* Not on disable_jump
			FIXME: This code is pretty hacky and it is possible to miss some jumps or detect false
			jumps because of delays, rounding errors, etc.
			What this code *really* needs is some kind of jumping “callback” which this engine lacks
			as of 0.4.15.
			]]

			if minetest.get_item_group(nod_feet, "liquid") == 0 and
					minetest.get_item_group(nod_stand, "liquid") == 0 and
					not minetest.registered_nodes[nod_feet].climbable and
					not minetest.registered_nodes[nod_stand].climbable and
					(minetest.registered_nodes[nod_stand].walkable or minetest.registered_nodes[nod_stand_below].walkable)
					and minetest.get_item_group(nod_stand, "disable_jump") == 0
					and minetest.get_item_group(nod_stand_below, "disable_jump") == 0 then
			-- Cause exhaustion for jumping
			mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_JUMP)

			-- Reset cooldown timer
				playerplus_internal[name].jump_cooldown = 0.45
			end
		end
	end

	-- Run the rest of the code every 0.5 seconds
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
		local pos = player:getpos()

		-- what is around me?
		local nod_stand, nod_stand_below, nod_head, nod_feet = get_player_nodes(pos)
		playerplus[name].nod_stand = nod_stand
		playerplus[name].nod_stand_below = nod_stand_below
		playerplus[name].nod_head = nod_head
		playerplus[name].nod_feet = nod_feet

		-- set defaults
		def.speed = 1
		def.jump = 1
		def.gravity = 1

		-- is 3d_armor mod active? if so make armor physics default
		if armor_mod and armor and armor.def then
			-- get player physics from armor
			def.speed = armor.def[name].speed or 1
			def.jump = armor.def[name].jump or 1
			def.gravity = armor.def[name].gravity or 1
		end

		-- standing on soul sand? if so walk slower
		if playerplus[name].nod_stand == "mcl_nether:soul_sand" then
			-- TODO: Tweak walk speed
			-- TODO: Also slow down mobs
			-- FIXME: This whole speed thing is a giant hack. We need a proper framefork for cleanly handling player speeds
			local below = playerplus[name].nod_stand_below 
			if below == "mcl_core:ice" or below == "mcl_core:packed_ice" or below == "mcl_core:slimeblock" then
				def.speed = def.speed - 0.9
			else
				def.speed = def.speed - 0.6
			end
		end

		-- set player physics
		-- TODO: Resolve conflict
		player:set_physics_override(def.speed, def.jump, def.gravity)

		-- Is player suffocating inside node? (Only for solid full opaque cube type nodes
		-- without group disable_suffocation=1)
		local ndef = minetest.registered_nodes[playerplus[name].nod_head]

		if (ndef.walkable == nil or ndef.walkable == true)
		and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
		and (ndef.node_box == nil or ndef.node_box.type == "regular")
		and (ndef.groups.disable_suffocation ~= 1)
		and (ndef.groups.opaque == 1)
		-- Check privilege, too
		and (not minetest.check_player_privs(name, {noclip = true})) then
			if player:get_hp() > 0 then
				player:set_hp(player:get_hp() - 1)
			end
		end

		-- am I near a cactus?
		local near = minetest.find_node_near(pos, 1, "mcl_core:cactus")

		if near then
			-- am I touching the cactus? if so it hurts
			for _,object in pairs(minetest.get_objects_inside_radius(near, 1.1)) do
				if object:get_hp() > 0 then
					object:set_hp(object:get_hp() - 1)
					if object:is_player() then
						mcl_hunger.exhaust(object:get_player_name(), mcl_hunger.EXHAUST_DAMAGE)
					end
				end
			end

		end

		-- Apply black sky in the Void and deal Void damage
		if pos.y < mcl_vars.mg_bedrock_overworld_max then
			-- Player reached the void, set black sky box
			player:set_sky("#000000", "plain")
			-- FIXME: Sky handling in MCL2 is held together with lots of duct tape.
			-- This only works beause weather_pack currently does not touch the sky for players below the height used for this check.
			-- There should be a real skybox API.
		end
		local void, void_deadly = mcl_util.is_in_void(pos)
		if void_deadly then
			-- Player is deep into the void, deal void damage
			if player:get_hp() > 0 then
				player:set_hp(player:get_hp() - 4)
			end
		end

		--[[ Swimming: Cause exhaustion.
		NOTE: As of 0.4.15, it only counts as swimming when you are with the feet inside the liquid!
		Head alone does not count. We respect that for now. ]]
		if minetest.get_item_group(playerplus[name].nod_feet, "liquid") ~= 0 and
				minetest.get_item_group(playerplus[name].nod_stand, "liquid") ~= 0 then
			local lastPos = playerplus_internal[name].lastPos
			if lastPos then
				local dist = vector.distance(lastPos, pos)
				playerplus_internal[name].swimDistance = playerplus_internal[name].swimDistance + dist
				if playerplus_internal[name].swimDistance >= 1 then
					local superficial = math.floor(playerplus_internal[name].swimDistance)
					mcl_hunger.exhaust(name, mcl_hunger.EXHAUST_SWIM * superficial)
					playerplus_internal[name].swimDistance = playerplus_internal[name].swimDistance - superficial
				end
			end

		end

		-- Underwater: Spawn bubble particles
		if minetest.get_item_group(playerplus[name].nod_head, "water") ~= 0 then

			minetest.add_particlespawner({
				amount = 10,
				time = 0.15,
				minpos = { x = -0.25, y = 0.3, z = -0.25 },
				maxpos = { x = 0.25, y = 0.7, z = 0.75 },
				attached = player,
				minvel = {x = -0.2, y = 0, z = -0.2},
				maxvel = {x = 0.5, y = 0, z = 0.5},
				minacc = {x = -0.4, y = 4, z = -0.4},
				maxacc = {x = 0.5, y = 1, z = 0.5},
				minexptime = 0.3,
				maxexptime = 0.8,
				minsize = 0.7,
				maxsize = 2.4,
				texture = "mcl_particles_bubble.png"
			})
		end

		-- Show positions of barriers when player is wielding a barrier
		if player:get_wielded_item():get_name() == "mcl_core:barrier" then
			local pos = vector.round(player:getpos())
			local r = 8
			local vm = minetest.get_voxel_manip()
			local emin, emax = vm:read_from_map({x=pos.x-r, y=pos.y-r, z=pos.z-r}, {x=pos.x+r, y=pos.y+r, z=pos.z+r})
			local area = VoxelArea:new{
				MinEdge = emin,
				MaxEdge = emax,
			}
			local data = vm:get_data()
			for x=pos.x-r, pos.x+r do
			for y=pos.y-r, pos.y+r do
			for z=pos.z-r, pos.z+r do
				local vi = area:indexp(pos)
				local node = minetest.get_name_from_content_id(data[vi])
				if minetest.get_node({x=x,y=y,z=z}).name == "mcl_core:barrier" then
					minetest.add_particle({
						pos = {x=x, y=y, z=z},
						expirationtime = 1,
						size = 8,
						texture = "default_barrier.png",
						playername = name
					})
				end
			end
			end
			end
		end

		-- Update internal values
		playerplus_internal[name].lastPos = pos

	end

end)

-- set to blank on join (for 3rd party mods)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()

	playerplus[name] = {
		nod_head = "",
		nod_feet = "",
		nod_stand = "",
	}

	playerplus_internal[name] = {
		lastPos = nil,
		swimDistance = 0,
		jump_cooldown = -1,	-- Cooldown timer for jumping, we need this to prevent the jump exhaustion to increase rapidly
	}
end)

-- clear when player leaves
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	playerplus[name] = nil
	playerplus_internal[name] = nil
end)
