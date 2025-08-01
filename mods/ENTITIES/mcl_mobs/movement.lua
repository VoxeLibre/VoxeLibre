local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
local DEFAULT_FALL_SPEED = -9.81*1.5
local FLOP_HEIGHT = 6
local FLOP_HOR_SPEED = 1.5

local CHECK_HERD_FREQUENCY = 4

local PATHFINDING = "gowp"

local node_snow = "mcl_core:snow"

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local logging = minetest.settings:get_bool("mcl_logging_mobs_movement", false)

local random = math.random
local sin = math.sin
local cos = math.cos
local abs = math.abs
local floor = math.floor
local PI = math.pi
local TWOPI = 2 * math.pi
local HALFPI = 0.5 * math.pi
local QUARTERPI = 0.25 * math.pi

local vector_new = vector.new
local vector_zero = vector.zero
local vector_copy = vector.copy
local vector_offset = vector.offset
local vector_distance = vector.distance
local raycast_line_of_sight = mcl_mobs.check_line_of_sight

local registered_fallback_node = minetest.registered_nodes[mcl_mobs.fallback_node]

-- Stop movement and stand
function mob_class:stand()
	self:set_velocity(0)
	self.state = "stand"
	self:set_animation("stand")
end

-- get node but use fallback for nil or unknown
local node_ok = function(pos, fallback)
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then return node end
	return fallback and minetest.registered_nodes[fallback] or registered_fallback_node
end

