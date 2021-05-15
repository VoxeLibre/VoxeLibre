local math_random = math.random
local math_pi     = math.pi
local math_floor  = math.floor
local math_round  = math.round

local vector_multiply = vector.multiply
local vector_add      = vector.add
local vector_new      = vector.new
local vector_distance = vector.distance

local minetest_yaw_to_dir                   = minetest.yaw_to_dir
local minetest_get_item_group               = minetest.get_item_group
local minetest_get_node                     = minetest.get_node
local minetest_line_of_sight                = minetest.line_of_sight
local minetest_get_node_light               = minetest.get_node_light

local DOUBLE_PI = math.pi * 2
local THIRTY_SECONDTH_PI = DOUBLE_PI * 0.03125


--a simple helper function which is too small to move into movement.lua
local quick_rotate = function(self,dtime)
	self.yaw = self.yaw + THIRTY_SECONDTH_PI
	if self.yaw > DOUBLE_PI then
		self.yaw = self.yaw - DOUBLE_PI
	end
end

--a simple helper function for rounding
--http://lua-users.org/wiki/SimpleRound
function round2(num, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end


--[[
 _                     _ 
| |                   | |
| |     __ _ _ __   __| |
| |    / _` | '_ \ / _` | 
| |___| (_| | | | | (_| |
\_____/\__,_|_| |_|\__,_|
]]--

--this is basically reverse jump_check
local cliff_check = function(self,dtime)
	--mobs will flip out if they are falling without this
	if self.object:get_velocity().y ~= 0 then
		return false
	end

	local pos = self.object:get_pos()
    local dir = minetest_yaw_to_dir(self.yaw)
	local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

	dir = vector_multiply(dir,radius)

	local free_fall, blocker = minetest_line_of_sight(
		{x = pos.x + dir.x, y = pos.y, z = pos.z + dir.z},
		{x = pos.x + dir.x, y = pos.y - self.fear_height, z = pos.z + dir.z})

	return free_fall
end


-- state switching logic (stand, walk, run, attacks)
local land_state_list_wandering = {"stand", "walk"}

local land_state_switch = function(self, dtime)

	--do math before sure not attacking, following, or running away so continue
	--doing random walking for mobs if all states are not met
	self.state_timer = self.state_timer - dtime

	--only run away
	if self.skittish and self.state == "run" then
		self.run_timer = self.run_timer - dtime
		if self.run_timer > 0 then
			return
		end
		--continue
	end

	--ignore everything else if breeding
	if self.breed_lookout_timer and self.breed_lookout_timer > 0 then
		self.state = "breed"
		return
	--reset the state timer to get the mob out of
	--the breed state
	elseif self.state == "breed" then
		self.state_timer = 0
	end

	--ignore everything else if following
	if mobs.check_following(self) and 
	(not self.breed_lookout_timer or (self.breed_lookout_timer and self.breed_lookout_timer == 0)) and 
	(not self.breed_timer or (self.breed_timer and self.breed_timer == 0)) then
		self.state = "follow"
		return
	--reset the state timer to get the mob out of
	--the follow state - not the cleanest option
	--but the easiest
	elseif self.state == "follow" then
		self.state_timer = 0
	end

	--only attack
	if self.hostile and self.attacking then
		self.state = "attack"
		return
	end

	--if finally reached here then do random wander
	if self.state_timer <= 0 then
		self.state_timer = math.random(4,10) + math.random()
		self.state = land_state_list_wandering[math.random(1,#land_state_list_wandering)]
	end

end

-- states are executed here
local land_state_execution = function(self,dtime)

	--[[ -- this is a debug which shows the timer and makes mobs breed 100 times faster
	print(self.breed_timer)
	if self.breed_timer > 0 then
		self.breed_timer = self.breed_timer - (dtime * 100)
		if self.breed_timer <= 0 then
			self.breed_timer = 0
		end
	end
	]]--

	--no collisionbox exception
	if not self.object:get_properties() then
		return
	end
	

	--timer to time out looking for mate
	if self.breed_lookout_timer and self.breed_lookout_timer > 0 then
		self.breed_lookout_timer = self.breed_lookout_timer - dtime
		--looking for mate failed
		if self.breed_lookout_timer <= 0 then
			self.breed_lookout_timer = 0
		end
	end

	--cool off after breeding
	if self.breed_timer and self.breed_timer > 0 then
		self.breed_timer = self.breed_timer - dtime
		--do this to skip the first check, using as switch
		if self.breed_timer <= 0 then
			self.breed_timer = 0
		end
	end


	local pos = self.object:get_pos()
	local collisionbox = self.object:get_properties().collisionbox
	--get the center of the mob
	pos.y = pos.y + (collisionbox[2] + collisionbox[5] / 2)
	local current_node = minetest_get_node(pos).name
	local float_now = false

	--recheck if in water or lava
	if minetest_get_item_group(current_node, "water") ~= 0 or minetest_get_item_group(current_node, "lava") ~= 0 then
		float_now = true
	end

	--make slow falling mobs fall slow
	if self.fall_slow then
		local velocity = self.object:get_velocity()
		if velocity then
			if velocity.y < 0 then
				--lua is acting really weird so we have to help it
				if round2(self.object:get_acceleration().y, 1) == -self.gravity then
					self.object:set_acceleration(vector_new(0,0,0))
					mobs.mob_fall_slow(self)
				end
			else
				if round2(self.object:get_acceleration().y, 1) == 0 then
					self.object:set_acceleration(vector_new(0,-self.gravity,0))
				end
			end
		end
	end

	--calculate fall damage
	if self.fall_damage then
		mobs.calculate_fall_damage(self)
	end

	if self.state == "stand" then

		--do animation
		mobs.set_mob_animation(self, "stand")

		--set the velocity of the mob
		mobs.set_velocity(self,0)

		--animation fixes for explosive mobs
		if self.attack_type == "explode" then
			mobs.reverse_explosion_animation(self,dtime)
		end

		mobs.lock_yaw(self)
	elseif self.state == "follow" then		

		--always look at players
		mobs.set_yaw_while_following(self)

		--check distance
		local distance_from_follow_person = vector_distance(self.object:get_pos(), self.following_person:get_pos())
		local distance_2d = mobs.get_2d_distance(self.object:get_pos(), self.following_person:get_pos())
				
		--don't push the player if too close
		--don't spin around randomly
		if self.follow_distance < distance_from_follow_person and self.minimum_follow_distance < distance_2d then
			mobs.set_mob_animation(self, "run")
			mobs.set_velocity(self,self.run_velocity)

			if mobs.jump_check(self) == 1 then
				mobs.jump(self)
			end
		else
			mobs.set_mob_animation(self, "stand")
			mobs.set_velocity(self,0)
		end

	elseif self.state == "walk" then

		self.walk_timer = self.walk_timer - dtime

		--reset the walk timer
		if self.walk_timer <= 0 then

			--re-randomize the walk timer
			self.walk_timer = math.random(1,6) + math.random()

			--set the mob into a random direction
			self.yaw = (math_random() * (math.pi * 2))
		end

		--do animation
		mobs.set_mob_animation(self, "walk")

		--enable rotation locking
		mobs.movement_rotation_lock(self)

		--check for nodes to jump over
		local node_in_front_of = mobs.jump_check(self)

		if node_in_front_of == 1 then

			mobs.jump(self)
		
		--turn if on the edge of cliff
		--(this is written like this because unlike
		--jump_check which simply tells the mob to jump
		--this requires a mob to turn, removing the
		--ease of a full implementation for it in a single
		--function)
		elseif node_in_front_of == 2 or (self.fear_height ~= 0 and cliff_check(self,dtime)) then
			--turn 45 degrees if so
			quick_rotate(self,dtime)
			--stop the mob so it doesn't fall off
			mobs.set_velocity(self,0)
		end

		--only move forward if path is clear
		if node_in_front_of == 0 or node_in_front_of == 1 then
			--set the velocity of the mob
			mobs.set_velocity(self,self.walk_velocity)
		end

		--animation fixes for explosive mobs
		if self.attack_type == "explode" then
			mobs.reverse_explosion_animation(self,dtime)
		end

	elseif self.state == "run" then

		--do animation
		mobs.set_mob_animation(self, "run")

		--enable rotation locking
		mobs.movement_rotation_lock(self)

		--check for nodes to jump over
		local node_in_front_of = mobs.jump_check(self)

		if node_in_front_of == 1 then

			mobs.jump(self)
		
		--turn if on the edge of cliff
		--(this is written like this because unlike
		--jump_check which simply tells the mob to jump
		--this requires a mob to turn, removing the
		--ease of a full implementation for it in a single
		--function)
		elseif node_in_front_of == 2 or (self.fear_height ~= 0 and cliff_check(self,dtime)) then
			--turn 45 degrees if so
			quick_rotate(self,dtime)
			--stop the mob so it doesn't fall off
			mobs.set_velocity(self,0)
		end

		--only move forward if path is clear
		if node_in_front_of == 0 or node_in_front_of == 1 then
			--set the velocity of the mob
			mobs.set_velocity(self,self.run_velocity)
		end

	elseif self.state == "attack" then

		--execute mob attack type
		if self.attack_type == "explode" then

			mobs.explode_attack_walk(self, dtime)

		elseif self.attack_type == "punch" then

			mobs.punch_attack_walk(self,dtime)

		elseif self.attack_type == "projectile" then

			mobs.projectile_attack_walk(self,dtime)

		end
	elseif self.state == "breed" then

		mobs.breeding_effect(self)

		local mate = mobs.look_for_mate(self)

		--found a mate
		if mate then
			mobs.set_yaw_while_breeding(self,mate)
			mobs.set_velocity(self, self.walk_velocity)

			--smoosh together basically
			if vector_distance(self.object:get_pos(), mate:get_pos()) <= self.breed_distance then
				mobs.set_mob_animation(self, "stand")
				if self.special_breed_timer == 0 then
					self.special_breed_timer = 2 --breeding takes 2 seconds
				end

				self.special_breed_timer = self.special_breed_timer - dtime
				if self.special_breed_timer <= 0 then

					--pop a baby out, it's a miracle!
					local baby_pos = vector.divide(vector.add(self.object:get_pos(), mate:get_pos()), 2)
					local baby_mob = minetest.add_entity(pos, self.name, minetest.serialize({baby = true, grow_up_timer = self.grow_up_goal, bred = true}))

					mobs.play_sound_specific(self,"item_drop_pickup")

					self.special_breed_timer = 0
					self.breed_lookout_timer = 0
					self.breed_timer = self.breed_timer_cooloff

					mate:get_luaentity().special_breed_timer = 0
					mate:get_luaentity().breed_lookout_timer = 0
					mate:get_luaentity().breed_timer = self.breed_timer_cooloff -- can reuse because it's the same mob
				end
			else
				mobs.set_mob_animation(self, "walk")
			end
		--couldn't find a mate, just stand there until the player pushes it towards one
		--or the timer runs out
		else
			mobs.set_mob_animation(self, "stand")
			mobs.set_velocity(self,0)
		end

	end	
	
	if float_now then
		mobs.float(self)
	else
		local acceleration = self.object:get_acceleration()
		if acceleration and acceleration.y == 0 then
			self.object:set_acceleration(vector_new(0,-self.gravity,0))
		end
	end
end




--[[
 _____          _           
/  ___|        (_)          
\ `--.__      ___ _ __ ___  
 `--. \ \ /\ / / | '_ ` _ \ 
/\__/ /\ V  V /| | | | | | |
\____/  \_/\_/ |_|_| |_| |_|
]]--



-- state switching logic (stand, walk, run, attacks)
local swim_state_list_wandering = {"stand", "swim"}

local swim_state_switch = function(self, dtime)
	self.state_timer = self.state_timer - dtime
	if self.state_timer <= 0 then
		self.state_timer = math.random(4,10) + math.random()
		self.state = swim_state_list_wandering[math.random(1,#swim_state_list_wandering)]
	end
end


--check if a mob needs to turn while swimming
local swim_turn_check = function(self,dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest_yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector_multiply(dir, radius)

    local test_dir = vector.add(pos,dir)

	local green_flag_1 = minetest_get_item_group(minetest_get_node(test_dir).name, "solid") ~= 0

	return(green_flag_1)
end

--this is to swap the built in engine acceleration modifier
local swim_physics_swapper = function(self,inside_swim_node)

	--should be swimming, gravity is applied, switch to floating
	if inside_swim_node and self.object:get_acceleration().y ~= 0 then
		self.object:set_acceleration(vector_new(0,0,0))
	--not be swim, gravity isn't applied, switch to falling
	elseif not inside_swim_node and self.object:get_acceleration().y == 0 then
		self.pitch = 0
		self.object:set_acceleration(vector_new(0,-self.gravity,0))
	end
end


local random_pitch_multiplier = {-1,1}
-- states are executed here
local swim_state_execution = function(self,dtime)

	local pos = self.object:get_pos()

	pos.y = pos.y + self.object:get_properties().collisionbox[5]
	local current_node = minetest_get_node(pos).name
	local inside_swim_node = false

	--quick scan everything to see if inside swim node
	for _,id in pairs(self.swim_in) do
		if id == current_node then
			inside_swim_node = true
			break
		end
	end

	--turn gravity on or off
	swim_physics_swapper(self,inside_swim_node)

	--swim properly if inside swim node
	if inside_swim_node then

		if self.state == "stand" then

			--do animation
			mobs.set_mob_animation(self, "stand")

			mobs.set_swim_velocity(self,0)

			if self.tilt_swim then
				mobs.set_static_pitch(self)
			end

			mobs.lock_yaw(self)

		elseif self.state == "swim" then

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

			--do animation
			mobs.set_mob_animation(self, "walk")

			--do a quick turn to make mob continuously move
			--if in a fish tank or something
			if swim_turn_check(self,dtime) then
				quick_rotate(self,dtime)
			end

			mobs.set_swim_velocity(self,self.walk_velocity)

			--only enable tilt swimming if enabled
			if self.tilt_swim then
				mobs.set_dynamic_pitch(self)
			end

			--enable rotation locking
			mobs.movement_rotation_lock(self)
		end
	--flop around if not inside swim node
	else
		--do animation
		mobs.set_mob_animation(self, "stand")

		mobs.flop(self)

		if self.tilt_swim then
			mobs.set_static_pitch(self)
		end
	end

end


--[[
______ _       
|  ___| |      
| |_  | |_   _ 
|  _| | | | | |
| |   | | |_| |
\_|   |_|\__, |
          __/ |
         |___/ 
]]--

-- state switching logic (stand, walk, run, attacks)
local fly_state_list_wandering = {"stand", "fly"}

local fly_state_switch = function(self, dtime)

	if self.hostile and self.attacking then
		self.state = "attack"
		return
	end

	self.state_timer = self.state_timer - dtime
	if self.state_timer <= 0 then
		self.state_timer = math.random(4,10) + math.random()
		self.state = fly_state_list_wandering[math.random(1,#fly_state_list_wandering)]
	end
end


--check if a mob needs to turn while flying
local fly_turn_check = function(self,dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest_yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector_multiply(dir, radius)

    local test_dir = vector.add(pos,dir)

	local green_flag_1 = minetest_get_item_group(minetest_get_node(test_dir).name, "solid") ~= 0

	return(green_flag_1)
end

--this is to swap the built in engine acceleration modifier
local fly_physics_swapper = function(self,inside_fly_node)

	--should be flyming, gravity is applied, switch to floating
	if inside_fly_node and self.object:get_acceleration().y ~= 0 then
		self.object:set_acceleration(vector_new(0,0,0))
	--not be fly, gravity isn't applied, switch to falling
	elseif not inside_fly_node and self.object:get_acceleration().y == 0 then
		self.pitch = 0
		self.object:set_acceleration(vector_new(0,-self.gravity,0))
	end
end


local random_pitch_multiplier = {-1,1}
-- states are executed here
local fly_state_execution = function(self,dtime)
	local pos = self.object:get_pos()
	pos.y = pos.y + 0.1
	local current_node = minetest_get_node(pos).name
	local inside_fly_node = minetest_get_item_group(current_node, "solid") == 0

	local float_now = false
	--recheck if in water or lava
	if minetest_get_item_group(current_node, "water") ~= 0 or minetest_get_item_group(current_node, "lava") ~= 0 then
		inside_fly_node = false
		float_now = true
	end

	--turn gravity on or off
	fly_physics_swapper(self,inside_fly_node)

	--fly properly if inside fly node
	if inside_fly_node then
		if self.state == "stand" then

			--do animation
			mobs.set_mob_animation(self, "stand")

			mobs.set_fly_velocity(self,0)

			if self.tilt_fly then
				mobs.set_static_pitch(self)
			end

			mobs.lock_yaw(self)

		elseif self.state == "fly" then

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

			--do animation
			mobs.set_mob_animation(self, "walk")

			--do a quick turn to make mob continuously move
			--if in a bird cage or something
			if fly_turn_check(self,dtime) then
				quick_rotate(self,dtime)
			end

			if self.tilt_fly then
				mobs.set_dynamic_pitch(self)
			end

			mobs.set_fly_velocity(self,self.walk_velocity)

			--enable rotation locking
			mobs.movement_rotation_lock(self)

		elseif self.state == "attack" then
		
			--execute mob attack type
			--if self.attack_type == "explode" then

				--mobs.explode_attack_fly(self, dtime)

			--elseif self.attack_type == "punch" then

				--mobs.punch_attack_fly(self,dtime)

			if self.attack_type == "projectile" then

				mobs.projectile_attack_fly(self,dtime)

			end
		end
	else
		--make the mob float
		if self.floats and float_now then
			mobs.set_velocity(self, 0)

			mobs.float(self)

			if self.tilt_fly then
				mobs.set_static_pitch(self)
			end
		end
	end
end


--[[
   ___                       
  |_  |                      
    | |_   _ _ __ ___  _ __  
    | | | | | '_ ` _ \| '_ \ 
/\__/ / |_| | | | | | | |_) |
\____/ \__,_|_| |_| |_| .__/ 
                      | |    
                      |_|    
]]--


--check if a mob needs to turn while jumping
local jump_turn_check = function(self,dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest_yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector_multiply(dir, radius)

    local test_dir = vector.add(pos,dir)

	local green_flag_1 = minetest_get_item_group(minetest_get_node(test_dir).name, "solid") ~= 0

	return(green_flag_1)
end

-- state switching logic (stand, jump, run, attacks)
local jump_state_list_wandering = {"stand", "jump"}

local jump_state_switch = function(self, dtime)
	self.state_timer = self.state_timer - dtime
	if self.state_timer <= 0 then
		self.state_timer = math.random(4,10) + math.random()
		self.state = jump_state_list_wandering[math.random(1,#jump_state_list_wandering)]
	end
end

-- states are executed here
local jump_state_execution = function(self,dtime)

	local pos = self.object:get_pos()
	local collisionbox = self.object:get_properties().collisionbox
	--get the center of the mob
	pos.y = pos.y + (collisionbox[2] + collisionbox[5] / 2)
	local current_node = minetest_get_node(pos).name

	local float_now = false

	--recheck if in water or lava
	if minetest_get_item_group(current_node, "water") ~= 0 or minetest_get_item_group(current_node, "lava") ~= 0 then
		float_now = true
	end

	if self.state == "stand" then

		--do animation
		mobs.set_mob_animation(self, "stand")

		--set the velocity of the mob
		mobs.set_velocity(self,0)

		mobs.lock_yaw(self)

	elseif self.state == "jump" then

		self.walk_timer = self.walk_timer - dtime

		--reset the jump timer
		if self.walk_timer <= 0 then

			--re-randomize the jump timer
			self.walk_timer = math.random(1,6) + math.random()

			--set the mob into a random direction
			self.yaw = (math_random() * (math.pi * 2))
		end

		--do animation
		mobs.set_mob_animation(self, "walk")

		--enable rotation locking
		mobs.movement_rotation_lock(self)

		--jumping mobs are more loosey goosey
		if node_in_front_of == 1 then
			quick_rotate(self,dtime)
		end

		--only move forward if path is clear
		mobs.jump_move(self,self.walk_velocity)

	elseif self.state == "run" then

		print("run")

	elseif self.state == "attack" then

		print("attack")

	end	
	
	if float_now then
		mobs.float(self)
	end
end




--[[
___  ___      _         _                 _      
|  \/  |     (_)       | |               (_)     
| .  . | __ _ _ _ __   | |     ___   __ _ _  ___ 
| |\/| |/ _` | | '_ \  | |    / _ \ / _` | |/ __|
| |  | | (_| | | | | | | |___| (_) | (_| | | (__ 
\_|  |_/\__,_|_|_| |_| \_____/\___/ \__, |_|\___|
                                     __/ |       
                                    |___/        
]]--

--the main loop
mobs.mob_step = function(self, dtime)

	--do not continue if non-existent
	if not self or not self.object or not self.object:get_luaentity() then
		self.object:remove()
		return false
	end


	--DEBUG TIME!
	--REMEMBER TO MOVE THIS AFTER DEATH CHECK

	--if self.has_head then
	--	mobs.do_head_logic(self,dtime)
	--end



	--if true then--DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG DEBUG
	--	return
	--end

	--despawn mechanism
	--don't despawned tamed or bred mobs
	if not self.tamed and not self.bred then
		self.lifetimer = self.lifetimer - dtime
		if self.lifetimer <= 0 then
			self.lifetimer = self.lifetimer_reset
			if not mobs.check_for_player_within_area(self, 64) then
				--print("removing in MAIN LOGIC!")
				self.object:remove()
				return
			end
		end
	end

	--color modifier which coincides with the pause_timer
	if self.old_health and self.health < self.old_health then		
		self.object:set_texture_mod("^[colorize:red:120")
		--fix double death sound
		if self.health > 0 then
			mobs.play_sound(self,"damage")
		end
	end	
	self.old_health = self.health

	--do death logic (animation, poof, explosion, etc)
	if self.health <= 0 or self.dead then
		--play death sound once
		if not self.played_death_sound then
			self.dead = true
			mobs.play_sound(self,"death")
			self.played_death_sound = true
		end

		mobs.death_logic(self, dtime)

		--this is here because the mob must continue to move
		--while stunned before coming to a complete halt even during
		--the death tilt
		if self.pause_timer > 0 then
			self.pause_timer = self.pause_timer - dtime
			--perfectly reset pause_timer
			if self.pause_timer < 0 then
				self.pause_timer = 0
			end
		end

		return
	end

	mobs.random_sound_handling(self,dtime)

	--mobs drowning mechanic
	if not self.breathes_in_water then

		local pos = self.object:get_pos()

		pos.y = pos.y + self.eye_height

		local node = minetest_get_node(pos).name

		if minetest_get_item_group(node, "water") ~= 0 then
			self.breath = self.breath - dtime

			--reset breath when drowning
			if self.breath <= 0 then
				self.health = self.health - 4
				self.breath = 1
				self.pause_timer = 0.5
			end

		elseif self.breath < self.breath_max then
			self.breath = self.breath + dtime
			
			--clean timer reset
			if self.breath > self.breath_max then
				self.breath = self.breath_max
			end
		end
	end

	--set mobs on fire when burned by sunlight
	if self.ignited_by_sunlight then
		local pos = self.object:get_pos()
		pos.y = pos.y + 0.1

		if self.burn_timer > 0 then
			self.burn_timer = self.burn_timer - dtime

			if self.burn_timer <= 0 then
				self.health = self.health - 4
				self.burn_timer = 0
			end
		end

		if self.burn_timer == 0 then
			local light_current, light_day = minetest_get_node_light(pos), minetest_get_node_light(pos, 0.5)
			if light_current and light_day and light_current > 12 and light_day == 15 then
				mcl_burning.set_on_fire(self.object, 1)
				self.burn_timer = 1 --1.7 seconds
				self.pause_timer = 0.4
			end
		end
	end

	

	

	--baby grows up
	if self.baby then
		--print(self.grow_up_timer)
		--catch missing timer
		if not self.grow_up_timer then
			self.grow_up_timer = self.grow_up_goal
		end

		self.grow_up_timer = self.grow_up_timer - dtime

		--baby grows up!
		if self.grow_up_timer <= 0 then
			self.grow_up_timer = 0
			mobs.baby_grow_up(self)
		end
	end
	


	--do custom mob instructions
	if self.do_custom then
		-- when false skip going any further
		if self.do_custom(self, dtime) == false then
			--this needs to be here or the mob becomes immortal
			if self.pause_timer > 0 then
				self.pause_timer = self.pause_timer - dtime
				--perfectly reset pause_timer
				if self.pause_timer <= 0 then
					self.pause_timer = 0
					self.object:set_texture_mod("")
				end
			end
			--this overrides internal lua collision detection
			return
		end
	end

	local attacking = nil

	--scan for players within eyesight
	if self.hostile then
		--true for line_of_sight is debug
		attacking = mobs.detect_closest_player_within_radius(self,true,self.view_range,self.eye_height)

		--go get the closest player
		if attacking then

			self.memory = 6 --6 seconds of memory

			--set initial punch timer
			if self.attacking == nil then
				if self.attack_type == "punch" then
					self.punch_timer = -1
				end
			end
			self.attacking = attacking

		--no player in area
		elseif self.memory > 0 then
			--try to remember
			self.memory = self.memory - dtime
			--get if memory player is within viewing range
			if self.attacking and self.attacking:is_player() then
				local distance = vector_distance(self.object:get_pos(), self.attacking:get_pos())
				if distance > self.view_range then
					self.memory = 0
				end
			--out of viewing range, forget em
			else
				self.memory = 0
			end

			if self.memory <= 0 then

				--reset states when coming out of hostile state
				if self.attacking ~= nil then
					self.state_timer = -1
				end

				self.attacking = nil
				self.memory = 0
			end
		end
	end

	--count down hostile cooldown timer when no players in range
	if self.neutral and self.hostile and not attacking and self.hostile_cooldown_timer then

		self.hostile_cooldown_timer = self.hostile_cooldown_timer - dtime

		if self.hostile_cooldown_timer <= 0 then
			self.hostile = false
			self.hostile_cooldown_timer = 0
		end
	end

	--mob is stunned after being hit
	if self.pause_timer > 0 then
		self.pause_timer = self.pause_timer - dtime
		--don't break eye contact
		if self.hostile and self.attacking then
			mobs.set_yaw_while_attacking(self)
		end

		--perfectly reset pause_timer
		if self.pause_timer <= 0 then
			self.pause_timer = 0
			self.object:set_texture_mod("")
		end

		--stop walking mobs from falling through the water
		if not self.jump_only and not self.swim and not self.fly then
			local pos = self.object:get_pos()
			local collisionbox = self.object:get_properties().collisionbox
			--get the center of the mob
			pos.y = pos.y + (collisionbox[2] + collisionbox[5] / 2)
			local current_node = minetest_get_node(pos).name

			--recheck if in water or lava
			if minetest_get_item_group(current_node, "water") ~= 0 or minetest_get_item_group(current_node, "lava") ~= 0 then
				mobs.float(self)
			end
		end

		--stop projectile mobs from being completely disabled while stunned
		if self.projectile_timer and self.projectile_timer > 0.01 then
			self.projectile_timer = self.projectile_timer - dtime
			if self.projectile_timer < 0.01 then
				self.projectile_timer = 0.01
			end
		end

		return -- don't allow collision detection
	--do normal ai
	else
		--jump only (like slimes)
		if self.jump_only then
			jump_state_switch(self, dtime)
			jump_state_execution(self, dtime)		
		--swimming
		elseif self.swim then
			swim_state_switch(self, dtime)
			swim_state_execution(self, dtime)
		--flying
		elseif self.fly then
			fly_state_switch(self, dtime)
			fly_state_execution(self,dtime)
		--regular mobs that walk around
		else
			land_state_switch(self, dtime)
			land_state_execution(self,dtime)
		end
	end

	--do not continue if non-existent
	if not self or not self.object or not self.object:get_luaentity() then
		self.object:remove()
		return false
	end

	--make it so mobs do not glitch out when walking around/jumping
	mobs.swap_auto_step_height_adjust(self)


	-- can mob be pushed, if so calculate direction -- do this last (overrides everything)
	if self.pushable then
		mobs.collision(self)
	end

	--overrides absolutely everything
	--mobs get stuck in cobwebs like players
	if not self.ignores_cobwebs then

		local pos = self.object:get_pos()
		local node = pos and minetest_get_node(pos).name
		
		if node == "mcl_core:cobweb" then

			--fight the rest of the api
			if self.object:get_acceleration().y ~= 0 then
				self.object:set_acceleration(vector_new(0,0,0))
			end

			mobs.stick_in_cobweb(self)

			self.was_stuck_in_cobweb = true

		else
			--do not override other functions
			if self.was_stuck_in_cobweb == true then
				--return the mob back to normal
				self.was_stuck_in_cobweb = nil
				if self.object:get_acceleration().y == 0 and not self.swim and not self.fly then
					self.object:set_acceleration(vector_new(0,-self.gravity,0))
				end
			end
		end
	end

	self.old_velocity = self.object:get_velocity()
	self.old_pos = self.object:get_pos()
end
