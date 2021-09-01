--[[
mobs.punch_attack_walk = function(self,dtime)

    --this needs an exception
    if self.attacking == nil or not self.attacking:is_player() then
        self.attacking = nil
        return
    end

    local distance_from_attacking = mobs.get_2d_distance(self.object:get_pos(), self.attacking:get_pos())

    if distance_from_attacking >= self.minimum_follow_distance then
        mobs.set_velocity(self, self.run_velocity)
        mobs.set_mob_animation(self, "run")
    else
        mobs.set_velocity(self, 0)
        mobs.set_mob_animation(self, "stand")
    end

    self:look_at(self.attack)

    --make punchy mobs jump
    --check for nodes to jump over
    --explosive mobs will just ride against walls for now
	local node_in_front_of = mobs.jump_check(self)

	if node_in_front_of == 1 then
		mobs.jump(self)
    end

    --mobs that can climb over stuff
    if self.always_climb and node_in_front_of > 0 then
        mobs.climb(self)
    end


    --auto reset punch_timer
    if not self.punch_timer then
        self.punch_timer = 0
    end

    if self.punch_timer > 0 then
        self.punch_timer = self.punch_timer - dtime
    end
end

mobs.punch_attack = function(self)

    self.attacking:punch(self.object, 1.0, {
        full_punch_interval = 1.0,
        damage_groups = {fleshy = self.damage}
    }, nil)

    self.punch_timer = self.punch_timer_cooloff


    --knockback
    local pos1 = self.object:get_pos()
    pos1.y = 0
    local pos2 = self.attacking:get_pos()
    pos2.y = 0
    local dir = vector.direction(pos1,pos2)

    dir = vector.multiply(dir,3)

    if self.attacking:get_velocity().y <= 1 then
        dir.y = 5
    end

    self.attacking:add_velocity(dir)
end
--]]
--[[
--integrate mob punching into collision detection
local check_for_attack = false

if self.attack_type == "punch" and self.hostile and self.attacking then
	check_for_attack = true
end

if check_for_attack and self.punch_timer <= 0 then
	if object == self.attacking then
		mobs.punch_attack(self)
	end
end

]]--