-- Returns true is node can deal damage to self
function mob_class:is_node_dangerous(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef and (
          (self.lava_damage > 0 and ndef.groups.lava)
	   or (self.fire_damage > 0 and ndef.groups.fire)
	   or ((ndef.damage_per_second or 0) > 0))
end

-- Returns true if node is a water hazard
function mob_class:is_node_waterhazard(nodename)
	local ndef = minetest.registered_nodes[nodename]
	return ndef	and ndef.groups.water and (
          (self.water_damage > 0)
	   or (not self.breathes_in_water and self.initial_properties.breath_max ~= -1 and (ndef.drowning or 0) > 0))
end


function mob_class:target_visible(origin)
	if not origin then return end
	if not self.attack then return end
	local target_pos = self.attack:get_pos()
	if not target_pos then return end

	local origin_eye_pos = vector_offset(origin, 0, self.head_eye_height, 0)

	--minetest.log("origin: " .. dump(origin))
	--minetest.log("origin_eye_pos: " .. dump(origin_eye_pos))

	local targ_head_height, targ_feet_height
	local cbox = self.initial_properties.collisionbox
	if self.attack:is_player() then
		targ_head_height = vector_offset(target_pos, 0, cbox[5], 0)
		targ_feet_height = target_pos -- Cbox would put feet under ground which interferes with ray
	else
		targ_head_height = vector_offset(target_pos, 0, cbox[5], 0)
		targ_feet_height = vector_offset(target_pos, 0, cbox[2], 0)
	end

	--minetest.log("start targ_head_height: " .. dump(targ_head_height))
	if raycast_line_of_sight (origin_eye_pos, targ_head_height) then
		return true
	end

	--minetest.log("Start targ_feet_height: " .. dump(targ_feet_height))
	if raycast_line_of_sight (origin_eye_pos, targ_feet_height) then
		return true
	end

	-- TODO mid way between feet and head

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
	local npos1 = vector_copy(pos1)
	local r, pos = minetest.line_of_sight(npos1, pos2, stepsize)

	-- Checks the return
	if r == true then return true end

	-- Nodename found
	local nn = minetest.get_node(pos).name

	-- Target Distance (td) to travel
	local td = vector_distance(pos1, pos2)

	-- Actual Distance (ad) traveled
	local ad = 0

	-- It continues to advance in the line of sight in search of a real
	-- obstruction which counts as 'normal' nodebox.
	while minetest.registered_nodes[nn] and minetest.registered_nodes[nn].walkable == false do
		-- Check if you can still move forward
		if td < ad + stepsize then return true end -- Reached the target

		-- Moves the analyzed pos
		local d = vector_distance(pos1, pos2)

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
	local cbox = self.initial_properties.collisionbox

	-- where is front
	local dir_x = -sin(yaw) * (cbox[4] + 0.5)
	local dir_z =  cos(yaw) * (cbox[4] + 0.5)

	--is there nothing under the block in front? if so jump the gap.
	local node_low  = node_ok(vector_offset(pos, dir_x * 0.6, -0.5, dir_z * 0.6), "air")
	-- next is solid, no need to jump
	if minetest.registered_nodes[node_low.name] and minetest.registered_nodes[node_low.name].walkable == true then
		self._jumping_cliff = false
		return false
	end

	local node_far  = node_ok(vector_offset(pos, dir_x * 1.6, -0.5, dir_z * 1.6), "air")
	local node_far2 = node_ok(vector_offset(pos, dir_x * 2.5, -0.5, dir_z * 2.5), "air")
	-- TODO: also check there is air above these nodes?

	-- some place to land on
	if (minetest.registered_nodes[node_far.name] and minetest.registered_nodes[node_far.name].walkable == true)
		or (minetest.registered_nodes[node_far2.name] and minetest.registered_nodes[node_far2.name].walkable == true)
	then
		--disable fear height while we make our jump
		self._jumping_cliff = true
		--minetest.log("Jumping cliff: " .. self.name .. " nodes " .. node_low.name .. " - " .. node_far.name .. " - " .. node_far2.name)
		minetest.after(.1, function()
			if self and self.object then
				self._jumping_cliff = false
			end
		end)
		return true
	else
		self._jumping_cliff = false
		return false
	end
end

-- is mob facing a cliff or danger
function mob_class:is_at_cliff_or_danger()
	--minetest.log(self.name.. " "..tostring(self.fear_height).." "..tostring(self._jumping_cliff).." "..tostring(self._can_jump_cliff).." "..tostring(self.fly))
	if self.fear_height == 0 or self._jumping_cliff or self._can_jump_cliff or not self.object:get_luaentity() then -- 0 for no falling protection!
		return false
	end
	if self.fly then -- also avoids checking fish
		return false
	end
	local yaw = self.object:get_yaw()
	local cbox = self.initial_properties.collisionbox
	local dir_x = -sin(yaw) * (cbox[4] + 0.5)
	local dir_z = cos(yaw) * (cbox[4] + 0.5)

	local pos = self.object:get_pos()
	local ypos = pos.y + cbox[2] + 0.1 -- just above floor

	local free_fall, blocker = minetest.line_of_sight(
			vector_new(pos.x + dir_x, ypos, pos.z + dir_z),
			vector_new(pos.x + dir_x, floor(ypos - self.fear_height), pos.z + dir_z))

	if free_fall then
		return "free fall"
	end
	local height = ypos + 0.4 - blocker.y
	local chance = (self.jump_height or 4) * 0.25 / (height * height)
	if height >= self.fear_height and random() < chance then
		if logging then
			minetest.log("action", "[mcl_mobs] "..self.name.." avoiding drop of "..height) --.." chance "..chance)
		end
		return "drop of "..tostring(height)
	end
	local bnode = minetest.get_node(blocker)
	-- minetest.log("At cliff: " .. self.name .. " below " .. bnode.name .. " height "..height)
	if self:is_node_dangerous(self.standing_in) or self:is_node_waterhazard(self.standing_in) then
		return false -- allow to get out of the immediate danger
	end
	if self:is_node_dangerous(bnode.name) or self:is_node_waterhazard(bnode.name) then
		return bnode.name
	end
	return false
end


