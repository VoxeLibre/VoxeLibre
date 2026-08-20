local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
-- based on lib_mount by Blert2112 (edited by TenPlus1)

local enable_crash = false
local crash_threshold = 6.5 -- ignored if enable_crash=false
local GRAVITY = -9.8

local node_ok = mcl_mobs.node_ok
local sign = math.sign -- minetest extension

local function node_is(pos)
	local node = node_ok(pos)
	if node.name == "air" then return "air" end
	local ndef = minetest.registered_nodes[node.name]
	if not ndef then return "other" end -- unknown/ignore
	if ndef.groups.lava then return "lava" end
	if ndef.groups.liquid then return "liquid" end
	if ndef.walkable then return "walkable" end
	return "other"
end


local function force_detach(player)
	local attached_to = player:get_attach()
	if not attached_to then return end

	local entity = attached_to:get_luaentity()
	if entity.driver and entity.driver == player then entity.driver = nil end

	player:set_detach()
	mcl_player.player_attached[player:get_player_name()] = false
	player:set_eye_offset(vector.zero(), vector.zero())
	mcl_player.player_set_animation(player, "stand" , 30)
	player:set_properties({visual_size = {x = 1, y = 1} })
end

minetest.register_on_leaveplayer(force_detach)

minetest.register_on_shutdown(function()
	local players = minetest.get_connected_players()
	for i = 1, #players do
		force_detach(players[i])
	end
end)

minetest.register_on_dieplayer(function(player)
	force_detach(player)
	return true
end)

function mcl_mobs.attach(entity, player)
	entity.player_rotation = entity.player_rotation or vector.zero()
	entity.driver_attach_at = entity.driver_attach_at or vector.zero()
	entity.driver_eye_offset = entity.driver_eye_offset or vector.zero()
	entity.driver_scale = entity.driver_scale or {x = 1, y = 1}

	local rot_view = entity.player_rotation.y == 90 and math.pi/2 or 0
	local attach_at = entity.driver_attach_at
	local eye_offset = entity.driver_eye_offset
	entity.driver = player

	force_detach(player)

	player:set_attach(entity.object, "", attach_at, entity.player_rotation)
	mcl_player.player_attached[player:get_player_name()] = true
	player:set_eye_offset(eye_offset, vector.zero())

	player:set_properties({ visual_size = entity.driver_scale })

	minetest.after(0.2, function(name)
		local player = minetest.get_player_by_name(name)
		if player then
			mcl_player.player_set_animation(player, "sit_mount" , 30)
		end
	end, player:get_player_name())

	player:set_look_horizontal(entity.object:get_yaw() - rot_view)
end


function mcl_mobs.detach(player, offset)
	force_detach(player)
	mcl_player.player_set_animation(player, "stand" , 30)
	player:add_velocity(vector.new(math.random()*12-6,math.random()*3+5,math.random()*12-6)) --throw the rider off
end


