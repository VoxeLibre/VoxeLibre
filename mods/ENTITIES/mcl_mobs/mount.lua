local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
-- based on lib_mount by Blert2112 (edited by TenPlus1)

local enable_crash = false
local crash_threshold = 6.5 -- ignored if enable_crash=false
local GRAVITY = -9.8

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
    entity.driver_attach_at = entity.driver_attach_at or vector.zero()
    entity.driver_eye_offset = entity.driver_eye_offset or vector.zero()
    entity.driver_scale = entity.driver_scale or {x = 1, y = 1}

    entity.driver = player

    force_detach(player)

    player:set_attach(entity.object, "", entity.driver_attach_at, {x=0, y=0, z=0})
    mcl_player.player_attached[player:get_player_name()] = true

    -- set eye offset and visual scale
    player:set_eye_offset(entity.driver_eye_offset, vector.zero())
    player:set_properties({ visual_size = entity.driver_scale })

    -- play sitting/mount animation after short delay
    minetest.after(0.2, function(name)
        local player = minetest.get_player_by_name(name)
        if player then
            mcl_player.player_set_animation(player, "sit_mount", 30)
        end
    end, player:get_player_name())

    -- align player look with entity yaw
    player:set_look_horizontal(entity.object:get_yaw())
end

function mcl_mobs.detach(player, offset)
	force_detach(player)
	mcl_player.player_set_animation(player, "stand" , 30)
	player:add_velocity(vector.new(math.random()*12-6,math.random()*3+5,math.random()*12-6)) --throw the rider off
end

function mcl_mobs.drive(entity, moving_anim, stand_anim, can_fly, dtime)
    local velo = entity.object:get_velocity()
    local new_velo = velo
    local acce_y = GRAVITY
    local horizontal_speed = math.sqrt(velo.x^2 + velo.z^2)   

    -- process player controls
    if entity.driver and entity.driver:is_player() then
        local ctrl = entity.driver:get_player_control()

        local speed_change = 0
        local velocity_change = 0.1 * entity.run_velocity * 0.385
        if ctrl.up then -- forward
            speed_change = entity.accel * velocity_change
        elseif ctrl.down then -- backward
            speed_change = -entity.accel * velocity_change
        else -- nothing pressed, reset speed
	    horizontal_speed = 0 
	end

        horizontal_speed = horizontal_speed + speed_change

        -- enforce speed limits
        horizontal_speed = math.max(-entity.max_speed_reverse,
                                    math.min(horizontal_speed, entity.max_speed_forward))

        -- update entity yaw to match driver look
        local yaw = entity.driver:get_look_horizontal()
        entity:set_yaw(yaw, 2)

        -- compute horizontal movement vector
        local dir = { x = -math.sin(yaw), y = 0, z = math.cos(yaw) }
        dir = vector.normalize(dir)

        -- prepare new velocity vector
        new_velo = {
            x = dir.x * horizontal_speed,
            y = velo.y,
            z = dir.z * horizontal_speed
        }

	-- handle jumping / flying separately
        if can_fly then
            -- vertical fly input
            if ctrl.jump then
                new_velo.y = math.min(new_velo.y + 1, entity.accel)
            elseif ctrl.sneak then
                new_velo.y = math.max(new_velo.y - 1, -entity.accel)
            end
        else
            -- jump
            if ctrl.jump and velo.y == 0 then
                new_velo.y = new_velo.y + entity.jump_height
                acce_y = acce_y + 1
            end
        end
    else
        -- no driver: stop horizontal movement
        new_velo = {
            x = 0,
            y = velo.y,
            z = 0
        }
    end

    -- apply new velocity and acceleration
    entity.object:set_velocity(new_velo)       
    entity.object:set_acceleration({ x = 0, y = acce_y, z = 0 })

    -- set animation
    if horizontal_speed > 0.01 then
        entity:set_animation(moving_anim)
    else
        entity:set_animation(stand_anim)
    end

    -- optional crash handling when exceeding horizontal speed
    if enable_crash and horizontal_speed >= crash_threshold then
        entity.object:punch(entity.object, 1.0, {
            full_punch_interval = 1.0,
            damage_groups = { fleshy = horizontal_speed }
        }, nil)
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

