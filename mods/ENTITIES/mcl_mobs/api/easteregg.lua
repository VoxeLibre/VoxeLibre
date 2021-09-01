function mcl_mobs.mob:update_easteregg()
	local old_easteregg = self.easteregg or {}
	local eastereggs = table.key_value_swap(mcl_mobs.eastereggs)

	local easteregg_name = eastereggs[self.data.nametag]
	local easteregg = old_easteregg

	if old_easteregg.name ~= easteregg_name then
		easteregg = {
			name = easteregg_name,
			[easteregg_name] = true,
		}
	end

	if easteregg.rainbow ~= old_easteregg.rainbow then
		if easteregg.rainbow then
			easteregg.hue = 0
		end
	elseif easteregg.upside_down ~= old_easteregg.upside_down then
		self:update_roll()
		self:update_collisionbox()
	end

	self.easteregg = easteregg
end

function mcl_mobs.mob:easteregg_step()
	if self.easteregg.rainbow then
		self.easteregg.hue = self.easteregg.hue + 60 * self.dtime
		self:update_textures()
	elseif self.easteregg.spin then
		self.data.yaw = self.data.yaw + 180 * dtime
	end
end
