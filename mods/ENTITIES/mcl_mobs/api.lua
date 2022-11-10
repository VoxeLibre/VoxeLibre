local mob_class = mcl_mobs.mob_class
local mob_class_meta = {__index = mcl_mobs.mob_class}
local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
-- API for Mobs Redo: MineClone 2 Edition (MRM)
local MAX_MOB_NAME_LENGTH = 30
local HORNY_TIME = 30
local HORNY_AGAIN_TIME = 300
local CHILD_GROW_TIME = 60*20
local DEATH_DELAY = 0.5
local DEFAULT_FALL_SPEED = -9.81*1.5
local FLOP_HEIGHT = 6
local FLOP_HOR_SPEED = 1.5

local PATHFINDING = "gowp"

-- Localize
local S = minetest.get_translator("mcl_mobs")

local mob_active_range = tonumber(minetest.settings:get("mcl_mob_active_range")) or 48

local LOGGING_ON = minetest.settings:get_bool("mcl_logging_mobs_villager",false)
local function mcl_log (message)
	if LOGGING_ON then
		mcl_util.mcl_log (message, "[Mobs]", true)
	end
end


-- Invisibility mod check
mcl_mobs.invis = {}

-- localize math functions
local atann = math.atan

local function atan(x)
	if not x or x ~= x then
		return 0
	else
		return atann(x)
	end
end

-- Load settings
local damage_enabled = minetest.settings:get_bool("enable_damage")
local disable_blood = minetest.settings:get_bool("mobs_disable_blood")
local mobs_drop_items = minetest.settings:get_bool("mobs_drop_items") ~= false
local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local spawn_protected = minetest.settings:get_bool("mobs_spawn_protected") ~= false
local remove_far = true
local difficulty = tonumber(minetest.settings:get("mob_difficulty")) or 1.0
local show_health = false
local old_spawn_icons = minetest.settings:get_bool("mcl_old_spawn_icons",false)
-- Shows helpful debug info above each mob
local mobs_debug = minetest.settings:get_bool("mobs_debug", false)
local spawn_logging = minetest.settings:get_bool("mcl_logging_mobs_spawn",true)

-- Peaceful mode message so players will know there are no monsters
if minetest.settings:get_bool("only_peaceful_mobs", false) then
	minetest.register_on_joinplayer(function(player)
		minetest.chat_send_player(player:get_player_name(),
			S("Peaceful mode active! No monsters will spawn."))
	end)
end

local function dir_to_pitch(dir)
	--local dir2 = vector.normalize(dir)
	local xz = math.abs(dir.x) + math.abs(dir.z)
	return -math.atan2(-dir.y, xz)
end

-- default nodes
local node_ice = "mcl_core:ice"
local node_snowblock = "mcl_core:snowblock"
local node_snow = "mcl_core:snow"
mcl_mobs.fallback_node = minetest.registered_aliases["mapgen_dirt"] or "mcl_core:dirt"

minetest.register_chatcommand("clearmobs",{
	privs={maphack=true},
	params = "<all>|<nametagged>|<range>",
	description=S("Removes all spawned mobs except nametagged and tamed ones. all removes all mobs, nametagged only nametagged ones and with the range paramter all mobs in a distance of the current player are removed."),
	func=function(n,param)
		local p = minetest.get_player_by_name(n)
		local num=tonumber(param)
		for _,o in pairs(minetest.luaentities) do
			if o.is_mob then
				if  param == "all" or
				( param == "nametagged" and o.nametag ) or
				( param == "" and ( not o.nametag or o.nametag == "" ) and not o.tamed ) or
				( num and num > 0 and vector.distance(p:get_pos(),o.object:get_pos()) <= num ) then
					o.object:remove()
				end
			end
		end
end})


minetest.register_on_leaveplayer(function(player)
	local pn = player:get_player_name()
	if not active_particlespawners[pn] then return end
	for _,m in pairs(active_particlespawners[pn]) do
		for k,v in pairs(m) do
			minetest.delete_particlespawner(v)
		end
	end
	active_particlespawners[pn] = nil
end)

function mob_class:player_in_active_range()
	for _,p in pairs(minetest.get_connected_players()) do
		if vector.distance(self.object:get_pos(),p:get_pos()) <= mob_active_range then return true end
		-- slightly larger than the mc 32 since mobs spawn on that circle and easily stand still immediately right after spawning.
	end
end


-- Return true if object is in view_range
function mob_class:object_in_range(object)
	if not object then
		return false
	end
	local factor
	-- Apply view range reduction for special player armor
	if object:is_player() then
		local factors = mcl_armor.player_view_range_factors[object]
		factor = factors and factors[self.name]
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

-- Returns true is node can deal damage to self
local is_node_dangerous = function(self, nodename)
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
local is_node_waterhazard = function(self, nodename)
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

-- check if within physical map limits (-30911 to 30927)
local function within_limits(pos, radius)
	local wmin, wmax = -30912, 30928
	if mcl_vars then
		if mcl_vars.mapgen_edge_min and mcl_vars.mapgen_edge_max then
			wmin, wmax = mcl_vars.mapgen_edge_min, mcl_vars.mapgen_edge_max
		end
	end
	if radius then
		wmin = wmin - radius
		wmax = wmax + radius
	end
	for _,v in pairs(pos) do
		if v < wmin or v > wmax then return false end
	end
	return true
end

-- get node but use fallback for nil or unknown
local node_ok = function(pos, fallback)

	fallback = fallback or mcl_mobs.fallback_node

	local node = minetest.get_node_or_nil(pos)

	if node and minetest.registered_nodes[node.name] then
		return node
	end

	return minetest.registered_nodes[fallback]
end


local can_jump_cliff = function(self)
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
local is_at_cliff_or_danger = function(self)

	if self.fear_height == 0 or can_jump_cliff(self) or self._jumping_cliff or not self.object:get_luaentity() then -- 0 for no falling protection!
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
		local danger = is_node_dangerous(self, bnode.name)
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
local is_at_water_danger = function(self)


	if not self.object:get_luaentity() or can_jump_cliff(self) or self._jumping_cliff then
		return false
	end
	local yaw = self.object:get_yaw()
	local dir_x = -math.sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = math.cos(yaw) * (self.collisionbox[4] + 0.5)
	local pos = self.object:get_pos()
	local ypos = pos.y + self.collisionbox[2] -- just above floor

	local free_fall, blocker = minetest.line_of_sight(
		{x = pos.x + dir_x, y = ypos, z = pos.z + dir_z},
		{x = pos.x + dir_x, y = ypos - 3, z = pos.z + dir_z})
	if free_fall then
		return true
	else
		local bnode = minetest.get_node(blocker)
		local waterdanger = is_node_waterhazard(self, bnode.name)
		if
			waterdanger and (is_node_waterhazard(self, self.standing_in) or is_node_waterhazard(self, self.standing_on)) then
			return false
		elseif waterdanger and (is_node_waterhazard(self, self.standing_in) or is_node_waterhazard(self, self.standing_on)) == false then
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
	if self.walk_chance == 0 or ndef and ndef.walkable or can_jump_cliff(self) then

		if minetest.get_item_group(nod.name, "fence") == 0
		and minetest.get_item_group(nod.name, "fence_gate") == 0
		and minetest.get_item_group(nod.name, "wall") == 0 then

			local v = self.object:get_velocity()

			v.y = self.jump_height + 0.1 * 3

			if can_jump_cliff(self) then
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
local follow_holding = function(self, clicker)
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
local replace = function(self, pos)

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
			yaw = yaw + pi
		end

		yaw = self:set_yaw( yaw, 4)
		self.state = "runaway"
		self.runaway_timer = 3
		self.following = nil
	end
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

			if (self:object_in_range(players[n]))
			and not mcl_mobs.invis[ players[n]:get_player_name() ] then

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
				if dist > 3
				and self.order ~= "stand" then

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

	-- swimmers flop when out of their element, and swim again when back in
	if self.fly then
		local s = self.object:get_pos()
		if self:flight_check( s) == false then

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

