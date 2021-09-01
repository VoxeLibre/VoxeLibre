--[[

--check if a mob needs to jump
mobs.jump_check = function(self,dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest.yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector.multiply(dir, radius)

	--only jump if there's a node and a non-solid node above it
    local test_dir = vector.add(pos,dir)

	local green_flag_1 = minetest.get_item_group(minetest.get_node(test_dir).name, "solid") ~= 0

	test_dir.y = test_dir.y + 1

	local green_flag_2 = minetest.get_item_group(minetest.get_node(test_dir).name, "solid") == 0

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

--check if a mob needs to turn while jumping
local function jump_turn_check(self, dtime)

    local pos = self.object:get_pos()
    pos.y = pos.y + 0.1
    local dir = minetest.yaw_to_dir(self.yaw)

    local collisionbox = self.object:get_properties().collisionbox
	local radius = collisionbox[4] + 0.5

    vector.multiply(dir, radius)

    local test_dir = vector.add(pos,dir)

	return minetest.get_item_group(minetest.get_node(test_dir).name, "solid") ~= 0
end

-- state switching logic (stand, jump, run, attacks)
local jump_state_list_wandering = {"stand", "jump"}

local function jump_state_switch(self, dtime)
	self.state_timer = self.state_timer - dtime
	if self.state_timer <= 0 then
		self.state_timer = math.random(4, 10) + math.random()
		self.state = jump_state_list_wandering[math.random(1, #jump_state_list_wandering)]
	end
end

-- states are executed here
local function jump_state_execution(self, dtime)

	local pos = self.object:get_pos()
	local collisionbox = self.object:get_properties().collisionbox
	--get the center of the mob
	pos.y = pos.y + (collisionbox[2] + collisionbox[5] / 2)
	local current_node = minetest.get_node(pos).name

	local float_now = false

	--recheck if in water or lava
	if minetest.get_item_group(current_node, "water") ~= 0 or minetest.get_item_group(current_node, "lava") ~= 0 then
		float_now = true
	end

	if self.state == "stand" then

		--do animation
		self:set_animation("stand")

		--set the velocity of the mob
		self:set_velocity(0)

		self:lock_yaw()

	elseif self.state == "jump" then

		self.walk_timer = self.walk_timer - dtime

		--reset the jump timer
		if self.walk_timer <= 0 then

			--re-randomize the jump timer
			self.walk_timer = math.random(1, 6) + math.random()

			--set the mob into a random direction
			self.yaw = (math.random() * (math.pi * 2))
		end

		--do animation
		self:set_animation("walk")

		--enable rotation locking
		self:movement_rotation_lock()

		--jumping mobs are more loosey goosey
		if node_in_front_of == 1 then
			quick_rotate(self, dtime)
		end

		--only move forward if path is clear
		self:jump_move(self.walk_velocity)

	elseif self.state == "run" then

		print("run")

	elseif self.state == "attack" then

		print("attack")

	end

	if float_now then
		self:float()
	end
end

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
		x = (math.sin(yaw) * -velocity),
		y = jump_height,
		z = (math.cos(yaw) * velocity),
	}


	local new_velocity_addition = vector.subtract(goal_velocity,current_velocity)

	if vector.length(new_velocity_addition) > vector.length(goal_velocity) then
		vector.multiply(new_velocity_addition, (vector.length(goal_velocity) / vector.length(new_velocity_addition)))
	end

	--smooths out mobs a bit
	if vector.length(new_velocity_addition) >= 0.0001 then
		self.object:add_velocity(new_velocity_addition)
	end
end

]]--
