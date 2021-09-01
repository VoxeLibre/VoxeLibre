--[[
function mcl_mobs.register_arrow(name, def)
	minetest.register_entity(name.."_entity", {

		physical = false,
		visual = def.visual,
		visual_size = def.visual_size,
		textures = def.textures,
		velocity = def.velocity,
		hit_player = def.hit_player,
		hit_node = def.hit_node,
		hit_mob = def.hit_mob,
		hit_object = def.hit_object,
		drop = def.drop or false, -- drops arrow as registered item when true
		collisionbox = {0, 0, 0, 0, 0, 0}, -- remove box around arrows
		timer = 0,
		switch = 0,
		owner_id = def.owner_id,
		rotate = def.rotate,
		speed = def.speed or nil,
		on_step = function(self)

			local vel = self.object:get_velocity()

			local pos = self.object:get_pos()

			if self.timer > 150
			or not mobs.within_limits(pos, 0) then
				mcl_burning.extinguish(self.object)
				self.object:remove();
				return
			end

			-- does arrow have a tail (fireball)
			if def.tail
			and def.tail == 1
			and def.tail_texture then

				--do this to prevent clipping through main entity sprite
				local pos_adjustment = vector.multiply(vector.normalize(vel), -1)
				local divider = def.tail_distance_divider or 1
				pos_adjustment = vector.divide(pos_adjustment, divider)
				local new_pos = vector.add(pos, pos_adjustment)
				minetest.add_particle({
					pos = new_pos,
					velocity = {x = 0, y = 0, z = 0},
					acceleration = {x = 0, y = 0, z = 0},
					expirationtime = def.expire or 0.25,
					collisiondetection = false,
					texture = def.tail_texture,
					size = def.tail_size or 5,
					glow = def.glow or 0,
				})
			end

			if self.hit_node then

				local node = minetest.get_node(pos).name

				if minetest.registered_nodes[node].walkable then

					self.hit_node(self, pos, node)

					if self.drop == true then

						pos.y = pos.y + 1

						self.lastpos = (self.lastpos or pos)

						minetest.add_item(self.lastpos, self.object:get_luaentity().name)
					end

					self.object:remove();

					return
				end
			end

			if self.hit_player or self.hit_mob or self.hit_object then

				for _,player in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do

					if self.hit_player
					and player:is_player() then

						if self.hit_player then
							self.hit_player(self, player)
						else
							mobs.arrow_hit(self, player)
						end

						self.object:remove();
						return
					end

					--[[
					local entity = player:get_luaentity()

					if entity
					and self.hit_mob
					and entity._cmi_is_mob == true
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name
					and (self._shooter and entity.name ~= self._shooter:get_luaentity().name) then

						--self.hit_mob(self, player)
						self.object:remove();
						return
					end
					] ]--

					--[[
					if entity
					and self.hit_object
					and (not entity._cmi_is_mob)
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name
					and (self._shooter and entity.name ~= self._shooter:get_luaentity().name) then

						--self.hit_object(self, player)
						self.object:remove();
						return
					end
					] ]--
				end
			end

			self.lastpos = pos
		end
	})
end


--this is used for arrow collisions
mobs.arrow_hit = function(self, player)

    player:punch(self.object, 1.0, {
        full_punch_interval = 1.0,
        damage_groups = {fleshy = self._damage}
    }, nil)


    --knockback
    local pos1 = self.object:get_pos()
	pos1.y = 0
    local pos2 = player:get_pos()
    pos2.y = 0
    local dir = vector.direction(pos1,pos2)

    dir = vector.multiply(dir,3)

    if player:get_velocity().y <= 1 then
        dir.y = 5
    end

    player:add_velocity(dir)
end
]]--