local function go_to_pos(entity,b)
	if not entity then return end
	local s=entity.object:get_pos()
	if not b then
		--self.state = "stand"
		return end
	if vector.distance(b,s) < 1 then
		--entity:set_velocity(0)
		return true
	end
	local v = { x = b.x - s.x, z = b.z - s.z }
	local yaw = (atann(v.z / v.x) +math.pi/ 2) - entity.rotate
	if b.x > s.x then yaw = yaw +math.pi end
	entity.object:set_yaw(yaw)
	entity:set_velocity(entity.follow_velocity)
	entity:set_animation("walk")
end

local function interact_with_door(self, action, target)
	local p = self.object:get_pos()
	--local t = minetest.get_timeofday()
	--local dd = minetest.find_nodes_in_area(vector.offset(p,-1,-1,-1),vector.offset(p,1,1,1),{"group:door"})
	--for _,d in pairs(dd) do
	if target then
		mcl_log("Door target is: ".. minetest.pos_to_string(target))

		local n = minetest.get_node(target)
		if n.name:find("_b_") or n.name:find("_t_") then
			mcl_log("Door")
			local def = minetest.registered_nodes[n.name]
			local closed = n.name:find("_b_1") or n.name:find("_t_1")
			--if self.state == PATHFINDING then
				if closed and action == "open" and def.on_rightclick then
					mcl_log("Open door")
					def.on_rightclick(target,n,self)
				end
				if not closed and action == "close" and def.on_rightclick then
					mcl_log("Close door")
					def.on_rightclick(target,n,self)
				end
			--else
		else
			mcl_log("Not door")
		end
	else
		mcl_log("no target. cannot try and open or close door")
	end
	--end
end

local function do_pathfind_action (self, action)
	if action then
		mcl_log("Action present")
		local type = action["type"]
		local action_val = action["action"]
		local target = action["target"]
		if target then
			mcl_log("Target: ".. minetest.pos_to_string(target))
		end
		if type and type == "door" then
			mcl_log("Type is door")
			interact_with_door(self, action_val, target)
		end
	end
end

-- execute current state (stand, walk, run, attacks)
-- returns true if mob has died
local do_states = function(self, dtime)
	--if self.can_open_doors then check_doors(self) end

	local yaw = self.object:get_yaw() or 0

	if self.state == "stand" then
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
			and is_at_cliff_or_danger(self) == false then

				self:set_velocity(self.walk_velocity)
				self.state = "walk"
				self:set_animation( "walk")
			end
		end

	elseif self.state == PATHFINDING then
		self:check_gowp(dtime)

	elseif self.state == "walk" then
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
			if (is_node_dangerous(self, self.standing_in) or
				is_node_dangerous(self, self.standing_on)) or (is_node_waterhazard(self, self.standing_in) or is_node_waterhazard(self, self.standing_on)) and (not self.fly) then
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
			cliff_or_danger = is_at_cliff_or_danger(self)
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

	-- runaway when punched
	elseif self.state == "runaway" then

		self.runaway_timer = self.runaway_timer + 1

		-- stop after 5 seconds or when at cliff
		if self.runaway_timer > 5
		or is_at_cliff_or_danger(self) then
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

	-- attack routines (explode, dogfight, shoot, dogshoot)
	elseif self.state == "attack" then

		local s = self.object:get_pos()
		local p = self.attack:get_pos() or s

		-- stop attacking if player invisible or out of range
		if not self.attack
		or not self.attack:get_pos()
		or not self:object_in_range(self.attack)
		or self.attack:get_hp() <= 0
		or (self.attack:is_player() and mcl_mobs.invis[ self.attack:get_player_name() ]) then

			self.state = "stand"
			self:set_velocity( 0)
			self:set_animation( "stand")
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

			yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate

			if p.x > s.x then yaw = yaw +math.pi end

			yaw = self:set_yaw( yaw, 0, dtime)

			local node_break_radius = self.explosion_radius or 1
			local entity_damage_radius = self.explosion_damage_radius
					or (node_break_radius * 2)

			-- start timer when in reach and line of sight
			if not self.v_start
			and dist <= self.reach
			and self:line_of_sight( s, p, 2) then

				self.v_start = true
				self.timer = 0
				self.blinktimer = 0
				self:mob_sound("fuse", nil, false)

			-- stop timer if out of reach or direct line of sight
			elseif self.allow_fuse_reset
			and self.v_start
			and (dist >= self.explosiontimer_reset_radius
					or not self:line_of_sight( s, p, 2)) then
				self.v_start = false
				self.timer = 0
				self.blinktimer = 0
				self.blinkstatus = false
				self:remove_texture_mod("^[brighten")
			end

			-- walk right up to player unless the timer is active
			if self.v_start and (self.stop_to_explode or dist < self.reach) then
				self:set_velocity( 0)
			else
				self:set_velocity( self.run_velocity)
			end

			if self.animation and self.animation.run_start then
				self:set_animation( "run")
			else
				self:set_animation( "walk")
			end

			if self.v_start then

				self.timer = self.timer + dtime
				self.blinktimer = (self.blinktimer or 0) + dtime

				if self.blinktimer > 0.2 then

					self.blinktimer = 0

					if self.blinkstatus then
						self:remove_texture_mod("^[brighten")
					else
						self:add_texture_mod("^[brighten")
					end

					self.blinkstatus = not self.blinkstatus
				end

				if self.timer > self.explosion_timer then

					local pos = self.object:get_pos()

					if mobs_griefing and not minetest.is_protected(pos, "") then
						mcl_explosions.explode(mcl_util.get_object_center(self.object), self.explosion_strength, { drop_chance = 1.0 }, self.object)
					else
						minetest.sound_play(self.sounds.explode, {
							pos = pos,
							gain = 1.0,
							max_hear_distance = self.sounds.distance or 32
						}, true)
						self:entity_physics(pos,entity_damage_radius)
						mcl_mobs.effect(pos, 32, "mcl_particles_smoke.png", nil, nil, node_break_radius, 1, 0)
					end
					mcl_burning.extinguish(self.object)
					self.object:remove()

					return true
				end
			end

		elseif self.attack_type == "dogfight"
		or (self.attack_type == "dogshoot" and self:dogswitch(dtime) == 2) and (dist >= self.avoid_distance or not self.shooter_avoid_enemy)
		or (self.attack_type == "dogshoot" and dist <= self.reach and self:dogswitch() == 0) then

			if self.fly
			and dist > self.reach then

				local p1 = s
				local me_y = math.floor(p1.y)
				local p2 = p
				local p_y = math.floor(p2.y + 1)
				local v = self.object:get_velocity()

				if self:flight_check( s) then

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

				if math.abs(p1.x-s.x) + math.abs(p1.z - s.z) < 0.6 then
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

			yaw = (atan(vec.z / vec.x) + math.pi / 2) - self.rotate

			if p.x > s.x then yaw = yaw + math.pi end

			yaw = self:set_yaw( yaw, 0, dtime)

			-- move towards enemy if beyond mob reach
			if dist > self.reach then

				-- path finding by rnd
				if self.pathfinding -- only if mob has pathfinding enabled
				and enable_pathfinding then

					self:smart_mobs(s, p, dist, dtime)
				end

				if is_at_cliff_or_danger(self) then

					self:set_velocity( 0)
					self:set_animation( "stand")
					local yaw = self.object:get_yaw() or 0
					yaw = self:set_yaw( yaw + 0.78, 8)
				else

					if self.path.stuck then
						self:set_velocity( self.walk_velocity)
					else
						self:set_velocity( self.run_velocity)
					end

					if self.animation and self.animation.run_start then
						self:set_animation( "run")
					else
						self:set_animation( "walk")
					end
				end

			else -- rnd: if inside reach range

				self.path.stuck = false
				self.path.stuck_timer = 0
				self.path.following = false -- not stuck anymore

				self:set_velocity( 0)

				if not self.custom_attack then

					if self.timer > 1 then

						self.timer = 0

						if self.double_melee_attack
						and math.random(1, 2) == 1 then
							self:set_animation( "punch2")
						else
							self:set_animation( "punch")
						end

						local p2 = p
						local s2 = s

						p2.y = p2.y + .5
						s2.y = s2.y + .5

						if self:line_of_sight( p2, s2) == true then

							-- play attack sound
							self:mob_sound("attack")

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
		or (self.attack_type == "dogshoot" and self:dogswitch(dtime) == 1)
		or (self.attack_type == "dogshoot" and (dist > self.reach or dist < self.avoid_distance and self.shooter_avoid_enemy) and self:dogswitch() == 0) then

			p.y = p.y - .5
			s.y = s.y + .5

			local dist = vector.distance(p, s)
			local vec = {
				x = p.x - s.x,
				y = p.y - s.y,
				z = p.z - s.z
			}

			yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate

			if p.x > s.x then yaw = yaw +math.pi end

			yaw = self:set_yaw( yaw, 0, dtime)

			local stay_away_from_player = vector.new(0,0,0)

			--strafe back and fourth

			--stay away from player so as to shoot them
			if dist < self.avoid_distance and self.shooter_avoid_enemy then
				self:set_animation( "shoot")
				stay_away_from_player=vector.multiply(vector.direction(p, s), 0.33)
			end

			if self.strafes then
				if not self.strafe_direction then
					self.strafe_direction = 1.57
				end
				if math.random(40) == 1 then
					self.strafe_direction = self.strafe_direction*-1
				end
				self.acc = vector.add(vector.multiply(vector.rotate_around_axis(vector.direction(s, p), vector.new(0,1,0), self.strafe_direction), 0.3*self.walk_velocity), stay_away_from_player)
			else
				self:set_velocity( 0)
			end

			local p = self.object:get_pos()
			p.y = p.y + (self.collisionbox[2] + self.collisionbox[5]) / 2

			if self.shoot_interval
			and self.timer > self.shoot_interval
			and not minetest.raycast(vector.add(p, vector.new(0,self.shoot_offset,0)), vector.add(self.attack:get_pos(), vector.new(0,1.5,0)), false, false):next()
			and math.random(1, 100) <= 60 then

				self.timer = 0
				self:set_animation( "shoot")

				-- play shoot attack sound
				self:mob_sound("shoot_attack")

				-- Shoot arrow
				if minetest.registered_entities[self.arrow] then

					local arrow, ent
					local v = 1
					if not self.shoot_arrow then
						self.firing = true
						minetest.after(1, function()
							self.firing = false
						end)
						arrow = minetest.add_entity(p, self.arrow)
						ent = arrow:get_luaentity()
						if ent.velocity then
							v = ent.velocity
						end
						ent.switch = 1
						ent.owner_id = tostring(self.object) -- add unique owner id to arrow

						-- important for mcl_shields
						ent._shooter = self.object
						ent._saved_shooter_pos = self.object:get_pos()
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
		else

		end
	end
