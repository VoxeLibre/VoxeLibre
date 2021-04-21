local disable_physics = function(object, luaentity, ignore_check, reset_movement)
	if luaentity.physical_state == true or ignore_check == true then
		luaentity.physical_state = false
		object:set_properties({
			physical = false
		})
		if reset_movement ~= false then
			object:set_velocity({x=0,y=0,z=0})
			object:set_acceleration({x=0,y=0,z=0})
		end
	end
end

----For Water Flowing:
local enable_physics = function(object, luaentity, ignore_check)
	if luaentity.physical_state == false or ignore_check == true then
		luaentity.physical_state = true
		object:set_properties({
			physical = true
		})
		object:set_velocity({x=0,y=0,z=0})
		object:set_acceleration({x=0,y=-9.81,z=0})
	end
end

--[[
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 1 then return end
	for _, player in pairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		for _, obj in pairs(minetest_get_objects_inside_radius(pos, 47)) do
			local lua = obj:get_luaentity()
			if lua and lua._cmi_is_mob then
				lua.lifetimer = math.max(20, lua.lifetimer)
				lua.despawn_immediately = false
			end
		end
	end
	timer = 0
end)
]]--

-- compatibility function for old entities to new modpack entities
function mobs:alias_mob(old_name, new_name)

	-- spawn egg
	minetest.register_alias(old_name, new_name)

	-- entity
	minetest.register_entity(":" .. old_name, {

		physical = false,

		on_step = function(self)

			if minetest_registered_entities[new_name] then
				minetest_add_entity(self.object:get_pos(), new_name)
			end

			self.object:remove()
		end
	})
end


-- Spawn a child
function mobs:spawn_child(pos, mob_type)
	local child = minetest_add_entity(pos, mob_type)
	if not child then
		return
	end

	local ent = child:get_luaentity()
	effect(pos, 15, "mcl_particles_smoke.png", 1, 2, 2, 15, 5)

	ent.child = true

	local textures
	-- using specific child texture (if found)
	if ent.child_texture then
		textures = ent.child_texture[1]
	end

	-- and resize to half height
	child:set_properties({
		textures = textures,
		visual_size = {
			x = ent.base_size.x * .5,
			y = ent.base_size.y * .5,
		},
		collisionbox = {
			ent.base_colbox[1] * .5,
			ent.base_colbox[2] * .5,
			ent.base_colbox[3] * .5,
			ent.base_colbox[4] * .5,
			ent.base_colbox[5] * .5,
			ent.base_colbox[6] * .5,
		},
		selectionbox = {
			ent.base_selbox[1] * .5,
			ent.base_selbox[2] * .5,
			ent.base_selbox[3] * .5,
			ent.base_selbox[4] * .5,
			ent.base_selbox[5] * .5,
			ent.base_selbox[6] * .5,
		},
	})

	return child
end



-- feeding, taming and breeding (thanks blert2112)
function mobs:feed_tame(self, clicker, feed_count, breed, tame)
	if not self.follow then
		return false
	end

	-- can eat/tame with item in hand
	if follow_holding(self, clicker) then

		-- if not in creative then take item
		if not mobs.is_creative(clicker:get_player_name()) then

			local item = clicker:get_wielded_item()

			item:take_item()

			clicker:set_wielded_item(item)
		end

		mob_sound(self, "eat", nil, true)

		-- increase health
		self.health = self.health + 4

		if self.health >= self.hp_max then

			self.health = self.hp_max

			if self.htimer < 1 then
				self.htimer = 5
			end
		end

		self.object:set_hp(self.health)

		update_tag(self)

		-- make children grow quicker
		if self.child == true then

			-- deduct 10% of the time to adulthood
			self.hornytimer = self.hornytimer + ((CHILD_GROW_TIME - self.hornytimer) * 0.1)

			return true
		end

		-- feed and tame
		self.food = (self.food or 0) + 1
		if self.food >= feed_count then

			self.food = 0

			if breed and self.hornytimer == 0 then
				self.horny = true
			end

			if tame then

				self.tamed = true

				if not self.owner or self.owner == "" then
					self.owner = clicker:get_player_name()
				end
			end

			-- make sound when fed so many times
			mob_sound(self, "random", true)
		end

		return true
	end

	return false
end

-- no damage to nodes explosion
function mobs:safe_boom(self, pos, strength)
	minetest_sound_play(self.sounds and self.sounds.explode or "tnt_explode", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = self.sounds and self.sounds.distance or 32
	}, true)
	local radius = strength
	entity_physics(pos, radius)
	effect(pos, 32, "mcl_particles_smoke.png", radius * 3, radius * 5, radius, 1, 0)
end


-- make explosion with protection and tnt mod check
function mobs:boom(self, pos, strength, fire)
	self.object:remove()
	if mod_explosions then
		if mobs_griefing and not minetest_is_protected(pos, "") then
			mcl_explosions.explode(pos, strength, { drop_chance = 1.0, fire = fire }, self.object)
		else
			mobs:safe_boom(self, pos, strength)
		end
	else
		mobs:safe_boom(self, pos, strength)
	end
end

-- falling and fall damage
-- returns true if mob died
local falling = function(self, pos)

	if self.fly and self.state ~= "die" then
		return
	end

	if mcl_portals ~= nil then
		if mcl_portals.nether_portal_cooloff(self.object) then
			return false -- mob has teleported through Nether portal - it's 99% not falling
		end
	end

	-- floating in water (or falling)
	local v = self.object:get_velocity()

	if v.y > 0 then

		-- apply gravity when moving up
		self.object:set_acceleration({
			x = 0,
			y = -10,
			z = 0
		})

	elseif v.y <= 0 and v.y > self.fall_speed then

		-- fall downwards at set speed
		self.object:set_acceleration({
			x = 0,
			y = self.fall_speed,
			z = 0
		})
	else
		-- stop accelerating once max fall speed hit
		self.object:set_acceleration({x = 0, y = 0, z = 0})
	end

	if minetest_registered_nodes[node_ok(pos).name].groups.lava then

		if self.floats_on_lava == 1 then

			self.object:set_acceleration({
				x = 0,
				y = -self.fall_speed / (max(1, v.y) ^ 2),
				z = 0
			})
		end
	end

	-- in water then float up
	if minetest_registered_nodes[node_ok(pos).name].groups.water then

		if self.floats == 1 then

			self.object:set_acceleration({
				x = 0,
				y = -self.fall_speed / (math_max(1, v.y) ^ 2),
				z = 0
			})
		end
	else

		-- fall damage onto solid ground
		if self.fall_damage == 1
		and self.object:get_velocity().y == 0 then

			local d = (self.old_y or 0) - self.object:get_pos().y

			if d > 5 then

				local add = minetest_get_item_group(self.standing_on, "fall_damage_add_percent")
				local damage = d - 5
				if add ~= 0 then
					damage = damage + damage * (add/100)
				end
				damage = math_floor(damage)
				if damage > 0 then
					self.health = self.health - damage

					effect(pos, 5, "mcl_particles_smoke.png", 1, 2, 2, nil)

					if check_for_death(self, "fall", {type = "fall"}) then
						return true
					end
				end
			end

			self.old_y = self.object:get_pos().y
		end
	end
end

local teleport = function(self, target)
	if self.do_teleport then
		if self.do_teleport(self, target) == false then
			return
		end
	end
end


-- find someone to runaway from
local runaway_from = function(self)

	if not self.runaway_from and self.state ~= "flop" then
		return
	end

	local s = self.object:get_pos()
	local p, sp, dist
	local player, obj, min_player
	local type, name = "", ""
	local min_dist = self.view_range + 1
	local objs = minetest_get_objects_inside_radius(s, self.view_range)

	for n = 1, #objs do

		if objs[n]:is_player() then

			if mobs.invis[ objs[n]:get_player_name() ]
			or self.owner == objs[n]:get_player_name()
			or (not object_in_range(self, objs[n])) then
				type = ""
			else
				player = objs[n]
				type = "player"
				name = "player"
			end
		else
			obj = objs[n]:get_luaentity()

			if obj then
				player = obj.object
				type = obj.type
				name = obj.name or ""
			end
		end

		-- find specific mob to runaway from
		if name ~= "" and name ~= self.name
		and specific_runaway(self.runaway_from, name) then

			p = player:get_pos()
			sp = s

			-- aim higher to make looking up hills more realistic
			p.y = p.y + 1
			sp.y = sp.y + 1

			dist = vector.distance(p, s)


			-- choose closest player/mpb to runaway from
			if dist < min_dist
			and line_of_sight(self, sp, p, 2) == true then
				min_dist = dist
				min_player = player
			end
		end
	end

	if min_player then

		local lp = player:get_pos()
		local vec = {
			x = lp.x - s.x,
			y = lp.y - s.y,
			z = lp.z - s.z
		}

		local yaw = (atan(vec.z / vec.x) + 3 * math_pi / 2) - self.rotate

		if lp.x > s.x then
			yaw = yaw + math_pi
		end

		yaw = set_yaw(self, yaw, 4)
		self.state = "runaway"
		self.runaway_timer = 3
		self.following = nil
	end
end


