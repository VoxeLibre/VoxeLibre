local vector_direction = vector.direction
local minetest_dir_to_yaw = minetest.dir_to_yaw
local vector_distance = vector.distance
local vector_multiply = vector.multiply
local math_random  = math.random

--[[
 _   _                     _   _ 
| | | |                   | | | |
| | | |     __ _ _ __   __| | | |
| | | |    / _` | '_ \ / _` | | |
|_| | |___| (_| | | | | (_| | |_|
(_) \_____/\__,_|_| |_|\__,_| (_)
]]--



--[[
 _____           _           _      
|  ___|         | |         | |     
| |____  ___ __ | | ___   __| | ___ 
|  __\ \/ / '_ \| |/ _ \ / _` |/ _ \
| |___>  <| |_) | | (_) | (_| |  __/
\____/_/\_\ .__/|_|\___/ \__,_|\___|
          | |                       
          |_|                       
]]--

mobs.explode_attack_walk = function(self,dtime)

    --this needs an exception
    if self.attacking == nil or not self.attacking:is_player() then
        self.attacking = nil
        return
    end

    mobs.set_yaw_while_attacking(self)

    local distance_from_attacking = vector_distance(self.object:get_pos(), self.attacking:get_pos())

    --make mob walk up to player within 2 nodes distance then start exploding
    if distance_from_attacking >= self.reach and
    --don't allow explosion to cancel unless out of the reach boundary
    not (self.explosion_animation ~= nil and self.explosion_animation > 0 and distance_from_attacking <= self.defuse_reach) then

        mobs.set_velocity(self, self.run_velocity)
        mobs.set_mob_animation(self,"run")

        mobs.reverse_explosion_animation(self,dtime)
    else
        mobs.set_velocity(self,0)

        --this is the only way I can reference this without dumping extra data on all mobs
        if not self.explosion_animation then
            self.explosion_animation = 0
        end

        --play ignite sound
        if self.explosion_animation == 0 then
            mobs.play_sound(self,"attack")
        end

        mobs.set_mob_animation(self,"stand")

        mobs.handle_explosion_animation(self)

        self.explosion_animation = self.explosion_animation + (dtime/2.5)
    end

    --make explosive mobs jump
    --check for nodes to jump over
    --explosive mobs will just ride against walls for now
	local node_in_front_of = mobs.jump_check(self)
	if node_in_front_of == 1 then
		mobs.jump(self)
    end
    

    --do biggening explosion thing
    if self.explosion_animation and self.explosion_animation > self.explosion_timer then
        mcl_explosions.explode(self.object:get_pos(), self.explosion_strength,{ drop_chance = 1.0 })
        self.object:remove()
    end
end


--this is a small helper function to make working with explosion animations easier
mobs.reverse_explosion_animation = function(self,dtime)

    --if explosion animation was greater than 0 then reverse it
    if self.explosion_animation ~= nil and self.explosion_animation > 0 then
        self.explosion_animation = self.explosion_animation - dtime
        if self.explosion_animation < 0 then
            self.explosion_animation = 0
        end
    end

    mobs.handle_explosion_animation(self)
end




--[[
______                 _     
| ___ \               | |    
| |_/ /   _ _ __   ___| |__  
|  __/ | | | '_ \ / __| '_ \ 
| |  | |_| | | | | (__| | | |
\_|   \__,_|_| |_|\___|_| |_|
]]--



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

    mobs.set_yaw_while_attacking(self)

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
    local dir = vector_direction(pos1,pos2)

    dir = vector_multiply(dir,3)

    if self.attacking:get_velocity().y <= 1 then
        dir.y = 5
    end

    self.attacking:add_velocity(dir)
end




--[[
______          _           _   _ _      
| ___ \        (_)         | | (_) |     
| |_/ / __ ___  _  ___  ___| |_ _| | ___ 
|  __/ '__/ _ \| |/ _ \/ __| __| | |/ _ \
| |  | | | (_) | |  __/ (__| |_| | |  __/
\_|  |_|  \___/| |\___|\___|\__|_|_|\___|
              _/ |                       
             |__/                        
]]--


mobs.projectile_attack_walk = function(self,dtime)

    --this needs an exception
    if self.attacking == nil or not self.attacking:is_player() then
        self.attacking = nil
        return
    end

    mobs.set_yaw_while_attacking(self)

    local distance_from_attacking = vector_distance(self.object:get_pos(), self.attacking:get_pos())


    if distance_from_attacking >= self.reach then
        mobs.set_velocity(self, self.run_velocity)
        mobs.set_mob_animation(self,"run")
    else
        mobs.set_velocity(self,0)
        mobs.set_mob_animation(self,"stand")
    end

    --do this to not load data into other mobs
    if not self.projectile_timer then
        self.projectile_timer = math_random(self.projectile_cooldown_min, self.projectile_cooldown_max)
    end

    --run projectile timer
    if self.projectile_timer > 0 then
        self.projectile_timer = self.projectile_timer - dtime

        --shoot
        if self.projectile_timer <= 0 then
            --reset timer
            self.projectile_timer = math_random(self.projectile_cooldown_min, self.projectile_cooldown_max)
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









--[[
 _  ______ _         _ 
| | |  ___| |       | |
| | | |_  | |_   _  | |
| | |  _| | | | | | | |
|_| | |   | | |_| | |_|
(_) \_|   |_|\__, | (_)
              __/ |    
             |___/     
]]--




--[[
______          _           _   _ _      
| ___ \        (_)         | | (_) |     
| |_/ / __ ___  _  ___  ___| |_ _| | ___ 
|  __/ '__/ _ \| |/ _ \/ __| __| | |/ _ \
| |  | | | (_) | |  __/ (__| |_| | |  __/
\_|  |_|  \___/| |\___|\___|\__|_|_|\___|
              _/ |                       
             |__/                        
]]--

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
            self.yaw = (math_random() * (math.pi * 2))
            --create a truly random pitch, since there is no easy access to pitch math that I can find
            self.pitch = math_random() * math.random(1,3) * random_pitch_multiplier[math_random(1,2)]
        end

        mobs.set_fly_velocity(self, self.run_velocity)

    else

        mobs.set_yaw_while_attacking(self)

        local distance_from_attacking = vector_distance(self.object:get_pos(), self.attacking:get_pos())

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
        self.projectile_timer = math_random(self.projectile_cooldown_min, self.projectile_cooldown_max)
    end

    --run projectile timer
    if self.projectile_timer > 0 then
        self.projectile_timer = self.projectile_timer - dtime

        --shoot
        if self.projectile_timer <= 0 then

            if self.fly_random_while_attack then
                mobs.set_yaw_while_attacking(self)
                self.walk_timer = 0
            end
            --reset timer
            self.projectile_timer = math_random(self.projectile_cooldown_min, self.projectile_cooldown_max)
            mobs.shoot_projectile(self)
        end
    end
end