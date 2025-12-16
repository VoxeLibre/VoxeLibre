mcl_playerplus = {
	elytra = {},
	is_pressing_jump = {},
}

local get_connected_players = minetest.get_connected_players
local dir_to_yaw = minetest.dir_to_yaw
local get_item_group = minetest.get_item_group
local check_player_privs = minetest.check_player_privs
local find_node_near = minetest.find_node_near
local get_name_from_content_id = minetest.get_name_from_content_id
local get_voxel_manip = minetest.get_voxel_manip
local add_particle = minetest.add_particle
local add_particlespawner = minetest.add_particlespawner

local is_sprinting = mcl_sprint.is_sprinting
local exhaust = mcl_hunger.exhaust
local playerphysics = playerphysics

local vector = vector
local math = math
local PI = math.pi
local TWOPI = math.pi * 2

-- Internal player state
local mcl_playerplus_internal = {}

-- Could occassionally hit about 4.6 but servers and high power machines struggle to keep up with this.
-- Until mapgen can keep up, it's best to limit for server performance etc.
local elytra_vars = {
	slowdown_mult = 0.0, -- amount of vel to take per sec
	fall_speed = 0.2, -- amount of vel to fall down per sec
	speedup_mult = 2, -- amount of speed to add based on look dir
	max_speed = tonumber(minetest.settings:get("mcl_elytra_max_speed")) or 4.0, -- was 6 max amount to multiply against look direction when flying
	pitch_penalty = 1.3, -- if pitching up, slow down at this rate as a multiplier
	rocket_speed = tonumber(minetest.settings:get("mcl_elytra_rocket_speed")) or 3.5, --was 5.5
}

--minetest.log("action", "elytra_vars.max_speed: " .. dump(elytra_vars.max_speed))
--minetest.log("action", "elytra_vars.rocket_speed: " .. dump(elytra_vars.rocket_speed))

local time = 0
local look_pitch = 0

local function player_collision(player)

	local pos = player:get_pos()
	--local vel = player:get_velocity()
	local x = 0
	local z = 0
	local width = .75

	for _,object in pairs(minetest.get_objects_inside_radius(pos, width)) do

		local ent = object:get_luaentity()
		if (object:is_player() or (ent and ent.is_mob and object ~= player)) then

			local pos2 = object:get_pos()
			local vec  = {x = pos.x - pos2.x, z = pos.z - pos2.z}
			local force = (width + 0.5) - vector.distance(
				{x = pos.x, y = 0, z = pos.z},
				{x = pos2.x, y = 0, z = pos2.z})

			x = x + (vec.x * force)
			z = z + (vec.z * force)
		end
	end
	return {x,z}
end

local function walking_player(player, control)
	return not not (control.up or control.down or control.left or control.right)
end

local function dir_to_pitch(dir)
	return -math.atan2(-dir.y, math.sqrt(dir.x * dir.x + dir.z * dir.z))
end

local player_vel_yaws = {}

function limit_vel_yaw(player_vel_yaw, yaw)
	player_vel_yaw = player_vel_yaw % TWOPI
	yaw = yaw % TWOPI

	if math.abs(player_vel_yaw - yaw) > 0.7 then
		local player_vel_yaw_nm, yaw_nm = player_vel_yaw, yaw
		if player_vel_yaw > yaw then
			player_vel_yaw_nm = player_vel_yaw - TWOPI
		else
			yaw_nm = yaw - TWOPI
		end
		if math.abs(player_vel_yaw_nm - yaw_nm) > 0.7 then
			local diff = math.abs(player_vel_yaw - yaw)
			if diff > PI and diff < 3.229 or diff < PI and diff > 3.054 then
				player_vel_yaw = yaw
			elseif diff < PI then
				if player_vel_yaw < yaw then
					player_vel_yaw = yaw - 0.7
				else
					player_vel_yaw = yaw + 0.7
				end
			else
				if player_vel_yaw < yaw then
					player_vel_yaw = yaw + 0.7
				else
					player_vel_yaw = yaw - 0.7
				end
			end
		end
	end
	return player_vel_yaw % TWOPI
end

local node_stand, node_stand_below, node_head, node_feet, node_head_top
local is_swimming