-- specific runaway
local specific_runaway = function(list, what)

	-- no list so do not run
	if list == nil then
		return false
	end

	-- found entity on list to attack?
	for no = 1, #list do

		if list[no] == what then
			return true
		end
	end

	return false
end


-- follow player if owner or holding item, if fish outta water then flop
local follow_flop = function(self)

	-- find player to follow
	if (self.follow ~= ""
	or self.order == "follow")
	and not self.following
	and self.state ~= "attack"
	and self.order ~= "sit"
	and self.state ~= "runaway" then

		local s = self.object:get_pos()
		local players = minetest.get_connected_players()

		for n = 1, #players do

			if (object_in_range(self, players[n]))
			and not mobs.invis[ players[n]:get_player_name() ] then

				self.following = players[n]

				break
			end
		end
	end

	if self.type == "npc"
	and self.order == "follow"
	and self.state ~= "attack"
	and self.order ~= "sit"
	and self.owner ~= "" then

		-- npc stop following player if not owner
		if self.following
		and self.owner
		and self.owner ~= self.following:get_player_name() then
			self.following = nil
		end
	else
		-- stop following player if not holding specific item,
		-- mob is horny, fleeing or attacking
		if self.following
		and self.following:is_player()
		and (follow_holding(self, self.following) == false or
		self.horny or self.state == "runaway") then
			self.following = nil
		end

	end

	-- follow that thing
	if self.following then

		local s = self.object:get_pos()
		local p

		if self.following:is_player() then

			p = self.following:get_pos()

		elseif self.following.object then

			p = self.following.object:get_pos()
		end

		if p then

			local dist = vector.distance(p, s)

			-- dont follow if out of range
			if (not object_in_range(self, self.following)) then
				self.following = nil
			else
				local vec = {
					x = p.x - s.x,
					z = p.z - s.z
				}

				local yaw = (atan(vec.z / vec.x) + math_pi / 2) - self.rotate

				if p.x > s.x then yaw = yaw + math_pi end

				set_yaw(self, yaw, 2.35)

				-- anyone but standing npc's can move along
				if dist > 3
				and self.order ~= "stand" then

 					set_velocity(self, self.follow_velocity)

					if self.walk_chance ~= 0 then
						set_animation(self, "run")
					end
				else
					set_velocity(self, 0)
					set_animation(self, "stand")
				end

				return
			end
		end
	end

	-- swimmers flop when out of their element, and swim again when back in
	if self.fly then
		local s = self.object:get_pos()
		if not flight_check(self, s) then

			self.state = "flop"
			self.object:set_acceleration({x = 0, y = DEFAULT_FALL_SPEED, z = 0})

			local sdef = minetest_registered_nodes[self.standing_on]
			-- Flop on ground
			if sdef and sdef.walkable then
				mob_sound(self, "flop")
				self.object:set_velocity({
					x = math_random(-FLOP_HOR_SPEED, FLOP_HOR_SPEED),
					y = FLOP_HEIGHT,
					z = math_random(-FLOP_HOR_SPEED, FLOP_HOR_SPEED),
				})
			end

			set_animation(self, "stand", true)

			return
		elseif self.state == "flop" then
			self.state = "stand"
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			set_velocity(self, 0)
		end
	end
end


-- npc, find closest monster to attack
local npc_attack = function(self)

	if self.type ~= "npc"
	or not self.attacks_monsters
	or self.state == "attack" then
		return
	end

	local p, sp, obj, min_player
	local s = self.object:get_pos()
	local min_dist = self.view_range + 1
	local objs = minetest_get_objects_inside_radius(s, self.view_range)

	for n = 1, #objs do

		obj = objs[n]:get_luaentity()

		if obj and obj.type == "monster" then

			p = obj.object:get_pos()
			sp = s

			local dist = vector.distance(p, s)

			-- aim higher to make looking up hills more realistic
			p.y = p.y + 1
			sp.y = sp.y + 1

			if dist < min_dist
			and line_of_sight(self, sp, p, 2) == true then
				min_dist = dist
				min_player = obj.object
			end
		end
	end

	if min_player then
		do_attack(self, min_player)
	end
end


-- monster find someone to attack
local monster_attack = function(self)

	if self.type ~= "monster"
	or not damage_enabled
	or minetest_is_creative_enabled("")
	or self.passive
	or self.state == "attack"
	or day_docile(self) then
		return
	end

	local s = self.object:get_pos()
	local p, sp, dist
	local player, obj, min_player
	local type, name = "", ""
	local min_dist = self.view_range + 1
	local objs = minetest_get_objects_inside_radius(s, self.view_range)

	for n = 1, #objs do

		if objs[n]:is_player() then

			if mobs.invis[ objs[n]:get_player_name() ] or (not object_in_range(self, objs[n])) then
				type = ""
			else
				player = objs[n]
				type = "player"
				name = "player"
			end
		else
			obj = objs[n]:get_luaentity()

			if obj then
				player = obj.object
				type = obj.type
				name = obj.name or ""
			end
		end

		-- find specific mob to attack, failing that attack player/npc/animal
		if specific_attack(self.specific_attack, name)
		and (type == "player" or type == "npc"
			or (type == "animal" and self.attack_animals == true)) then

			p = player:get_pos()
			sp = s

			dist = vector.distance(p, s)

			-- aim higher to make looking up hills more realistic
			p.y = p.y + 1
			sp.y = sp.y + 1


			-- choose closest player to attack
			if dist < min_dist
			and line_of_sight(self, sp, p, 2) == true then
				min_dist = dist
				min_player = player
			end
		end
	end

	-- attack player
	if min_player then
		do_attack(self, min_player)
	end
end


-- specific attacks
local specific_attack = function(list, what)

	-- no list so attack default (player, animals etc.)
	if list == nil then
		return true
	end

	-- found entity on list to attack?
	for no = 1, #list do

		if list[no] == what then
			return true
		end
	end

	return false
end


-- dogfight attack switch and counter function
local dogswitch = function(self, dtime)

	-- switch mode not activated
	if not self.dogshoot_switch
	or not dtime then
		return 0
	end

	self.dogshoot_count = self.dogshoot_count + dtime

	if (self.dogshoot_switch == 1
	and self.dogshoot_count > self.dogshoot_count_max)
	or (self.dogshoot_switch == 2
	and self.dogshoot_count > self.dogshoot_count2_max) then

		self.dogshoot_count = 0

		if self.dogshoot_switch == 1 then
			self.dogshoot_switch = 2
		else
			self.dogshoot_switch = 1
		end
	end

	return self.dogshoot_switch
end