end



local check_herd_timer = 0
local function check_herd(self,dtime)
	local pos = self.object:get_pos()
	if not pos then return end
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
				go_to_pos(self,p)
			elseif y then
				self:set_yaw(y)
			end
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


-- deal damage and effects when mob punched
local mob_punch = function(self, hitter, tflp, tool_capabilities, dir)

	-- custom punch function
	if self.do_punch then

		-- when false skip going any further
		if self.do_punch(self, hitter, tflp, tool_capabilities, dir) == false then
			return
		end
	end

	-- error checking when mod profiling is enabled
	if not tool_capabilities then
		minetest.log("warning", "[mobs] Mod profiling enabled, damage not enabled")
		return
	end

	local is_player = hitter:is_player()

	if is_player then
		-- is mob protected?
		if self.protected and minetest.is_protected(self.object:get_pos(), hitter:get_player_name()) then
			return
		end

		if minetest.is_creative_enabled(hitter:get_player_name()) then
			self.health = 0
		end

		-- set/update 'drop xp' timestamp if hitted by player
		self.xp_timestamp = minetest.get_us_time()
	end


	-- punch interval
	local weapon = hitter:get_wielded_item()
	local punch_interval = 1.4

	-- exhaust attacker
	if is_player then
		mcl_hunger.exhaust(hitter:get_player_name(), mcl_hunger.EXHAUST_ATTACK)
	end

	-- calculate mob damage
	local damage = 0
	local armor = self.object:get_armor_groups() or {}
	local tmp

	-- quick error check incase it ends up 0 (serialize.h check test)
	if tflp == 0 then
		tflp = 0.2
	end


	for group,_ in pairs( (tool_capabilities.damage_groups or {}) ) do

		tmp = tflp / (tool_capabilities.full_punch_interval or 1.4)

		if tmp < 0 then
			tmp = 0.0
		elseif tmp > 1 then
			tmp = 1.0
		end

		damage = damage + (tool_capabilities.damage_groups[group] or 0)
			* tmp * ((armor[group] or 0) / 100.0)
	end

	if weapon then
		local fire_aspect_level = mcl_enchanting.get_enchantment(weapon, "fire_aspect")
		if fire_aspect_level > 0 then
			mcl_burning.set_on_fire(self.object, fire_aspect_level * 4)
		end
	end

	-- check for tool immunity or special damage
	for n = 1, #self.immune_to do

		if self.immune_to[n][1] == weapon:get_name() then

			damage = self.immune_to[n][2] or 0
			break
		end
	end

	-- healing
	if damage <= -1 then
		self.health = self.health - math.floor(damage)
		return
	end

	if tool_capabilities then
		punch_interval = tool_capabilities.full_punch_interval or 1.4
	end

	-- add weapon wear manually
	-- Required because we have custom health handling ("health" property)
	if minetest.is_creative_enabled("") ~= true
	and tool_capabilities then
		if tool_capabilities.punch_attack_uses then
			-- Without this delay, the wear does not work. Quite hacky ...
			minetest.after(0, function(name)
				local player = minetest.get_player_by_name(name)
				if not player then return end
				local weapon = hitter:get_wielded_item(player)
				local def = weapon:get_definition()
				if def.tool_capabilities and def.tool_capabilities.punch_attack_uses then
					local wear = math.floor(65535/tool_capabilities.punch_attack_uses)
					weapon:add_wear(wear)
					hitter:set_wielded_item(weapon)
				end
			end, hitter:get_player_name())
		end
	end

	local die = false


	if damage >= 0 then
		-- only play hit sound and show blood effects if damage is 1 or over; lower to 0.1 to ensure armor works appropriately.
		if damage >= 0.1 then
			-- weapon sounds
			if weapon:get_definition().sounds ~= nil then

				local s = math.random(0, #weapon:get_definition().sounds)

				minetest.sound_play(weapon:get_definition().sounds[s], {
					object = self.object, --hitter,
					max_hear_distance = 8
				}, true)
			else
				minetest.sound_play("default_punch", {
					object = self.object,
					max_hear_distance = 5
				}, true)
			end

			self:damage_effect(damage)

			-- do damage
			self.health = self.health - damage

			-- skip future functions if dead, except alerting others
			if self:check_for_death( "hit", {type = "punch", puncher = hitter}) then
				die = true
			end
		end
		-- knock back effect (only on full punch)
		if self.knock_back
		and tflp >= punch_interval then
			-- direction error check
			dir = dir or {x = 0, y = 0, z = 0}

			local v = self.object:get_velocity()
			if not v then return end
			local r = 1.4 - math.min(punch_interval, 1.4)
			local kb = r * (math.abs(v.x)+math.abs(v.z))
			local up = 2

			if die==true then
				kb=kb*2
			end

			-- if already in air then dont go up anymore when hit
			if math.abs(v.y) > 0.1
			or self.fly then
				up = 0
			end


			-- check if tool already has specific knockback value
			if tool_capabilities.damage_groups["knockback"] then
				kb = tool_capabilities.damage_groups["knockback"]
			else
				kb = kb * 1.5
			end


			local luaentity
			if hitter then
				luaentity = hitter:get_luaentity()
			end
			if hitter and is_player then
				local wielditem = hitter:get_wielded_item()
				kb = kb + 3 * mcl_enchanting.get_enchantment(wielditem, "knockback")
			elseif luaentity and luaentity._knockback then
				kb = kb + luaentity._knockback
			end
			self._kb_turn = true
			self._turn_to=self.object:get_yaw()-1.57
			self.frame_speed_multiplier=2.3
			if self.animation.run_end then
				self:set_animation( "run")
			elseif self.animation.walk_end then
				self:set_animation( "walk")
			end
			minetest.after(0.2, function()
				if self and self.object then
					self.frame_speed_multiplier=1
					self._kb_turn = false
				end
			end)
			self.object:add_velocity({
				x = dir.x * kb,
				y = up*2,
				z = dir.z * kb
			})

			self.pause_timer = 0.25
		end
	end -- END if damage

	-- if skittish then run away
	if hitter and is_player and hitter:get_pos() and not die and self.runaway == true and self.state ~= "flop" then

		local yaw = self:set_yaw( minetest.dir_to_yaw(vector.direction(hitter:get_pos(), self.object:get_pos())))
		minetest.after(0.2,function()
			if self and self.object and self.object:get_pos() and hitter and is_player and hitter:get_pos() then
				yaw = self:set_yaw( minetest.dir_to_yaw(vector.direction(hitter:get_pos(), self.object:get_pos())))
				self:set_velocity( self.run_velocity)
			end
		end)
		self.state = "runaway"
		self.runaway_timer = 0
		self.following = nil
	end

	local name = hitter:get_player_name() or ""

	-- attack puncher and call other mobs for help
	if self.passive == false
	and self.state ~= "flop"
	and (self.child == false or self.type == "monster")
	and hitter:get_player_name() ~= self.owner
	and not mcl_mobs.invis[ name ] then
		if not die then
			-- attack whoever punched mob
			self.state = ""
			self:do_attack(hitter)
			self._aggro= true
		end

		-- alert others to the attack
		local objs = minetest.get_objects_inside_radius(hitter:get_pos(), self.view_range)
		local obj = nil

		for n = 1, #objs do

			obj = objs[n]:get_luaentity()

			if obj then
				-- only alert members of same mob or friends
				if obj.group_attack
				and obj.state ~= "attack"
				and obj.owner ~= name then
					if obj.name == self.name then
						obj:do_attack(hitter)
					elseif type(obj.group_attack) == "table" then
						for i=1, #obj.group_attack do
							if obj.name == obj.group_attack[i] then
								obj._aggro = true
								obj:do_attack(hitter)
								break
							end
						end
					end
				end

				-- have owned mobs attack player threat
				if obj.owner == name and obj.owner_loyal then
					obj:do_attack(self.object)
				end
			end
		end
	end
end

local mob_detach_child = function(self, child)

	if self.detach_child then
		if self.detach_child(self, child) then
			return
		end
	end
	if self.driver == child then
		self.driver = nil
	end

end

-- get entity staticdata
local mob_staticdata = function(self)

	for _,p in pairs(minetest.get_connected_players()) do
		self:remove_particlespawners(p:get_player_name())
	end
	-- remove mob when out of range unless tamed
	if remove_far
	and self.can_despawn
	and self.remove_ok
	and ((not self.nametag) or (self.nametag == ""))
	and self.lifetimer <= 20 then
		if spawn_logging then
			minetest.log("action", "[mcl_mobs] Mob "..tostring(self.name).." despawns at "..minetest.pos_to_string(vector.round(self.object:get_pos())) .. " - out of range")
		end

		return "remove"-- nil
	end

	self.remove_ok = true
	self.attack = nil
	self.following = nil
	self.state = "stand"

	local tmp = {}

	for _,stat in pairs(self) do

		local t = type(stat)

		if  t ~= "function"
		and t ~= "nil"
		and t ~= "userdata"
		and _ ~= "_cmi_components" then
			tmp[_] = self[_]
		end
	end

	return minetest.serialize(tmp)
end


-- activate mob and reload settings
local mob_activate = function(self, staticdata, def, dtime)
	if not self.object:get_pos() or staticdata == "remove" then
		mcl_burning.extinguish(self.object)
		self.object:remove()
		return
	end
	-- remove monsters in peaceful mode
	if self.type == "monster"
	and minetest.settings:get_bool("only_peaceful_mobs", false) then
		mcl_burning.extinguish(self.object)
		self.object:remove()
		return
	end

	-- load entity variables
	local tmp = minetest.deserialize(staticdata)

	if tmp then
		for _,stat in pairs(tmp) do
			self[_] = stat
		end
	end

	-- select random texture, set model and size
	if not self.base_texture then

		-- compatiblity with old simple mobs textures
		if type(def.textures[1]) == "string" then
			def.textures = {def.textures}
		end

		local c = 1
		if #def.textures > c then c = #def.textures end

		self.base_texture = def.textures[math.random(c)]
		self.base_mesh = def.mesh
		self.base_size = self.visual_size
		self.base_colbox = self.collisionbox
		self.base_selbox = self.selectionbox
	end

	-- for current mobs that dont have this set
	if not self.base_selbox then
		self.base_selbox = self.selectionbox or self.base_colbox
	end

	-- set texture, model and size
	local textures = self.base_texture
	local mesh = self.base_mesh
	local vis_size = self.base_size
	local colbox = self.base_colbox
	local selbox = self.base_selbox

	-- specific texture if gotten
	if self.gotten == true
	and def.gotten_texture then
		textures = def.gotten_texture
	end

	-- specific mesh if gotten
	if self.gotten == true
	and def.gotten_mesh then
		mesh = def.gotten_mesh
	end

	-- set child objects to half size
	if self.child == true then

		vis_size = {
			x = self.base_size.x * .5,
			y = self.base_size.y * .5,
		}

		if def.child_texture then
			textures = def.child_texture[1]
		end

		colbox = {
			self.base_colbox[1] * .5,
			self.base_colbox[2] * .5,
			self.base_colbox[3] * .5,
			self.base_colbox[4] * .5,
			self.base_colbox[5] * .5,
			self.base_colbox[6] * .5
		}
		selbox = {
			self.base_selbox[1] * .5,
			self.base_selbox[2] * .5,
			self.base_selbox[3] * .5,
			self.base_selbox[4] * .5,
			self.base_selbox[5] * .5,
			self.base_selbox[6] * .5
		}
	end

	if self.health == 0 then
		self.health = math.random (self.hp_min, self.hp_max)
	end
	if self.breath == nil then
		self.breath = self.breath_max
	end

	-- pathfinding init
	self.path = {}
	self.path.way = {} -- path to follow, table of positions
	self.path.lastpos = {x = 0, y = 0, z = 0}
	self.path.stuck = false
	self.path.following = false -- currently following path?
	self.path.stuck_timer = 0 -- if stuck for too long search for path

	-- Armor groups
	-- immortal=1 because we use custom health
	-- handling (using "health" property)
	local armor
	if type(self.armor) == "table" then
		armor = table.copy(self.armor)
		armor.immortal = 1
	else
		armor = {immortal=1, fleshy = self.armor}
	end
	self.object:set_armor_groups(armor)
	self.old_y = self.object:get_pos().y
	self.old_health = self.health
	self.sounds.distance = self.sounds.distance or 10
	self.textures = textures
	self.mesh = mesh
	self.collisionbox = colbox
	self.selectionbox = selbox
	self.visual_size = vis_size
	self.standing_in = "ignore"
	self.standing_on = "ignore"
	self.jump_sound_cooloff = 0 -- used to prevent jump sound from being played too often in short time
	self.opinion_sound_cooloff = 0 -- used to prevent sound spam of particular sound types

	self.texture_mods = {}
	self.object:set_texture_mod("")

	self.v_start = false
	self.timer = 0
	self.blinktimer = 0
	self.blinkstatus = false

	-- check existing nametag
	if not self.nametag then
		self.nametag = def.nametag
	end
	if not self.custom_visual_size then
		-- Remove saved visual_size on old existing entites.
		self.visual_size = nil
		self.base_size = self.visual_size
		if self.child then
			self.visual_size = {
				x = self.visual_size.x * 0.5,
				y = self.visual_size.y * 0.5,
			}
		end
	end

	-- set anything changed above
	self.object:set_properties(self)
	self:set_yaw( (math.random(0, 360) - 180) / 180 * math.pi, 6)
	self:update_tag()
	self._current_animation = nil
	self:set_animation( "stand")

	-- run on_spawn function if found
	if self.on_spawn and not self.on_spawn_run then
		if self.on_spawn(self) then
			self.on_spawn_run = true --  if true, set flag to run once only
		end
	end

	if not self.wears_armor and self.armor_list then
		self.armor_list = nil
	end

	if not self._run_armor_init and self.wears_armor then
		self.armor_list={helmet="",chestplate="",boots="",leggings=""}
		self:set_armor_texture()
		self._run_armor_init = true
	end


	-- run after_activate
	if def.after_activate then

		def.after_activate(self, staticdata, def, dtime)
	end
end

local function check_aggro(self,dtime)
	if not self._aggro or not self.attack then return end
	if not self._check_aggro_timer or self._check_aggro_timer > 5 then
		self._check_aggro_timer = 0
		if not self.attack:get_pos() or vector.distance(self.attack:get_pos(),self.object:get_pos()) > 128 then
			self._aggro = nil
			self.attack = nil
			self.state = "stand"
		end
	end
	self._check_aggro_timer = self._check_aggro_timer + dtime
end

-- main mob function
local mob_step = function(self, dtime)
	self.lifetimer = self.lifetimer - dtime

	local pos = self.object:get_pos()
	-- Despawning: when lifetimer expires, remove mob
	if remove_far
	and self.can_despawn == true
	and ((not self.nametag) or (self.nametag == ""))
	and self.state ~= "attack"
	and self.following == nil then
		if self.despawn_immediately or self.lifetimer <= 0 then
			if spawn_logging then
				minetest.log("action", "[mcl_mobs] Mob "..self.name.." despawns at "..minetest.pos_to_string(pos, 1) .. " lifetimer ran out")
			end
			mcl_burning.extinguish(self.object)
			self.object:remove()
			return
		elseif self.lifetimer <= 10 then
			if math.random(10) < 4 then
				self.despawn_immediately = true
			else
				self.lifetimer = 20
			end
		end
	end

	local v = self.object:get_velocity()
	local d = 0.85

	if (self.state and self.state=="die" or self:check_for_death()) and not self.animation.die_end then
		d = 0.92
		local rot = self.object:get_rotation()
		rot.z = ((math.pi/2-rot.z)*.2)+rot.z
		self.object:set_rotation(rot)
	end

	if not self:player_in_active_range() then
		self:set_animation( "stand", true)
		local node_under = node_ok(vector.offset(pos,0,-1,0)).name
		local acc = self.object:get_acceleration()
		if acc.y > 0 or node_under ~= "air" then
			self.object:set_acceleration(vector.new(0,0,0))
			self.object:set_velocity(vector.new(0,0,0))
		end
		if acc.y == 0 and node_under == "air" then
			self:falling(pos)
		end
		return
	end

	if v then
		--diffuse object velocity
		self.object:set_velocity({x = v.x*d, y = v.y, z = v.z*d})
	end

	check_aggro(self,dtime)
	self:check_item_pickup()

	self:check_particlespawners(dtime)
	if not self.fire_resistant then
		mcl_burning.tick(self.object, dtime, self)
		-- mcl_burning.tick may remove object immediately
		if not self.object:get_pos() then return end
	end

	local yaw = 0

	if mobs_debug then
		self:update_tag()
	end

	if self.state == "die" then
		return
	end

	if self.jump_sound_cooloff > 0 then
		self.jump_sound_cooloff = self.jump_sound_cooloff - dtime
	end
	if self.opinion_sound_cooloff > 0 then
		self.opinion_sound_cooloff = self.opinion_sound_cooloff - dtime
	end
	if self:falling(pos) then
		-- Return if mob died after falling
		return
	end

	--Mob following code.
	follow_flop(self)

	--set animation speed relitive to velocity
	local v = self.object:get_velocity()
	if v then
		if self.frame_speed_multiplier then
			local v2 = math.abs(v.x)+math.abs(v.z)*.833
			if not self.animation.walk_speed then
				self.animation.walk_speed = 25
			end
			if math.abs(v.x)+math.abs(v.z) > 0.5 then
				self.object:set_animation_frame_speed((v2/math.max(1,self.run_velocity))*self.animation.walk_speed*self.frame_speed_multiplier)
			else
				self.object:set_animation_frame_speed(25)
			end
		end

		--set_speed
		if self.acc then
			self.object:add_velocity(self.acc)
		end
	end


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
		self:update_roll()
	end

	-- end rotation

	if self.head_swivel and type(self.head_swivel) == "string" then
		local final_rotation = vector.new(0,0,0)
		local oldp,oldr = self.object:get_bone_position(self.head_swivel)

		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 10)) do
			if obj:is_player() and not self.attack or obj:get_luaentity() and obj:get_luaentity().name == self.name and self ~= obj:get_luaentity() then
				if not self._locked_object then
					if math.random(5000/self.curiosity) == 1 or vector.distance(pos,obj:get_pos())<4 and obj:is_player() then
						self._locked_object = obj
					end
				else
					if math.random(10000/self.curiosity) == 1 then
						self._locked_object = nil
					end
				end
			end
		end

		if self.attack or self.following then
			self._locked_object = self.attack or self.following
		end

		if self._locked_object and (self._locked_object:is_player() or self._locked_object:get_luaentity()) and self._locked_object:get_hp() > 0 then
			local _locked_object_eye_height = 1.5
			if self._locked_object:get_luaentity() then
				_locked_object_eye_height = self._locked_object:get_luaentity().head_eye_height
			end
			if self._locked_object:is_player() then
				_locked_object_eye_height = self._locked_object:get_properties().eye_height
			end
			if _locked_object_eye_height then
				local self_rot = self.object:get_rotation()
				if self.object:get_attach() then
					self_rot = self.object:get_attach():get_rotation()
				end
				if self.rot then
					local player_pos = self._locked_object:get_pos()
					local direction_player = vector.direction(vector.add(self.object:get_pos(), vector.new(0, self.head_eye_height*.7, 0)), vector.add(player_pos, vector.new(0, _locked_object_eye_height, 0)))
					local mob_yaw = math.deg(-(-(self_rot.y)-(-minetest.dir_to_yaw(direction_player))))+self.head_yaw_offset
					local mob_pitch = math.deg(-dir_to_pitch(direction_player))*self.head_pitch_multiplier

					if (mob_yaw < -60 or mob_yaw > 60) and not (self.attack and self.state == "attack" and not self.runaway) then
						final_rotation = vector.multiply(oldr, 0.9)
					elseif self.attack and self.state == "attack" and not self.runaway then
						if self.head_yaw == "y" then
							final_rotation = vector.new(mob_pitch, mob_yaw, 0)
						elseif self.head_yaw == "z" then
							final_rotation = vector.new(mob_pitch, 0, -mob_yaw)
						end

					else

						if self.head_yaw == "y" then
							final_rotation = vector.new(((mob_pitch-oldr.x)*.3)+oldr.x, ((mob_yaw-oldr.y)*.3)+oldr.y, 0)
						elseif self.head_yaw == "z" then
							final_rotation = vector.new(((mob_pitch-oldr.x)*.3)+oldr.x, 0, -(((mob_yaw-oldr.y)*.3)+oldr.y)*3)
						end
					end
				end
			end
		elseif not self._locked_object and math.abs(oldr.y) > 3 and math.abs(oldr.x) < 3 then
			final_rotation = vector.multiply(oldr, 0.9)
		else
			final_rotation = vector.new(0,0,0)
		end

		mcl_util.set_bone_position(self.object,self.head_swivel, vector.new(0,self.bone_eye_height,self.horrizonatal_head_height), final_rotation)

	end


	-- run custom function (defined in mob lua file)
	if self.do_custom then

		-- when false skip going any further
		if self.do_custom(self, dtime) == false then
			return
		end
	end

	-- knockback timer
	if self.pause_timer > 0 then

		self.pause_timer = self.pause_timer - dtime

		return
	end

	-- attack timer
	self.timer = self.timer + dtime

	if self.state ~= "attack" and self.state ~= PATHFINDING then
		if self.timer < 1 then
			return
		end

		self.timer = 0
	end

	-- never go over 100
	if self.timer > 100 then
		self.timer = 1
	end

	-- mob plays random sound at times
	if math.random(1, 70) == 1 then
		self:mob_sound("random", true)
	end

	-- environmental damage timer (every 1 second)
	self.env_damage_timer = self.env_damage_timer + dtime

	if (self.state == "attack" and self.env_damage_timer > 1)
	or self.state ~= "attack" then
		self:check_entity_cramming()
		self.env_damage_timer = 0

		-- check for environmental damage (water, fire, lava etc.)
		if self:do_env_damage() then
			return
		end

		-- node replace check (cow eats grass etc.)
		replace(self, pos)
	end

	self:monster_attack()

	self:npc_attack()

	self:check_breeding()

	if do_states(self, dtime) then
		return
	end

	if not self.object:get_luaentity() then
		return false
	end

	do_jump(self)

	self:set_armor_texture()

	runaway_from(self)

	if is_at_water_danger(self) and self.state ~= "attack" then
		if math.random(1, 10) <= 6 then
			self:set_velocity(0)
			self.state = "stand"
			self:set_animation( "stand")
			yaw = yaw + math.random(-0.5, 0.5)
			yaw = self:set_yaw( yaw, 8)
		end
	else
		if self.move_in_group ~= false then
			check_herd(self,dtime)
		end
	end

	-- Add water flowing for mobs from mcl_item_entity
		local p, node, nn, def
		p = self.object:get_pos()
		node = minetest.get_node_or_nil(p)
		if node then
			nn = node.name
			def = minetest.registered_nodes[nn]
		end

		-- Move item around on flowing liquids
		if def and def.liquidtype == "flowing" then

			--[[ Get flowing direction (function call from flowlib), if there's a liquid.
			NOTE: According to Qwertymine, flowlib.quickflow is only reliable for liquids with a flowing distance of 7.
			Luckily, this is exactly what we need if we only care about water, which has this flowing distance. ]]
			local vec = flowlib.quick_flow(p, node)
			-- Just to make sure we don't manipulate the speed for no reason
			if vec.x ~= 0 or vec.y ~= 0 or vec.z ~= 0 then
				-- Minecraft Wiki: Flowing speed is "about 1.39 meters per second"
				local f = 1.39
				-- Set new item moving speed into the direciton of the liquid
				local newv = vector.multiply(vec, f)
				self.object:set_acceleration({x = 0, y = 0, z = 0})
				self.object:set_velocity({x = newv.x, y = -0.22, z = newv.z})

				self.physical_state = true
				self._flowing = true
				self.object:set_properties({
					physical = true
				})
				return
			end
		elseif self._flowing == true then
			-- Disable flowing physics if not on/in flowing liquid
			self._flowing = false
			return
		end

	if is_at_cliff_or_danger(self) then
			self:set_velocity(0)
			self.state = "stand"
			self:set_animation( "stand")
			local yaw = self.object:get_yaw() or 0
			yaw = self:set_yaw( yaw + 0.78, 8)
	end