-- HACK work around https://github.com/luanti-org/luanti/issues/15692
-- Scales corresponding to default perfect 180° rotations in the character b3d model
local bone_workaround_scales = {
	Body_Control = vector.new(-1, 1, -1),
	Leg_Right = vector.new(1, -1, -1),
	Leg_Left = vector.new(1, -1, -1),
	Cape = vector.new(1, -1, 1),
	Arm_Right_Pitch_Control = vector.new(1, -1, -1),
	Arm_Left_Pitch_Control = vector.new(1, -1, -1),
}

local function set_bone_pos(player, bonename, pos, rot, scale)
	return mcl_util.set_bone_position(
		player,
		bonename,
		pos,
		rot,
		scale or bone_workaround_scales[bonename]
	)
end

local set_properties = mcl_util.set_properties

local function anglediff(a1, a2)
	local a = a1 - a2
	return math.abs((a + math.pi) % (math.pi*2) - math.pi)
end
local function clamp(num, min, max)
	return math.min(max, math.max(num, min))
end



local player_props_elytra = {
	collisionbox = { -0.35, 0, -0.35, 0.35, 0.8, 0.35 },
	eye_height = 0.6,
	nametag_color = { r = 225, b = 225, a = 225, g = 225 }
}
local player_props_riding = {
	collisionbox = { -0.312, 0, -0.312, 0.312, 1.8, 0.312 },
	eye_height = 1.6,
	nametag_color = { r = 225, b = 225, a = 225, g = 225 }
}
local player_props_sneaking = {
	collisionbox = { -0.312, 0, -0.312, 0.312, 1.8, 0.312 },
	eye_height = 1.45,
	nametag_color = { r = 225, b = 225, a = 0, g = 225 }
}
local player_props_swimming = {
	collisionbox = { -0.312, 0, -0.312, 0.312, 0.8, 0.312 },
	eye_height = 0.6,
	nametag_color = { r = 225, b = 225, a = 225, g = 225 }
}
local player_props_normal = {
	collisionbox = { -0.312, 0, -0.312, 0.312, 1.8, 0.312 },
	eye_height = 1.6,
	nametag_color = { r = 225, b = 225, a = 225, g = 225 }
}

