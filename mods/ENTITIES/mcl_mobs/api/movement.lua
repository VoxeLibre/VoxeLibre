function mcl_mobs.mob:update_node_type()
	self.last_node_type = self.node_type or "ignore"
	self.node_type = mcl_mobs.util.get_node_type(self.object:get_pos())

	if self.def.ignore_cobweb and self.node_type == "cobweb" then
		self.node_type = "air"
	end
end

function mcl_mobs.mob:backup_movement()
	self.last_pos = self.object:get_pos()
	self.last_velocity = self.object:get_velocity()
end

-- vertical_acceleration, vertical_speed, horizontal_speed_factor
function mcl_mobs.mob:get_movement()
	if self.node_type == "solid" or self.node_type == "ignore" then
		return 0, 0, 0
	elseif self.node_type == "air" then
		return self.def.gravity, nil, nil
	elseif self.node_type == "water" then
		return 0, mcl_mobs.const.water_sink_speed, mcl_mobs.const.water_slowdown_factor
	elseif self.node_type == "lava" then
		return 0, mcl_mobs.const.lava_sink_speed, mcl_mobs.const.lava_slowdown_factor
	elseif self.node_type == "cobweb" then
		return 0, mcl_mobs.const.cobweb_sink_speed, mcl_mobs.const.cobweb_slowdown_factor
	end
end

function mcl_mobs.mob:update_movement()
	local vertical_acceleration, vertical_speed, horizontal_speed_factor = self:get_movement()

	if vertical_acceleration then
		self.object:set_acceleration(vector.new(0, vertical_acceleration, 0))
	end

	local velocity = self.object:get_velocity()

	if vertical_speed then
		velocity.y = vertical_speed
	end

	if horizontal_speed_factor then
		velocity.x = velocity.x * horizontal_speed_factor
		velocity.z = velocity.z * horizontal_speed_factor
	end

	self.horizontal_speed_factor = horizontal_speed_factor

	self.object:set_velocity(velocity)
end

function mcl_mobs.mob:movement_step()
	if self.last_node_type ~= self.node_type then
		self:update_movement()
	end
end
