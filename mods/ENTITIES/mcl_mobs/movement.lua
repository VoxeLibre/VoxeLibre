local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
local DEFAULT_FALL_SPEED = -9.81*1.5
local FLOP_HEIGHT = 6
local FLOP_HOR_SPEED = 1.5

local CHECK_HERD_FREQUENCY = 4

local PATHFINDING = "gowp"

local node_snow = "mcl_core:snow"

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local logging = minetest.settings:get_bool("mcl_logging_mobs_movement", true)

local random = math.random
local sin = math.sin
local cos = math.cos
local atan2 = math.atan2
local abs = math.abs
local floor = math.floor
local PI = math.pi
local TWOPI = 2 * math.pi
local PIHALF = 0.5 * math.pi
local PIQUARTER = 0.25 * math.pi

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
	if minetest.registered_nodes[nn] and (minetest.registered_nodes[nn].drowning or 0) > 0 then
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


local function raycast_line_of_sight (origin, target)
	local raycast = minetest.raycast(origin, target, false, true)

	local los_blocked = false

	for hitpoint in raycast do
		if hitpoint.type == "node" then
			--TODO type object could block vision, for example chests
			local node = minetest.get_node(minetest.get_pointed_thing_position(hitpoint))

			if node.name ~= "air" then
				local nodef = minetest.registered_nodes[node.name]
				if nodef and nodef.walkable then
					los_blocked = true
					break
				end
			end
		end
	end
	return not los_blocked
end

