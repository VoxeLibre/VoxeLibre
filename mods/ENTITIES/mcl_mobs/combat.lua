local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class

-- pathfinding settings
local enable_pathfinding = true
local stuck_timeout = 3 -- how long before mob gets stuck in place and starts searching
local stuck_path_timeout = 10 -- how long will mob follow path before giving up

-- attack player/mob
function mob_class:do_attack(player)

	if self.state == "attack" or self.state == "die" then
		return
	end

	self.attack = player
	self.state = "attack"

	-- TODO: Implement war_cry sound without being annoying
	--if random(0, 100) < 90 then
		--self:mob_sound("war_cry", true)
	--end
end

-- blast damage to entities nearby
local function entity_physics(pos,radius)

	radius = radius * 2

	local objs = minetest.get_objects_inside_radius(pos, radius)
	local obj_pos, dist

	for n = 1, #objs do

		obj_pos = objs[n]:get_pos()

		dist = vector.distance(pos, obj_pos)
		if dist < 1 then dist = 1 end

		local damage = math.floor((4 / dist) * radius)
		local ent = objs[n]:get_luaentity()

		-- punches work on entities AND players
		objs[n]:punch(objs[n], 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = damage},
		}, pos)
	end
end

function mob_class:entity_physics(self,pos,radius) return entity_physics(pos,radius) end

local los_switcher = false
local height_switcher = false