-- path finding and smart mob routine by rnd, line_of_sight and other edits by Elkien3
local smart_mobs = function(self, s, p, dist, dtime)

	local s1 = self.path.lastpos

	local target_pos = self.attack:get_pos()

	-- is it becoming stuck?
	if math_abs(s1.x - s.x) + math_abs(s1.z - s.z) < .5 then
		self.path.stuck_timer = self.path.stuck_timer + dtime
	else
		self.path.stuck_timer = 0
	end

	self.path.lastpos = {x = s.x, y = s.y, z = s.z}

	local use_pathfind = false
	local has_lineofsight = minetest_line_of_sight(
		{x = s.x, y = (s.y) + .5, z = s.z},
		{x = target_pos.x, y = (target_pos.y) + 1.5, z = target_pos.z}, .2)

	-- im stuck, search for path
	if not has_lineofsight then

		if los_switcher == true then
			use_pathfind = true
			los_switcher = false
		end -- cannot see target!
	else
		if los_switcher == false then

			los_switcher = true
			use_pathfind = false

			minetest_after(1, function(self)
				if not self.object:get_luaentity() then
					return
				end
				if has_lineofsight then self.path.following = false end
			end, self)
		end -- can see target!
	end

	if (self.path.stuck_timer > stuck_timeout and not self.path.following) then

		use_pathfind = true
		self.path.stuck_timer = 0

		minetest_after(1, function(self)
			if not self.object:get_luaentity() then
				return
			end
			if has_lineofsight then self.path.following = false end
		end, self)
	end

	if (self.path.stuck_timer > stuck_path_timeout and self.path.following) then

		use_pathfind = true
		self.path.stuck_timer = 0

		minetest_after(1, function(self)
			if not self.object:get_luaentity() then
				return
			end
			if has_lineofsight then self.path.following = false end
		end, self)
	end

	if math_abs(vector.subtract(s,target_pos).y) > self.stepheight then

		if height_switcher then
			use_pathfind = true
			height_switcher = false
		end
	else
		if not height_switcher then
			use_pathfind = false
			height_switcher = true
		end
	end

	if use_pathfind then
		-- lets try find a path, first take care of positions
		-- since pathfinder is very sensitive
		local sheight = self.collisionbox[5] - self.collisionbox[2]

		-- round position to center of node to avoid stuck in walls
		-- also adjust height for player models!
		s.x = math_floor(s.x + 0.5)
		s.z = math_floor(s.z + 0.5)

		local ssight, sground = minetest_line_of_sight(s, {
			x = s.x, y = s.y - 4, z = s.z}, 1)

		-- determine node above ground
		if not ssight then
			s.y = sground.y + 1
		end

		local p1 = self.attack:get_pos()

		p1.x = math_floor(p1.x + 0.5)
		p1.y = math_floor(p1.y + 0.5)
		p1.z = math_floor(p1.z + 0.5)

		local dropheight = 12
		if self.fear_height ~= 0 then dropheight = self.fear_height end
		local jumpheight = 0
		if self.jump and self.jump_height >= 4 then
			jumpheight = math.min(math.ceil(self.jump_height / 4), 4)
		elseif self.stepheight > 0.5 then
			jumpheight = 1
		end
		self.path.way = minetest_find_path(s, p1, 16, jumpheight, dropheight, "A*_noprefetch")

		self.state = ""
		do_attack(self, self.attack)

		-- no path found, try something else
		if not self.path.way then

			self.path.following = false

			 -- lets make way by digging/building if not accessible
			if self.pathfinding == 2 and mobs_griefing then

				-- is player higher than mob?
				if s.y < p1.y then

					-- build upwards
					if not minetest_is_protected(s, "") then

						local ndef1 = minetest_registered_nodes[self.standing_in]

						if ndef1 and (ndef1.buildable_to or ndef1.groups.liquid) then

								minetest_set_node(s, {name = mobs.fallback_node})
						end
					end

					local sheight = math.ceil(self.collisionbox[5]) + 1

					-- assume mob is 2 blocks high so it digs above its head
					s.y = s.y + sheight

					-- remove one block above to make room to jump
					if not minetest_is_protected(s, "") then

						local node1 = node_ok(s, "air").name
						local ndef1 = minetest_registered_nodes[node1]

						if node1 ~= "air"
						and node1 ~= "ignore"
						and ndef1
						and not ndef1.groups.level
						and not ndef1.groups.unbreakable
						and not ndef1.groups.liquid then

							minetest_set_node(s, {name = "air"})
							minetest_add_item(s, ItemStack(node1))

						end
					end

					s.y = s.y - sheight
					self.object:set_pos({x = s.x, y = s.y + 2, z = s.z})

				else -- dig 2 blocks to make door toward player direction

					local yaw1 = self.object:get_yaw() + math_pi / 2
					local p1 = {
						x = s.x + math_cos(yaw1),
						y = s.y,
						z = s.z + math_sin(yaw1)
					}

					if not minetest_is_protected(p1, "") then

						local node1 = node_ok(p1, "air").name
						local ndef1 = minetest_registered_nodes[node1]

						if node1 ~= "air"
							and node1 ~= "ignore"
							and ndef1
							and not ndef1.groups.level
							and not ndef1.groups.unbreakable
							and not ndef1.groups.liquid then

							minetest_add_item(p1, ItemStack(node1))
							minetest_set_node(p1, {name = "air"})
						end

						p1.y = p1.y + 1
						node1 = node_ok(p1, "air").name
						ndef1 = minetest_registered_nodes[node1]

						if node1 ~= "air"
						and node1 ~= "ignore"
						and ndef1
						and not ndef1.groups.level
						and not ndef1.groups.unbreakable
						and not ndef1.groups.liquid then

							minetest_add_item(p1, ItemStack(node1))
							minetest_set_node(p1, {name = "air"})
						end

					end
				end
			end

			-- will try again in 2 seconds
			self.path.stuck_timer = stuck_timeout - 2
		elseif s.y < p1.y and (not self.fly) then
			do_jump(self) --add jump to pathfinding
			self.path.following = true
			-- Yay, I found path!
			-- TODO: Implement war_cry sound without being annoying
			--mob_sound(self, "war_cry", true)
		else
			set_velocity(self, self.walk_velocity)

			-- follow path now that it has it
			self.path.following = true
		end
	end
end

local update_tag = function(self)
	local tag
	if mobs_debug then
		tag = "nametag = '"..tostring(self.nametag).."'\n"..
		"state = '"..tostring(self.state).."'\n"..
		"order = '"..tostring(self.order).."'\n"..
		"attack = "..tostring(self.attack).."\n"..
		"health = "..tostring(self.health).."\n"..
		"breath = "..tostring(self.breath).."\n"..
		"gotten = "..tostring(self.gotten).."\n"..
		"tamed = "..tostring(self.tamed).."\n"..
		"horny = "..tostring(self.horny).."\n"..
		"hornytimer = "..tostring(self.hornytimer).."\n"..
		"runaway_timer = "..tostring(self.runaway_timer).."\n"..
		"following = "..tostring(self.following)
	else
		tag = self.nametag
	end
	self.object:set_properties({
		nametag = tag,
	})

	update_roll(self)
end

-- drop items
local item_drop = function(self, cooked, looting_level)

	-- no drops if disabled by setting
	if not mobs_drop_items then return end

	looting_level = looting_level or 0

	-- no drops for child mobs (except monster)
	if (self.child and self.type ~= "monster") then
		return
	end

	local obj, item, num
	local pos = self.object:get_pos()

	self.drops = self.drops or {} -- nil check

	for n = 1, #self.drops do
		local dropdef = self.drops[n]
		local chance = 1 / dropdef.chance
		local looting_type = dropdef.looting

		if looting_level > 0 then
			local chance_function = dropdef.looting_chance_function
			if chance_function then
				chance = chance_function(looting_level)
			elseif looting_type == "rare" then
				chance = chance + (dropdef.looting_factor or 0.01) * looting_level
			end
		end

		local num = 0
		local do_common_looting = (looting_level > 0 and looting_type == "common")
		if math_random() < chance then
			num = math_random(dropdef.min or 1, dropdef.max or 1)
		elseif not dropdef.looting_ignore_chance then
			do_common_looting = false
		end

		if do_common_looting then
			num = num + math_floor(math_random(0, looting_level) + 0.5)
		end

		if num > 0 then
			item = dropdef.name

			-- cook items when true
			if cooked then

				local output = minetest_get_craft_result({
					method = "cooking", width = 1, items = {item}})

				if output and output.item and not output.item:is_empty() then
					item = output.item:get_name()
				end
			end

			-- add item if it exists
			for x = 1, num do
				obj = minetest_add_item(pos, ItemStack(item .. " " .. 1))
			end

			if obj and obj:get_luaentity() then

				obj:set_velocity({
					x = math_random(-10, 10) / 9,
					y = 6,
					z = math_random(-10, 10) / 9,
				})
			elseif obj then
				obj:remove() -- item does not exist
			end
		end
	end

	self.drops = {}
end


-- check if mob is dead or only hurt
local check_for_death = function(self, cause, cmi_cause)

	if self.state == "die" then
		return true
	end

	-- has health actually changed?
	if self.health == self.old_health and self.health > 0 then
		return false
	end

	local damaged = self.health < self.old_health
	self.old_health = self.health

	-- still got some health?
	if self.health > 0 then

		-- make sure health isn't higher than max
		if self.health > self.hp_max then
			self.health = self.hp_max
		end

		-- play damage sound if health was reduced and make mob flash red.
		if damaged then
			add_texture_mod(self, "^[colorize:red:130")
			minetest_after(.2, function(self)
				if self and self.object then
					remove_texture_mod(self, "^[colorize:red:130")
				end
			end, self)
			mob_sound(self, "damage")
		end

		-- backup nametag so we can show health stats
		if not self.nametag2 then
			self.nametag2 = self.nametag or ""
		end

		if show_health
		and (cmi_cause and cmi_cause.type == "punch") then

			self.htimer = 2
			self.nametag = "♥ " .. self.health .. " / " .. self.hp_max

			update_tag(self)
		end

		return false
	end

	mob_sound(self, "death")

	local function death_handle(self)
		-- dropped cooked item if mob died in fire or lava
		if cause == "lava" or cause == "fire" then
			item_drop(self, true, 0)
		else
			local wielditem = ItemStack()
			if cause == "hit" then
				local puncher = cmi_cause.puncher
				if puncher then
					wielditem = puncher:get_wielded_item()
				end
			end
			local cooked = mcl_burning.is_burning(self.object) or mcl_enchanting.has_enchantment(wielditem, "fire_aspect")
			local looting = mcl_enchanting.get_enchantment(wielditem, "looting")
			item_drop(self, cooked, looting)

			if mod_experience and ((not self.child) or self.type ~= "animal") and (minetest_get_us_time() - self.xp_timestamp <= 5000000) then
				mcl_experience.throw_experience(self.object:get_pos(), math_random(self.xp_min, self.xp_max))
			end
		end
	end

	-- execute custom death function
	if self.on_die then

		local pos = self.object:get_pos()
		local on_die_exit = self.on_die(self, pos, cmi_cause)
		if on_die_exit ~= true then
			death_handle(self)
		end

		if use_cmi then
			cmi.notify_die(self.object, cmi_cause)
		end

		if on_die_exit == true then
			self.state = "die"
			mcl_burning.extinguish(self.object)
			self.object:remove()
			return true
		end
	end

	local collisionbox
	if self.collisionbox then
		collisionbox = table.copy(self.collisionbox)
	end

	self.state = "die"
	self.attack = nil
	self.v_start = false
	self.fall_speed = DEFAULT_FALL_SPEED
	self.timer = 0
	self.blinktimer = 0
	remove_texture_mod(self, "^[colorize:#FF000040")
	remove_texture_mod(self, "^[brighten")
	self.passive = true

	self.object:set_properties({
		pointable = false,
		collide_with_objects = false,
	})

	set_velocity(self, 0)
	local acc = self.object:get_acceleration()
	acc.x, acc.y, acc.z = 0, DEFAULT_FALL_SPEED, 0
	self.object:set_acceleration(acc)

	local length
	-- default death function and die animation (if defined)
	if self.instant_death then
		length = 0
	elseif self.animation
	and self.animation.die_start
	and self.animation.die_end then

		local frames = self.animation.die_end - self.animation.die_start
		local speed = self.animation.die_speed or 15
		length = max(frames / speed, 0) + DEATH_DELAY
		set_animation(self, "die")
	else
		local rot = self.object:get_rotation()
		rot.z = math_pi/2
		self.object:set_rotation(rot)
		length = 1 + DEATH_DELAY
		set_animation(self, "stand", true)
	end


	-- Remove body after a few seconds and drop stuff
	local kill = function(self)
		if not self.object:get_luaentity() then
			return
		end
		if use_cmi  then
			cmi.notify_die(self.object, cmi_cause)
		end

		death_handle(self)
		local dpos = self.object:get_pos()
		local cbox = self.collisionbox
		local yaw = self.object:get_rotation().y
		mcl_burning.extinguish(self.object)
		self.object:remove()
		mobs.death_effect(dpos, yaw, cbox, not self.instant_death)
	end
	if length <= 0 then
		kill(self)
	else
		minetest_after(length, kill, self)
	end

	return true
