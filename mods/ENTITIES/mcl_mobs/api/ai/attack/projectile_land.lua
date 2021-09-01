--[[

mobs.projectile_attack_walk = function(self,dtime)

    --this needs an exception
    if self.attacking == nil or not self.attacking:is_player() then
        self.attacking = nil
        return
    end

    self:look_at(self.attack)

    local distance_from_attacking = vector.distance(self.object:get_pos(), self.attacking:get_pos())


    if distance_from_attacking >= self.reach then
        mobs.set_velocity(self, self.run_velocity)
        mobs.set_mob_animation(self,"run")
    else
        mobs.set_velocity(self,0)
        mobs.set_mob_animation(self,"stand")
    end

    --do this to not load data into other mobs
    if not self.projectile_timer then
        self.projectile_timer = math.random(self.projectile_cooldown_min, self.projectile_cooldown_max)
    end

    --run projectile timer
    if self.projectile_timer > 0 then
        self.projectile_timer = self.projectile_timer - dtime

        --shoot
        if self.projectile_timer <= 0 then
            --reset timer
            self.projectile_timer = math.random(self.projectile_cooldown_min, self.projectile_cooldown_max)
            mobs.shoot_projectile(self)
        end
    end

    --make shooty mobs jump
    --check for nodes to jump over
    --explosive mobs will just ride against walls for now
	local node_in_front_of = mobs.jump_check(self)
	if node_in_front_of == 1 then
		mobs.jump(self)
    end

end


]]--
