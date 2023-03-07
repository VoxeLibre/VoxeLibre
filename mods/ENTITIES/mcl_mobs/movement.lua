local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
local DEFAULT_FALL_SPEED = -9.81*1.5
local FLOP_HEIGHT = 6
local FLOP_HOR_SPEED = 1.5

local node_snow = "mcl_core:snow"


local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

local atann = math.atan
local function atan(x)
	if not x or x ~= x then
		return 0
	else
		return atann(x)
	end
end

local registered_fallback_node = minetest.registered_nodes[mcl_mobs.fallback_node]

-- get node but use fallback for nil or unknown
local node_ok = function(pos, fallback)
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	if fallback then
		return minetest.registered_nodes[fallback]
	else
		return registered_fallback_node
	end
end

-- Returns true is node can deal damage to self
function mob_class:is_node_dangerous(nodename)
	local nn = nodename
	if self.lava_damage > 0 then
		if minetest.get_item_group(nn, "lava") ~= 0 then
			return true
		end
	end
	if self.fire_damage > 0 then
		if minetest.get_item_group(nn, "fire") ~= 0 then
			return true
		end
	end
	if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].damage_per_second and minetest.registered_nodes[nn].damage_per_second > 0 then
		return true
	end
	return false
end


-- Returns true if node is a water hazard
function mob_class:is_node_waterhazard(nodename)
	local nn = nodename
	if self.water_damage > 0 then
		if minetest.get_item_group(nn, "water") ~= 0 then
			return true
		end
	end
	if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].drowning and minetest.registered_nodes[nn].drowning > 0 then
		if self.breath_max ~= -1 then
			-- check if the mob is water-breathing _and_ the block is water; only return true if neither is the case
			-- this will prevent water-breathing mobs to classify water or e.g. sand below them as dangerous
			if not self.breathes_in_water and minetest.get_item_group(nn, "water") ~= 0 then
				return true
			end
		end
	end
	return false
end

-- check line of sight (BrunoMine)
function mob_class:line_of_sight(pos1, pos2, stepsize)

	stepsize = stepsize or 1

	local s, pos = minetest.line_of_sight(pos1, pos2, stepsize)

	-- normal walking and flying mobs can see you through air
	if s == true then
		return true
	end

	-- New pos1 to be analyzed
	local npos1 = {x = pos1.x, y = pos1.y, z = pos1.z}

	local r, pos = minetest.line_of_sight(npos1, pos2, stepsize)

	-- Checks the return
	if r == true then return true end

	-- Nodename found
	local nn = minetest.get_node(pos).name

	-- Target Distance (td) to travel
	local td = vector.distance(pos1, pos2)

	-- Actual Distance (ad) traveled
	local ad = 0

	-- It continues to advance in the line of sight in search of a real
	-- obstruction which counts as 'normal' nodebox.
	while minetest.registered_nodes[nn]
	and minetest.registered_nodes[nn].walkable == false do

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
		r, pos = minetest.line_of_sight(npos1, pos2, stepsize)

		if r == true then return true end

		-- New Nodename found
		nn = minetest.get_node(pos).name

	end

	return false
end

