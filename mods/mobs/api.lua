mobs = {}
function mobs:register_mob(name, def)
	minetest.register_entity(name, {
		hp_max = def.hp_max,
		physical = true,
		collisionbox = def.collisionbox,
		collide_with_objects = def.collide_with_objects,
		visual = def.visual,
		visual_size = def.visual_size,
		mesh = def.mesh,
		textures = def.textures,
		makes_footstep_sound = def.makes_footstep_sound,
		view_range = def.view_range,
		walk_velocity = def.walk_velocity,
		run_velocity = def.run_velocity,
		damage = def.damage,
		light_damage = def.light_damage,
		water_damage = def.water_damage,
		lava_damage = def.lava_damage,
		disable_fall_damage = def.disable_fall_damage,
		drops = def.drops,
		armor = def.armor,
		drawtype = def.drawtype,
		on_rightclick = def.on_rightclick,
		type = def.type,
		hostile_type = def.hostile_type or 1,
		attack_type = def.attack_type,
		arrow = def.arrow,
		shoot_interval = def.shoot_interval,
		sounds = def.sounds or nil,
		animation = def.animation,
		randomsound = def.randomsound,
		hit= def.hit,
		follow = def.follow,
		jump = def.jump or true,
		exp_min = def.exp_min or 0,
		exp_max = def.exp_max or 0,
		walk_chance = def.walk_chance or 10,
		attacks_monsters = def.attacks_monsters or false,
		group_attack = def.group_attack or false,
		step = def.step or 0,
		fov = def.fov or 120,
		passive = def.passive or false,
		recovery_time = def.recovery_time or 0.5,
		knock_back = def.knock_back or 2,
		pause_timer = def.pause_timer or 30,
		rewards = def.rewards or nil,
		animaltype = def.animaltype,

		stimer = 0,
		canfight = 0,
		timer = 0,
		affolated_timer = 0;
		blinktimer = 0,
		blinkstatus = true,
		env_damage_timer = 0, -- only if state = "attack"
		attack = {player = nil, dist = nil},
		state = "stand",
		v_start = false,
		have_been_hit = 0,
		old_y = nil,
		lifetimer = 600,
		tamed = false,
		
		do_attack = function(self, player, dist)
			if self.state ~= "attack" then
				if self.sounds ~= nil and self.sounds.war_cry then
					if math.random(0,100) < 90 then
						minetest.sound_play(self.sounds.war_cry,{ object = self.object })
					end
				end
				self.state = "attack"
				self.attack.player = player
				self.attack.dist = dist
			end
		end,
		set_affolated = function(self)
			local yaw = self.object:getyaw()
			self.affolated_timer = math.random(1,4)
			self.set_velocity(self, self.run_velocity + math.random(-10,10))
		end,
		
		set_velocity = function(self, v)
			local yaw = self.object:getyaw()
			if self.drawtype == "side" then
				yaw = yaw+(math.pi/2)
			end
			local x = math.sin(yaw) * -v
			local z = math.cos(yaw) * v
			self.object:setvelocity({x =x, y = self.object:getvelocity().y, z =z})
		end,
		
		give_hit = function(self)
			self.hit = self.hit
			if self.hit == 1 then
				self.object:settexturemod("")
				self.hit = 0
			else
				self.object:settexturemod("^[brighten")
				self.hit = 1
			end
		end,
		
		get_velocity = function(self)
			local v = self.object:getvelocity()
			return (v.x^2 + v.z^2)^(0.5)
		end,
		
		in_fov = function(self,pos)
			local yaw = self.object:getyaw()
			if self.drawtype == "side" then
				yaw = yaw+(math.pi/2)
			end
			local vx = math.sin(yaw)
			local vz = math.cos(yaw)
			local ds = math.sqrt(vx^2 + vz^2)
			local ps = math.sqrt(pos.x^2 + pos.z^2)
			local d = { x = vx / ds, z = vz / ds }
			local p = { x = pos.x / ps, z = pos.z / ps }
			
			local an = ( d.x * p.x ) + ( d.z * p.z )
			
			a = math.deg( math.acos( an ) )
			
			if a > ( self.fov / 2 ) then
				return false
			else
				return true
			end
		end,
		
		set_animation = function(self, type)
			if not self.animation then
				return
			end
			if not self.animation.current then
				self.animation.current = ""
			end
			if type == "die" and self.animation.current ~= "die" then
				if self.animation.stand_start
					and self.animation.stand_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x = self.animation.stand_start,y = self.animation.stand_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "die"
				end
			elseif type == "stand" and self.animation.current ~= "stand" then
				if
					self.animation.stand_start
					and self.animation.stand_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x = self.animation.stand_start,y = self.animation.stand_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "stand"
				end
			elseif type == "walk" and self.animation.current ~= "walk"  then
				if
					self.animation.walk_start
					and self.animation.walk_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x = self.animation.walk_start,y = self.animation.walk_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "walk"
				end
			elseif type == "run" and self.animation.current ~= "run"  then
				if
					self.animation.run_start
					and self.animation.run_end
					and self.animation.speed_run
				then
					if self.animation.run_start ~= nil then
						self.object:set_animation(
							{x = self.animation.run_start,y = self.animation.run_end},
							self.animation.speed_run, 0
						)
					else
						self.object:set_animation(
						{x = self.animation.walk_start,y = self.animation.walk_end},
						self.animation.speed_run, 0
						)
					end
					self.animation.current = "run"
				end
			elseif type == "punch" and self.animation.current ~= "punch"  then
				if
					self.animation.punch_start
					and self.animation.punch_end
					and self.animation.speed_normal
				then
					self.object:set_animation(
						{x = self.animation.punch_start,y = self.animation.punch_end},
						self.animation.speed_normal, 0
					)
					self.animation.current = "punch"
				end
			end
		end,
		
		on_step = function(self, dtime)
			
			if self.lifetimer < 600 and self.lifetimer > 590 and self.state == "stand" then
				self.set_velocity(self, self.walk_velocity)
				self.state = "walk"
				self.set_animation(self, "walk")
				self.pause_timer = 25;
			elseif type == "animal" then
				if math.random(1, 5) == 1 and self.pause_timer == 0  then
					self.set_velocity(self, self.walk_velocity)
					self.state = "walk"
					self.set_animation(self, "walk")
				else
					self.set_velocity(self, 0)
					self:set_animation("stand")
					self.pause_timer = 25;
				end
				
			end
			
			if self.pause_timer > 0 then
				self.pause_timer = self.pause_timer - dtime
			end
			
			if self.type == "monster" and minetest.setting_getbool("only_peaceful") then
				self.object:remove()
			end
			
			self.affolated_timer = self.affolated_timer - dtime
			if self.affolated_timer <= 0 and self.type == "animal" then
				for _,player in pairs(minetest.get_connected_players()) do
					local s = self.object:getpos()
					local p = player:getpos()
					local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.8
					if self.view_range and dist < self.view_range then
						self.set_velocity(self, self.walk_velocity)
						self.state = "walk"
						self.set_animation(self, "walk")
						self.following = player
						break
					end
				end
			end
			
			if self.hostile_type == 1 then
				self.canfight = 1
			elseif self.hostile_type == 2 then
				local pos = self.object:getpos()
				local n = minetest.get_node(pos)
				if minetest.get_timeofday() > 0.2 and minetest.get_timeofday() < 0.8 and self.have_been_hit == 0 then
					self.canfight = 0
				else
					self.canfight = 1
				end
			elseif self.hostile_type == 3 then
				if self.have_been_hit == 0 then
					self.canfight = 0
				else
					self.canfight = 1
				end
			end
				-- FIND SOMEONE TO ATTACK
			if self.type == "monster" and self.state ~= "attack" and self.canfight == 1 then
			
					local s = self.object:getpos()
					local inradius = minetest.get_objects_inside_radius(s,self.view_range)
					local player = nil
					local type = nil
					for _,oir in ipairs(inradius) do
						if oir:is_player() then
							player = oir
							type = "player"
						else
							local obj = oir:get_luaentity()
							if obj then
								player = obj.object
								type = obj.type
							end
						end
						
						if type == "player" or type == "npc" then
							local s = self.object:getpos()
							local p = player:getpos()
							local sp = s
							p.y = p.y - 1
							local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
							if dist < self.view_range and self.in_fov(self,p) then
									self.do_attack(self,player,dist)
							end
						end
					end
					

			end
			
			-- NPC FIND A MONSTER TO ATTACK
			if self.type == "npc" and self.attacks_monsters and self.state ~= "attack" then
				local s = self.object:getpos()
				local inradius = minetest.get_objects_inside_radius(s,self.view_range)
				for _, oir in pairs(inradius) do
					local obj = oir:get_luaentity()
					if obj then
						if obj.type == "monster" then
							-- attack monster
							local p = obj.object:getpos()
							local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
							self.do_attack(self,obj.object,dist)
							break
						end
					end
				end
			end
			
			self.lifetimer = self.lifetimer - dtime
			if self.lifetimer <= 0 and not self.tamed and self.type ~= "npc" then
				local player_count = 0
				for _,obj in ipairs(minetest.get_objects_inside_radius(self.object:getpos(), 12)) do
					if obj:is_player() then
						player_count = player_count + 1
					end
				end
				if player_count == 0 and self.state ~= "attack" then
					local pos = self.object:getpos()
					local hp = self.object:get_hp()
					minetest.log("action", "A mob with " .. tostring(hp) .. " HP despawned at " .. minetest.pos_to_string(pos) .. ".")
					self.object:remove()
					return
				end
			end
			
			if self.object:getvelocity().y > 0.1 then
				local yaw = self.object:getyaw()
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				local x = math.sin(yaw) * -2
				local z = math.cos(yaw) * 2
				if minetest.get_item_group(minetest.get_node(self.object:getpos()).name, "water") ~= 0 then
					self.object:setacceleration({x = x, y = 1.5, z = z})
				else
					self.object:setacceleration({x = x, y = -10, z = z})
				end
			else
				if minetest.get_item_group(minetest.get_node(self.object:getpos()).name, "water") ~= 0 then
					self.object:setacceleration({x = 0, y = 1.5, z = 0})
				else
					self.object:setacceleration({x = 0, y = -10, z = 0})
				end
			end
			
			
			if self.disable_fall_damage and self.object:getvelocity().y == 0 then
				if not self.old_y then
					self.old_y = self.object:getpos().y
				else
					local d = self.old_y - self.object:getpos().y
					if d > 5 then
						local damage = d-5
						self.object:set_hp(self.object:get_hp()-damage)
						minetest.sound_play("monster_damage", {object = self.object, gain = 0.25})
						if self.object:get_hp() == 0 then
							minetest.sound_play("monster_death", {object = self.object, gain = 0.4})
							self.object:remove()
						end
					end
					self.old_y = self.object:getpos().y
				end
			end
			
			self.timer = self.timer + dtime
			if self.state ~= "attack" then
				if self.timer < 1.0 then return end
				self.timer = 0
			end
			
			if self.randomsound and math.random(1, 200) <= 1 then
				minetest.sound_play(self.randomsound, {object = self.object})
			end
			
			local do_env_damage = function(self)
				local pos = self.object:getpos()
				local n = minetest.get_node(pos)
				self.give_hit(self)
				if self.light_damage and self.light_damage ~= 0
					and pos.y > 0
					and minetest.get_node_light(pos)
					and minetest.get_node_light(pos) > 10
					and minetest.get_timeofday() > 0.2
					and minetest.get_timeofday() < 0.8
				then
					self.object:set_hp(self.object:get_hp()-self.light_damage)
					minetest.sound_play("zombie_sun_damage", {object = self.object, gain = 0.25})
					if self.object:get_hp() <= 0 then
						minetest.sound_play("monster_death", {object = self.object, gain = 0.4})
						self.object:remove()
					end
				end
				
				if self.water_damage and self.water_damage ~= 0 and
					minetest.get_item_group(n.name, "water") ~= 0
				then
					self.object:set_hp(self.object:get_hp()-self.water_damage)
					minetest.sound_play("monster_damage", {object = self.object, gain = 0.25})
					if self.object:get_hp() <= 0 then
						minetest.sound_play("monster_death", {object = self.object, gain = 0.4})
						self.object:remove()
					end
				end
				
				if self.lava_damage and self.lava_damage ~= 0 and
					minetest.get_item_group(n.name, "lava") ~= 0
				then
					self.object:set_hp(self.object:get_hp()-self.lava_damage)
					minetest.sound_play("monster_damage", {object = self.object, gain = 0.25})
					if self.object:get_hp() <= 0 then
						minetest.sound_play("monster_death", {object = self.object, gain = 0.4})
						self.object:remove()
					end
				end
				self.give_hit(self)
			end
			
			self.env_damage_timer = self.env_damage_timer + dtime
			if self.state == "attack" and self.env_damage_timer > 1 then
				self.env_damage_timer = 0
				do_env_damage(self)
			elseif self.state ~= "attack" then
				do_env_damage(self)
			end

			if self.follow ~= "" and not self.following then
				for _,player in pairs(minetest.get_connected_players()) do
					local s = self.object:getpos()
					local p = player:getpos()
					local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
					if self.view_range and dist < self.view_range then
						self.following = player
						break
					end
				end
			end
			
			if self.following and self.following:is_player() then
				if self.following:get_wielded_item():get_name() ~= self.follow then
					self.following = nil
				else
					local s = self.object:getpos()
					local p = self.following:getpos()
					local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
					if dist > self.view_range then
						self.following = nil
						self.v_start = false
					else
						local vec = {x=p.x-s.x, y=p.y-s.y, z=p.z-s.z}
						local yaw = math.atan(vec.z/vec.x)+math.pi/2
						if self.drawtype == "side" then
							yaw = yaw+(math.pi/2)
						end
						if p.x > s.x then
							yaw = yaw+math.pi
						end
						self.object:setyaw(yaw)
						if dist > 2 then
							if not self.v_start then
								self.v_start = true
								self.set_velocity(self, self.walk_velocity)
							else
								if self.jump and self.get_velocity(self) <= 1.5 and self.object:getvelocity().y == 0 then
									local v = self.object:getvelocity()
									v.y = 6
									self.object:setvelocity(v)
								end
								self.set_velocity(self, self.walk_velocity)
							end
							self:set_animation("walk")
						else
							self.v_start = false
							self.set_velocity(self, 0)
							self:set_animation("stand")
						end
						return
					end
				end
			end
			
			if self.state == "stand" then
				if math.random(1, 4) == 1 then
					-- if there is a player nearby look at them
					local lp = nil
					local s = self.object:getpos()
					if self.type == "npc" then
						local o = minetest.get_objects_inside_radius(self.object:getpos(), 3)
						
						local yaw = 0
						for _,o in ipairs(o) do
							if o:is_player() then
								lp = o:getpos()
								break
							end
						end
					end
					if lp ~= nil then
						local vec = {x=lp.x-s.x, y=lp.y-s.y, z=lp.z-s.z}
						yaw = math.atan(vec.z/vec.x)+math.pi/2
						if self.drawtype == "side" then
							yaw = yaw+(math.pi/2)
						end
						if lp.x > s.x then
							yaw = yaw+math.pi
						end
					else 
						yaw = self.object:getyaw()+((math.random(0,360)-180)/180*math.pi)
					end
					self.object:setyaw(yaw)
				end
				self.set_velocity(self, 0)
				self.set_animation(self, "stand")
				if math.random(1, 100) <= self.walk_chance then
					self.set_velocity(self, self.walk_velocity)
					self.state = "walk"
					self.set_animation(self, "walk")
				end
			elseif self.state == "walk" then
				if math.random(1, 100) <= 30 then
					self.object:setyaw(self.object:getyaw()+((math.random(0,360)-180)/180*math.pi))
				end
				if self.jump and self.get_velocity(self) <= 0.5 and self.object:getvelocity().y == 0 then
					local v = self.object:getvelocity()
					v.y = 5
					self.object:setvelocity(v)
				end
				self:set_animation("walk")
				self.set_velocity(self, self.walk_velocity)
				if math.random(1, 100) <= 30 then
					self.set_velocity(self, 0)
					self.state = "stand"
					self:set_animation("stand")
				end
			elseif self.state == "attack" and self.attack_type == "kamicaze" then
				if not self.attack.player or not self.attack.player:is_player() then
					self.state = "stand"
					self:set_animation("stand")
					self.timer = 0
					self.blinktimer = 0
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				local dist = ((p.x - s.x) ^ 2 + (p.y - s.y) ^ 2 + (p.z - s.z) ^ 2) ^ 0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.v_start = false
					self.set_velocity(self, 0)
					self.timer = 0
					self.blinktimer = 0
					self.attack = {player = nil, dist = nil}
					self:set_animation("stand")
					return
				else
					self:set_animation("walk")
					self.attack.dist = dist
				end
				
				local vec = {x = p.x -s.x, y = p.y -s.y, z = p.z -s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				if self.attack.dist > 3 then
					if not self.v_start then
						self.v_start = true
						self.set_velocity(self, self.run_velocity)
						self.timer = 0
						 self.blinktimer = 0
					else
					     self.timer = 0
						 self.blinktimer = 0
						if self.get_velocity(self) <= 1.58 and self.object:getvelocity().y == 0 then
							local v = self.object:getvelocity()
							v.y = 5
							self.object:setvelocity(v)
						end
						self.set_velocity(self, self.run_velocity)
					end
					self:set_animation("run")
				else
					self.set_velocity(self, 0)
					self.timer = self.timer + dtime
					self.blinktimer = self.blinktimer + dtime
						if self.blinktimer > 0.2 then
							self.blinktimer = self.blinktimer - 0.2
							if self.blinkstatus then
								self.object:settexturemod("")
							else
								self.object:settexturemod("^[brighten")
							end
							self.blinkstatus = not self.blinkstatus
						end
						if self.timer > 3 then
							local pos = self.object:getpos()
							pos.x = math.floor(pos.x+0.5)
							pos.y = math.floor(pos.y+0.5)
							pos.z = math.floor(pos.z+0.5)
							do_tnt_physics(pos, 3)
							local meta = minetest.env:get_meta(pos)
							minetest.sound_play("tnt_explode", {pos = pos,gain = 1.0,max_hear_distance = 16,})
							if minetest.env:get_node(pos).name == "default:water_source" or minetest.env:get_node(pos).name == "default:water_flowing" or minetest.is_protected(pos, "tnt") then
								self.object:remove()
								return
							end
							for x=-3,3 do
								for y=-3,3 do
									for z=-3,3 do
										if x*x+y*y+z*z <= 3 * 3 + 3 then
											local np={x=pos.x+x,y=pos.y+y,z=pos.z+z}
											local n = minetest.env:get_node(np)
											if n.name ~= "air" and n.name ~= "default:obsidian" and n.name ~= "default:bedrock" and n.name ~= "protector:protect" then
												activate_if_tnt(n.name, np, pos, 3)
												minetest.env:remove_node(np)
												nodeupdate(np)
												if n.name ~= "tnt:tnt" and math.random() > 0.9 then
													local drop = minetest.get_node_drops(n.name, "")
													for _,item in ipairs(drop) do
														if type(item) == "string" then
															if math.random(1,100) > 40 then
															local obj = minetest.env:add_item(np, item)
															end
														end
													end
												end
											end
										end
									end
								end
								self.object:remove()
							end
						end
				end
			elseif self.state == "attack" and self.attack_type == "dogfight" then
				if not self.attack.player or not self.attack.player:getpos() then
					self.state = "stand"
					self:set_animation("stand")
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				local dist = ((p.x - s.x) ^ 2 + (p.y - s.y) ^ 2 + (p.z - s.z) ^ 2) ^ 0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.v_start = false
					self.set_velocity(self, 0)
					self.attack = {player = nil, dist = nil}
					self:set_animation("stand")
					return
				else
					self:set_animation("walk")
					self.attack.dist = dist
				end
				
				local vec = {x = p.x -s.x, y = p.y -s.y, z = p.z -s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				if self.attack.dist > 2 then
					if not self.v_start then
						self.v_start = true
						self.set_velocity(self, self.run_velocity)
					else
						if self.get_velocity(self) <= 1.58 and self.object:getvelocity().y == 0 then
							local v = self.object:getvelocity()
							v.y = 5
							self.object:setvelocity(v)
						end
						self.set_velocity(self, self.run_velocity)
					end
					self:set_animation("run")
				else
					self.set_velocity(self, 0)
					self:set_animation("punch")
					self.v_start = false
					if self.timer > 1 then
						self.timer = 0
						minetest.sound_play("mobs_punch", {object = self.object, gain = 1})
						self.attack.player:punch(self.object, 1.0,  {
							full_punch_interval= 1.0,
							damage_groups = {fleshy = self.damage}
						}, vec)
					end
				end
			elseif self.state == "attack" and self.attack_type == "shoot" then
				if not self.attack.player or not self.attack.player:is_player() then
					self.state = "stand"
					self:set_animation("stand")
					return
				end
				local s = self.object:getpos()
				local p = self.attack.player:getpos()
				p.y = p.y - .5
				s.y = s.y + .5
				local dist = ((p.x-s.x)^2 + (p.y-s.y)^2 + (p.z-s.z)^2)^0.5
				if dist > self.view_range or self.attack.player:get_hp() <= 0 then
					self.state = "stand"
					self.v_start = false
					self.set_velocity(self, 0)
					if self.type ~= "npc" then
						self.attack = {player=nil, dist=nil}
					end
					self:set_animation("stand")
					return
				else
					self.attack.dist = dist
				end
				
				local vec = {x = p.x -s.x, y = p.y -s.y, z = p.z -s.z}
				local yaw = math.atan(vec.z/vec.x)+math.pi/2
				if self.drawtype == "side" then
					yaw = yaw+(math.pi/2)
				end
				if p.x > s.x then
					yaw = yaw+math.pi
				end
				self.object:setyaw(yaw)
				self.set_velocity(self, 0)
				
				if self.timer > self.shoot_interval and math.random(1, 100) <= 60 then
					self.timer = 0
					
					self:set_animation("punch")
					
					if self.sounds ~= nil and self.sounds.attack then
						minetest.sound_play(self.sounds.attack, {object = self.object})
					end
					
					local p = self.object:getpos()
					p.y = p.y + (self.collisionbox[2]+self.collisionbox[5])/2
					local obj = minetest.add_entity(p, self.arrow)
					local amount = (vec.x^ 2+vec.y^ 2+vec.z^ 2) ^ 0.5
					local v = obj:get_luaentity().velocity
					vec.y = vec.y+1
					vec.x = vec.x*v/amount
					vec.y = vec.y*v/amount
					vec.z = vec.z*v/amount
					obj:setvelocity(vec)
				end
			end
		end,
		
		on_activate = function(self, staticdata, dtime_s)
			self.object:set_armor_groups({fleshy = self.armor})
			self.object:setacceleration({x = 0, y = -10, z = 0})
			self.state = "stand"
			self.object:setvelocity({x = 0, y = self.object:getvelocity().y, z = 0})
			self.object:setyaw(math.random(1, 360) / 180 *  math.pi)
			
			if self.type ~= "npc" then
				self.lifetimer = 600 - dtime_s
			else
				self.lifetimer = 300 - dtime_s
			end
			
			if self.type == "monster" and minetest.setting_getbool("only_peaceful") then
				self.object:remove()
			end
			
			if staticdata then
				local tmp = minetest.deserialize(staticdata)
				if tmp and tmp.lifetimer then
					self.lifetimer = tmp.lifetimer - dtime_s
				end
				if tmp and tmp.tamed then
					self.tamed = tmp.tamed
				end
			end
			if self.lifetimer <= 0 and not self.tamed then
				local pos = self.object:getpos()
				local hp = self.object:get_hp()
				minetest.log("action", "A mob with " .. tostring(hp) .. " HP despawned at " .. minetest.pos_to_string(pos) .. " on activation.")
				self.object:remove()
			end
		end,
		
		get_staticdata = function(self)
			local tmp = {
				lifetimer = self.lifetimer,
				tamed = self.tamed,
				textures = { textures = self.textures },
			}
			return minetest.serialize(tmp)
		end,

		on_punch = function(self, hitter, tflp, tool_capabilities, dir)
		local hp = self.object:get_hp()
		self.have_been_hit = 1
		if hp >= 1 then
			process_weapon(hitter,tflp,tool_capabilities)
		end
		
			local pos = self.object:getpos()
			if self.object:get_hp() <= 0 then
				if hitter and hitter:is_player() and hitter:get_inventory() then
					for _,drop in ipairs(self.drops) do
						if math.random(1, drop.chance) == 1 then
							local d = ItemStack(drop.name.." "..math.random(drop.min, drop.max))
--							default.drop_item(pos,d)
							local pos2 = pos
							pos2.y = pos2.y + 0.5 -- drop items half block higher
							minetest.add_item(pos2,d)
						end
					end
					
					if self.sounds ~= nil and self.sounds.death ~= nil then
						minetest.sound_play(self.sounds.death,{
							object = self.object,
						})
					end
					if minetest.get_modpath("skills") and minetest.get_modpath("experience") then
						-- DROP experience
						local distance_rating = ( ( get_distance({x=0,y=0,z=0},pos) ) / ( skills.get_player_level(hitter:get_player_name()).level * 1000 ) )
						local emax = math.floor( self.exp_min + ( distance_rating * self.exp_max ) )
						local expGained = math.random(self.exp_min, emax)
						skills.add_exp(hitter:get_player_name(),expGained)
						local expStack = experience.exp_to_items(expGained)
						for _,stack in ipairs(expStack) do
							default.drop_item(pos,stack)
						end
					end

					-- see if there are any NPCs to shower you with rewards
					if self.type ~= "npc" then
						local inradius = minetest.get_objects_inside_radius(hitter:getpos(),10)
						for _, oir in pairs(inradius) do
							local obj = oir:get_luaentity()
							if obj then	
								if obj.type == "npc" and obj.rewards ~= nil then
									local yaw = nil
									local lp = hitter:getpos()
									local s = obj.object:getpos()
									local vec = {x=lp.x-s.x, y=1, z=lp.z-s.z}
									yaw = math.atan(vec.z/vec.x)+math.pi/2
									if self.drawtype == "side" then
										yaw = yaw+(math.pi/2)
									end
									if lp.x > s.x then
										yaw = yaw+math.pi
									end
									obj.object:setyaw(yaw)
									local x = math.sin(yaw) * -2
									local z = math.cos(yaw) * 2
									acc = {x=x, y=-5, z=z}
									for _, r in pairs(obj.rewards) do
										if math.random(0,100) < r.chance then
											default.drop_item(obj.object:getpos(),r.item, vec, acc)
										end
									end
								end
							end
						end
					end
					
				end
			end

			-- knock back effect, adapted from blockmen's pyramids mod
			-- https://github.com/BlockMen/pyramids
			local kb = self.knock_back
			local r = self.recovery_time

			if tflp < tool_capabilities.full_punch_interval then
				kb = kb * ( tflp / tool_capabilities.full_punch_interval )
				r = r * ( tflp / tool_capabilities.full_punch_interval )
			end

			local ykb=2
			local v = self.object:getvelocity()
			if v.y ~= 0 then
				ykb = 0
			end 

			self.object:setvelocity({x=dir.x*kb,y=ykb,z=dir.z*kb})
			self.pause_timer = r
			if self.type == "animal" then
				self.set_affolated(self)
				self:set_animation("run")
			end
			-- for zombie pig <3
			if self.passive == false then
				if self.state ~= "attack" then
					self.do_attack(self,hitter,1)
				end
				-- alert other NPCs to the attack
				local inradius = minetest.get_objects_inside_radius(hitter:getpos(),10)
				for _, oir in pairs(inradius) do
					local obj = oir:get_luaentity()
					if obj then
						if obj.group_attack == true and obj.name == self.name and obj.state ~= "attack" then
							obj.do_attack(obj,hitter,1)
						end
					end
				end
			end
		end,
		
	})
end

mobs.spawning_mobs = {}
function mobs:register_spawn(name, description, nodes, max_light, min_light, chance, active_object_count, max_height, spawn_func)
	mobs.spawning_mobs[name] = true
	minetest.register_abm({
		nodenames = nodes,
		neighbors = {"air"},
		interval = 15,
		chance = chance,
		action = function(pos, node, _, active_object_count_wider)
			 --local players = minetest.get_connected_players()
			 --if players == 0 then return end
			if active_object_count_wider > active_object_count then return end
			if not mobs.spawning_mobs[name] then return end
			pos.y = pos.y + 1
			if not minetest.get_node_light(pos) then return end
			if minetest.get_node(pos).name ~= "air" then return end
			if pos.y > max_height then return end
			if not minetest.get_node_light(pos) then return end
			if minetest.get_node_light(pos) > max_light then return end
			if minetest.get_node_light(pos) < min_light then return end
			if minetest.registered_nodes[minetest.get_node(pos).name].walkable then else return end
			if min_dist == nil then
				min_dist = {x=-1,z=-1}
			end
			if max_dist == nil then
				max_dist = {x=33000,z=33000}
			end
	
			if math.abs(pos.x) < min_dist.x or math.abs(pos.z) < min_dist.z then
				return
			end
			
			if math.abs(pos.x) > max_dist.x or math.abs(pos.z) > max_dist.z then
				return
			end
			if spawn_func and not spawn_func(pos, node) then return end
			if math.random(1,1000) <= chance or chance > 99 then
				if chance > 99 then
					minetest.log("action", "Spawned " .. description .. " at " .. minetest.pos_to_string(pos) .. " with 100% chance .")
				 minetest.add_entity(pos, name)
				elseif math.random(1.0,100.9) <= chance then
					minetest.log("action", "Spawned " .. description .. " at " .. minetest.pos_to_string(pos) .. "with "..chance.."% chance.")
				 minetest.add_entity(pos, name)
				end
			end
			
		end
	})
end

function do_tnt_physics(tnt_np,tntr)
    local objs = minetest.env:get_objects_inside_radius(tnt_np, tntr)
    for k, obj in pairs(objs) do
        local oname = obj:get_entity_name()
        local v = obj:getvelocity()
        local p = obj:getpos()
        if oname == "tnt:tnt" then
            obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 2) + v.x, y=(p.y - tnt_np.y) + tntr + v.y, z=(p.z - tnt_np.z) + (tntr / 2) + v.z})
        else
            if v ~= nil then
                obj:setvelocity({x=(p.x - tnt_np.x) + (tntr / 4) + v.x, y=(p.y - tnt_np.y) + (tntr / 2) + v.y, z=(p.z - tnt_np.z) + (tntr / 4) + v.z})
            else
                if obj:get_player_name() ~= nil then
                    obj:set_hp(obj:get_hp() - 1)
                end
            end
        end
    end
