local math_random = math.random

-- execute current state (stand, walk, run, attacks)
-- returns true if mob has died
local do_states = function(self, dtime)
	local yaw = self.object:get_yaw() or 0

	self.state_timer = self.state_timer - dtime

	if self.state_timer <= 0 then
		self.state_timer = math.random(0,2) + math.random()
		--let's do a random state
		self.yaw = (math_random() * (math.pi * 2))
	end

	mobs.set_velocity(self,1)
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


	do_states(self, dtime)


	mobs.movement_rotation_lock(self)

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
end
