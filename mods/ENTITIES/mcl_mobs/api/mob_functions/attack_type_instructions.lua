local vector_direction = vector.direction
local minetest_dir_to_yaw = minetest.dir_to_yaw
local vector_distance = vector.distance
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

    --make mob walk up to player within 2 nodes distance then start exploding
    if vector_distance(self.object:get_pos(), self.attacking:get_pos()) >= self.reach then
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

    mobs.set_yaw_while_attacking(self)

    mobs.set_velocity(self, self.run_velocity)

    mobs.set_mob_animation(self, "run")

    --make punchy mobs jump
    --check for nodes to jump over
    --explosive mobs will just ride against walls for now
	local node_in_front_of = mobs.jump_check(self)
	if node_in_front_of == 1 then
		mobs.jump(self)
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
end