end


-- default function when mobs are blown up with TNT
local do_tnt = function(obj, damage)

	obj.object:punch(obj.object, 1.0, {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = damage},
	}, nil)

	return false, true, {}
end


mcl_mobs.spawning_mobs = {}

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

			self:update_tag()

			if not minetest.is_creative_enabled(clicker:get_player_name()) then
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

-- register mob entity
function mcl_mobs.register_mob(name, def)

	mcl_mobs.spawning_mobs[name] = true

local can_despawn
if def.can_despawn ~= nil then
	can_despawn = def.can_despawn
elseif def.spawn_class == "passive" then
	can_despawn = false
else
	can_despawn = true
end

local function scale_difficulty(value, default, min, special)
	if (not value) or (value == default) or (value == special) then
		return default
	else
		return math.max(min, value * difficulty)
	end
end

local collisionbox = def.collisionbox or {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}
-- Workaround for <https://github.com/minetest/minetest/issues/5966>:
-- Increase upper Y limit to avoid mobs glitching through solid nodes.
-- FIXME: Remove workaround if it's no longer needed.
if collisionbox[5] < 0.79 then
	collisionbox[5] = 0.79
end

minetest.register_entity(name, setmetatable({

	use_texture_alpha = def.use_texture_alpha,
	head_swivel = def.head_swivel or nil, -- bool to activate this function
	head_yaw_offset = def.head_yaw_offset or 0, -- for wonkey model bones
	head_pitch_multiplier = def.head_pitch_multiplier or 1, --for inverted pitch
	bone_eye_height = def.bone_eye_height or 1.4, -- head bone offset
	head_eye_height = def.head_eye_height or def.bone_eye_height or 0, -- how hight aproximatly the mobs head is fromm the ground to tell the mob how high to look up at the player
	curiosity = def.curiosity or 1, -- how often mob will look at player on idle
	head_yaw = def.head_yaw or "y", -- axis to rotate head on
	horrizonatal_head_height = def.horrizonatal_head_height or 0,
	wears_armor = def.wears_armor, -- a number value used to index texture slot for armor
	stepheight = def.stepheight or 0.6,
	name = name,
	description = def.description,
	type = def.type,
	attack_type = def.attack_type,
	fly = def.fly,
	fly_in = def.fly_in or {"air", "__airlike"},
	owner = def.owner or "",
	order = def.order or "",
	on_die = def.on_die,
	spawn_small_alternative = def.spawn_small_alternative,
	do_custom = def.do_custom,
	detach_child = def.detach_child,
	jump_height = def.jump_height or 4, -- was 6
	rotate = math.rad(def.rotate or 0), --  0=front, 90=side, 180=back, 270=side2
	lifetimer = def.lifetimer or 57.73,
	hp_min = scale_difficulty(def.hp_min, 5, 1),
	hp_max = scale_difficulty(def.hp_max, 10, 1),
	xp_min = def.xp_min or 0,
	xp_max = def.xp_max or 0,
	xp_timestamp = 0,
	breath_max = def.breath_max or 15,
	breathes_in_water = def.breathes_in_water or false,
	physical = true,
	collisionbox = collisionbox,
	selectionbox = def.selectionbox or def.collisionbox,
	visual = def.visual,
	visual_size = def.visual_size or {x = 1, y = 1},
	mesh = def.mesh,
	makes_footstep_sound = def.makes_footstep_sound or false,
	view_range = def.view_range or 16,
	walk_velocity = def.walk_velocity or 1,
	run_velocity = def.run_velocity or 2,
	damage = scale_difficulty(def.damage, 0, 0),
	light_damage = def.light_damage or 0,
	sunlight_damage = def.sunlight_damage or 0,
	water_damage = def.water_damage or 0,
	lava_damage = def.lava_damage or 8,
	fire_damage = def.fire_damage or 1,
	suffocation = def.suffocation or true,
	fall_damage = def.fall_damage or 1,
	fall_speed = def.fall_speed or DEFAULT_FALL_SPEED, -- must be lower than -2
	drops = def.drops or {},
	armor = def.armor or 100,
	on_rightclick = create_mob_on_rightclick(def.on_rightclick),
	arrow = def.arrow,
	shoot_interval = def.shoot_interval,
	sounds = def.sounds or {},
	animation = def.animation or {},
	follow = def.follow,
	nofollow = def.nofollow,
	can_open_doors = def.can_open_doors,
	jump = def.jump ~= false,
	automatic_face_movement_max_rotation_per_sec = 300,
	walk_chance = def.walk_chance or 50,
	attacks_monsters = def.attacks_monsters or false,
	group_attack = def.group_attack or false,
	passive = def.passive or false,
	knock_back = def.knock_back ~= false,
	shoot_offset = def.shoot_offset or 0,
	floats = def.floats or 1, -- floats in water by default
	floats_on_lava = def.floats_on_lava or 0,
	replace_rate = def.replace_rate,
	replace_what = def.replace_what,
	replace_with = def.replace_with,
	replace_offset = def.replace_offset or 0,
	on_replace = def.on_replace,
	timer = 0,
	env_damage_timer = 0,
	tamed = false,
	pause_timer = 0,
	horny = false,
	hornytimer = 0,
	gotten = false,
	health = 0,
	frame_speed_multiplier = 1,
	reach = def.reach or 3,
	htimer = 0,
	texture_list = def.textures,
	child_texture = def.child_texture,
	docile_by_day = def.docile_by_day or false,
	time_of_day = 0.5,
	fear_height = def.fear_height or 0,
	runaway = def.runaway,
	runaway_timer = 0,
	pathfinding = def.pathfinding,
	immune_to = def.immune_to or {},
	explosion_radius = def.explosion_radius, -- LEGACY
	explosion_damage_radius = def.explosion_damage_radius, -- LEGACY
	explosiontimer_reset_radius = def.explosiontimer_reset_radius,
	explosion_timer = def.explosion_timer or 3,
	allow_fuse_reset = def.allow_fuse_reset ~= false,
	stop_to_explode = def.stop_to_explode ~= false,
	custom_attack = def.custom_attack,
	double_melee_attack = def.double_melee_attack,
	dogshoot_switch = def.dogshoot_switch,
	dogshoot_count = 0,
	dogshoot_count_max = def.dogshoot_count_max or 5,
	dogshoot_count2_max = def.dogshoot_count2_max or (def.dogshoot_count_max or 5),
	attack_animals = def.attack_animals or false,
	attack_npcs = def.attack_npcs or false,
	specific_attack = def.specific_attack,
	runaway_from = def.runaway_from,
	owner_loyal = def.owner_loyal,
	facing_fence = false,
	is_mob = true,
	pushable = def.pushable or true,


	-- MCL2 extensions
	shooter_avoid_enemy = def.shooter_avoid_enemy,
	strafes = def.strafes,
	avoid_distance = def.avoid_distance or 9,
	teleport = teleport,
	do_teleport = def.do_teleport,
	spawn_class = def.spawn_class,
	can_spawn = def.can_spawn,
	ignores_nametag = def.ignores_nametag or false,
	rain_damage = def.rain_damage or 0,
	glow = def.glow,
	can_despawn = can_despawn,
	child = def.child or false,
	texture_mods = {},
	shoot_arrow = def.shoot_arrow,
    sounds_child = def.sounds_child,
	_child_animations = def.child_animations,
    pick_up = def.pick_up,
	explosion_strength = def.explosion_strength,
	suffocation_timer = 0,
	follow_velocity = def.follow_velocity or 2.4,
	instant_death = def.instant_death or false,
	fire_resistant = def.fire_resistant or false,
	fire_damage_resistant = def.fire_damage_resistant or false,
	ignited_by_sunlight = def.ignited_by_sunlight or false,
	spawn_in_group = def.spawn_in_group,
	spawn_in_group_min = def.spawn_in_group_min,
	noyaw = def.noyaw or false,
	particlespawners = def.particlespawners,
	-- End of MCL2 extensions

	on_spawn = def.on_spawn,

	on_blast = def.on_blast or do_tnt,

	on_step = mob_step,

	do_punch = def.do_punch,

	on_punch = mob_punch,

	on_breed = def.on_breed,

	on_grown = def.on_grown,

	on_pick_up = def.on_pick_up,

	on_detach_child = mob_detach_child,

	on_activate = function(self, staticdata, dtime)
		--this is a temporary hack so mobs stop
		--glitching and acting really weird with the
		--default built in engine collision detection
		self.is_mob = true
		self.object:set_properties({
			collide_with_objects = false,
		})

		return mob_activate(self, staticdata, def, dtime)
	end,

	get_staticdata = function(self)
		return mob_staticdata(self)
	end,

	harmed_by_heal = def.harmed_by_heal,

	on_lightning_strike = def.on_lightning_strike
},mob_class_meta))