function mob_class:can_jump_cliff()
	local yaw = self.object:get_yaw()
	local pos = self.object:get_pos()
	local v = self.object:get_velocity()

	local v2 = math.abs(v.x)+math.abs(v.z)*.833
	local jump_c_multiplier = 1
	if v2/self.walk_velocity/2>1 then
		jump_c_multiplier = v2/self.walk_velocity/2
	end

	-- where is front
	local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)*jump_c_multiplier+0.6
	local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)*jump_c_multiplier+0.6

	--is there nothing under the block in front? if so jump the gap.
	local nodLow = node_ok({
		x = pos.x + dir_x-0.6,
		y = pos.y - 0.5,
		z = pos.z + dir_z-0.6
	}, "air")

	local nodFar = node_ok({
		x = pos.x + dir_x*2,
		y = pos.y - 0.5,
		z = pos.z + dir_z*2
	}, "air")

	local nodFar2 = node_ok({
		x = pos.x + dir_x*2.5,
		y = pos.y - 0.5,
		z = pos.z + dir_z*2.5
	}, "air")


	if minetest.registered_nodes[nodLow.name]
	and minetest.registered_nodes[nodLow.name].walkable ~= true


	and (minetest.registered_nodes[nodFar.name]
	and minetest.registered_nodes[nodFar.name].walkable == true

	or minetest.registered_nodes[nodFar2.name]
	and minetest.registered_nodes[nodFar2.name].walkable == true)

	then
		--disable fear heigh while we make our jump
		self._jumping_cliff = true
		minetest.after(1, function()
			if self and self.object then
				self._jumping_cliff = false
			end
		end)
		return true
	else
		return false
	end
end

-- is mob facing a cliff or danger
function mob_class:is_at_cliff_or_danger(can_jump_cliff)
	if can_jump_cliff == nil then
		can_jump_cliff = self:can_jump_cliff()
	end

	if self.fear_height == 0 or can_jump_cliff or self._jumping_cliff or not self.object:get_luaentity() then -- 0 for no falling protection!
		return false
	end

	local yaw = self.object:get_yaw()
	local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)

	local pos = self.object:get_pos()
	local ypos = pos.y + self.collisionbox[2] -- just above floor

	local free_fall, blocker = minetest.line_of_sight(
		{x = pos.x + dir_x, y = ypos, z = pos.z + dir_z},
		{x = pos.x + dir_x, y = ypos - self.fear_height, z = pos.z + dir_z})
	if free_fall then
		return true
	else
		local bnode = minetest.get_node(blocker)
		local danger = self:is_node_dangerous(bnode.name)
		if danger then
			return true
		else
			local def = minetest.registered_nodes[bnode.name]
			if def and def.walkable then
				return false
			end
		end
	end

	return false
end


-- copy the 'mob facing cliff_or_danger check' from above, and rework to avoid water
function mob_class:is_at_water_danger(can_jump_cliff)
	if can_jump_cliff == nil then
		can_jump_cliff = self:can_jump_cliff()
	end

	if not self.object:get_luaentity() or can_jump_cliff or self._jumping_cliff then
		return false
	end
	local yaw = self.object:get_yaw()
	local pos = self.object:get_pos()

	if not yaw or not pos then
		return
	end

	local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)

	local ypos = pos.y + self.collisionbox[2] -- just above floor

	local free_fall, blocker = minetest.line_of_sight(
		{x = pos.x + dir_x, y = ypos, z = pos.z + dir_z},
		{x = pos.x + dir_x, y = ypos - 3, z = pos.z + dir_z})
	if free_fall then
		return true
	else
		local bnode = minetest.get_node(blocker)
		local waterdanger = self:is_node_waterhazard(bnode.name)
		if
			waterdanger and (self:is_node_waterhazard(self.standing_in) or self:is_node_waterhazard( self.standing_on)) then
			return false
		elseif waterdanger and (self:is_node_waterhazard(self.standing_in) or self:is_node_waterhazard(self.standing_on)) == false then
			return true
		else
			local def = minetest.registered_nodes[bnode.name]
			if def and def.walkable then
				return false
			end
		end
	end

	return false
end

function mob_class:env_danger_movement_checks(dtime)
	local yaw = 0

	local can_jump_cliff = self:can_jump_cliff()
	if self.state ~= "attack" and self:is_at_water_danger(can_jump_cliff) then
		if math.random(1, 10) <= 6 then
			self:set_velocity(0)
			self.state = "stand"
			self:set_animation( "stand")
			yaw = yaw + math.random(-0.5, 0.5)
			yaw = self:set_yaw( yaw, 8)
		end
	end

	if self:is_at_cliff_or_danger(can_jump_cliff) then
		self:set_velocity(0)
		self.state = "stand"
		self:set_animation( "stand")
		local yaw = self.object:get_yaw() or 0
		yaw = self:set_yaw( yaw + 0.78, 8)
	end
