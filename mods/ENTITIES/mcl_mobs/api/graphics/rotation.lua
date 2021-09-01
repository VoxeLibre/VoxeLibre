-- this is used when a mob is following player and for when mobs breed
function mcl_mobs.mob:look_at(obj)
	self:lock_yaw()

	-- turn positions into pseudo 2d vectors
	local pos1 = self.object:get_pos()
	pos1.y = 0

	local pos2 = obj:get_pos()
	pos2.y = 0

	local new_direction = vector.direction(pos1, pos2)
	local new_yaw = minetest.dir_to_yaw(new_direction)

	self.object:set_yaw(new_yaw)
	self.yaw = new_yaw
end

-- this allows auto facedir rotation while making it so mobs
-- don't look like wet noodles flopping around
function mcl_mobs.mob:movement_rotation_lock()
	local current_engine_yaw = self.object:get_yaw()
	local current_lua_yaw = self.yaw

	if current_engine_yaw > math.pi * 2 then
		current_engine_yaw = current_engine_yaw - math.pi * 2
	end

	local diff = math.abs(current_engine_yaw - current_lua_yaw)

	if diff <= 0.05 then
		self:lock_yaw()
	elseif diff > 0.05 then
		self:unlock_yaw()
	end
end

-- this is used to unlock a mob's yaw after attacking
function mcl_mobs.mob:unlock_yaw()
	if not self.properties.automatic_face_movement_dir then
		self:set_properties({automatic_face_movement_dir = self.def.rotate})
	end
end

-- this is used to lock a mob's yaw when they're standing
function mcl_mobs.mob:lock_yaw()
	if self.properties.automatic_face_movement_dir then
		self:set_properties({automatic_face_movement_dir = false})
	end
end

function mcl_mobs.mob:calculate_pitch(self)
	local pos  = self.object:get_pos()
	local pos2 = self.old_pos

	if pos == nil or pos2 == nil then
		return false
	end

    return minetest.dir_to_yaw(vector.new(vector.distance(vector.new(pos.x, 0, pos.z), vector.new(pos2.x, 0, pos2.z)), 0, pos.y - pos2.y)) + math.pi / 2
end

--this is a helper function used to make mobs pitch rotation dynamically flow when flying/swimming
function mcl_mobs.mob:set_dynamic_pitch()
	local pitch = self:calculate_pitch()

	if not pitch then
		return
	end

	local rotation = self.object:get_rotation()
	rotation.x = pitch
	self.object:set_rotation(rotation)

	self.dynamic_pitch = true
end

--this is a helper function used to make mobs pitch rotation reset when flying/swimming
function mcl_mobs.mob:set_static_pitch()
	if not self.dynamic_pitch then
		return
	end

	local current_rotation = self.object:get_rotation()
	current_rotation.x = 0
	self.object:set_rotation(current_rotation)

	self.dynamic_pitch = nil
end

function mcl_mobs.mob:quick_rotate()
	self.yaw = self.yaw + math.pi * 2 * 0.03125
	if self.yaw > math.pi * 2 then
		self.yaw = self.yaw - math.pi * 2
	end
end

function mcl_mobs.mob:update_roll()
	local roll = 0

	if self.dead then
		roll = math.pi * math.min(0.5, 1 - self.death_timer / mcl_mobs.const.death_timer)
	elseif self.easteregg.upside_down then
		roll = math.pi
	end

	local rotation = self.object:get_rotation()
	rotation.z = roll
	self.object:set_rotation(rotation)
end
