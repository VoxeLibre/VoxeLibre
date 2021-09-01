function mcl_mobs.mob:breath_step()
	local pos = self.object:get_pos()

	pos.y = pos.y + self.eye_height

	local node = minetest.get_node(pos).name

	if minetest.get_item_group(node, "water") ~= 0 then
		self.data.breath = self.data.breath - self.dtime

		if self.data.breath <= 0 then
			self:deal_damage(4, {type = "drowning"})
			self.data.breath = 1
		end

	elseif self.data.breath < self.def.breath_max then
		self.data.breath = self.data.breath + self.dtime
		if self.data.breath > self.def.breath_max then
			self.data.breath = self.def.breath_max
		end
	end
end