end

-- jump if facing a solid node (not fences or gates)
function mob_class:do_jump()
	if not self.jump
	or self.jump_height == 0
	or self.fly
	or self.order == "stand" then
		return false
	end

	self.facing_fence = false

	-- something stopping us while moving?
	if self.state ~= "stand"
	and self:get_velocity() > 0.5
	and self.object:get_velocity().y ~= 0 then
		return false
	end

	local pos = self.object:get_pos()
	local yaw = self.object:get_yaw()

	-- what is mob standing on?
	pos.y = pos.y + self.collisionbox[2] - 0.2

	local nod = node_ok(pos)

	if minetest.registered_nodes[nod.name].walkable == false then
		return false
	end

	local v = self.object:get_velocity()
	local v2 = math.abs(v.x)+math.abs(v.z)*.833
	local jump_c_multiplier = 1
	if v2/self.walk_velocity/2>1 then
		jump_c_multiplier = v2/self.walk_velocity/2
	end

	-- where is front
	local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)*jump_c_multiplier+0.6
	local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)*jump_c_multiplier+0.6

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
	if minetest.registered_nodes[nodTop.name].walkable == true and not (self.attack and self.state == "attack") then
		return false
	end

	-- thin blocks that do not need to be jumped
	if nod.name == node_snow then
		return false
	end

	local ndef = minetest.registered_nodes[nod.name]
	if self.walk_chance == 0 or ndef and ndef.walkable or self:can_jump_cliff() then

		if minetest.get_item_group(nod.name, "fence") == 0
		and minetest.get_item_group(nod.name, "fence_gate") == 0
		and minetest.get_item_group(nod.name, "wall") == 0 then

			local v = self.object:get_velocity()

			v.y = self.jump_height + 0.1 * 3

			if self:can_jump_cliff() then
				v=vector.multiply(v, vector.new(2.8,1,2.8))
			end

			self:set_animation( "jump") -- only when defined

			self.object:set_velocity(v)

			-- when in air move forward
			minetest.after(0.3, function(self, v)
				if (not self.object) or (not self.object:get_luaentity()) or (self.state == "die") then
					return
				end
				self.object:set_acceleration({
					x = v.x * 2,
					y = DEFAULT_FALL_SPEED,
					z = v.z * 2,
				})
			end, self, v)

			if self.jump_sound_cooloff <= 0 then
				self:mob_sound("jump")
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

				yaw = self:set_yaw( yaw + 1.35, 8)

				self.jump_count = 0
			end
		end

		return true
	end

	return false
end

-- should mob follow what I'm holding ?
function mob_class:follow_holding(clicker)
	if self.nofollow then return false end

	if mcl_mobs.invis[clicker:get_player_name()] then
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