minetest.register_globalstep(function(dtime)

	time = time + dtime

	for _,player in pairs(get_connected_players()) do

		--[[

						 _                 _   _
			  __ _ _ __ (_)_ __ ___   __ _| |_(_) ___  _ __  ___
			 / _` | '_ \| | '_ ` _ \ / _` | __| |/ _ \| '_ \/ __|
			| (_| | | | | | | | | | | (_| | |_| | (_) | | | \__ \
			 \__,_|_| |_|_|_| |_| |_|\__,_|\__|_|\___/|_| |_|___/

		]]--

		local control = player:get_player_control()
		local name = player:get_player_name()
		--local meta = player:get_meta()
		local parent = player:get_attach()
		local wielded = player:get_wielded_item()
		local player_velocity = player:get_velocity() or player:get_player_velocity()
		local wielded_def = wielded:get_definition()

		local c_x, c_y = unpack(player_collision(player))

		if player_velocity.x + player_velocity.y < .5 and c_x + c_y > 0 then
			player:add_velocity({x = c_x, y = 0, z = c_y})
			player_velocity = player:get_velocity() or player:get_player_velocity()
		end

		-- control head bone
		local pitch = -player:get_look_vertical()
		local yaw = player:get_look_horizontal()

		local player_vel_yaw = dir_to_yaw(player_velocity)
		if player_vel_yaw == 0 then
			player_vel_yaw = player_vel_yaws[name] or yaw
		end
		player_vel_yaw = limit_vel_yaw(player_vel_yaw, yaw)
		player_vel_yaws[name] = player_vel_yaw

		local fly_pos = player:get_pos()
		local fly_node = minetest.get_node({x = fly_pos.x, y = fly_pos.y - 0.1, z = fly_pos.z}).name
		local elytra = mcl_playerplus.elytra[player]

		if not elytra.active then
			elytra.speed = 0
		end

		if not elytra.last_yaw then
			elytra.last_yaw = player:get_look_horizontal()
		end

		local is_just_jumped = control.jump and not mcl_playerplus.is_pressing_jump[name] and not elytra.active
		mcl_playerplus.is_pressing_jump[name] = control.jump
		if is_just_jumped and not elytra.active then
			local direction = player:get_look_dir()
			elytra.speed = 1 - (direction.y/2 + 0.5)
		end

		local fly_node_walkable = minetest.registered_nodes[fly_node] and minetest.registered_nodes[fly_node].walkable
		elytra.active = minetest.get_item_group(player:get_inventory():get_stack("armor", 3):get_name(), "elytra") ~= 0
			and not parent
			and (elytra.active or (is_just_jumped and player_velocity.y < -0))
			and ((not fly_node_walkable) or fly_node == "ignore")

		if elytra.active then
			if is_just_jumped then -- move the player up when they start flying to give some clearance
				player:set_pos(vector.offset(player:get_pos(), 0, 0.8, 0))
			end
			mcl_player.player_set_animation(player, "fly")
			local direction = player:get_look_dir()
			local player_vel = player:get_velocity()
			local turn_amount = anglediff(minetest.dir_to_yaw(direction), minetest.dir_to_yaw(player_vel))
			local direction_mult = clamp(-(direction.y+0.1), -1, 1)
			if direction_mult < 0 then direction_mult = direction_mult * elytra_vars.pitch_penalty end

			local speed_mult = elytra.speed
			local block_below = minetest.get_node(vector.offset(fly_pos, 0, -0.9, 0)).name
			local reg_node_below = minetest.registered_nodes[block_below]
			if (reg_node_below and not reg_node_below.walkable) and (player_vel.y ~= 0) then
				speed_mult = speed_mult + direction_mult * elytra_vars.speedup_mult * dtime
			end
			speed_mult = speed_mult - elytra_vars.slowdown_mult * clamp(dtime, 0.09, 0.2) -- slow down but don't overdo it
			speed_mult = clamp(speed_mult, -elytra_vars.max_speed, elytra_vars.max_speed)
			if turn_amount > 0.3 and math.abs(direction.y) < 0.98 then -- don't do this if looking straight up / down
				speed_mult = speed_mult - (speed_mult * (turn_amount / (math.pi*8)))
			end

			playerphysics.add_physics_factor(player, "gravity", "mcl_playerplus:elytra", elytra_vars.fall_speed)
			if elytra.rocketing > 0 then
				elytra.rocketing = elytra.rocketing - dtime
				if vector.length(player_velocity) < 40 then
					-- player:add_velocity(vector.multiply(player:get_look_dir(), 4))
					speed_mult = elytra_vars.rocket_speed

					if mcl_util.check_dtime_timer(name, dtime, "ely_rocket_particle_spawn", 0.3) then
						add_particle({
							pos = fly_pos,
							velocity = vector.zero(),
							acceleration = vector.zero(),
							expirationtime = 0.3 + math.random() * 0.2,
							size = math.random(1, 2),
							collisiondetection = false,
							vertical = false,
							texture = "mcl_particles_bonemeal.png^[colorize:#bc7a57:127",
							glow = 5,
						})
					end
				end
			end

			elytra.speed = speed_mult -- set the speed so you can keep track of it and add to it

			local new_vel = vector.multiply(direction, speed_mult * dtime * 30) -- use the look dir and speed as a mult
			-- new_vel.y = new_vel.y - elytra_vars.fall_speed * dtime -- make the player fall a set amount

			-- slow the player down so less spongy movement by applying some of the inverse velocity
			-- NOTE: do not set this higher than about 0.2 or the game will get the wrong vel and it will be broken
			-- this is far from ideal, but there's no good way to set_velocity or slow down the player
			player_vel = vector.multiply(player_vel, -0.1)
			-- if speed_mult < 1 then player_vel.y = player_vel.y * 0.1 end
			new_vel = vector.add(new_vel, player_vel)

			player:add_velocity(new_vel)
		else -- reset things when you stop flying with elytra
			elytra.rocketing = 0
			playerphysics.remove_physics_factor(player, "gravity", "mcl_playerplus:elytra")
		end

		if control.RMB and core.get_item_group(wielded:get_name(), "spear") > 0 then
			set_bone_pos(player, "Wield_Item", vector.new(0, 5.2, 1.2), vector.new(-1.57, 5.7, 1.57))
		elseif wielded_def and wielded_def._mcl_toollike_wield then
			set_bone_pos(player, "Wield_Item", vector.new(0, 4.7, 3.1), vector.new(-1.57, 3.93, 1.57))
		elseif string.find(wielded:get_name(), "mcl_bows:bow") then
			set_bone_pos(player, "Wield_Item", vector.new(1, 4, 0), vector.new(1.57, 2.27, 2.01))
		elseif string.find(wielded:get_name(), "mcl_bows:crossbow_loaded") then
			set_bone_pos(player, "Wield_Item", vector.new(0, 5.2, 1.2), vector.new(0, 3.1415, 1.27))
		elseif string.find(wielded:get_name(), "mcl_bows:crossbow") then
			set_bone_pos(player, "Wield_Item", vector.new(0, 5.2, 1.2), vector.new(0, 3.1415, 0.78))
		elseif wielded_def.inventory_image == "" then
			set_bone_pos(player, "Wield_Item", vector.new(0, 6, 2), vector.new(3.1415, -0.785, 0))
		else
			set_bone_pos(player, "Wield_Item", vector.new(0, 5.3, 2), vector.new(1.57, 0, 0))
		end

		-- controls right and left arms pitch when shooting a bow or blocking
		if mcl_shields.is_blocking(player) == 2 then
			set_bone_pos(player, "Arm_Right_Pitch_Control", nil, vector.new(0.35, -0.35, 0))
		elseif mcl_shields.is_blocking(player) == 1 then
			set_bone_pos(player, "Arm_Left_Pitch_Control", nil, vector.new(0.35, 0.35, 0))
		elseif string.find(wielded:get_name(), "mcl_bows:bow") and control.RMB then
			local right_arm_rot = vector.new(pitch + 1.57, -0.524, pitch * -1 * .35)
			local left_arm_rot = vector.new(pitch + 1.57, 0.75, pitch * .35)
			set_bone_pos(player, "Arm_Right_Pitch_Control", nil, right_arm_rot)
			set_bone_pos(player, "Arm_Left_Pitch_Control", nil, left_arm_rot)
		-- controls right and left arms pitch when holing a loaded crossbow
		elseif string.find(wielded:get_name(), "mcl_bows:crossbow_loaded") then
			local right_arm_rot = vector.new(pitch + 1.57, -0.524, pitch * -1 * .35)
			local left_arm_rot = vector.new(pitch + 1.57, 0.75, pitch * .35)
			set_bone_pos(player, "Arm_Right_Pitch_Control", nil, right_arm_rot)
			set_bone_pos(player, "Arm_Left_Pitch_Control", nil, left_arm_rot)
		-- controls arm for spear throwing
		elseif core.get_item_group(wielded:get_name(), "spear") > 0 and control.RMB then
			local right_arm_rot = vector.new(pitch + 1.8, 0, pitch * -1 * .35)
			set_bone_pos(player, "Arm_Right_Pitch_Control", nil, right_arm_rot)
		-- controls right and left arms pitch when loading a crossbow
		elseif string.find(wielded:get_name(), "mcl_bows:crossbow_") then
			set_bone_pos(player, "Arm_Right_Pitch_Control", nil, vector.new(0.786, -0.35, 0.47))
			set_bone_pos(player, "Arm_Left_Pitch_Control", nil, vector.new(0.96, 0.35, -0.786))
		-- when punching
		elseif control.LMB and not parent then
			set_bone_pos(player,"Arm_Right_Pitch_Control", nil, vector.new(pitch, 0, 0))
			set_bone_pos(player,"Arm_Left_Pitch_Control", nil, vector.zero())
		-- when holding an item.
		elseif wielded:get_name() ~= "" then
			set_bone_pos(player, "Arm_Right_Pitch_Control", nil, vector.new(0.35, 0, 0))
			set_bone_pos(player, "Arm_Left_Pitch_Control", nil, vector.zero())
		-- resets arms pitch
		else
			set_bone_pos(player, "Arm_Left_Pitch_Control", nil, vector.zero())
			set_bone_pos(player, "Arm_Right_Pitch_Control", nil, vector.zero())
		end

		if elytra.active then
			-- set head pitch and yaw when flying
			local head_rot = vector.new(pitch - dir_to_pitch(player_velocity) + 0.87, player_vel_yaw - yaw, 0)
			set_bone_pos(player, "Head_Control", nil, head_rot)

			-- sets eye height, and nametag color accordingly
			set_properties(player, player_props_elytra)

			-- control body bone when flying
			local body_rot = vector.new(dir_to_pitch(player_velocity) + 1.92, -player_vel_yaw + yaw, 3.1415)
			set_bone_pos(player, "Body_Control", nil, body_rot, vector.new(-1, 1, 1))
		elseif parent then
			set_properties(player, player_props_riding)
			local parent_yaw = parent:get_yaw()
			local head_rot = vector.new(pitch, -limit_vel_yaw(yaw, parent_yaw) + parent_yaw, 0)
			set_bone_pos(player, "Head_Control", nil, head_rot)
			set_bone_pos(player,"Body_Control", nil, vector.zero())
		elseif control.sneak then
			-- controls head pitch when sneaking
			local head_rot = vector.new(pitch, player_vel_yaw - yaw, player_vel_yaw - yaw)
			set_bone_pos(player, "Head_Control", nil, head_rot)

			-- sets eye height, and nametag color accordingly
			set_properties(player, player_props_sneaking)

			-- sneaking body conrols
			set_bone_pos(player, "Body_Control", nil, vector.new(0, -player_vel_yaw + yaw, 0))
		elseif get_item_group(mcl_playerinfo[name].node_head, "water") ~= 0 and is_sprinting(name) == true then
			-- set head pitch and yaw when swimming
			is_swimming = true
			local head_rot = vector.new(pitch - dir_to_pitch(player_velocity) + 0.35, player_vel_yaw - yaw, 0)
			set_bone_pos(player, "Head_Control", nil, head_rot)

			-- sets eye height, and nametag color accordingly
			set_properties(player, player_props_swimming)

			-- control body bone when swimming
			local body_rot = vector.new((1.3 + dir_to_pitch(player_velocity)), player_vel_yaw - yaw, 3.1415)
			set_bone_pos(player, "Body_Control", nil, body_rot, vector.new(-1, 1, 1))
		elseif get_item_group(mcl_playerinfo[name].node_head, "solid") == 0
		and get_item_group(mcl_playerinfo[name].node_head_top, "solid") == 0 then
			-- sets eye height, and nametag color accordingly
			is_swimming = false
			set_properties(player, player_props_normal)

			set_bone_pos(player,"Head_Control", nil, vector.new(pitch, player_vel_yaw - yaw, 0))
			set_bone_pos(player,"Body_Control", nil, vector.new(0, -player_vel_yaw + yaw, 0))
		end

		local playerinfo = mcl_playerinfo[name] or {}
		local plusinfo = playerinfo.mcl_playerplus
		if not plusinfo then
			plusinfo = {}
			playerinfo.mcl_playerplus = plusinfo
		end

		-- Only process if node_head changed
		if plusinfo.old_node_head ~= playerinfo.node_head then
			local node_head = playerinfo.node_head or ""
			local old_node_head = plusinfo.old_node_head or ""
			plusinfo.old_node_head = playerinfo.node_head

			-- Update skycolor if moving in or out of water
			if (get_item_group(node_head, "water") == 0) ~= (get_item_group(old_node_head, "water") == 0) then
				mcl_weather.skycolor.update_sky_color()
			end
		end

		elytra.last_yaw = player:get_look_horizontal()
		-- Update jump status immediately since we need this info in real time.
		-- WARNING: This section is HACKY as hell since it is all just based on heuristics.

		if mcl_playerplus_internal[name].jump_cooldown > 0 then
			mcl_playerplus_internal[name].jump_cooldown = mcl_playerplus_internal[name].jump_cooldown - dtime
		end

		if control.jump and mcl_playerplus_internal[name].jump_cooldown <= 0 then

			--pos = player:get_pos()

			node_stand = mcl_playerinfo[name].node_stand
			node_stand_below = mcl_playerinfo[name].node_stand_below
			node_head = mcl_playerinfo[name].node_head
			node_feet = mcl_playerinfo[name].node_feet
			node_head_top = mcl_playerinfo[name].node_head_top
			if not node_stand or not node_stand_below or not node_head or not node_feet then
				return
			end
			if (not minetest.registered_nodes[node_stand]
			or not minetest.registered_nodes[node_stand_below]
			or not minetest.registered_nodes[node_head]
			or not minetest.registered_nodes[node_feet]
			or not minetest.registered_nodes[node_head_top]) then
				return
			end

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

			if get_item_group(node_feet, "liquid") == 0 and
					get_item_group(node_stand, "liquid") == 0 and
					not minetest.registered_nodes[node_feet].climbable and
					not minetest.registered_nodes[node_stand].climbable and
					(minetest.registered_nodes[node_stand].walkable or minetest.registered_nodes[node_stand_below].walkable)
					and get_item_group(node_stand, "disable_jump") == 0
					and get_item_group(node_stand_below, "disable_jump") == 0 then
			-- Cause exhaustion for jumping
			if is_sprinting(name) then
				exhaust(name, mcl_hunger.EXHAUST_SPRINT_JUMP)
			else
				exhaust(name, mcl_hunger.EXHAUST_JUMP)
			end

			-- Reset cooldown timer
				mcl_playerplus_internal[name].jump_cooldown = 0.45
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
	for _,player in pairs(get_connected_players()) do
		-- who am I?
		local name = player:get_player_name()

		-- where am I?
		local pos = player:get_pos()

		-- what is around me?
		local node_stand = mcl_playerinfo[name].node_stand
		local node_stand_below = mcl_playerinfo[name].node_stand_below
		local node_head = mcl_playerinfo[name].node_head
		local node_feet = mcl_playerinfo[name].node_feet
		local node_head_top = mcl_playerinfo[name].node_head_top
		if not node_stand or not node_stand_below or not node_head or not node_feet or not node_head_top then
			return
		end

		local boots = player:get_inventory():get_stack("armor", 5)
		local soul_speed = mcl_enchanting.get_enchantment(boots, "soul_speed")

		-- Standing on a soul block? If so, check for speed bonus / penalty
		if get_item_group(node_stand, "soul_block") ~= 0 then
			
			-- Standing on soul sand? If so, walk slower (unless player wears Soul Speed boots, then apply bonus)
			if node_stand == "mcl_nether:soul_sand" then
				-- TODO: Tweak walk speed
				-- TODO: Also slow down mobs
				-- Slow down even more when soul sand is above certain block
				if soul_speed > 0 then
					playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:soul_speed", soul_speed * 0.105 + 1.3)
				else
					if node_stand_below == "mcl_core:ice" or node_stand_below == "mcl_core:packed_ice" or node_stand_below == "mcl_core:slimeblock" or node_stand_below == "mcl_core:water_source" then
						playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:soul_speed", 0.1)
					else
						playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:soul_speed", 0.4)
					end
				end
			elseif soul_speed > 0 then
				-- Standing on a different soul block? If so, apply Soul Speed bonus unconditionally
				playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:soul_speed", soul_speed * 0.105 + 1.3)
			end
		else
			playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:soul_speed")
		end
		if get_item_group(node_feet, "liquid") ~= 0 and mcl_enchanting.get_enchantment(player:get_inventory():get_stack("armor", 5), "depth_strider") then
			local boots = player:get_inventory():get_stack("armor", 5)
			local depth_strider = mcl_enchanting.get_enchantment(boots, "depth_strider")
			if depth_strider > 0 then
				playerphysics.add_physics_factor(player, "speed", "mcl_playerplus:depth_strider", (depth_strider / 3) + 0.75)
			else
				playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:depth_strider")
			end
		else
			playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:depth_strider")
		end

		-- Sneak faster with swift sneak
		local leggings = player:get_inventory():get_stack("armor", 4)
		local swift_sneak = mcl_enchanting.get_enchantment(leggings, "swift_sneak")
		if swift_sneak > 0 then
			playerphysics.add_physics_factor(player, "speed_crouch", "mcl_playerplus:swift_sneak", (swift_sneak / 2) + 1)
		else
			playerphysics.remove_physics_factor(player, "speed_crouch", "mcl_playerplus:swift_sneak")
		end


		-- Is player suffocating inside node? (Only for solid full opaque cube type nodes
		-- without group disable_suffocation=1)
		-- if swimming, check the feet node instead, because the head node will be above the player when swimming
		local ndef = minetest.registered_nodes[node_head]
		if is_swimming then
			ndef = minetest.registered_nodes[node_feet]
		end
		if (ndef.walkable == nil or ndef.walkable == true)
		and (ndef.collision_box == nil or ndef.collision_box.type == "regular")
		and (ndef.node_box == nil or ndef.node_box.type == "regular")
		and (ndef.groups.disable_suffocation ~= 1)
		and (ndef.groups.opaque == 1)
		and (node_head ~= "ignore")
		-- Check privilege, too
		and (not check_player_privs(name, {noclip = true})) then
			mcl_util.deal_damage(player, 1, {type = "in_wall"})
		end

		-- Cactus damage
		if node_stand == "mcl_core:cactus" or node_feet == "mcl_core:cactus" or node_head == "mcl_core:cactus" then
			mcl_util.deal_damage(player, 1, {type = "cactus"})
		else
			-- Touching cactus from the side
			local node_collide_width = 1 - .75 -- FIXME: Player collision box width is defined earlier as .75 - use common variable for this at some point
			if core.find_nodes_in_area(
				vector.offset(pos, node_collide_width, 0, node_collide_width),
				vector.offset(pos, -node_collide_width, 0, -node_collide_width),
				"mcl_core:cactus"
			)[1] then
				mcl_util.deal_damage(player, 1, {type = "cactus"})
			end
		end

		--[[ Swimming: Cause exhaustion.
		NOTE: As of 0.4.15, it only counts as swimming when you are with the feet inside the liquid!
		Head alone does not count. We respect that for now. ]]
		if not player:get_attach() and (get_item_group(node_feet, "liquid") ~= 0 or
				get_item_group(node_stand, "liquid") ~= 0) then
			local lastPos = mcl_playerplus_internal[name].lastPos
			if lastPos then
				local dist = vector.distance(lastPos, pos)
				mcl_playerplus_internal[name].swimDistance = mcl_playerplus_internal[name].swimDistance + dist
				if mcl_playerplus_internal[name].swimDistance >= 1 then
					local superficial = math.floor(mcl_playerplus_internal[name].swimDistance)
					exhaust(name, mcl_hunger.EXHAUST_SWIM * superficial)
					mcl_playerplus_internal[name].swimDistance = mcl_playerplus_internal[name].swimDistance - superficial
				end
			end

		end

		-- Underwater: Spawn bubble particles
		if get_item_group(node_head, "water") ~= 0 then
			add_particlespawner({
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
		local wi = player:get_wielded_item():get_name()
		if wi == "mcl_core:barrier" or wi == "mcl_core:realm_barrier" or minetest.get_item_group(wi, "light_block") ~= 0 then
			local pos = vector.round(player:get_pos())
			local r = 8
			local vm = get_voxel_manip()
			local emin, emax = vm:read_from_map({x=pos.x-r, y=pos.y-r, z=pos.z-r}, {x=pos.x+r, y=pos.y+r, z=pos.z+r})
			local area = VoxelArea:new{
				MinEdge = emin,
				MaxEdge = emax,
			}
			local data = vm:get_data()
			for x=pos.x-r, pos.x+r do
			for y=pos.y-r, pos.y+r do
			for z=pos.z-r, pos.z+r do
				local vi = area:indexp({x=x, y=y, z=z})
				local nodename = get_name_from_content_id(data[vi])
				local light_block_group = minetest.get_item_group(nodename, "light_block")

				local tex
				if nodename == "mcl_core:barrier" then
					tex = "mcl_core_barrier.png"
				elseif nodename == "mcl_core:realm_barrier" then
					tex = "mcl_core_barrier.png^[colorize:#FF00FF:127^[transformFX"
				elseif light_block_group ~= 0 then
					tex = "mcl_core_light_" .. (light_block_group - 1) .. ".png"
				end
				if tex then
					add_particle({
						pos = {x=x, y=y, z=z},
						expirationtime = 1,
						size = 8,
						texture = tex,
						glow = 14,
						playername = name
					})
				end
			end
			end
			end
		end

		-- Update internal values
		mcl_playerplus_internal[name].lastPos = pos

	end

end)

-- set to blank on join (for 3rd party mods)
minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	local hp = player:get_hp()

	mcl_playerplus_internal[name] = {
		lastPos = nil,
		swimDistance = 0,
		jump_cooldown = -1,	-- Cooldown timer for jumping, we need this to prevent the jump exhaustion to increase rapidly
		last_damage = 0,
		invul_timestamp = 0,
	}
	mcl_playerplus.elytra[player] = {active = false, rocketing = 0, speed = 0}

	-- Luanti limitation: get_bone_position() returns all zeros vectors, because models are client-side not server-side
	-- Workaround: call set_bone_position() one time first.
	set_bone_pos(player, "Head_Control", vector.new(0, 6.75, 0))
	set_bone_pos(player, "Arm_Right_Pitch_Control", vector.new(-3, 5.785, 0))
	set_bone_pos(player, "Arm_Left_Pitch_Control", vector.new(3, 5.785, 0))
	set_bone_pos(player, "Body_Control", vector.new(0, 6.75, 0))
	-- Respawn dead players on joining
	if hp <= 0 then
		player:respawn()
		minetest.log("warning", name .. " joined the game with 0 hp and has been forced to respawn")
	end

	playerphysics.remove_physics_factor(player, "speed", "mcl_playerplus:surface")
end)

-- clear when player leaves
minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	mcl_playerplus_internal[name] = nil
	mcl_playerplus.elytra[player] = nil
end)

-- Don't change HP if the player falls in the water or through End Portal:
mcl_damage.register_modifier(function(obj, damage, reason)
	if reason.type == "fall" then
		local pos = obj:get_pos()
		local node = minetest.get_node(pos)
		local velocity = obj:get_velocity() or obj:get_player_velocity() or {x=0,y=-10,z=0}
		local v_axis_max = math.max(math.abs(velocity.x), math.abs(velocity.y), math.abs(velocity.z))
		local step = {x = velocity.x / v_axis_max, y = velocity.y / v_axis_max, z = velocity.z / v_axis_max}
		for i = 1, math.ceil(v_axis_max/5)+1 do -- trace at least 1/5 of the way per second
			if not node or node.name == "ignore" then
				minetest.get_voxel_manip():read_from_map(pos, pos)
				node = minetest.get_node(pos)
			end
			if node then
				local def = minetest.registered_nodes[node.name]
				if not def or def.walkable then
					return
				end
				if minetest.get_item_group(node.name, "water") ~= 0 then
					return 0
				end
				if node.name == "mcl_portals:portal_end" then
					if mcl_portals and mcl_portals.end_teleport then
						mcl_portals.end_teleport(obj)
					end
					return 0
				end
				if node.name == "mcl_core:cobweb" then
					return 0
				end
				if node.name == "mcl_core:vine" then
					return 0
				end
			end
			pos = vector.add(pos, step)
			node = minetest.get_node(pos)
		end
	end
end, -200)

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	-- attack reach limit
	if hitter and hitter:is_player() then
		local weapon = hitter:get_wielded_item()
		local player_pos = player:get_pos()
		local hitter_pos = hitter:get_pos()
		-- 0.6 correction factor below is for the difference between player hitbox position and player object origin
		if (vector.distance(player_pos, hitter_pos) - 0.6) > (weapon:get_definition().range or 3) then
			damage = 0
			return damage
		end
	end
	-- damage invulnerability
	if hitter then
		local name = player:get_player_name()
		local time_now = minetest.get_us_time()
		local invul_timestamp = mcl_playerplus_internal[name].invul_timestamp
		local time_diff = time_now - invul_timestamp
		-- check for invulnerability time in microseconds (0.5 second)
		if time_diff <= 500000 and time_diff >= 0 then
			player:get_meta():set_int("mcl_damage:invulnerable", 1)
			minetest.after(0.5, function()
				local player = minetest.get_player_by_name(name)
				if not player then return end
				player:get_meta():set_int("mcl_damage:invulnerable", 0)
			end)
			damage = damage - mcl_playerplus_internal[name].last_damage
			if damage < 0 then
				damage = 0
			end
			return damage
		else
			mcl_playerplus_internal[name].last_damage = damage
			mcl_playerplus_internal[name].invul_timestamp = time_now
			player:get_meta():set_int("mcl_damage:damage_animation", 1)
			minetest.after(0.5, function()
				local player = minetest.get_player_by_name(name)
				if not player then return end
				player:get_meta():set_int("mcl_damage:damage_animation", 0)
			end)
		end
	end
end)

minetest.register_on_respawnplayer(function(player)
	local pos = player:get_pos()
	minetest.add_particlespawner({
		amount = 50,
		time = 0.001,
		minpos = vector.add(pos, 0),
		maxpos = vector.add(pos, 0),
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_mob_death.png^[colorize:#000000:255",
	})

	minetest.sound_play("mcl_mobs_mob_poof", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 8,
	}, true)
end)
