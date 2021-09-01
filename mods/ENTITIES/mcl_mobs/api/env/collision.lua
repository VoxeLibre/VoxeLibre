function mcl_mobs.mob:collision_step()
	local own_box, own_pos, own_boundary = mcl_mobs.util.get_collision_data(self.object)

	local radius = math.max(own_boundary, own_box[5])
	local max_cramming = tonumber(minetest.settings:get("mclMaxEntityCramming")) or mcl_mobs.const.max_entity_cramming
	local parent = self.object:get_attach()

	for _, obj in pairs(minetest.get_objects_inside_radius(own_pos, radius * 1.25)) do
		if obj ~= self.object and obj ~= parent and obj:get_attach() ~= self.object then
			local luaentity = obj:get_luaentity()

			if not luaentity and obj:get_hp() > 0 or luaentity and luaentity.is_mob and not luaentity.dead then
				max_cramming = max_cramming - 1

				if max_cramming <= 0 then
					local target, source = self.object, obj
					-- hurt adults before babies
					if self.data.baby and luaentity then
						target, source = source, target -- how the turntables...
					end
					mcl_util.deal_damage(target, mcl_util.get_hp(target), {type = "cramming", source = source})
					return
				end

				local obj_box, obj_pos, obj_boundary = mcl_mobs.util.get_collision_data(obj)

				-- this is checking the difference of the object collided with's possision
				-- if positive top of other object is inside (y axis) of current object

				local y_base_diff = obj_pos.y + obj_box[5] - own_pos.y
				local y_top_diff  = own_pos.y + own_box[5] - obj_pos.y

				local distance = vector.distance(
					vector.new(own_pos.x, 0, own_pos.z),
					vector.new(obj_pos.x, 0, obj_pos.z)
				)

				local combined_boundary = own_boundary + obj_boundary

				if distance <= combined_boundary and y_base_diff >= 0 and y_top_diff >= 0 then
					local dir = vector.direction(own_pos, obj_pos)
					dir.y = 0

					-- eliminate mob being stuck in corners
					if dir.x == 0 and dir.z == 0 then
						-- slightly adjust mob position to prevent equal length
						-- corner/wall sticking
						dir.x = dir.x + math.random() / 10 * (math.round(math.random()) * 2 - 1)
						dir.z = dir.z + math.random() / 10 * (math.round(math.random()) * 2 - 1)
					end

					local obj_vel = vector.multiply(dir, 0.5 * (1 - distance / combined_boundary) * 1.5)
					local own_vel = vector.multiply(obj_vel, -10)

					if not luaentity then
						obj_vel = vector.multiply(obj_vel, 2.5)
					end

					obj:add_velocity(obj_vel)
					self.object:add_velocity(own_vel)
				end
			end
		end
	end
end