if minetest.get_modpath("doc_identifier") ~= nil then
	doc.sub.identifier.register_object(name, "basics", "mobs")
end

end -- END mcl_mobs.register_mob function


-- register arrow for shoot attack
function mcl_mobs.register_arrow(name, def)

	if not name or not def then return end -- errorcheck

	minetest.register_entity(name, setmetatable({

		physical = false,
		visual = def.visual,
		visual_size = def.visual_size,
		textures = def.textures,
		velocity = def.velocity,
		hit_player = def.hit_player,
		hit_node = def.hit_node,
		hit_mob = def.hit_mob,
		hit_object = def.hit_object,
		drop = def.drop or false, -- drops arrow as registered item when true
		collisionbox = {0, 0, 0, 0, 0, 0}, -- remove box around arrows
		timer = 0,
		switch = 0,
		owner_id = def.owner_id,
		rotate = def.rotate,
		on_punch = function(self)
			local vel = self.object:get_velocity()
			self.object:set_velocity({x=vel.x * -1, y=vel.y * -1, z=vel.z * -1})
		end,
		collisionbox = def.collisionbox or {0, 0, 0, 0, 0, 0},
		automatic_face_movement_dir = def.rotate
			and (def.rotate - (math.pi / 180)) or false,

		on_activate = def.on_activate,

		on_step = def.on_step or function(self, dtime)

			self.timer = self.timer + 1

			local pos = self.object:get_pos()

			if self.switch == 0
			or self.timer > 150
			or not within_limits(pos, 0) then
				mcl_burning.extinguish(self.object)
				self.object:remove();

				return
			end

			-- does arrow have a tail (fireball)
			if def.tail
			and def.tail == 1
			and def.tail_texture then

				minetest.add_particle({
					pos = pos,
					velocity = {x = 0, y = 0, z = 0},
					acceleration = {x = 0, y = 0, z = 0},
					expirationtime = def.expire or 0.25,
					collisiondetection = false,
					texture = def.tail_texture,
					size = def.tail_size or 5,
					glow = def.glow or 0,
				})
			end

			if self.hit_node then

				local node = node_ok(pos).name

				if minetest.registered_nodes[node].walkable then

					self.hit_node(self, pos, node)

					if self.drop == true then

						pos.y = pos.y + 1

						self.lastpos = (self.lastpos or pos)

						minetest.add_item(self.lastpos, self.object:get_luaentity().name)
					end

					self.object:remove();

					return
				end
			end

			if self.hit_player or self.hit_mob or self.hit_object then

				for _,player in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do

					if self.hit_player
					and player:is_player() then

						self.hit_player(self, player)
						self.object:remove();
						return
					end

					local entity = player:get_luaentity()

					if entity
					and self.hit_mob
					and entity.is_mob == true
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name then
						self.hit_mob(self, player)
						self.object:remove();
						return
					end

					if entity
					and self.hit_object
					and (not entity.is_mob)
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name then
						self.hit_object(self, player)
						self.object:remove();
						return
					end
				end
			end

			self.lastpos = pos
		end
	},mob_class))