-- copy the 'mob facing cliff_or_danger check' from above, and rework to avoid water
function mob_class:is_at_water_danger()
	if self.water_damage == 0 and self.initial_properties.breath_max == -1 then
		--minetest.log("Do not need a water check for: " .. self.name)
		return false
	end
	if self.fly then -- also avoids checking fish
		return false
	end

	local in_water_danger = self:is_node_waterhazard(self.standing_in) or self:is_node_waterhazard(self.standing_on)
	if in_water_danger then return false end -- If you're in trouble, do not stop

	if not self.object:get_luaentity() or self._jumping_cliff or self._can_jump_cliff then
		return false
	end
	local yaw = self.object:get_yaw()
	local pos = self.object:get_pos()

	if not yaw or not pos then
		return false
	end

	local cbox = self.initial_properties.collisionbox
	local dir_x = -sin(yaw) * (cbox[4] + 0.5)
	local dir_z =  cos(yaw) * (cbox[4] + 0.5)

	local ypos = pos.y + cbox[2] + 0.1 -- just above floor

	local los, blocker = minetest.line_of_sight(
		vector_new(pos.x + dir_x, ypos, pos.z + dir_z),
		vector_new(pos.x + dir_x, ypos - 3, pos.z + dir_z))

	if not los then
		local bnode = minetest.get_node(blocker)
		local waterdanger = self:is_node_waterhazard(bnode.name)
		if waterdanger then
			return bnode.name
		end
	end
	return false
end

function mob_class:env_danger_movement_checks(player_in_active_range)
	if not player_in_active_range then return end

	if self.state == PATHFINDING
			or self.state == "attack"
			or self.state == "stand"
			or self.state == "runaway" then
		return
	end

	if self:is_at_water_danger() then
		if logging then
			minetest.log("action", "[mcl_mobs] "..self.name.." at water danger, stop and rotate?")
		end
		if random() <= 0.9 then
			if self.state ~= "stand" then self:stand() end
			self:turn_by(PI * (random() - 0.5), 10)
			return
		end
	end
	if not self._can_jump_cliff and self:is_at_cliff_or_danger() then
		if logging then
			minetest.log("action", "[mcl_mobs] "..self.name.." at cliff danger, rotate")
		end
		if random() <= 0.99 then
			if self.state ~= "stand" then self:stand() end
			self:turn_by(PI * (random() - 0.5), 10)
		end
	end
end

-- jump if facing a solid node (not fences or gates)
function mob_class:do_jump()
	if not self.jump or self.jump_height == 0 or self.fly or self.order == "stand" then return false end
	self.facing_fence = false
	self._jumping_cliff = false

	-- something stopping us while moving?
	if self.state ~= "stand" and self:get_velocity() > 0.5 and self.object:get_velocity().y ~= 0 then return false end

	local pos = self.object:get_pos()
	local v = self.object:get_velocity()
	local cbox = self.initial_properties.collisionbox

	local in_water = minetest.get_item_group(node_ok(pos).name, "water") > 0
	self.in_water = in_water
	-- what is mob standing on?
	pos.y = pos.y + cbox[2]

	local node_below = node_ok(vector_offset(pos, 0, -0.2, 0))
	local nbdef = minetest.registered_nodes[node_below.name]
	if nbdef and nbdef.walkable == false and not in_water then return false end

	local yaw = self.object:get_yaw()

	-- where is front
	local dir_x = -sin(yaw) * (cbox[4] + 0.5) + v.x * 0.25
	local dir_z =  cos(yaw) * (cbox[4] + 0.5) + v.z * 0.25

	-- what is in front of mob?
	local nod = node_ok(vector_offset(pos, dir_x, 0.5, dir_z))
	local ndef = minetest.registered_nodes[nod.name]

	-- thin blocks that do not need to be jumped
	if nod.name == node_snow or (ndef and ndef.groups.carpet or 0) > 0 then return false end

	-- this is used to detect if there's a block on top of the block in front of the mob.
	-- If there is, there is no point in jumping as we won't manage.
	local node_top = node_ok(vector_offset(pos, dir_x, 1.5, dir_z), "air")
	-- TODO: also check above the mob itself?

	-- we don't attempt to jump if there's a stack of blocks blocking, unless attacking
	local ntdef = minetest.registered_nodes[node_top.name]
	if ntdef and ntdef.walkable == true and not (self.attack and self.state == "attack") then return false end

	if self.walk_chance ~= 0 and not (ndef and ndef.walkable) and not self._can_jump_cliff then return false end

	if (ndef.groups.fence or 0) ~= 0 or (ndef.groups.fence_gate or 0) ~= 0 or (ndef.groups.wall or 0) ~= 0 then
		self.facing_fence = true
		return false
	end

	v.y = self.jump_height + 0.3
	if in_water then
		v.x, v.y, v.z = v.x * 1.2, v.y * 1.5, v.z * 1.2
	elseif self._can_jump_cliff then
		v.x, v.y, v.z = v.x * 2.5, v.y * 1.1, v.z * 2.5
	end

	self:set_animation("jump") -- only when defined
	self.object:set_velocity(v)

	-- when in air move forward
	local forward = function(self, v)
		if not self.object or not self.object:get_luaentity() or self.state == "die" then return end
		self.object:set_acceleration(vector_new(v.x * 2, DEFAULT_FALL_SPEED, v.z * 2))
	end
	-- trying multiple time helps mobs jump
	minetest.after(0.1, forward, self, v)
	minetest.after(0.2, forward, self, v)
	minetest.after(0.3, forward, self, v)

	if self.jump_sound_cooloff <= 0 then
		self:mob_sound("jump")
		self.jump_sound_cooloff = 0.5
	end

	-- if we jumped against a block/wall 4 times then turn
	if (v.x * v.x + v.z * v.z) < 0.1 then
		self._jump_count = (self._jump_count or 0) + 1
		if self._jump_count == 4 then
			self:turn_by(TWOPI * (random() - 0.5), 8)
			self._jump_count = 0
			return false
		end
	else
		self._jump_count = 0
	end
	return true