function mcl_mobs.drive(entity, moving_anim, stand_anim, can_fly, dtime)
	local velo = entity.object:get_velocity()
	local v = math.sqrt(velo.x * velo.x + velo.z * velo.z)
	local acce_y = GRAVITY

	-- process controls
	if entity.driver then
		local ctrl = entity.driver:get_player_control()
		if ctrl.up then -- forward
			v = v + entity.accel * 0.1 * entity.run_velocity * 0.385
		elseif ctrl.down then -- backwards
			if entity.max_speed_reverse == 0 and v == 0 then return end
			v = v - entity.accel * 0.1 * entity.run_velocity * 0.385
		end

		entity:set_yaw(entity.driver:get_look_horizontal() - entity.rotate, 2)

		if can_fly then
			-- FIXME: use acce_y instead?
			-- fly up
			if ctrl.jump then
				velo.y = math.min(velo.y + 1, entity.accel)
			elseif velo.y > 0.1 then
				velo.y = velo.y - 0.1
			elseif velo.y > 0 then
				velo.y = 0
			end

			-- fly down
			if ctrl.sneak then
				velo.y = math.max(velo.y - 1, -entity.accel)
			elseif velo.y < -0.1 then
				velo.y = velo.y + 0.1
			elseif velo.y < 0 then
				velo.y = 0
			end
		else
			-- jump
			if ctrl.jump then
				if velo.y == 0 then
					velo.y = velo.y + entity.jump_height
					acce_y = acce_y + 1
				end
			end
		end
	end

	if math.abs(v) < 0.02 then -- stop
		entity.object:set_velocity(vector.zero())
		v = 0
	else
		v = v - 0.02 * sign(v) -- slow down
	end

	-- if not moving then set animation and return
	if v == 0 and velo.x == 0 and velo.y == 0 and velo.z == 0 then
		entity:set_animation(stand_anim)
		return
	else
		entity:set_animation(moving_anim)
	end

	-- enforce speed limit forward and reverse
	v = math.max(-entity.max_speed_reverse, math.min(v, entity.max_speed_forward))

	-- Set position, velocity and acceleration
	local p = entity.object:get_pos()
	p.y = p.y - 0.5

	local ni = node_is(p)
	if ni == "air" then
		if can_fly then acce_y = acce_y - GRAVITY end
	elseif ni == "liquid" or ni == "lava" then
		if ni == "lava" and entity.lava_damage ~= 0 then
			entity.lava_counter = (entity.lava_counter or 0) + dtime
			if entity.lava_counter > 1 then
				minetest.sound_play("default_punch", {
					object = entity.object,
					max_hear_distance = 5
				}, true)

				entity.object:punch(entity.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = entity.lava_damage}
				}, nil)

				entity.lava_counter = 0
			end
		end

		if entity.terrain_type == 2
		or entity.terrain_type == 3 then
			acce_y = 0
			p.y = p.y + 1
			if node_is(p) == "liquid" then
				if velo.y >= 5 then
					velo.y = 5
				elseif velo.y < 0 then
					acce_y = 20
				else
					acce_y = 5
				end
			else
				if math.abs(velo.y) < 1 then
					local pos = entity.object:get_pos()
					pos.y = math.floor(pos.y) + 0.5
					entity.object:set_pos(pos)
					velo.y = 0
				end
			end
		else
			v = v * 0.25
		end
	end

	local rot_view = entity.player_rotation.y == 90 and math.pi/2 or 0
	local new_yaw = entity.object:get_yaw() - rot_view
	local new_velo = vector.new(-math.sin(new_yaw) * v, velo.y, math.cos(new_yaw) * v)

	entity.object:set_velocity(new_velo)
	entity.object:set_acceleration(vector.new(0, acce_y, 0))

	if enable_crash then
		if v >= crash_threshold then
			entity.object:punch(entity.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = v}
			}, nil)
		end
	end
end

-- directional flying routine by D00Med (edited by TenPlus1)
function mcl_mobs.fly(entity, dtime, speed, shoots, arrow, moving_anim, stand_anim)
	local ctrl = entity.driver:get_player_control()
	local velo = entity.object:get_velocity()
	local dir = entity.driver:get_look_dir()
	local yaw = entity.driver:get_look_horizontal()

	if ctrl.up then
		entity.object:set_velocity(vector.new(dir.x * speed, dir.y * speed + 2, dir.z * speed))
	elseif ctrl.down then
		entity.object:set_velocity(vector.new(-dir.x * speed, dir.y * speed + 2, -dir.z * speed))
	elseif not ctrl.down or ctrl.up or ctrl.jump then
		entity.object:set_velocity(vector.new(0, -2, 0))
	end

	entity:set_yaw(yaw - entity.rotate, 2)

	-- firing arrows
	if ctrl.LMB and ctrl.sneak and shoots then
		local pos = entity.object:get_pos()
		local obj = minetest.add_entity(vector.offset(pos, dir.x * 2.5, 1.5 + dir.y, dir.z * 2.5), arrow)
		local ent = obj:get_luaentity()
		if ent then
			ent.switch = 1 -- for mob specific arrows
			ent.owner_id = tostring(entity.object) -- so arrows dont hurt entity you are riding
			local vec = vector.new(dir.x * 6, dir.y * 6, dir.z * 6)
			local yaw = entity.driver:get_look_horizontal()
			obj:set_yaw(yaw)
			obj:set_velocity(vec)
		else
			obj:remove()
		end
	end

	-- change animation if stopped
	if velo.x == 0 and velo.y == 0 and velo.z == 0 then
		entity:set_animation(stand_anim)
	else
		entity:set_animation(moving_anim)
	end
end

mcl_mobs.mob_class.drive = mcl_mobs.drive
mcl_mobs.mob_class.fly = mcl_mobs.fly
mcl_mobs.mob_class.attach = mcl_mobs.attach

function mob_class:on_detach_child(child)
	if self.detach_child and self.detach_child(self, child) then return end
	if self.driver == child then self.driver = nil end
end

