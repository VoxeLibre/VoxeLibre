--[[

mobs.shoot_projectile_handling = function(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, bow_stack, collectable, gravity)
	local obj = mcl_bows.shoot_arrow(arrow_item, pos, dir, yaw, shooter, power, damage, is_critical, bow_stack, collectable, gravity, true)

    --play custom shoot sound
    if shooter ~= nil and shooter.shoot_sound then
        minetest.sound_play(shooter.shoot_sound, {pos=pos, max_hear_distance=16}, true)
    end

	return obj
end

--do internal per mob projectile calculations
mobs.shoot_projectile = function(self)

	local pos1 = self.object:get_pos()
	--add mob eye height
	pos1.y = pos1.y + self.eye_height

	local pos2 = self.attacking:get_pos()
	--add player eye height
	pos2.y = pos2.y + mcl_mobs.util.get_eye_height(self.attacking)

	--get direction
	local dir = vector.direction(pos1,pos2)

	--call internal shoot_arrow function
	self.shoot_arrow(self,pos1,dir)
end
]]--