-- path finding and smart mob routine by rnd, line_of_sight and other edits by Elkien3
function mob_class:smart_mobs(s, p, dist, dtime)

	local s1 = self.path.lastpos

	local target_pos = self.attack:get_pos()

	-- is it becoming stuck?
	if math.abs(s1.x - s.x) + math.abs(s1.z - s.z) < .5 then
		self.path.stuck_timer = self.path.stuck_timer + dtime
	else
		self.path.stuck_timer = 0
	end

	self.path.lastpos = {x = s.x, y = s.y, z = s.z}

	local use_pathfind = false
	local has_lineofsight = minetest.line_of_sight(
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

			minetest.after(1, function(self)
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

		minetest.after(1, function(self)
			if not self.object:get_luaentity() then
				return
			end
			if has_lineofsight then self.path.following = false end
		end, self)
	end

	if (self.path.stuck_timer > stuck_path_timeout and self.path.following) then

		use_pathfind = true
		self.path.stuck_timer = 0

		minetest.after(1, function(self)
			if not self.object:get_luaentity() then
				return
			end
			if has_lineofsight then self.path.following = false end
		end, self)
	end

	if math.abs(vector.subtract(s,target_pos).y) > self.stepheight then

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
		s.x = math.floor(s.x + 0.5)
		s.z = math.floor(s.z + 0.5)

		local ssight, sground = minetest.line_of_sight(s, {
			x = s.x, y = s.y - 4, z = s.z}, 1)

		-- determine node above ground
		if not ssight then
			s.y = sground.y + 1
		end

		local p1 = self.attack:get_pos()

		p1.x = math.floor(p1.x + 0.5)
		p1.y = math.floor(p1.y + 0.5)
		p1.z = math.floor(p1.z + 0.5)

		local dropheight = 12
		if self.fear_height ~= 0 then dropheight = self.fear_height end
		local jumpheight = 0
		if self.jump and self.jump_height >= 4 then
			jumpheight = math.min(math.ceil(self.jump_height / 4), 4)
		elseif self.stepheight > 0.5 then
			jumpheight = 1
		end
		self.path.way = minetest.find_path(s, p1, 16, jumpheight, dropheight, "A*_noprefetch")

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
					if not minetest.is_protected(s, "") then

						local ndef1 = minetest.registered_nodes[self.standing_in]

						if ndef1 and (ndef1.buildable_to or ndef1.groups.liquid) then

								minetest.set_node(s, {name = mcl_mobs.fallback_node})
						end
					end

					local sheight = math.ceil(self.collisionbox[5]) + 1

					-- assume mob is 2 blocks high so it digs above its head
					s.y = s.y + sheight

					-- remove one block above to make room to jump
					if not minetest.is_protected(s, "") then

						local node1 = node_ok(s, "air").name
						local ndef1 = minetest.registered_nodes[node1]

						if node1 ~= "air"
						and node1 ~= "ignore"
						and ndef1
						and not ndef1.groups.level
						and not ndef1.groups.unbreakable
						and not ndef1.groups.liquid then

							minetest.set_node(s, {name = "air"})
							minetest.add_item(s, ItemStack(node1))

						end
					end

					s.y = s.y - sheight
					self.object:set_pos({x = s.x, y = s.y + 2, z = s.z})

				else -- dig 2 blocks to make door toward player direction

					local yaw1 = self.object:get_yaw() + math.pi / 2
					local p1 = {
						x = s.x + math.cos(yaw1),
						y = s.y,
						z = s.z + math.sin(yaw1)
					}

					if not minetest.is_protected(p1, "") then

						local node1 = node_ok(p1, "air").name
						local ndef1 = minetest.registered_nodes[node1]

						if node1 ~= "air"
							and node1 ~= "ignore"
							and ndef1
							and not ndef1.groups.level
							and not ndef1.groups.unbreakable
							and not ndef1.groups.liquid then

							minetest.add_item(p1, ItemStack(node1))
							minetest.set_node(p1, {name = "air"})
						end

						p1.y = p1.y + 1
						node1 = node_ok(p1, "air").name
						ndef1 = minetest.registered_nodes[node1]

						if node1 ~= "air"
						and node1 ~= "ignore"
						and ndef1
						and not ndef1.groups.level
						and not ndef1.groups.unbreakable
						and not ndef1.groups.liquid then

							minetest.add_item(p1, ItemStack(node1))
							minetest.set_node(p1, {name = "air"})
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
			--self:mob_sound("war_cry", true)
		else
			self:set_velocity(self.walk_velocity)

			-- follow path now that it has it
			self.path.following = true
		end
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

-- find someone to attack
function mob_class:monster_attack()
	if not damage_enabled
	or self.passive ~= false
	or self.state == "attack"
	or day_docile(self) then
		return
	end

	local s = self.object:get_pos()
	local p, sp, dist
	local player, obj, min_player
	local type, name = "", ""
	local min_dist = self.view_range + 1
	local objs = minetest.get_objects_inside_radius(s, self.view_range)
	local blacklist_attack = {}

	for n = 1, #objs do
		if not objs[n]:is_player() then
			obj = objs[n]:get_luaentity()

			if obj then
				player = obj.object
				name = obj.name or ""
			end
			if obj and obj.type == self.type and obj.passive == false and obj.state == "attack" and obj.attack then
				table.insert(blacklist_attack, obj.attack)
			end
		end
	end

	for n = 1, #objs do


		if objs[n]:is_player() then
			if mcl_mobs.invis[ objs[n]:get_player_name() ] or (not self:object_in_range(objs[n])) then
				type = ""
			elseif (self.type == "monster" or self._aggro) then
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
		and (type == "player" or ( type == "npc" and self.attack_npcs )
			or (type == "animal" and self.attack_animals == true)) then

			p = player:get_pos()
			sp = s

			dist = vector.distance(p, s)

			-- aim higher to make looking up hills more realistic
			p.y = p.y + 1
			sp.y = sp.y + 1

			local attacked_p = false
			for c=1, #blacklist_attack do
				if blacklist_attack[c] == player then
					attacked_p = true
				end
			end
			-- choose closest player to attack
			if dist < min_dist
			and not attacked_p
			and self:line_of_sight( sp, p, 2) == true then
				min_dist = dist
				min_player = player
			end
		end
	end
	if not min_player and #blacklist_attack > 0 then
		min_player=blacklist_attack[math.random(#blacklist_attack)]
	end
	-- attack player
	if min_player then
		self:do_attack(min_player)
	end
end


-- npc, find closest monster to attack
function mob_class:npc_attack()

	if self.type ~= "npc"
	or not self.attacks_monsters
	or self.state == "attack" then
		return
	end

	local p, sp, obj, min_player
	local s = self.object:get_pos()
	local min_dist = self.view_range + 1
	local objs = minetest.get_objects_inside_radius(s, self.view_range)

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
			and self:line_of_sight( sp, p, 2) == true then
				min_dist = dist
				min_player = obj.object
			end
		end
	end

	if min_player then
		self:do_attack(min_player)
	end
end



-- dogshoot attack switch and counter function
function mob_class:dogswitch(dtime)

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

-- no damage to nodes explosion
function mob_class:safe_boom(pos, strength)
	minetest.sound_play(self.sounds and self.sounds.explode or "tnt_explode", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = self.sounds and self.sounds.distance or 32
	}, true)
	local radius = strength
	entity_physics(pos, radius)
	mcl_mobs.effect(pos, 32, "mcl_particles_smoke.png", radius * 3, radius * 5, radius, 1, 0)
end


-- make explosion with protection and tnt mod check
function mob_class:boom(pos, strength, fire)
	if mobs_griefing and not minetest.is_protected(pos, "") then
		mcl_explosions.explode(pos, strength, { drop_chance = 1.0, fire = fire }, self.object)
	else
		mcl_mobs.mob_class.safe_boom(self, pos, strength) --need to call it this way bc self is the "arrow" object here
	end

	-- delete the object after it punched the player to avoid nil entities in e.g. mcl_shields!!
	self.object:remove()
end