end


function mobs:register_arrow(name, def)
	minetest.register_entity(name, {
		physical = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = def.visual,
		visual_size = def.visual_size,
		textures = def.textures,
		velocity = def.velocity,
		hit_player = def.hit_player,
		hit_node = def.hit_node,
		
		on_step = function(self, dtime)
			local pos = self.object:getpos()
			if minetest.get_node(self.object:getpos()).name ~= "air" then
				self.hit_node(self, pos, node)
				self.object:remove()
				return
			end
			-- pos.y = pos.y-1.0
			for _,player in pairs(minetest.get_objects_inside_radius(pos, 1)) do
				if player:is_player() then
					self.hit_player(self, player)
					self.object:remove()
					return
				end
			end
		end
	})
end

function get_distance(pos1,pos2)
	if ( pos1 ~= nil and pos2 ~= nil ) then
		return math.abs(math.floor(math.sqrt( (pos1.x - pos2.x)^2 + (pos1.z - pos2.z)^2 )))
	else
		return 0
	end
end

function process_weapon(player, time_from_last_punch, tool_capabilities)
local weapon = player:get_wielded_item()
	if tool_capabilities ~= nil then
		local wear = ( tool_capabilities.full_punch_interval / 75 ) * 65535
		weapon:add_wear(wear)
		player:set_wielded_item(weapon)
	end
	
	if weapon:get_definition().sounds ~= nil then
		local s = math.random(0,#weapon:get_definition().sounds)
		minetest.sound_play(weapon:get_definition().sounds[s], {
			object=player,
		})
	else
		minetest.sound_play("default_sword_wood", {
			object = player,
		})
	end	
end

