local math_random = math.random

local vector_multiply = vector.multiply
local vector_add      = vector.add
local vector_new      = vector.new

local minetest_yaw_to_dir                   = minetest.yaw_to_dir
local minetest_get_item_group               = minetest.get_item_group
local minetest_get_node                     = minetest.get_node
local minetest_line_of_sight                = minetest.line_of_sight

local DOUBLE_PI = math.pi * 2
local THIRTY_SECONDTH_PI = DOUBLE_PI * 0.03125


--a simple helper function which is too small to move into movement.lua
local quick_rotate = function(self,dtime)
	self.yaw = self.yaw + THIRTY_SECONDTH_PI
	if self.yaw > DOUBLE_PI then
		self.yaw = self.yaw - DOUBLE_PI
	end
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

--check if a mob needs to jump
local jump_check = function(self,dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest_yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector_multiply(dir, radius)

	--only jump if there's a node and a non-solid node above it
    local test_dir = vector.add(pos,dir)

	local green_flag_1 = minetest_get_item_group(minetest_get_node(test_dir).name, "solid") ~= 0

	test_dir.y = test_dir.y + 1

	local green_flag_2 = minetest_get_item_group(minetest_get_node(test_dir).name, "solid") == 0

    if green_flag_1 and green_flag_2 then
		--can jump over node
        return(1)
	elseif green_flag_1 and not green_flag_2 then 
		--wall in front of mob
		return(2)
    end

	--nothing to jump over
	return(0)
end



-- state switching logic (stand, walk, run, attacks)
local land_state_list_wandering = {"stand", "walk"}

local land_state_switch = function(self, dtime)
	self.state_timer = self.state_timer - dtime
	if self.wandering and self.state_timer <= 0 then
		self.state_timer = math.random(4,10) + math.random()
		self.state = land_state_list_wandering[math.random(1,#land_state_list_wandering)]
	end

end

-- states are executed here
local land_state_execution = function(self,dtime)

	if self.state == "stand" then

		--do animation
		mobs.set_mob_animation(self, "stand")

		--set the velocity of the mob
		mobs.set_velocity(self,0)

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
		local node_in_front_of = jump_check(self)

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

	elseif self.state == "run" then

		print("run")

	elseif self.state == "attack" then

		print("attack")

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
	if self.wandering and self.state_timer <= 0 then
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

		elseif self.state == "swim" then

			self.walk_timer = self.walk_timer - dtime

			--reset the walk timer
			if self.walk_timer <= 0 then
	
				--re-randomize the walk timer
				self.walk_timer = math.random(1,6) + math.random()
	
				--set the mob into a random direction
				self.yaw = (math_random() * (math.pi * 2))

				--create a truly random pitch, since there is no easy access to pitch math that I can find
				self.pitch = math_random() * random_pitch_multiplier[math_random(1,2)]
			end

			--do animation
			mobs.set_mob_animation(self, "walk")

			--do a quick turn to make mob continuously move
			--if in a fish tank or something
			if swim_turn_check(self,dtime) then
				quick_rotate(self,dtime)
			end

			mobs.set_swim_velocity(self,self.walk_velocity)
		end
	--flop around if not inside swim node
	else
		--do animation
		mobs.set_mob_animation(self, "stand")

		mobs.flop(self)
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
	self.state_timer = self.state_timer - dtime
	if self.wandering and self.state_timer <= 0 then
		self.state_timer = math.random(4,10) + math.random()
		self.state = fly_state_list_wandering[math.random(1,#fly_state_list_wandering)]
	end
end


--check if a mob needs to turn while flyming
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
	pos.y = pos.y + self.object:get_properties().collisionbox[5]
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

		elseif self.state == "fly" then

			self.walk_timer = self.walk_timer - dtime

			--reset the walk timer
			if self.walk_timer <= 0 then
	
				--re-randomize the walk timer
				self.walk_timer = math.random(1,6) + math.random()
	
				--set the mob into a random direction
				self.yaw = (math_random() * (math.pi * 2))

				--create a truly random pitch, since there is no easy access to pitch math that I can find
				self.pitch = math_random() * random_pitch_multiplier[math_random(1,2)]
			end

			--do animation
			mobs.set_mob_animation(self, "walk")

			--do a quick turn to make mob continuously move
			--if in a bird cage or something
			if fly_turn_check(self,dtime) then
				quick_rotate(self,dtime)
			end

			mobs.set_fly_velocity(self,self.walk_velocity)
		end
	else
		--make the mob float
		if self.floats and float_now then
			mobs.float(self)
		end
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
		return false
	end

	--swimming
	if self.swim then
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


	-- can mob be pushed, if so calculate direction -- do this last (overrides everything)
	if self.pushable then
		mobs.collision(self)
	end

    self.old_velocity = self.object:get_velocity()
end