end

local damage_effect = function(self, damage)
	-- damage particles
	if (not disable_blood) and damage > 0 then

		local amount_large = math_floor(damage / 2)
		local amount_small = damage % 2

		local pos = self.object:get_pos()

		pos.y = pos.y + (self.collisionbox[5] - self.collisionbox[2]) * .5

		local texture = "mobs_blood.png"
		-- full heart damage (one particle for each 2 HP damage)
		if amount_large > 0 then
			effect(pos, amount_large, texture, 2, 2, 1.75, 0, nil, true)
		end
		-- half heart damage (one additional particle if damage is an odd number)
		if amount_small > 0 then
			-- TODO: Use "half heart"
			effect(pos, amount_small, texture, 1, 1, 1.75, 0, nil, true)
		end
	end
end


-- custom particle effects
local effect = function(pos, amount, texture, min_size, max_size, radius, gravity, glow, go_down)

	radius = radius or 2
	min_size = min_size or 0.5
	max_size = max_size or 1
	gravity = gravity or -10
	glow = glow or 0
	go_down = go_down or false

	local ym
	if go_down then
		ym = 0
	else
		ym = -radius
	end

	minetest_add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = ym, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size,
		maxsize = max_size,
		texture = texture,
		glow = glow,
	})
end


-- are we flying in what we are suppose to? (taikedz)
local flight_check = function(self)

	local nod = self.standing_in
	local def = minetest_registered_nodes[nod]

	if not def then return false end -- nil check

	local fly_in
	if type(self.fly_in) == "string" then
		fly_in = { self.fly_in }
	elseif type(self.fly_in) == "table" then
		fly_in = self.fly_in
	else
		return false
	end

	for _,checknode in pairs(fly_in) do
		if nod == checknode then
			return true
		elseif checknode == "__airlike" and def.walkable == false and
				(def.liquidtype == "none" or minetest_get_item_group(nod, "fake_liquid") == 1) then
			return true
		end
	end

	return false
end


-- check line of sight (BrunoMine)
local line_of_sight = function(self, pos1, pos2, stepsize)

	stepsize = stepsize or 1

	local s, pos = minetest_line_of_sight(pos1, pos2, stepsize)

	-- normal walking and flying mobs can see you through air
	if s == true then
		return true
	end

	-- New pos1 to be analyzed
	local npos1 = {x = pos1.x, y = pos1.y, z = pos1.z}

	local r, pos = minetest_line_of_sight(npos1, pos2, stepsize)

	-- Checks the return
	if r == true then return true end

	-- Nodename found
	local nn = minetest_get_node(pos).name

	-- Target Distance (td) to travel
	local td = vector.distance(pos1, pos2)

	-- Actual Distance (ad) traveled
	local ad = 0

	-- It continues to advance in the line of sight in search of a real
	-- obstruction which counts as 'normal' nodebox.
	while minetest_registered_nodes[nn]
	and minetest_registered_nodes[nn].walkable == false do

		-- Check if you can still move forward
		if td < ad + stepsize then
			return true -- Reached the target
		end

		-- Moves the analyzed pos
		local d = vector.distance(pos1, pos2)

		npos1.x = ((pos2.x - pos1.x) / d * stepsize) + pos1.x
		npos1.y = ((pos2.y - pos1.y) / d * stepsize) + pos1.y
		npos1.z = ((pos2.z - pos1.z) / d * stepsize) + pos1.z

		-- NaN checks
		if d == 0
		or npos1.x ~= npos1.x
		or npos1.y ~= npos1.y
		or npos1.z ~= npos1.z then
			return false
		end

		ad = ad + stepsize

		-- scan again
		r, pos = minetest_line_of_sight(npos1, pos2, stepsize)

		if r == true then return true end

		-- New Nodename found
		nn = minetest_get_node(pos).name

	end

	return false
end

-- Returns true if node is a water hazard
local is_node_waterhazard = function(self, nodename)
	local nn = nodename
	if self.water_damage > 0 then
		if minetest_get_item_group(nn, "water") ~= 0 then
			return true
		end
	end
	if minetest_registered_nodes[nn] and minetest_registered_nodes[nn].drowning and minetest_registered_nodes[nn].drowning > 0 then
		if self.breath_max ~= -1 then
			-- check if the mob is water-breathing _and_ the block is water; only return true if neither is the case
			-- this will prevent water-breathing mobs to classify water or e.g. sand below them as dangerous
			if not self.breathes_in_water and minetest_get_item_group(nn, "water") ~= 0 then
				return true
			end
		end
	end
	return false
end


-- Returns true is node can deal damage to self
local is_node_dangerous = function(self, nodename)
	local nn = nodename
	if self.lava_damage > 0 then
		if minetest_get_item_group(nn, "lava") ~= 0 then
			return true
		end
	end
	if self.fire_damage > 0 then
		if minetest_get_item_group(nn, "fire") ~= 0 then
			return true
		end
	end
	if minetest_registered_nodes[nn] and minetest_registered_nodes[nn].damage_per_second and minetest_registered_nodes[nn].damage_per_second > 0 then
		return true
	end
	return false
end


local add_texture_mod = function(self, mod)
	local full_mod = ""
	local already_added = false
	for i=1, #self.texture_mods do
		if mod == self.texture_mods[i] then
			already_added = true
		end
		full_mod = full_mod .. self.texture_mods[i]
	end
	if not already_added then
		full_mod = full_mod .. mod
		table.insert(self.texture_mods, mod)
	end
	self.object:set_texture_mod(full_mod)
end


local remove_texture_mod = function(self, mod)
	local full_mod = ""
	local remove = {}
	for i=1, #self.texture_mods do
		if self.texture_mods[i] ~= mod then
			full_mod = full_mod .. self.texture_mods[i]
		else
			table.insert(remove, i)
		end
	end
	for i=#remove, 1 do
		table.remove(self.texture_mods, remove[i])
	end
	self.object:set_texture_mod(full_mod)
end


-- Return true if object is in view_range
local function object_in_range(self, object)
	if not object then
		return false
	end
	local factor
	-- Apply view range reduction for special player armor
	if object:is_player() and mod_armor then
		factor = armor:get_mob_view_range_factor(object, self.name)
	end
	-- Distance check
	local dist
	if factor and factor == 0 then
		return false
	elseif factor then
		dist = self.view_range * factor
	else
		dist = self.view_range
	end

	local p1, p2 = self.object:get_pos(), object:get_pos()
	return p1 and p2 and (vector.distance(p1, p2) <= dist)
end

-- attack player/mob
local do_attack = function(self, player)

	if self.state == "attack" or self.state == "die" then
		return
	end

	self.attack = player
	self.state = "attack"

	-- TODO: Implement war_cry sound without being annoying
	--if math_random(0, 100) < 90 then
		--mob_sound(self, "war_cry", true)
	--end
end


-- play sound
local mob_sound = function(self, soundname, is_opinion, fixed_pitch)
	local soundinfo
	if self.sounds_child and self.child then
		soundinfo = self.sounds_child
	elseif self.sounds then
		soundinfo = self.sounds
	end
	if not soundinfo then
		return
	end
	local sound = soundinfo[soundname]
	if sound then
		if is_opinion and self.opinion_sound_cooloff > 0 then
			return
		end
		local pitch
		if not fixed_pitch then
			local base_pitch = soundinfo.base_pitch
			if not base_pitch then
				base_pitch = 1
			end
			if self.child and (not self.sounds_child) then
				-- Children have higher pitch
				pitch = base_pitch * 1.5
			else
				pitch = base_pitch
			end
			-- randomize the pitch a bit
			pitch = pitch + math_random(-10, 10) * 0.005
		end
		minetest_sound_play(sound, {
			object = self.object,
			gain = 1.0,
			max_hear_distance = self.sounds.distance,
			pitch = pitch,
		}, true)
		self.opinion_sound_cooloff = 1
	end
