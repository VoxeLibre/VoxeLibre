local minetest_get_objects_inside_radius    = minetest.get_objects_inside_radius

local math_random = math.random
local vector_multiply = vector.multiply

local vector_direction = vector.direction

local integer_test = {-1,1}

mobs.collision = function(self)
				
	local pos = self.object:get_pos()


	if not self or not self.object or not self.object:get_luaentity() then
		return
	end

	--do collision detection from the base of the mob
	local collisionbox = self.object:get_properties().collisionbox

	pos.y = pos.y + collisionbox[2]
	
	local collision_boundary = collisionbox[4]

	local radius = collision_boundary

	if collisionbox[5] > collision_boundary then
		radius = collisionbox[5]
	end

	local collision_count = 0


	local check_for_attack = false

	if self.attack_type == "punch" and self.hostile and self.attacking then
		check_for_attack = true
	end

	for _,object in ipairs(minetest_get_objects_inside_radius(pos, radius*1.25)) do
		if object and object ~= self.object and (object:is_player() or object:get_luaentity()._cmi_is_mob == true) then--and
		--don't collide with rider, rider don't collide with thing
		--(not object:get_attach() or (object:get_attach() and object:get_attach() ~= self.object)) and 
		--(not self.object:get_attach() or (self.object:get_attach() and self.object:get_attach() ~= object)) then
			--stop infinite loop
			collision_count = collision_count + 1
			if collision_count > 100 then
				break
			end

			local pos2 = object:get_pos()
			
			local object_collisionbox = object:get_properties().collisionbox

			pos2.y = pos2.y + object_collisionbox[2]

			local object_collision_boundary = object_collisionbox[4]


			--this is checking the difference of the object collided with's possision
			--if positive top of other object is inside (y axis) of current object
			local y_base_diff = (pos2.y + object_collisionbox[5]) - pos.y

			local y_top_diff = (pos.y + collisionbox[5]) - pos2.y


			local distance = vector.distance(vector.new(pos.x,0,pos.z),vector.new(pos2.x,0,pos2.z))

			if distance <= collision_boundary + object_collision_boundary and y_base_diff >= 0 and y_top_diff >= 0 then

				local dir = vector.direction(pos,pos2)

				dir.y = 0
				
				--eliminate mob being stuck in corners
				if dir.x == 0 and dir.z == 0 then
					--slightly adjust mob position to prevent equal length
					--corner/wall sticking
					dir.x = dir.x + ((math_random()/10)*integer_test[math.random(1,2)])
					dir.z = dir.z + ((math_random()/10)*integer_test[math.random(1,2)])
				end

				local velocity = dir
				
				--0.5 is the max force multiplier
				local force = 0.5 - (0.5 * distance / (collision_boundary + object_collision_boundary))

				local vel1 = vector.multiply(velocity, -1.5)
				local vel2 = vector.multiply(velocity,  1.5)

				vel1 = vector.multiply(vel1, force * 10)
				vel2 = vector.multiply(vel2, force)

				if object:is_player() then
					vel2 = vector_multiply(vel2, 2.5)

					--integrate mob punching into collision detection
					if check_for_attack and self.punch_timer <= 0 then
						if object == self.attacking then
							mobs.punch_attack(self)
						end
					end
				end
			
				self.object:add_velocity(vel1)
				object:add_velocity(vel2)
			end
			
		end
	end
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
    local dir = vector_direction(pos1,pos2)

    dir = vector_multiply(dir,3)

    if player:get_velocity().y <= 1 then
        dir.y = 5
    end

    player:add_velocity(dir)
end