function mob_class:target_visible(origin)
	if not origin then return end

	if not self.attack then return end
	local target_pos = self.attack:get_pos()

	if not target_pos then return end

	local origin_eye_pos = vector.offset(origin, 0, self.head_eye_height, 0)

	--minetest.log("origin: " .. dump(origin))
	--minetest.log("origin_eye_pos: " .. dump(origin_eye_pos))

	local targ_head_height, targ_feet_height
	local cbox = self.collisionbox
	if self.attack:is_player() then
		targ_head_height = vector.offset(target_pos, 0, cbox[5], 0)
		targ_feet_height = target_pos -- Cbox would put feet under ground which interferes with ray
	else
		targ_head_height = vector.offset(target_pos, 0, cbox[5], 0)
		targ_feet_height = vector.offset(target_pos, 0, cbox[2], 0)
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
	local cbox = self.collisionbox

	-- where is front
	local dir_x = -sin(yaw) * (cbox[4] + 0.5)
	local dir_z =  cos(yaw) * (cbox[4] + 0.5)

	--is there nothing under the block in front? if so jump the gap.
	local node_low  = node_ok({ x = pos.x + dir_x*0.6, y = pos.y - 0.5, z = pos.z + dir_z*0.6 }, "air")
	-- next is solid, no need to jump
	if minetest.registered_nodes[node_low.name] and minetest.registered_nodes[node_low.name].walkable == true then
		self._jumping_cliff = false
		return false
	end

	local node_far  = node_ok({ x = pos.x + dir_x*1.6, y = pos.y - 0.5, z = pos.z + dir_z*1.6 }, "air")
	local node_far2 = node_ok({ x = pos.x + dir_x*2.5, y = pos.y - 0.5, z = pos.z + dir_z*2.5 }, "air")
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
	local cbox = self.collisionbox
	local dir_x = -sin(yaw) * (cbox[4] + 0.5)
	local dir_z = cos(yaw) * (cbox[4] + 0.5)

	local pos = self.object:get_pos()
	local ypos = pos.y + cbox[2] + 0.1 -- just above floor

	local free_fall, blocker = minetest.line_of_sight(
			vector.new(pos.x + dir_x, ypos, pos.z + dir_z),
			vector.new(pos.x + dir_x, floor(ypos - self.fear_height), pos.z + dir_z))

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
	if self.water_damage == 0 and self.breath_max == -1 then
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

	local cbox = self.collisionbox
	local dir_x = -sin(yaw) * (cbox[4] + 0.5)
	local dir_z =  cos(yaw) * (cbox[4] + 0.5)

	local ypos = pos.y + cbox[2] + 0.1 -- just above floor

	local los, blocker = minetest.line_of_sight(
		vector.new(pos.x + dir_x, ypos, pos.z + dir_z),
		vector.new(pos.x + dir_x, ypos - 3, pos.z + dir_z))

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
		if random() <= 0.8 then
			if self.state ~= "stand" then
				self:stand()
			end
			local yaw = self.object:get_yaw() or 0
			self:set_yaw(yaw + PIHALF * (random() - 0.5), 10)
			return
		end
	end
	if self:is_at_cliff_or_danger() and not self._can_jump_cliff then
		if logging then
			minetest.log("action", "[mcl_mobs] "..self.name.." at cliff danger, rotate")
		end
		if random() <= 0.99 then
			if self.state ~= "stand" then
				self:stand()
			end
			local yaw = self.object:get_yaw() or 0
			yaw = self:set_yaw(yaw + PI * (random() - 0.5), 10)
		end
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
	self._jumping_cliff = false

	-- something stopping us while moving?
	if self.state ~= "stand"
	and self:get_velocity() > 0.5
	and self.object:get_velocity().y ~= 0 then
		return false
	end

	local pos = self.object:get_pos()
	local cbox = self.collisionbox

	local in_water = minetest.get_item_group(node_ok(pos).name, "water") > 0
	-- what is mob standing on?
	pos.y = pos.y + cbox[2]

	local nodBelow = node_ok({ x = pos.x, y = pos.y - 0.2, z = pos.z })
	if minetest.registered_nodes[nodBelow.name].walkable == false and not in_water then
		return false
	end

	local yaw = self.object:get_yaw()

	-- where is front
	local dir_x = -sin(yaw) * (cbox[4] + 0.5)
	local dir_z =  cos(yaw) * (cbox[4] + 0.5)

	-- what is in front of mob?
	local nod = node_ok({ x = pos.x + dir_x, y = pos.y + 0.5, z = pos.z + dir_z })

	-- this is used to detect if there's a block on top of the block in front of the mob.
	-- If there is, there is no point in jumping as we won't manage.
	local nodTop = node_ok({ x = pos.x + dir_x, y = pos.y + 1.5, z = pos.z + dir_z }, "air")
	-- TODO: also check above the mob itself?

	-- we don't attempt to jump if there's a stack of blocks blocking, unless attacking
	if minetest.registered_nodes[nodTop.name].walkable == true and not (self.attack and self.state == "attack") then
		return false
	end

	-- thin blocks that do not need to be jumped
	if nod.name == node_snow then
		return false
	end

	local ndef = minetest.registered_nodes[nod.name]
	if self.walk_chance == 0 or ndef and ndef.walkable or self._can_jump_cliff then

		if minetest.get_item_group(nod.name, "fence") == 0
		and minetest.get_item_group(nod.name, "fence_gate") == 0
		and minetest.get_item_group(nod.name, "wall") == 0 then

			local v = self.object:get_velocity()

			v.y = self.jump_height + 0.1 * 3

			if in_water then
				v=vector.multiply(v, vector.new(1.2,1.5,1.2))
			elseif self._can_jump_cliff then
				v=vector.multiply(v, vector.new(2.5,1.1,2.5))
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
		if self.object:get_velocity().x ~= 0 and self.object:get_velocity().z ~= 0 then
			self.jump_count = (self.jump_count or 0) + 1
			if self.jump_count == 4 then
				local yaw = self.object:get_yaw() or 0
				yaw = self:set_yaw(yaw + PI * (random() - 0.5), 8)
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
		local yaw = -atan2(s.x - lp.x, s.z - lp.z) - self.rotate -- away from player
		self:set_yaw(yaw, 4)
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

		local p
		if self.following:is_player() then
			p = self.following:get_pos()
		elseif self.following.object then
			p = self.following.object:get_pos()
		end

		if p then
			if (not self:object_in_range(self.following)) then
				self.following = nil
			else
				self:set_yaw(-atan2(p.x - s.x, p.z - s.z) - self.rotate, 2.35)

				-- anyone but standing npc's can move along
				local dist = vector.distance(p, s)
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
			self.object:set_acceleration({x = 0, y = DEFAULT_FALL_SPEED, z = 0})

			local p = self.object:get_pos()
			local sdef = minetest.registered_nodes[node_ok(vector.add(p, vector.new(0,self.collisionbox[2]-0.2,0))).name]
			-- Flop on ground
			if sdef and sdef.walkable then
				if self.object:get_velocity().y < 0.1 then
					self:mob_sound("flop")
					self.object:set_velocity({
						x = (random() * 2 - 1) * FLOP_HOR_SPEED,
						y = FLOP_HEIGHT,
						z = (random() * 2 - 1) * FLOP_HOR_SPEED,
					})
				end
			end

			self:set_animation( "stand", true)
			return
		elseif self.state == "flop" then
			self.state = "stand"
			self.object:set_acceleration(vector.zero())
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
	self.object:set_yaw(-atan2(b.x - s.x, b.z - s.z) - self.rotate)
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
	if check_herd_timer < CHECK_HERD_FREQUENCY then return end
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

function mob_class:animate_walk_or_fly()
	if self:flight_check()
			and self.animation
			and self.animation.fly_start
			and self.animation.fly_end then
		self:set_animation("fly")
	else
		self:set_animation("walk")
	end
end

