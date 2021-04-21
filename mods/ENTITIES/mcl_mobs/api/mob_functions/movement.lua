local math_pi     = math.pi
local math_sin    = math.sin
local math_cos    = math.cos
local math_random = math.random
local HALF_PI     = math_pi / 2
local DOUBLE_PI   = math_pi * 2

-- localize vector functions
local vector_new      = vector.new
local vector_length   = vector.length
local vector_multiply = vector.multiply
local vector_distance = vector.distance

local minetest_yaw_to_dir = minetest.yaw_to_dir
local minetest_dir_to_yaw = minetest.dir_to_yaw

local DEFAULT_JUMP_HEIGHT = 5
local DEFAULT_FLOAT_SPEED = 4



--this is a generic float function
mobs.float = function(self)

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = 0,
		y = DEFAULT_FLOAT_SPEED,
		z = 0,
	}

	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	new_velocity_addition.x = 0
	new_velocity_addition.z = 0

	--smooths out mobs a bit
	if vector_length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end



--[[
 _                     _ 
| |                   | |
| |     __ _ _ __   __| |
| |    / _` | '_ \ / _` | 
| |___| (_| | | | | (_| |
\_____/\__,_|_| |_|\__,_|
]]


-- move mob in facing direction
--this has been modified to be internal
--internal = lua (self.yaw)
--engine = c++ (self.object:get_yaw())
mobs.set_velocity = function(self, v)
	
	local yaw = (self.yaw or 0)

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = (math_sin(yaw) * -v),
		y = 0,
		z = (math_cos(yaw) * v),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector_length(new_velocity_addition) > vector_length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector_length(goal_velocity) / vector_length(new_velocity_addition)))
	end

	new_velocity_addition.y = 0

	--smooths out mobs a bit
	if vector_length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end



-- calculate mob velocity
mobs.get_velocity = function(self)

	local v = self.object:get_velocity()

	v.y = 0

	if v then
		return vector_length(v)
	end

	return 0
end

--make mobs jump
mobs.jump = function(self, velocity)

    if self.object:get_velocity().y ~= 0 or not self.old_velocity or (self.old_velocity and self.old_velocity.y > 0) then
        return
    end

	--fallback velocity to allow modularity
    velocity = velocity or DEFAULT_JUMP_HEIGHT

    self.object:add_velocity(vector_new(0,velocity,0))    
end





--[[
 _____          _           
/  ___|        (_)          
\ `--.__      ___ _ __ ___  
 `--. \ \ /\ / / | '_ ` _ \ 
/\__/ /\ V  V /| | | | | | |
\____/  \_/\_/ |_|_| |_| |_|
]]--




--make mobs flop
mobs.flop = function(self, velocity)

    if self.object:get_velocity().y ~= 0 or not self.old_velocity or (self.old_velocity and self.old_velocity.y > 0) then
        return false
    end

	mobs.set_velocity(self, 0)

	--fallback velocity to allow modularity
    velocity = velocity or DEFAULT_JUMP_HEIGHT

	--create a random direction (2d yaw)
	local dir = DOUBLE_PI * math_random()

	--create a random force value
	local force = math_random(0,3) + math_random()

	--convert the yaw to a direction vector then multiply it times the force
	local final_additional_force = vector_multiply(minetest_yaw_to_dir(dir), force)

	--place in the "flop" velocity to make the mob flop
	final_additional_force.y = velocity	

    self.object:add_velocity(final_additional_force)

	return true
end



-- move mob in facing direction
--this has been modified to be internal
--internal = lua (self.yaw)
--engine = c++ (self.object:get_yaw())
mobs.set_swim_velocity = function(self, v)
	
	local yaw = (self.yaw or 0)
	local pitch = (self.pitch or 0)

	if v == 0 then
		pitch = 0
	end

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = (math_sin(yaw) * -v),
		y = pitch,
		z = (math_cos(yaw) * v),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector_length(new_velocity_addition) > vector_length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector_length(goal_velocity) / vector_length(new_velocity_addition)))
	end

	--smooths out mobs a bit
	if vector_length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
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

-- move mob in facing direction
--this has been modified to be internal
--internal = lua (self.yaw)
--engine = c++ (self.object:get_yaw())
mobs.set_fly_velocity = function(self, v)
	
	local yaw = (self.yaw or 0)
	local pitch = (self.pitch or 0)

	if v == 0 then
		pitch = 0
	end

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = (math_sin(yaw) * -v),
		y = pitch,
		z = (math_cos(yaw) * v),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector_length(new_velocity_addition) > vector_length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector_length(goal_velocity) / vector_length(new_velocity_addition)))
	end

	--smooths out mobs a bit
	if vector_length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end

--a quick and simple pitch calculation between two vector positions
mobs.calculate_pitch = function(pos1, pos2)

	if pos1 == nil or pos2 == nil then
		return false
	end

    return(minetest_dir_to_yaw(vector_new(vector_distance(vector_new(pos1.x,0,pos1.z),vector_new(pos2.x,0,pos2.z)),0,pos1.y - pos2.y)) + HALF_PI)
end

--make mobs fly up or down based on their y difference
mobs.set_pitch_while_attacking = function(self)
	local pos1 = self.object:get_pos()
	local pos2 = self.attacking:get_pos()

	local pitch = mobs.calculate_pitch(pos2,pos1)

	self.pitch = pitch
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

--special mob jump movement
mobs.jump_move = function(self, velocity)

    if self.object:get_velocity().y ~= 0 or not self.old_velocity or (self.old_velocity and self.old_velocity.y > 0) then
        return
    end

	--make the mob stick for a split second
	mobs.set_velocity(self,0)

	--fallback velocity to allow modularity
    jump_height = DEFAULT_JUMP_HEIGHT

	local yaw = (self.yaw or 0)

	local current_velocity = self.object:get_velocity()

	local goal_velocity = {
		x = (math_sin(yaw) * -velocity),
		y = jump_height,
		z = (math_cos(yaw) * velocity),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector_length(new_velocity_addition) > vector_length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector_length(goal_velocity) / vector_length(new_velocity_addition)))
	end

	--smooths out mobs a bit
	if vector_length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end