-- find and replace what mob is looking for (grass, wheat etc.)
function mob_class:replace_node(pos)

	if not self.replace_rate
	or not self.replace_what
	or self.child == true
	or self.object:get_velocity().y ~= 0
	or math.random(1, self.replace_rate) > 1 then
		return
	end

	local what, with, y_offset

	if type(self.replace_what[1]) == "table" then

		local num = math.random(#self.replace_what)

		what = self.replace_what[num][1] or ""
		with = self.replace_what[num][2] or ""
		y_offset = self.replace_what[num][3] or 0
	else
		what = self.replace_what
		with = self.replace_with or ""
		y_offset = self.replace_offset or 0
	end

	pos.y = pos.y + y_offset

	local node = minetest.get_node(pos)
	if node.name == what then

		local oldnode = {name = what, param2 = node.param2}
		local newnode = {name = with, param2 = node.param2}
		local on_replace_return

		if self.on_replace then
			on_replace_return = self.on_replace(self, pos, oldnode, newnode)
		end

		if on_replace_return ~= false then

			if mobs_griefing then
				minetest.set_node(pos, newnode)
			end

		end
	end
end

-- specific runaway
local specific_runaway = function(list, what)
	if type(list) ~= "table" then
		list = {}
	end

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


-- find someone to runaway from
function mob_class:check_runaway_from()
	if not self.runaway_from and self.state ~= "flop" then
		return
	end

	local s = self.object:get_pos()
	local p, sp, dist
	local player, obj, min_player
	local type, name = "", ""
	local min_dist = self.view_range + 1
	local objs = minetest.get_objects_inside_radius(s, self.view_range)

	for n = 1, #objs do

		if objs[n]:is_player() then

			if mcl_mobs.invis[ objs[n]:get_player_name() ]
			or self.owner == objs[n]:get_player_name()
			or (not self:object_in_range(objs[n])) then
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
			and self:line_of_sight(sp, p, 2) == true then
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

		local yaw = (atan(vec.z / vec.x) + 3 *math.pi/ 2) - self.rotate

		if lp.x > s.x then
			yaw = yaw + math.pi
		end

		yaw = self:set_yaw( yaw, 4)
		self.state = "runaway"
		self.runaway_timer = 3
		self.following = nil
	end
end


-- follow player if owner or holding item, if fish outta water then flop
function mob_class:check_follow()
	-- find player to follow
	if (self.follow ~= "" or self.order == "follow") and not self.following
	and self.state ~= "attack"
	and self.order ~= "sit"
	and self.state ~= "runaway" then
		local s = self.object:get_pos()
		local players = minetest.get_connected_players()
		for n = 1, #players do
			if (self:object_in_range(players[n])) and not mcl_mobs.invis[ players[n]:get_player_name() ] then
				self.following = players[n]
				break
			end
		end
	end

	if self.type == "npc" and self.order == "follow"
			and self.state ~= "attack" and self.order ~= "sit" and self.owner ~= "" then

		if self.following and self.owner and self.owner ~= self.following:get_player_name() then
			self.following = nil
		end
	else
		-- stop following player if not holding specific item,
		-- mob is horny, fleeing or attacking
		if self.following and self.following:is_player()
				and (self:follow_holding(self.following) == false or self.horny or self.state == "runaway") then
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

			if (not self:object_in_range(self.following)) then
				self.following = nil
			else
				local vec = {
					x = p.x - s.x,
					z = p.z - s.z
				}

				local yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate
				if p.x > s.x then yaw = yaw +math.pi end
				self:set_yaw( yaw, 2.35)

				-- anyone but standing npc's can move along
				if dist > 3 and self.order ~= "stand" then
 					self:set_velocity(self.follow_velocity)
					if self.walk_chance ~= 0 then
						self:set_animation( "run")
					end
				else
					self:set_velocity(0)
					self:set_animation( "stand")
				end
				return
			end
		end
	end
end

function mob_class:flop()
	-- swimmers flop when out of their element, and swim again when back in
	if self.fly then
		local s = self.object:get_pos()

		if self:flight_check(s) == false then
			self.state = "flop"
			self.object:set_acceleration({x = 0, y = DEFAULT_FALL_SPEED, z = 0})

			local p = self.object:get_pos()
			local sdef = minetest.registered_nodes[node_ok(vector.add(p, vector.new(0,self.collisionbox[2]-0.2,0))).name]
			-- Flop on ground
			if sdef and sdef.walkable then
				if self.object:get_velocity().y < 0.1 then
					self:mob_sound("flop")
					self.object:set_velocity({
						x = math.random(-FLOP_HOR_SPEED, FLOP_HOR_SPEED),
						y = FLOP_HEIGHT,
						z = math.random(-FLOP_HOR_SPEED, FLOP_HOR_SPEED),
					})
				end
			end

			self:set_animation( "stand", true)
			return
		elseif self.state == "flop" then
			self.state = "stand"
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self:set_velocity(0)
		end
	end
end

function mob_class:go_to_pos(b)
	if not self then return end
	local s=self.object:get_pos()
	if not b then
		--self.state = "stand"
		return end
	if vector.distance(b,s) < 1 then
		--self:set_velocity(0)
		return true
	end
	local v = { x = b.x - s.x, z = b.z - s.z }
	local yaw = (atann(v.z / v.x) +math.pi/ 2) - self.rotate
	if b.x > s.x then yaw = yaw +math.pi end
	self.object:set_yaw(yaw)
	self:set_velocity(self.follow_velocity)
	self:set_animation("walk")
end

local check_herd_timer = 0
function mob_class:check_herd(dtime)
	local pos = self.object:get_pos()
	if not pos or self.state == "attack" then return end
	-- Does any mob not move in group. Weird check for something not set?
	if self.move_in_group == false then return end

	check_herd_timer = check_herd_timer + dtime
	if check_herd_timer < 4 then return end
	check_herd_timer = 0
	for _,o in pairs(minetest.get_objects_inside_radius(pos,self.view_range)) do
		local l = o:get_luaentity()
		local p,y
		if l and l.is_mob and l.name == self.name then
			if self.horny and l.horny then
				p = l.object:get_pos()
			else
				y = o:get_yaw()
			end
			if p then
				self:go_to_pos(p)
			elseif y then
				self:set_yaw(y)
			end
		end
	end
end

function mob_class:teleport(target)
	if self.do_teleport then
		if self.do_teleport(self, target) == false then
			return
		end
	end
end

function mob_class:do_states_walk()
	local yaw = self.object:get_yaw() or 0

	local s = self.object:get_pos()
	local lp = nil

	-- is there something I need to avoid?
	if (self.water_damage > 0
			and self.lava_damage > 0)
			or self.breath_max ~= -1 then
		lp = minetest.find_node_near(s, 1, {"group:water", "group:lava"})
	elseif self.water_damage > 0 then
		lp = minetest.find_node_near(s, 1, {"group:water"})
	elseif self.lava_damage > 0 then
		lp = minetest.find_node_near(s, 1, {"group:lava"})
	elseif self.fire_damage > 0 then
		lp = minetest.find_node_near(s, 1, {"group:fire"})
	end

	local is_in_danger = false
	if lp then
		-- If mob in or on dangerous block, look for land
		if (self:is_node_dangerous(self.standing_in) or
				self:is_node_dangerous(self.standing_on)) or (self:is_node_waterhazard(self.standing_in) or self:is_node_waterhazard(self.standing_on)) and (not self.fly) then
			is_in_danger = true

			-- If mob in or on dangerous block, look for land
			if is_in_danger then
				-- Better way to find shore - copied from upstream
				lp = minetest.find_nodes_in_area_under_air(
						{x = s.x - 5, y = s.y - 0.5, z = s.z - 5},
						{x = s.x + 5, y = s.y + 1, z = s.z + 5},
						{"group:solid"})

				lp = #lp > 0 and lp[math.random(#lp)]

				-- did we find land?
				if lp then

					local vec = {
						x = lp.x - s.x,
						z = lp.z - s.z
					}

					yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate


					if lp.x > s.x  then yaw = yaw +math.pi end

					-- look towards land and move in that direction
					yaw = self:set_yaw( yaw, 6)
					self:set_velocity(self.walk_velocity)

				end
			end

			-- A danger is near but mob is not inside
		else

			-- Randomly turn
			if math.random(1, 100) <= 30 then
				yaw = yaw + math.random(-0.5, 0.5)
				yaw = self:set_yaw( yaw, 8)
			end
		end

		yaw = self:set_yaw( yaw, 8)

		-- otherwise randomly turn
	elseif math.random(1, 100) <= 30 then
		yaw = yaw + math.random(-0.5, 0.5)
		yaw = self:set_yaw( yaw, 8)
	end

	-- stand for great fall or danger or fence in front
	local cliff_or_danger = false
	if is_in_danger then
		cliff_or_danger = self:is_at_cliff_or_danger()
	end
	if self.facing_fence == true
			or cliff_or_danger
			or math.random(1, 100) <= 30 then

		self:set_velocity(0)
		self.state = "stand"
		self:set_animation( "stand")
		local yaw = self.object:get_yaw() or 0
		yaw = self:set_yaw( yaw + 0.78, 8)
	else

		self:set_velocity(self.walk_velocity)

		if self:flight_check()
				and self.animation
				and self.animation.fly_start
				and self.animation.fly_end then
			self:set_animation( "fly")
		else
			self:set_animation( "walk")
		end
	end
end

function mob_class:do_states_stand()
	local yaw = self.object:get_yaw() or 0

	if math.random(1, 4) == 1 then

		local s = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(s, 3)
		local lp
		for n = 1, #objs do
			if objs[n]:is_player() then
				lp = objs[n]:get_pos()
				break
			end
		end

		-- look at any players nearby, otherwise turn randomly
		if lp and self.look_at_players then

			local vec = {
				x = lp.x - s.x,
				z = lp.z - s.z
			}

			yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate

			if lp.x > s.x then yaw = yaw +math.pi end
		else
			yaw = yaw + math.random(-0.5, 0.5)
		end

		yaw = self:set_yaw( yaw, 8)
	end
	if self.order == "sit" then
		self:set_animation( "sit")
		self:set_velocity(0)
	else
		self:set_animation( "stand")
		self:set_velocity(0)
	end

	-- npc's ordered to stand stay standing
	if self.order == "stand" or self.order == "sleep" or self.order == "work" then

	else
		if self.walk_chance ~= 0
				and self.facing_fence ~= true
				and math.random(1, 100) <= self.walk_chance
				and self:is_at_cliff_or_danger() == false then

			self:set_velocity(self.walk_velocity)
			self.state = "walk"
			self:set_animation( "walk")
		end
	end
end

function mob_class:do_states_runaway()
	local yaw = self.object:get_yaw() or 0

	self.runaway_timer = self.runaway_timer + 1

	-- stop after 5 seconds or when at cliff
	if self.runaway_timer > 5
			or self:is_at_cliff_or_danger() then
		self.runaway_timer = 0
		self:set_velocity(0)
		self.state = "stand"
		self:set_animation( "stand")
		local yaw = self.object:get_yaw() or 0
		yaw = self:set_yaw( yaw + 0.78, 8)
	else
		self:set_velocity( self.run_velocity)
		self:set_animation( "run")
	end
end






function mob_class:check_smooth_rotation(dtime)
	-- smooth rotation by ThomasMonroe314
	if self._turn_to then
		self:set_yaw( self._turn_to, .1)
	end

	if self.delay and self.delay > 0 then

		local yaw = self.object:get_yaw() or 0

		if self.delay == 1 then
			yaw = self.target_yaw
		else
			local dif = math.abs(yaw - self.target_yaw)

			if yaw > self.target_yaw then

				if dif > math.pi then
					dif = 2 * math.pi - dif -- need to add
					yaw = yaw + dif / self.delay
				else
					yaw = yaw - dif / self.delay -- need to subtract
				end

			elseif yaw < self.target_yaw then

				if dif >math.pi then
					dif = 2 * math.pi - dif
					yaw = yaw - dif / self.delay -- need to subtract
				else
					yaw = yaw + dif / self.delay -- need to add
				end
			end

			if yaw > (math.pi * 2) then yaw = yaw - (math.pi * 2) end
			if yaw < 0 then yaw = yaw + (math.pi * 2) end
		end

		self.delay = self.delay - 1
		if self.shaking then
			yaw = yaw + (math.random() * 2 - 1) * 5 * dtime
		end
		self.object:set_yaw(yaw)
		--self:update_roll()
	end
	-- end rotation
end