function mob_class:do_states_walk()
	local yaw = self.object:get_yaw() or 0
	local s = self.object:get_pos()

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
		if self:is_node_dangerous(self.standing_in) or self:is_node_waterhazard(self.standing_in)
				or not self.fly and (self:is_node_dangerous(self.standing_on) or self:is_node_waterhazard(self.standing_on)) then
			is_in_danger = true

			-- If mob in or on dangerous block, look for land
			if is_in_danger then
				-- Better way to find shore - copied from upstream
				lp = minetest.find_nodes_in_area_under_air(
						{x = s.x - 5, y = s.y - 0.5, z = s.z - 5},
						{x = s.x + 5, y = s.y + 1, z = s.z + 5},
						{"group:solid"})

				lp = #lp > 0 and lp[random(#lp)]
				-- did we find land?
				if lp then
					-- minetest.log(self.name .. " heading to land ".. tostring(minetest.get_node(lp).name or nil))
					yaw = atan2(lp.x - s.x, lp.z - s.z) - self.rotate
					-- look towards land and move in that direction
					self:set_yaw(yaw, 6)
					self:set_velocity(self.walk_velocity)
				end
			end

			-- A danger is near but mob is not inside
		else
			-- Randomly turn
			if random(1, 100) <= 30 then
				yaw = yaw + random() - 0.5
				self:set_yaw(yaw, 8)
			end
			self:stand()
			yaw = self:set_yaw(yaw + PIHALF * (random() - 0.5), 6)
			return
		elseif logging then
			minetest.log("action", "[mcl_mobs] "..self.name.." ignores the danger "..tostring(danger))
		end
	end
	-- If mob in or on dangerous block, look for land
	if self:is_node_dangerous(self.standing_in) or self:is_node_waterhazard(self.standing_in)
			or not self.fly and (self:is_node_dangerous(self.standing_on) or self:is_node_waterhazard(self.standing_on)) then
		-- Better way to find shore - copied from upstream
		local lp = minetest.find_nodes_in_area_under_air(
				{x = s.x - 5, y = s.y - 0.5, z = s.z - 5},
				{x = s.x + 5, y = s.y + 1, z = s.z + 5},
				{"group:solid"})
		-- TODO: use node with smallest change in yaw?

		lp = #lp > 0 and lp[random(#lp)]
		-- did we find land?
		if lp then
			if logging then
				minetest.log("action", "[mcl_mobs] "..self.name.." heading to land ".. tostring(minetest.get_node(lp).name or nil))
			end
			-- look towards land and move in that direction
			self:set_yaw(-atan2(lp.x - s.x, lp.z - s.z) - self.rotate, 8)
			self:set_velocity(self.walk_velocity)
			self:animate_walk_or_fly()
			return
		end
	end
	-- stop at fences or randomly
	if self.facing_fence == true or random() <= 0.3 then
		self:stand()
		return
	end
	-- facing wall? then turn
	local facing_wall = false
	local cbox = self.collisionbox
	local dir_x = -sin(yaw - PIQUARTER) * (cbox[4] + 0.5)
	local dir_z =  cos(yaw - PIQUARTER) * (cbox[4] + 0.5)
	local nodface = node_ok({ x = s.x + dir_x, y = s.y + cbox[5] - cbox[2], z = s.z + dir_z })
	if minetest.registered_nodes[nodface.name] and minetest.registered_nodes[nodface.name].walkable == true then
		dir_x = -sin(yaw + PIQUARTER) * (cbox[4] + 0.5)
		dir_z =  cos(yaw + PIQUARTER) * (cbox[4] + 0.5)
		nodface = node_ok({ x = s.x + dir_x, y = s.y + cbox[5] - cbox[2], z = s.z + dir_z })
		if minetest.registered_nodes[nodface.name] and minetest.registered_nodes[nodface.name].walkable == true then
			facing_wall = true
		end
	end
	if facing_wall then
		if logging then
			minetest.log("action", "[mcl_mobs] "..self.name.." facing a wall, turning.")
		end
		yaw = self:set_yaw(yaw + PI * (random() - 0.5), 6)
	-- otherwise randomly turn
	elseif random() <= 0.3 then
		yaw = self:set_yaw(yaw + PIHALF * (random() - 0.5), 10)
	end
	self:set_velocity(self.walk_velocity)
	self:animate_walk_or_fly()
end

function mob_class:do_states_stand(player_in_active_range)
	local yaw = self.object:get_yaw() or 0

	if random() < 0.25 then
		local lp
		if player_in_active_range and self.look_at_players then
			local s = self.object:get_pos()
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
			yaw = -atan2(lp.x - s.x, lp.z - s.z) - self.rotate
		else
			yaw = yaw + PIHALF * (random() - 0.5)
		end
		yaw = self:set_yaw(yaw, 10)
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
		if player_in_active_range then
			if self.walk_chance ~= 0
					and self.facing_fence ~= true
					and random(1, 100) <= self.walk_chance then
				if self:is_at_cliff_or_danger() then
					yaw = yaw + PI * (random() - 0.5)
					yaw = self:set_yaw(yaw, 10)
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
	local yaw = self.object:get_yaw() or 0

	self.runaway_timer = self.runaway_timer + 1

	-- stop after 5 seconds or when at cliff
	if self.runaway_timer > 5
			or self:is_at_cliff_or_danger() then
		self.runaway_timer = 0
		self:stand()
		yaw = self:set_yaw(yaw + PI * (random() + 0.5), 8)
	else
		self:set_velocity( self.run_velocity)
		self:set_animation( "run")
	end
end

