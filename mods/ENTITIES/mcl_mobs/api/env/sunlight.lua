function mcl_mobs.mob:sunlight_step()
	if self.data.burn_time then
		return
	end

	local pos = self.object:get_pos()
	pos.y = pos.y + 0.1

	if mcl_worlds.pos_to_dimension(pos) == "overworld" then
		local ok, light = pcall(minetest.get_natural_light or minetest.get_node_light, pos, minetest.get_timeofday())
		if ok and light >= minetest.LIGHT_MAX then
			mcl_burning.set_on_fire(self.object, math.huge)
		end
	end
end