end

-- should mob follow what I'm holding ?
function mob_class:follow_holding(clicker)
	if self.nofollow then return false end
	if mcl_mobs.invis[clicker:get_player_name()] then return false end

	local item = clicker:get_wielded_item()
	local t = type(self.follow)
	-- single item
	if t == "string" and item:get_name() == self.follow then
		return true
	-- multiple items
	elseif t == "table" then
		for no = 1, #self.follow do
			if self.follow[no] == item:get_name() then return true end
		end
	end
	return false
end


-- find and replace what mob is looking for (grass, wheat etc.)
function mob_class:replace_node(pos)
	if not self.replace_rate
	or not self.replace_what
	or self.child
	or self.object:get_velocity().y ~= 0
	or random(1, self.replace_rate) > 1 then
		return
	end

	local what, with, y_offset

	if type(self.replace_what[1]) == "table" then
		local num = random(#self.replace_what)

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
		local on_replace_return = false
		if self.on_replace then
			on_replace_return = self.on_replace(self, pos, oldnode, newnode)
		end


		if on_replace_return ~= false then
			if mobs_griefing then
				minetest.after(self.replace_delay, function()
					if self and self.object and self.object:get_velocity() and self.health > 0 then
						minetest.set_node(pos, newnode)
					end
				end)
			end
		end
	end
end

-- specific runaway
local specific_runaway = function(list, what)
	-- no list so do not run
	if list == nil then return false end
	if type(list) ~= "table" then list = {} end
	-- found entity on list to attack?
	for no = 1, #list do
		if list[no] == what then return true end
	end
	return false
end


-- find someone to runaway from
function mob_class:check_runaway_from()
	if not self.runaway_from and self.state ~= "flop" then return end

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
			dist = vector_distance(p, s)
			-- choose closest player/mpb to runaway from
			if dist < min_dist
			and self:line_of_sight(vector_offset(sp, 0, 1, 0), vector_offset(p, 0, 1, 0), 2) == true then
				-- aim higher to make looking up hills more realistic
				min_dist = dist
				min_player = player
			end
		end
	end

	if min_player then
		local lp = player:get_pos()
		self:turn_in_direction(s.x - lp.x, s.z - lp.z, 4) -- away from player
		self.state = "runaway"
		self.runaway_timer = 3
		self.following = nil
	end
end


-- follow player if owner or holding item
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
		local p = self.following:is_player() and self.following:get_pos()
			or self.following.object and self.following.object:get_pos()

		if p then
			if (not self:object_in_range(self.following)) then
				self.following = nil
			else
				self:turn_in_direction(p.x - s.x, p.z - s.z, 2.35)

				-- anyone but standing npc's can move along
				local dist = vector_distance(p, s)
				if dist > 3 and self.order ~= "stand" then
					self:set_velocity(self.follow_velocity)
					if self.walk_chance ~= 0 then
						self:set_animation("run")
					end
				else
					self:set_velocity(0)
					self:set_animation("stand")
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
			self.object:set_acceleration(vector_new(0, DEFAULT_FALL_SPEED, 0))

			local p = self.object:get_pos()
			local sdef = minetest.registered_nodes[node_ok(vector_offset(p, 0, self.initial_properties.collisionbox[2] - 0.2, 0)).name]
			-- Flop on ground
			if sdef and sdef.walkable then
				if self.object:get_velocity().y < 0.1 then
					self:mob_sound("flop")
					self.object:set_velocity(vector_new((random() * 2 - 1) * FLOP_HOR_SPEED, FLOP_HEIGHT, (random() * 2 - 1) * FLOP_HOR_SPEED))
				end
			end

			self:set_animation( "stand", true)
			return
		elseif self.state == "flop" then
			self.state = "stand"
			self.object:set_acceleration(vector_zero())
			self:set_velocity(0)
		end
	end
end

function mob_class:go_to_pos(b, speed)
	if not self then return end
	if not b then return end
	local s = self.object:get_pos()
	if vector_distance(b,s) < .4 then return true end
	if b.y > s.y + 0.2 then self:do_jump() end
	self:turn_in_direction(b.x - s.x, b.z - s.z, 2)
	speed = speed or self.walk_velocity
	self:set_velocity(speed)
	self:set_animation(speed <= self.walk_velocity and "walk" or "run")
end

local check_herd_timer = 0
function mob_class:check_herd(dtime)
	local pos = self.object:get_pos()
	if not pos or self.state == "attack" then return end
	-- Does any mob not move in group. Weird check for something not set?
	if self.move_in_group == false then return end

	check_herd_timer = check_herd_timer + dtime
	if check_herd_timer < CHECK_HERD_FREQUENCY then return end
	check_herd_timer = 0
	for _,o in pairs(minetest.get_objects_inside_radius(pos,self.view_range)) do
		local l = o:get_luaentity()
		if l and l.is_mob and l.name == self.name then
			if self.horny and l.horny then
				self:go_to_pos(l.object:get_pos())
			else
				self:set_yaw(o:get_yaw(), 8)
			end
		end
	end
end

function mob_class:teleport(target)
	if self.do_teleport then return self.do_teleport(self, target) end
end

function mob_class:animate_walk_or_fly()
	if self:flight_check() and self.animation and self.animation.fly_start and self.animation.fly_end then
		self:set_animation("fly")
	else
		self:set_animation("walk")
	end
end

function mob_class:do_states_walk()
	local yaw = self.object:get_yaw() or 0
	local s = self.object:get_pos()

	-- If mob in or on dangerous block, look for land
	if self:is_node_dangerous(self.standing_in) or self:is_node_waterhazard(self.standing_in)
			or not self.fly and (self:is_node_dangerous(self.standing_on) or self:is_node_waterhazard(self.standing_on)) then
		-- Better way to find shore - copied from upstream
		local lp = minetest.find_nodes_in_area_under_air(vector_offset(s, -5, -0.5, -5), vector_offset(s, 5, 1, 5), {"group:solid"})
		if #lp == 0 then
			local lp = minetest.find_nodes_in_area_under_air(vector_offset(s, -10, -0.5, -10), vector_offset(s, 10, 1, 10), {"group:solid"})
		end
		-- TODO: use node with smallest change in yaw instead of random?
		lp = #lp > 0 and lp[random(#lp)]
		-- did we find land?
		if lp then
			if logging then
				minetest.log("action", "[mcl_mobs] "..self.name.." heading to land ".. tostring(minetest.get_node(lp).name or nil))
			end
			-- look towards land and move in that direction
			self:turn_in_direction(lp.x - s.x, lp.z - s.z, 8)
			self:set_velocity(self.walk_velocity)
			self:animate_walk_or_fly()
			return
		end
	end
	-- stop at fences or randomly
	-- fences break villager pathfinding! if self.facing_fence == true or random() <= 0.3 then
	if random() <= 0.3 then
		self:stand()
		return
	end
	-- facing wall? then turn
	local facing_wall = false
	local cbox = self.initial_properties.collisionbox
	local dir_x = -sin(yaw - QUARTERPI) * (cbox[4] + 0.5)
	local dir_z =  cos(yaw - QUARTERPI) * (cbox[4] + 0.5)
	local nodface = node_ok(vector_offset(s,  dir_x, cbox[5] - cbox[2], dir_z))
	if minetest.registered_nodes[nodface.name] and minetest.registered_nodes[nodface.name].walkable == true then
		dir_x = -sin(yaw + QUARTERPI) * (cbox[4] + 0.5)
		dir_z =  cos(yaw + QUARTERPI) * (cbox[4] + 0.5)
		nodface = node_ok(vector_offset(s, dir_x, cbox[5] - cbox[2], dir_z))
		if minetest.registered_nodes[nodface.name] and minetest.registered_nodes[nodface.name].walkable == true then
			facing_wall = true
		end
	end
	if facing_wall then
		if logging then
			minetest.log("action", "[mcl_mobs] "..self.name.." facing a wall, turning.")
		end
		self:turn_by(TWOPI * (random() - 0.5), 6)
	-- otherwise randomly turn
	elseif random() <= 0.3 then
		local home = self._home or self._bed
		if home and random() < 0.1 then
			self:turn_in_direction(home.x - s.x, home.z - s.z, 8)
		else
			self:turn_by(QUARTERPI * (random() - 0.5), 10)
		end
	end
	self:set_velocity(self.walk_velocity)
	self:animate_walk_or_fly()
end

function mob_class:do_states_stand(player_in_active_range)
	if random() < 0.25 then
		local s = self.object:get_pos()
		local lp
		if player_in_active_range and self.look_at_players then
			local objs = minetest.get_objects_inside_radius(s, 3)
			for n = 1, #objs do
				if objs[n]:is_player() then
					lp = objs[n]:get_pos()
					break
				end
			end
		end
		-- look at any players nearby, otherwise turn randomly
		if lp then
			self:turn_in_direction(lp.x - s.x, lp.z - s.z, 10)
		else
			local home = self._home or self._bed
			if home and random() < 0.3 then
				self:turn_in_direction(home.x - s.x, home.z - s.z, 8)
			else
				self:turn_by(HALFPI * (random() - 0.5), 10)
			end
		end
	end
	if self.order == "sit" then
		self:set_animation("sit")
		self:set_velocity(0)
	else
		self:set_animation("stand")
		self:set_velocity(0)
	end

	-- npc's ordered to stand stay standing
	if self.order == "stand" or self.order == "sleep" or self.order == "work" then

	else
		if player_in_active_range then
			if self.walk_chance ~= 0
					and self.facing_fence ~= true
					and random(1, 100) <= self.walk_chance then
				if self:is_at_cliff_or_danger() then
					self:turn_by(PI * (random() - 0.5), 10)
				else
					self:set_velocity(self.walk_velocity)
					self.state = "walk"
					self:set_animation( "walk")
				end
			end
		end
	end
end

function mob_class:do_states_runaway()
	self.runaway_timer = self.runaway_timer + 1
	-- stop after 5 seconds or when at cliff
	if self.runaway_timer > 5
			or self:is_at_cliff_or_danger() then
		self.runaway_timer = 0
		self:stand()
		self:turn_by(PI * (random() + 0.5), 8)
	else
		self:set_velocity( self.run_velocity)
		self:set_animation( "run")
	end
end

