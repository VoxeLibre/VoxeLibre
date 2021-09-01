function mcl_mobs.mob:float_step()
	local vertical_speed

	if self.node_type ~= self.last_node_type then
		if self.node_type == "air" then
			vertical_speed = self.def.float_in_air
		elseif self.node_type == "water" then
			vertical_speed = self.def.float_in_water
		elseif self.node_type == "lava" then
			vertical_speed = self.def.float_in_lava
		end
	end
end