end


local function update_roll(self)
	local is_Fleckenstein = self.nametag == "Fleckenstein"
	local was_Fleckenstein = false

	local rot = self.object:get_rotation()
	rot.z = is_Fleckenstein and math_pi or 0
	self.object:set_rotation(rot)

	local cbox = table.copy(self.collisionbox)
	local acbox = self.object:get_properties().collisionbox

	if math_abs(cbox[2] - acbox[2]) > 0.1 then
		was_Fleckenstein = true
	end

	if is_Fleckenstein ~= was_Fleckenstein then
		local pos = self.object:get_pos()
		pos.y = pos.y + (acbox[2] + acbox[5])
		self.object:set_pos(pos)
	end

	if is_Fleckenstein then
		cbox[2], cbox[5] = -cbox[5], -cbox[2]
	end

	self.object:set_properties({collisionbox = cbox})
end



-- is mob facing a cliff or danger
local is_at_cliff_or_danger = function(self)

	if self.fear_height == 0 then -- 0 for no falling protection!
		return false
	end

	if not self.object:get_luaentity() then
		return false
	end
	local yaw = self.object:get_yaw()
	local dir_x = -math_sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math_cos(yaw) * (self.collisionbox[4] + 0.5)
	local pos = self.object:get_pos()
	local ypos = pos.y + self.collisionbox[2] -- just above floor

	local free_fall, blocker = minetest_line_of_sight(
		{x = pos.x + dir_x, y = ypos, z = pos.z + dir_z},
		{x = pos.x + dir_x, y = ypos - self.fear_height, z = pos.z + dir_z})
	if free_fall then
		return true
	else
		local bnode = minetest_get_node(blocker)
		local danger = is_node_dangerous(self, bnode.name)
		if danger then
			return true
		else
			local def = minetest_registered_nodes[bnode.name]
			if def and def.walkable then
				return false
			end
		end
	end

	return false
end


-- copy the 'mob facing cliff_or_danger check' from above, and rework to avoid water
local is_at_water_danger = function(self)


	if not self.object:get_luaentity() then
		return false
	end
	local yaw = self.object:get_yaw()
	local dir_x = -math_sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math_cos(yaw) * (self.collisionbox[4] + 0.5)
	local pos = self.object:get_pos()
	local ypos = pos.y + self.collisionbox[2] -- just above floor

	local free_fall, blocker = minetest_line_of_sight(
		{x = pos.x + dir_x, y = ypos, z = pos.z + dir_z},
		{x = pos.x + dir_x, y = ypos - 3, z = pos.z + dir_z})
	if free_fall then
		return true
	else
		local bnode = minetest_get_node(blocker)
		local waterdanger = is_node_waterhazard(self, bnode.name)
		if
			waterdanger and (is_node_waterhazard(self, self.standing_in) or is_node_waterhazard(self, self.standing_on)) then
			return false
		elseif waterdanger and (is_node_waterhazard(self, self.standing_in) or is_node_waterhazard(self, self.standing_on)) == false then
			return true
		else
			local def = minetest_registered_nodes[bnode.name]
			if def and def.walkable then
				return false
			end
		end
	end

	return false
end