end

-- Register spawn eggs

-- Note: This also introduces the “spawn_egg” group:
-- * spawn_egg=1: Spawn egg (generic mob, no metadata)
-- * spawn_egg=2: Spawn egg (captured/tamed mob, metadata)
function mcl_mobs.register_egg(mob, desc, background_color, overlay_color, addegg, no_creative)

	local grp = {spawn_egg = 1}

	-- do NOT add this egg to creative inventory (e.g. dungeon master)
	if no_creative == true then
		grp.not_in_creative_inventory = 1
	end

	local invimg = "(spawn_egg.png^[multiply:" .. background_color ..")^(spawn_egg_overlay.png^[multiply:" .. overlay_color .. ")"
	if old_spawn_icons then
		local mobname = mob:gsub("mobs_mc:","")
		local fn = "mobs_mc_spawn_icon_"..mobname..".png"
		if mcl_util.file_exists(minetest.get_modpath("mobs_mc").."/textures/"..fn) then
			invimg = fn
		end
	end
	if addegg == 1 then
		invimg = "mobs_chicken_egg.png^(" .. invimg ..
			"^[mask:mobs_chicken_egg_overlay.png)"
	end

	-- register old stackable mob egg
	minetest.register_craftitem(mob, {

		description = desc,
		inventory_image = invimg,
		groups = grp,

		_doc_items_longdesc = S("This allows you to place a single mob."),
		_doc_items_usagehelp = S("Just place it where you want the mob to appear. Animals will spawn tamed, unless you hold down the sneak key while placing. If you place this on a mob spawner, you change the mob it spawns."),

		on_place = function(itemstack, placer, pointed_thing)

			local pos = pointed_thing.above

			-- am I clicking on something with existing on_rightclick function?
			local under = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[under.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, under, placer, itemstack)
			end

			if pos
			and within_limits(pos, 0)
			and not minetest.is_protected(pos, placer:get_player_name()) then

				local name = placer:get_player_name()
				local privs = minetest.get_player_privs(name)
				if under.name == "mcl_mobspawners:spawner" then
					if minetest.is_protected(pointed_thing.under, name) then
						minetest.record_protection_violation(pointed_thing.under, name)
						return itemstack
					end
					if not privs.maphack then
						minetest.chat_send_player(name, S("You need the “maphack” privilege to change the mob spawner."))
						return itemstack
					end
					mcl_mobspawners.setup_spawner(pointed_thing.under, itemstack:get_name())
					if not minetest.is_creative_enabled(name) then
						itemstack:take_item()
					end
					return itemstack
				end

				if not minetest.registered_entities[mob] then
					return itemstack
				end

				if minetest.settings:get_bool("only_peaceful_mobs", false)
						and minetest.registered_entities[mob].type == "monster" then
					minetest.chat_send_player(name, S("Only peaceful mobs allowed!"))
					return itemstack
				end

				pos.y = pos.y - 0.5

				local mob = minetest.add_entity(pos, mob)
				local entityname = itemstack:get_name()
				minetest.log("action", "Player " ..name.." spawned "..entityname.." at "..minetest.pos_to_string(pos))
				local ent = mob:get_luaentity()

				-- don't set owner if monster or sneak pressed
				if ent.type ~= "monster"
				and not placer:get_player_control().sneak then
					ent.owner = placer:get_player_name()
					ent.tamed = true
				end

				-- set nametag
				local nametag = itemstack:get_meta():get_string("name")
				if nametag ~= "" then
					if string.len(nametag) > MAX_MOB_NAME_LENGTH then
						nametag = string.sub(nametag, 1, MAX_MOB_NAME_LENGTH)
					end
					ent.nametag = nametag
					update_tag(ent)
				end

				-- if not in creative then take item
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
			end

			return itemstack
		end,
	})

end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer < 1 then return end
	for _, player in pairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 47)) do
			local lua = obj:get_luaentity()
			if lua and lua.is_mob then
				lua.lifetimer = math.max(20, lua.lifetimer)
				lua.despawn_immediately = false
			end
		end
	end
	timer = 0
end)
