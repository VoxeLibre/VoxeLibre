--[[
local random_pitch_multiplier = {-1,1}

mobs.projectile_attack_fly = function(self, dtime)

    --this needs an exception
    if self.attacking == nil or not self.attacking:is_player() then
        self.attacking = nil
        return
    end

    --this is specifically for random ghast movement
    if self.fly_random_while_attack then

        --enable rotation locking
		mobs.movement_rotation_lock(self)

        self.walk_timer = self.walk_timer - dtime

        --reset the walk timer
        if self.walk_timer <= 0 then
            --re-randomize the walk timer
            self.walk_timer = math.random(1,6) + math.random()
            --set the mob into a random direction
            self.yaw = (math.random() * (math.pi * 2))
            --create a truly random pitch, since there is no easy access to pitch math that I can find
            self.pitch = math.random() * math.random(1,3) * random_pitch_multiplier[math.random(1,2)]
        end

        mobs.set_fly_velocity(self, self.run_velocity)

    else

        self:look_at(self.attack)

        local distance_from_attacking = vector.distance(self.object:get_pos(), self.attacking:get_pos())

        if distance_from_attacking >= self.reach then
            mobs.set_pitch_while_attacking(self)
            mobs.set_fly_velocity(self, self.run_velocity)
            mobs.set_mob_animation(self,"run")
        else
            mobs.set_pitch_while_attacking(self)
            mobs.set_fly_velocity(self, 0)
            mobs.set_mob_animation(self,"stand")
        end
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

            if self.fly_random_while_attack then
                self:look_at(self.attack)
                self.walk_timer = 0
            end
            --reset timer
            self.projectile_timer = math.random(self.projectile_cooldown_min, self.projectile_cooldown_max)
            mobs.shoot_projectile(self)
        end
    end
end
]]--