-- environmental damage (water, lava, fire, light etc.)
local do_env_damage = function(self)

	-- feed/tame text timer (so mob 'full' messages dont spam chat)
	if self.htimer > 0 then
		self.htimer = self.htimer - 1
	end

	-- reset nametag after showing health stats
	if self.htimer < 1 and self.nametag2 then

		self.nametag = self.nametag2
		self.nametag2 = nil

		update_tag(self)
	end

	local pos = self.object:get_pos()

	self.time_of_day = minetest.get_timeofday()

	-- remove mob if beyond map limits
	if not within_limits(pos, 0) then
		mcl_burning.extinguish(self.object)
		self.object:remove()
		return true
	end


	-- Deal light damage to mob, returns true if mob died
	local deal_light_damage = function(self, pos, damage)
		if not (mod_weather and (mcl_weather.rain.raining or mcl_weather.state == "snow") and mcl_weather.is_outdoor(pos)) then
			self.health = self.health - damage

			effect(pos, 5, "mcl_particles_smoke.png")

			if check_for_death(self, "light", {type = "light"}) then
				return true
			end
		end
	end

	-- Use get_node_light for Minetest version 5.3 where get_natural_light
	-- does not exist yet.
	local get_light = minetest_get_natural_light or minetest_get_node_light
	local sunlight = get_light(pos, self.time_of_day)

	-- bright light harms mob
	if self.light_damage ~= 0 and (sunlight or 0) > 12 then
		if deal_light_damage(self, pos, self.light_damage) then
			return true
		end
	end
	local _, dim = nil, "overworld"
	if mod_worlds then
		_, dim = mcl_worlds.y_to_layer(pos.y)
	end
	if (self.sunlight_damage ~= 0 or self.ignited_by_sunlight) and (sunlight or 0) >= minetest.LIGHT_MAX and dim == "overworld" then
		if self.ignited_by_sunlight then
			mcl_burning.set_on_fire(self.object, 10)
		else
			deal_light_damage(self, pos, self.sunlight_damage)
			return true
		end
	end

	local y_level = self.collisionbox[2]

	if self.child then
		y_level = self.collisionbox[2] * 0.5
	end

	-- what is mob standing in?
	pos.y = pos.y + y_level + 0.25 -- foot level
	local pos2 = {x=pos.x, y=pos.y-1, z=pos.z}
	self.standing_in = node_ok(pos, "air").name
	self.standing_on = node_ok(pos2, "air").name

	-- don't fall when on ignore, just stand still
	if self.standing_in == "ignore" then
		self.object:set_velocity({x = 0, y = 0, z = 0})
	end

	local nodef = minetest_registered_nodes[self.standing_in]

	-- rain
	if self.rain_damage > 0 and mod_weather then
		if mcl_weather.rain.raining and mcl_weather.is_outdoor(pos) then

			self.health = self.health - self.rain_damage

			if check_for_death(self, "rain", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		end
	end

	pos.y = pos.y + 1 -- for particle effect position

	-- water damage
	if self.water_damage > 0
	and nodef.groups.water then

		if self.water_damage ~= 0 then

			self.health = self.health - self.water_damage

			effect(pos, 5, "mcl_particles_smoke.png", nil, nil, 1, nil)

			if check_for_death(self, "water", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		end

	-- lava damage
	elseif self.lava_damage > 0
	and (nodef.groups.lava) then

		if self.lava_damage ~= 0 then

			self.health = self.health - self.lava_damage

			effect(pos, 5, "fire_basic_flame.png", nil, nil, 1, nil)

			if check_for_death(self, "lava", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		end

	-- fire damage
	elseif self.fire_damage > 0
	and (nodef.groups.fire) then

		if self.fire_damage ~= 0 then

			self.health = self.health - self.fire_damage

			effect(pos, 5, "fire_basic_flame.png", nil, nil, 1, nil)

			if check_for_death(self, "fire", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		end

	-- damage_per_second node check
	elseif nodef.damage_per_second ~= 0 and not nodef.groups.lava and not nodef.groups.fire then

		self.health = self.health - nodef.damage_per_second

		effect(pos, 5, "mcl_particles_smoke.png")

		if check_for_death(self, "dps", {type = "environment",
				pos = pos, node = self.standing_in}) then
			return true
		end
	end

	-- Drowning damage
	if self.breath_max ~= -1 then
		local drowning = false
		if self.breathes_in_water then
			if minetest_get_item_group(self.standing_in, "water") == 0 then
				drowning = true
			end
		elseif nodef.drowning > 0 then
			drowning = true
		end
		if drowning then

			self.breath = math_max(0, self.breath - 1)

			effect(pos, 2, "bubble.png", nil, nil, 1, nil)
			if self.breath <= 0 then
				local dmg
				if nodef.drowning > 0 then
					dmg = nodef.drowning
				else
					dmg = 4
				end
				damage_effect(self, dmg)
				self.health = self.health - dmg
			end
			if check_for_death(self, "drowning", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		else
			self.breath = math_min(self.breath_max, self.breath + 1)
		end
	end

	--- suffocation inside solid node
	-- FIXME: Redundant with mcl_playerplus
	if (self.suffocation == true)
	and (nodef.walkable == nil or nodef.walkable == true)
	and (nodef.collision_box == nil or nodef.collision_box.type == "regular")
	and (nodef.node_box == nil or nodef.node_box.type == "regular")
	and (nodef.groups.disable_suffocation ~= 1)
	and (nodef.groups.opaque == 1) then

		-- Short grace period before starting to take suffocation damage.
		-- This is different from players, who take damage instantly.
		-- This has been done because mobs might briefly be inside solid nodes
		-- when e.g. climbing up stairs.
		-- This is a bit hacky because it assumes that do_env_damage
		-- is called roughly every second only.
		self.suffocation_timer = self.suffocation_timer + 1
		if self.suffocation_timer >= 3 then
			-- 2 damage per second
			-- TODO: Deal this damage once every 1/2 second
			self.health = self.health - 2

			if check_for_death(self, "suffocation", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		end
	else
		self.suffocation_timer = 0
	end

	return check_for_death(self, "", {type = "unknown"})
end


-- jump if facing a solid node (not fences or gates)
local do_jump = function(self)

	if not self.jump
	or self.jump_height == 0
	or self.fly
	or (self.child and self.type ~= "monster")
	or self.order == "stand" then
		return false
	end

	self.facing_fence = false

	-- something stopping us while moving?
	if self.state ~= "stand"
	and get_velocity(self) > 0.5
	and self.object:get_velocity().y ~= 0 then
		return false
	end

	local pos = self.object:get_pos()
	local yaw = self.object:get_yaw()

	-- what is mob standing on?
	pos.y = pos.y + self.collisionbox[2] - 0.2

	local nod = node_ok(pos)

	if minetest_registered_nodes[nod.name].walkable == false then
		return false
	end

	-- where is front
	local dir_x = -math_sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math_cos(yaw) * (self.collisionbox[4] + 0.5)

	-- what is in front of mob?
	nod = node_ok({
		x = pos.x + dir_x,
		y = pos.y + 0.5,
		z = pos.z + dir_z
	})

	-- this is used to detect if there's a block on top of the block in front of the mob.
	-- If there is, there is no point in jumping as we won't manage.
	local nodTop = node_ok({
		x = pos.x + dir_x,
		y = pos.y + 1.5,
		z = pos.z + dir_z
	}, "air")

	-- we don't attempt to jump if there's a stack of blocks blocking
	if minetest_registered_nodes[nodTop.name].walkable == true then
		return false
	end

	-- thin blocks that do not need to be jumped
	if nod.name == node_snow then
		return false
	end

	if self.walk_chance == 0
	or minetest_registered_items[nod.name].walkable then

		if minetest_get_item_group(nod.name, "fence") == 0
		and minetest_get_item_group(nod.name, "fence_gate") == 0
		and minetest_get_item_group(nod.name, "wall") == 0 then

			local v = self.object:get_velocity()

			v.y = self.jump_height

			set_animation(self, "jump") -- only when defined

			self.object:set_velocity(v)

			-- when in air move forward
			minetest_after(0.3, function(self, v)
				if (not self.object) or (not self.object:get_luaentity()) or (self.state == "die") then
					return
				end
				self.object:set_acceleration({
					x = v.x * 2,
					y = -10,
					z = v.z * 2,
				})
			end, self, v)

			if self.jump_sound_cooloff <= 0 then
				mob_sound(self, "jump")
				self.jump_sound_cooloff = 0.5
			end
		else
			self.facing_fence = true
		end

		-- if we jumped against a block/wall 4 times then turn
		if self.object:get_velocity().x ~= 0
		and self.object:get_velocity().z ~= 0 then

			self.jump_count = (self.jump_count or 0) + 1

			if self.jump_count == 4 then

				local yaw = self.object:get_yaw() or 0

				yaw = set_yaw(self, yaw + 1.35, 8)

				self.jump_count = 0
			end
		end

		return true
	end

	return false
end


-- blast damage to entities nearby
local entity_physics = function(pos, radius)

	radius = radius * 2

	local objs = minetest_get_objects_inside_radius(pos, radius)
	local obj_pos, dist

	for n = 1, #objs do

		obj_pos = objs[n]:get_pos()

		dist = vector.distance(pos, obj_pos)
		if dist < 1 then dist = 1 end

		local damage = math_floor((4 / dist) * radius)
		local ent = objs[n]:get_luaentity()

		-- punches work on entities AND players
		objs[n]:punch(objs[n], 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = damage},
		}, pos)
	end
end


-- should mob follow what I'm holding ?
local follow_holding = function(self, clicker)

	if mobs.invis[clicker:get_player_name()] then
		return false
	end

	local item = clicker:get_wielded_item()
	local t = type(self.follow)

	-- single item
	if t == "string"
	and item:get_name() == self.follow then
		return true

	-- multiple items
	elseif t == "table" then

		for no = 1, #self.follow do

			if self.follow[no] == item:get_name() then
				return true
			end
		end
	end

	return false
end


-- find two animals of same type and breed if nearby and horny
local breed = function(self)

	-- child takes a long time before growing into adult
	if self.child == true then

		-- When a child, hornytimer is used to count age until adulthood
		self.hornytimer = self.hornytimer + 1

		if self.hornytimer >= CHILD_GROW_TIME then

			self.child = false
			self.hornytimer = 0

			self.object:set_properties({
				textures = self.base_texture,
				mesh = self.base_mesh,
				visual_size = self.base_size,
				collisionbox = self.base_colbox,
				selectionbox = self.base_selbox,
			})

			-- custom function when child grows up
			if self.on_grown then
				self.on_grown(self)
			else
				-- jump when fully grown so as not to fall into ground
				self.object:set_velocity({
					x = 0,
					y = self.jump_height,
					z = 0
				})
			end
		end

		return
	end

	-- horny animal can mate for BREED_TIME seconds,
	-- afterwards horny animal cannot mate again for BREED_TIME_AGAIN seconds
	if self.horny == true
	and self.hornytimer < BREED_TIME + BREED_TIME_AGAIN then

		self.hornytimer = self.hornytimer + 1

		if self.hornytimer >= BREED_TIME + BREED_TIME_AGAIN then
			self.hornytimer = 0
			self.horny = false
		end
	end

	-- find another same animal who is also horny and mate if nearby
	if self.horny == true
	and self.hornytimer <= BREED_TIME then

		local pos = self.object:get_pos()

		effect({x = pos.x, y = pos.y + 1, z = pos.z}, 8, "heart.png", 3, 4, 1, 0.1)

		local objs = minetest_get_objects_inside_radius(pos, 3)
		local num = 0
		local ent = nil

		for n = 1, #objs do

			ent = objs[n]:get_luaentity()

			-- check for same animal with different colour
			local canmate = false

			if ent then

				if ent.name == self.name then
					canmate = true
				else
					local entname = string.split(ent.name,":")
					local selfname = string.split(self.name,":")

					if entname[1] == selfname[1] then
						entname = string.split(entname[2],"_")
						selfname = string.split(selfname[2],"_")

						if entname[1] == selfname[1] then
							canmate = true
						end
					end
				end
			end

			if ent
			and canmate == true
			and ent.horny == true
			and ent.hornytimer <= BREED_TIME then
				num = num + 1
			end

			-- found your mate? then have a baby
			if num > 1 then

				self.hornytimer = BREED_TIME + 1
				ent.hornytimer = BREED_TIME + 1

				-- spawn baby
				minetest_after(5, function(parent1, parent2, pos)
					if not parent1.object:get_luaentity() then
						return
					end
					if not parent2.object:get_luaentity() then
						return
					end

					-- Give XP
					if mod_experience then
						mcl_experience.throw_experience(pos, math_random(1, 7))
					end

					-- custom breed function
					if parent1.on_breed then
						-- when false, skip going any further
						if parent1.on_breed(parent1, parent2) == false then
							return
						end
					end

					local child = mobs:spawn_child(pos, parent1.name)

					local ent_c = child:get_luaentity()


					-- Use texture of one of the parents
					local p = math_random(1, 2)
					if p == 1 then
						ent_c.base_texture = parent1.base_texture
					else
						ent_c.base_texture = parent2.base_texture
					end
					child:set_properties({
						textures = ent_c.base_texture
					})

					-- tamed and owned by parents' owner
					ent_c.tamed = true
					ent_c.owner = parent1.owner
				end, self, ent, pos)

				num = 0

				break
			end
		end
	end
end

-- find and replace what mob is looking for (grass, wheat etc.)
local replace = function(self, pos)

	if not self.replace_rate
	or not self.replace_what
	or self.child == true
	or self.object:get_velocity().y ~= 0
	or math_random(1, self.replace_rate) > 1 then
		return
	end

	local what, with, y_offset

	if type(self.replace_what[1]) == "table" then

		local num = math_random(#self.replace_what)

		what = self.replace_what[num][1] or ""
		with = self.replace_what[num][2] or ""
		y_offset = self.replace_what[num][3] or 0
	else
		what = self.replace_what
		with = self.replace_with or ""
		y_offset = self.replace_offset or 0
	end

	pos.y = pos.y + y_offset

	local node = minetest_get_node(pos)
	if node.name == what then

		local oldnode = {name = what, param2 = node.param2}
		local newnode = {name = with, param2 = node.param2}
		local on_replace_return

		if self.on_replace then
			on_replace_return = self.on_replace(self, pos, oldnode, newnode)
		end

		if on_replace_return ~= false then

			if mobs_griefing then
				minetest_set_node(pos, newnode)
			end

		end
	end
end


-- check if daytime and also if mob is docile during daylight hours
local day_docile = function(self)

	if self.docile_by_day == false then

		return false

	elseif self.docile_by_day == true
	and self.time_of_day > 0.2
	and self.time_of_day < 0.8 then

		return true
	end
end



local mob_detach_child = function(self, child)

	if self.driver == child then
		self.driver = nil
	end

end

function do_states(self) 

	if self.state == "stand" then

		if math_random(1, 4) == 1 then

			local lp = nil
			local s = self.object:get_pos()
			local objs = minetest_get_objects_inside_radius(s, 3)

			for n = 1, #objs do

				if objs[n]:is_player() then
					lp = objs[n]:get_pos()
					break
				end
			end

			-- look at any players nearby, otherwise turn randomly
			if lp then

				local vec = {
					x = lp.x - s.x,
					z = lp.z - s.z
				}

				yaw = (atan(vec.z / vec.x) + math_pi / 2) - self.rotate

				if lp.x > s.x then yaw = yaw + math_pi end
			else
				yaw = yaw + math_random(-0.5, 0.5)
			end

			yaw = set_yaw(self, yaw, 8)
		end

		set_velocity(self, 0)
		set_animation(self, "stand")

		-- npc's ordered to stand stay standing
		if self.type ~= "npc"
		or self.order ~= "stand" then

			if self.walk_chance ~= 0
			and self.facing_fence ~= true
			and math_random(1, 100) <= self.walk_chance
			and is_at_cliff_or_danger(self) == false then

				set_velocity(self, self.walk_velocity)
				self.state = "walk"
				set_animation(self, "walk")
			end
		end

	elseif self.state == "walk" then

		local s = self.object:get_pos()
		local lp = nil

		-- is there something I need to avoid?
		if (self.water_damage > 0
		and self.lava_damage > 0)
		or self.breath_max ~= -1 then

			lp = minetest_find_node_near(s, 1, {"group:water", "group:lava"})

		elseif self.water_damage > 0 then

			lp = minetest_find_node_near(s, 1, {"group:water"})

		elseif self.lava_damage > 0 then

			lp = minetest_find_node_near(s, 1, {"group:lava"})

		elseif self.fire_damage > 0 then

			lp = minetest_find_node_near(s, 1, {"group:fire"})

		end

		local is_in_danger = false
		if lp then
			-- If mob in or on dangerous block, look for land
			if (is_node_dangerous(self, self.standing_in) or
				is_node_dangerous(self, self.standing_on)) or (is_node_waterhazard(self, self.standing_in) or is_node_waterhazard(self, self.standing_on)) and (not self.fly) then
				is_in_danger = true

					-- If mob in or on dangerous block, look for land
					if is_in_danger then
					-- Better way to find shore - copied from upstream
						lp = minetest_find_nodes_in_area_under_air(
							{x = s.x - 5, y = s.y - 0.5, z = s.z - 5},
							{x = s.x + 5, y = s.y + 1, z = s.z + 5},
							{"group:solid"})

						lp = #lp > 0 and lp[math_random(#lp)]

						-- did we find land?
						if lp then

							local vec = {
								x = lp.x - s.x,
								z = lp.z - s.z
							}

							yaw = (atan(vec.z / vec.x) + math_pi / 2) - self.rotate


							if lp.x > s.x  then yaw = yaw + math_pi end

							-- look towards land and move in that direction
							yaw = set_yaw(self, yaw, 6)
							set_velocity(self, self.walk_velocity)

						end
					end

			-- A danger is near but mob is not inside
			else

				-- Randomly turn
				if math_random(1, 100) <= 30 then
					yaw = yaw + math_random(-0.5, 0.5)
					yaw = set_yaw(self, yaw, 8)
				end
			end

			yaw = set_yaw(self, yaw, 8)

		-- otherwise randomly turn
		elseif math_random(1, 100) <= 30 then

			yaw = yaw + math_random(-0.5, 0.5)
			yaw = set_yaw(self, yaw, 8)
		end

		-- stand for great fall or danger or fence in front
		local cliff_or_danger = false
		if is_in_danger then
			cliff_or_danger = is_at_cliff_or_danger(self)
		end
		if self.facing_fence == true
		or cliff_or_danger
		or math_random(1, 100) <= 30 then

			set_velocity(self, 0)
			self.state = "stand"
			set_animation(self, "stand")
			local yaw = self.object:get_yaw() or 0
			yaw = set_yaw(self, yaw + 0.78, 8)
		else

			set_velocity(self, self.walk_velocity)

			if flight_check(self)
			and self.animation
			and self.animation.fly_start
			and self.animation.fly_end then
				set_animation(self, "fly")
			else
				set_animation(self, "walk")
			end
		end

	-- runaway when punched
	elseif self.state == "runaway" then

		self.runaway_timer = self.runaway_timer + 1

		-- stop after 5 seconds or when at cliff
		if self.runaway_timer > 5
		or is_at_cliff_or_danger(self) then
			self.runaway_timer = 0
			set_velocity(self, 0)
			self.state = "stand"
			set_animation(self, "stand")
			local yaw = self.object:get_yaw() or 0
			yaw = set_yaw(self, yaw + 0.78, 8)
		else
			set_velocity(self, self.run_velocity)
			set_animation(self, "run")
		end

	-- attack routines (explode, dogfight, shoot, dogshoot)
	elseif self.state == "attack" then

		local s = self.object:get_pos()
		local p = self.attack:get_pos() or s

		-- stop attacking if player invisible or out of range
		if not self.attack
		or not self.attack:get_pos()
		or not object_in_range(self, self.attack)
		or self.attack:get_hp() <= 0
		or (self.attack:is_player() and mobs.invis[ self.attack:get_player_name() ]) then

			self.state = "stand"
			set_velocity(self, 0)
			set_animation(self, "stand")
			self.attack = nil
			self.v_start = false
			self.timer = 0
			self.blinktimer = 0
			self.path.way = nil

			return
		end

		-- calculate distance from mob and enemy
		local dist = vector.distance(p, s)

		if self.attack_type == "explode" then

			local vec = {
				x = p.x - s.x,
				z = p.z - s.z
			}

			yaw = (atan(vec.z / vec.x) + math_pi / 2) - self.rotate

			if p.x > s.x then yaw = yaw + math_pi end

			yaw = set_yaw(self, yaw, 0, dtime)

			local node_break_radius = self.explosion_radius or 1
			local entity_damage_radius = self.explosion_damage_radius
					or (node_break_radius * 2)

			-- start timer when in reach and line of sight
			if not self.v_start
			and dist <= self.reach
			and line_of_sight(self, s, p, 2) then

				self.v_start = true
				self.timer = 0
				self.blinktimer = 0
				mob_sound(self, "fuse", nil, false)

			-- stop timer if out of reach or direct line of sight
			elseif self.allow_fuse_reset
			and self.v_start
			and (dist >= self.explosiontimer_reset_radius
					or not line_of_sight(self, s, p, 2)) then
				self.v_start = false
				self.timer = 0
				self.blinktimer = 0
				self.blinkstatus = false
				remove_texture_mod(self, "^[brighten")
			end

			-- walk right up to player unless the timer is active
			if self.v_start and (self.stop_to_explode or dist < self.reach) then
				set_velocity(self, 0)
			else
				set_velocity(self, self.run_velocity)
			end

			if self.animation and self.animation.run_start then
				set_animation(self, "run")
			else
				set_animation(self, "walk")
			end

			if self.v_start then

				self.timer = self.timer + dtime
				self.blinktimer = (self.blinktimer or 0) + dtime

				if self.blinktimer > 0.2 then

					self.blinktimer = 0

					if self.blinkstatus then
						remove_texture_mod(self, "^[brighten")
					else
						add_texture_mod(self, "^[brighten")
					end

					self.blinkstatus = not self.blinkstatus
				end

				if self.timer > self.explosion_timer then

					local pos = self.object:get_pos()

					if mod_explosions then
					if mobs_griefing and not minetest_is_protected(pos, "") then
						mcl_explosions.explode(mcl_util.get_object_center(self.object), self.explosion_strength, { drop_chance = 1.0 }, self.object)
					else
						minetest_sound_play(self.sounds.explode, {
							pos = pos,
							gain = 1.0,
							max_hear_distance = self.sounds.distance or 32
						}, true)

						entity_physics(pos, entity_damage_radius)
						effect(pos, 32, "mcl_particles_smoke.png", nil, nil, node_break_radius, 1, 0)
					end
					end
					mcl_burning.extinguish(self.object)
					self.object:remove()

					return true
				end
			end

		elseif self.attack_type == "dogfight"
		or (self.attack_type == "dogshoot" and dogswitch(self, dtime) == 2)
		or (self.attack_type == "dogshoot" and dist <= self.reach and dogswitch(self) == 0) then

			if self.fly
			and dist > self.reach then

				local p1 = s
				local me_y = math_floor(p1.y)
				local p2 = p
				local p_y = math_floor(p2.y + 1)
				local v = self.object:get_velocity()

				if flight_check(self, s) then

					if me_y < p_y then

						self.object:set_velocity({
							x = v.x,
							y = 1 * self.walk_velocity,
							z = v.z
						})

					elseif me_y > p_y then

						self.object:set_velocity({
							x = v.x,
							y = -1 * self.walk_velocity,
							z = v.z
						})
					end
				else
					if me_y < p_y then

						self.object:set_velocity({
							x = v.x,
							y = 0.01,
							z = v.z
						})

					elseif me_y > p_y then

						self.object:set_velocity({
							x = v.x,
							y = -0.01,
							z = v.z
						})
					end
				end

			end

			-- rnd: new movement direction
			if self.path.following
			and self.path.way
			and self.attack_type ~= "dogshoot" then

				-- no paths longer than 50
				if #self.path.way > 50
				or dist < self.reach then
					self.path.following = false
					return
				end

				local p1 = self.path.way[1]

				if not p1 then
					self.path.following = false
					return
				end

				if math_abs(p1.x-s.x) + math_abs(p1.z - s.z) < 0.6 then
					-- reached waypoint, remove it from queue
					table.remove(self.path.way, 1)
				end

				-- set new temporary target
				p = {x = p1.x, y = p1.y, z = p1.z}
			end

			local vec = {
				x = p.x - s.x,
				z = p.z - s.z
			}

			yaw = (atan(vec.z / vec.x) + math_pi / 2) - self.rotate

			if p.x > s.x then yaw = yaw + math_pi end

			yaw = set_yaw(self, yaw, 0, dtime)

			-- move towards enemy if beyond mob reach
			if dist > self.reach then

				-- path finding by rnd
				if self.pathfinding -- only if mob has pathfinding enabled
				and enable_pathfinding then

					smart_mobs(self, s, p, dist, dtime)
				end

				if is_at_cliff_or_danger(self) then

					set_velocity(self, 0)
					set_animation(self, "stand")
					local yaw = self.object:get_yaw() or 0
					yaw = set_yaw(self, yaw + 0.78, 8)
				else

					if self.path.stuck then
						set_velocity(self, self.walk_velocity)
					else
						set_velocity(self, self.run_velocity)
					end

					if self.animation and self.animation.run_start then
						set_animation(self, "run")
					else
						set_animation(self, "walk")
					end
				end

			else -- rnd: if inside reach range

				self.path.stuck = false
				self.path.stuck_timer = 0
				self.path.following = false -- not stuck anymore

				set_velocity(self, 0)

				if not self.custom_attack then

					if self.timer > 1 then

						self.timer = 0

						if self.double_melee_attack
						and math_random(1, 2) == 1 then
							set_animation(self, "punch2")
						else
							set_animation(self, "punch")
						end

						local p2 = p
						local s2 = s

						p2.y = p2.y + .5
						s2.y = s2.y + .5

						if line_of_sight(self, p2, s2) == true then

							-- play attack sound
							mob_sound(self, "attack")

							-- punch player (or what player is attached to)
							local attached = self.attack:get_attach()
							if attached then
								self.attack = attached
							end
							self.attack:punch(self.object, 1.0, {
								full_punch_interval = 1.0,
								damage_groups = {fleshy = self.damage}
							}, nil)
						end
					end
				else	-- call custom attack every second
					if self.custom_attack
					and self.timer > 1 then

						self.timer = 0

						self.custom_attack(self, p)
					end
				end
			end

		elseif self.attack_type == "shoot"
		or (self.attack_type == "dogshoot" and dogswitch(self, dtime) == 1)
		or (self.attack_type == "dogshoot" and dist > self.reach and dogswitch(self) == 0) then

			p.y = p.y - .5
			s.y = s.y + .5

			local dist = vector.distance(p, s)
			local vec = {
				x = p.x - s.x,
				y = p.y - s.y,
				z = p.z - s.z
			}

			yaw = (atan(vec.z / vec.x) + math_pi / 2) - self.rotate

			if p.x > s.x then yaw = yaw + math_pi end

			yaw = set_yaw(self, yaw, 0, dtime)

			set_velocity(self, 0)

			local p = self.object:get_pos()
			p.y = p.y + (self.collisionbox[2] + self.collisionbox[5]) / 2

			if self.shoot_interval
			and self.timer > self.shoot_interval
			and not minetest_raycast(p, self.attack:get_pos(), false, false):next()
			and math_random(1, 100) <= 60 then

				self.timer = 0
				set_animation(self, "shoot")

				-- play shoot attack sound
				mob_sound(self, "shoot_attack")

				-- Shoot arrow
				if minetest_registered_entities[self.arrow] then

					local arrow, ent
					local v = 1
					if not self.shoot_arrow then
						self.firing = true
						minetest_after(1, function()
							self.firing = false
						end)
						arrow = minetest_add_entity(p, self.arrow)
						ent = arrow:get_luaentity()
						if ent.velocity then
							v = ent.velocity
						end
						ent.switch = 1
						ent.owner_id = tostring(self.object) -- add unique owner id to arrow
					end

					local amount = (vec.x * vec.x + vec.y * vec.y + vec.z * vec.z) ^ 0.5
					-- offset makes shoot aim accurate
					vec.y = vec.y + self.shoot_offset
					vec.x = vec.x * (v / amount)
					vec.y = vec.y * (v / amount)
					vec.z = vec.z * (v / amount)
					if self.shoot_arrow then
						vec = vector.normalize(vec)
						self:shoot_arrow(p, vec)
					else
						arrow:set_velocity(vec)
					end
				end
			end
		end
	end
end


	mobs.death_effect = function(pos, yaw, collisionbox, rotate)
		local min, max
		if collisionbox then
			min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
			max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
		else
			min = { x = -0.5, y = 0, z = -0.5 }
			max = { x = 0.5, y = 0.5, z = 0.5 }
		end
		if rotate then
			min = vector.rotate(min, {x=0, y=yaw, z=math_pi/2})
			max = vector.rotate(max, {x=0, y=yaw, z=math_pi/2})
			min, max = vector.sort(min, max)
			min = vector.multiply(min, 0.5)
			max = vector.multiply(max, 0.5)
		end
	
		minetest_add_particlespawner({
			amount = 50,
			time = 0.001,
			minpos = vector.add(pos, min),
			maxpos = vector.add(pos, max),
			minvel = vector.new(-5,-5,-5),
			maxvel = vector.new(5,5,5),
			minexptime = 1.1,
			maxexptime = 1.5,
			minsize = 1,
			maxsize = 2,
			collisiondetection = false,
			vertical = false,
			texture = "mcl_particles_mob_death.png^[colorize:#000000:255",
		})
	
		minetest_sound_play("mcl_mobs_mob_poof", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 8,
		}, true)
	end
	
-- above function exported for mount.lua
function mobs:set_animation(self, anim)
	set_animation(self, anim)
end


-- set defined animation
local set_animation = function(self, anim, fixed_frame)
	if not self.animation or not anim then
		return
	end
	if self.state == "die" and anim ~= "die" and anim ~= "stand" then
		return
	end

	self.animation.current = self.animation.current or ""

	if (anim == self.animation.current
	or not self.animation[anim .. "_start"]
	or not self.animation[anim .. "_end"]) and self.state ~= "die" then
		return
	end

	self.animation.current = anim

	local a_start = self.animation[anim .. "_start"]
	local a_end
	if fixed_frame then
		a_end = a_start
	else
		a_end = self.animation[anim .. "_end"]
	end

	self.object:set_animation({
		x = a_start,
		y = a_end},
		self.animation[anim .. "_speed"] or self.animation.speed_normal or 15,
		0, self.animation[anim .. "_loop"] ~= false)
end


-- Code to execute before custom on_rightclick handling
local on_rightclick_prefix = function(self, clicker)
	local item = clicker:get_wielded_item()

	-- Name mob with nametag
	if not self.ignores_nametag and item:get_name() == "mcl_mobs:nametag" then

		local tag = item:get_meta():get_string("name")
		if tag ~= "" then
			if string.len(tag) > MAX_MOB_NAME_LENGTH then
				tag = string.sub(tag, 1, MAX_MOB_NAME_LENGTH)
			end
			self.nametag = tag

			update_tag(self)

			if not mobs.is_creative(clicker:get_player_name()) then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			return true
		end

	end
	return false
end

local create_mob_on_rightclick = function(on_rightclick)
	return function(self, clicker)
		local stop = on_rightclick_prefix(self, clicker)
		if (not stop) and (on_rightclick) then
			on_rightclick(self, clicker)
		end
	end
end

-- set and return valid yaw
local set_yaw = function(self, yaw, delay, dtime)

	if not yaw or yaw ~= yaw then
		yaw = 0
	end

	delay = delay or 0

	if delay == 0 then
		if self.shaking and dtime then
			yaw = yaw + (math_random() * 2 - 1) * 5 * dtime
		end
		self.yaw(yaw)
		update_roll(self)
		return yaw
	end

	self.target_yaw = yaw
	self.delay = delay

	return self.target_yaw
end


-- global function to set mob yaw
function mobs:yaw(self, yaw, delay, dtime)
	set_yaw(self, yaw, delay, dtime)
end


mob_step = function()

	--if self.state == "die" then
	--	print("need custom die stop moving thing")
	--	return
	--end

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