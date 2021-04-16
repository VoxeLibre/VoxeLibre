local math_random = math.random

local vector_multiply = vector.multiply
local vector_add      = vector.add

local minetest_yaw_to_dir                   = minetest.yaw_to_dir
local minetest_get_item_group               = minetest.get_item_group
local minetest_get_node                     = minetest.get_node
local minetest_line_of_sight                = minetest.line_of_sight


local state_list_wandering = {"stand", "walk"}

local DOUBLE_PI = math.pi * 2
local THIRTY_SECONDTH_PI = DOUBLE_PI * 0.03125


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

--a simple helper function which is too small to move into movement.lua
local quick_rotate_45 = function(self,dtime)
	self.yaw = self.yaw + THIRTY_SECONDTH_PI
	if self.yaw > DOUBLE_PI then
		self.yaw = self.yaw - DOUBLE_PI
	end
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


    if green_flag_1 and green_flag_2 then -- can jump over node
        return(1)
	elseif green_flag_1 and not green_flag_2 then --wall in front of
		return(2)
    end

	--nothing to jump over
	return(0)
end



-- state switching logic (stand, walk, run, attacks)
local state_switch = function(self, dtime)
	self.state_timer = self.state_timer - dtime
	if self.wandering and self.state_timer <= 0 then
		self.state_timer = math.random(4,10) + math.random()
		self.state = state_list_wandering[math.random(1,#state_list_wandering)]
	end
end

-- states are executed here (goto would have been helpful :<)
local state_execution = function(self,dtime)

	--local yaw = self.object:get_yaw() or 0

	if self.state == "stand" then

		--do animation
		mobs.set_mob_animation(self, "stand")

		--set the velocity of the mob
		mobs.set_velocity(self,0)

		--print("stand")

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

		--set the velocity of the mob
		mobs.set_velocity(self,1)

		--check for nodes to jump over
		local node_in_front_of = jump_check(self)

		if node_in_front_of == 1 then
			mobs.jump(self)
		end

		--turn if on the edge of cliff
		--(this is written like this because unlike
		--jump_check which simply tells the mob to jump
		--this requires a mob to turn, removing the
		--ease of a full implementation for it in a single
		--function)
		if node_in_front_of == 2 or cliff_check(self,dtime) then
			--turn 45 degrees if so
			quick_rotate_45(self,dtime)
		end

		--print("walk")

	elseif self.state == "run" then

		print("run")

	elseif self.state == "attack" then

		print("attack")

	end	
	
end






mobs.mob_step = function(self, dtime)

	--do not continue if non-existent
	if not self or not self.object or not self.object:get_luaentity() then
		return false
	end

	--print(self.object:get_yaw())

	--if self.state == "die" then
	--	print("need custom die stop moving thing")
	--	return
	--end


	state_switch(self, dtime)

	state_execution(self,dtime)


	-- can mob be pushed, if so calculate direction -- do this last (overrides everything)
	if self.pushable then
		mobs.collision(self)
	end


	--if not self.fire_resistant then
	--	mcl_burning.tick(self.object, dtime)
	--end

	--if use_cmi then
		--cmi.notify_step(self.object, dtime)
	--end

	--local pos = self.object:get_pos()
	--local yaw = 0

	--if mobs_debug then
		--update_tag(self)
	--end



	--if self.jump_sound_cooloff > 0 then
	--	self.jump_sound_cooloff = self.jump_sound_cooloff - dtime
	--end

	--if self.opinion_sound_cooloff > 0 then
	--	self.opinion_sound_cooloff = self.opinion_sound_cooloff - dtime
	--end

	--if falling(self, pos) then
		-- Return if mob died after falling
	--	return
	--end


	-- run custom function (defined in mob lua file)
	--if self.do_custom then

		-- when false skip going any further
		--if self.do_custom(self, dtime) == false then
		--	return
		--end
	--end

	-- knockback timer
	--if self.pause_timer > 0 then

	--	self.pause_timer = self.pause_timer - dtime

	--	return
	--end

	-- attack timer
	--self.timer = self.timer + dtime

	--[[
	if self.state ~= "attack" then

		if self.timer < 1 then
			print("returning>>error code 1")
			return
		end

		self.timer = 0
	end
	]]--

	-- never go over 100
	--if self.timer > 100 then
	--	self.timer = 1
	--end

	-- mob plays random sound at times
	--if math_random(1, 70) == 1 then
	--	mob_sound(self, "random", true)
	--end

	-- environmental damage timer (every 1 second)
	--self.env_damage_timer = self.env_damage_timer + dtime

	--if (self.state == "attack" and self.env_damage_timer > 1)
	--or self.state ~= "attack" then
	--
	--	self.env_damage_timer = 0
	--
	--	-- check for environmental damage (water, fire, lava etc.)
	--	if do_env_damage(self) then
	--		return
	--	end
	--
		-- node replace check (cow eats grass etc.)
	--	replace(self, pos)
	--end

	--monster_attack(self)

	--npc_attack(self)

	--breed(self)

	--do_jump(self)

	--runaway_from(self)


	--if is_at_water_danger(self) and self.state ~= "attack" then
	--	if math_random(1, 10) <= 6 then
	--		set_velocity(self, 0)
	--		self.state = "stand"
	--		set_animation(self, "stand")
	--		yaw = yaw + math_random(-0.5, 0.5)
	--		yaw = set_yaw(self, yaw, 8)
	--	end
	--end

	
	-- Add water flowing for mobs from mcl_item_entity
	--[[
	local p, node, nn, def
	p = self.object:get_pos()
	node = minetest_get_node_or_nil(p)
	if node then
		nn = node.name
		def = minetest_registered_nodes[nnenable_physicss if not on/in flowing liquid
		self._flowing = false
		enable_physics(self.object, self, true)
		return
	end

	--Mob following code.
	follow_flop(self)


	if is_at_cliff_or_danger(self) then
			set_velocity(self, 0)
			self.state = "stand"
			set_animation(self, "stand")
			local yaw = self.object:get_yaw() or 0
			yaw = set_yaw(self, yaw + 0.78, 8)
	end

	-- Despawning: when lifetimer expires, remove mob
	if remove_far
	and self.can_despawn == true
	and ((not self.nametag) or (self.nametag == ""))
	and self.state ~= "attack"
	and self.following == nil then

		self.lifetimer = self.lifetimer - dtime
		if self.despawn_immediately or self.lifetimer <= 0 then
			minetest.log("action", "Mob "..self.name.." despawns in mob_step at "..minetest.pos_to_string(pos, 1))
			mcl_burning.extinguish(self.object)
			self.object:remove()
		elseif self.lifetimer <= 10 then
			if math_random(10) < 4 then
				self.despawn_immediately = true
			else
				self.lifetimer = 20
			end
		end
	end
	]]--

    self.old_velocity = self.object:get_velocity()
end
