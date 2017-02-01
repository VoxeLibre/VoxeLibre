
-- Mobs Api (1st December 2016)

mobs = {}
mobs.mod = "redo"

-- Intllib
local S
if minetest.get_modpath("intllib") then
	S = intllib.Getter()
else
	S = function(s, a, ...)
		if a == nil then
			return s
		end
		a = {a, ...}
		return s:gsub("(@?)@(%(?)(%d+)(%)?)",
			function(e, o, n, c)
				if e == "" then
					return a[tonumber(n)] .. (o == "" and c or "")
				else
					return "@" .. o .. n .. c
				end
			end)
	end
end
mobs.intllib = S

-- Invisibility mod check
mobs.invis = {}
if rawget(_G, "invisibility") then
	mobs.invis = invisibility
end

-- Load settings
local damage_enabled = minetest.setting_getbool("enable_damage")
local peaceful_only = minetest.setting_getbool("only_peaceful_mobs")
local disable_blood = minetest.setting_getbool("mobs_disable_blood")
local creative = minetest.setting_getbool("creative_mode")
local spawn_protected = tonumber(minetest.setting_get("mobs_spawn_protected")) or 1
local remove_far = minetest.setting_getbool("remove_far_mobs")
local difficulty = tonumber(minetest.setting_get("mob_difficulty")) or 1.0

-- pathfinding settings
local enable_pathfinding = true
local stuck_timeout = 3 -- how long before mob gets stuck in place and starts searching
local stuck_path_timeout = 10 -- how long will mob follow path before giving up

-- localize functions
local pi = math.pi
local square = math.sqrt
local sin = math.sin
local cos = math.cos
local abs = math.abs
local min = math.min
local max = math.max
local atann = math.atan
local random = math.random
local floor = math.floor
local atan = function(x)

	if x ~= x then
		--error("atan bassed NaN")
		--print ("atan based NaN")
		return 0
	else
		return atann(x)
	end
end

local do_attack = function(self, player)

	if self.state ~= "attack" then

		if random(0,100) < 90
		and self.sounds.war_cry then

			minetest.sound_play(self.sounds.war_cry, {
				object = self.object,
				max_hear_distance = self.sounds.distance
			})
		end

		self.state = "attack"
		self.attack = player
	end
end

local set_velocity = function(self, v)

	local yaw = self.object:getyaw() + self.rotate or 0

	self.object:setvelocity({
		x = sin(yaw) * -v,
		y = self.object:getvelocity().y,
		z = cos(yaw) * v
	})
end

local get_velocity = function(self)

	local v = self.object:getvelocity()

	return (v.x * v.x + v.z * v.z) ^ 0.5
end

local set_animation = function(self, type)

	if not self.animation then
		return
	end

	self.animation.current = self.animation.current or ""

	self.animation.speed_normal = self.animation.speed_normal or 15

	if type == "stand"
	and self.animation.current ~= "stand" then

		if self.animation.stand_start
		and self.animation.stand_end then

			self.object:set_animation({
				x = self.animation.stand_start,
				y = self.animation.stand_end},
				(self.animation.speed_stand or self.animation.speed_normal), 0)

			self.animation.current = "stand"
		end

	elseif type == "walk"
	and self.animation.current ~= "walk" then

		if self.animation.walk_start
		and self.animation.walk_end then

			self.object:set_animation({
				x = self.animation.walk_start,
				y = self.animation.walk_end},
				(self.animation.speed_walk or self.animation.speed_normal), 0)

			self.animation.current = "walk"
		end

	elseif type == "run"
	and self.animation.current ~= "run" then

		if self.animation.run_start
		and self.animation.run_end then

			self.object:set_animation({
				x = self.animation.run_start,
				y = self.animation.run_end},
				(self.animation.speed_run or self.animation.speed_normal), 0)

			self.animation.current = "run"
		end

	elseif type == "punch"
	and self.animation.current ~= "punch" then

		if self.animation.punch_start
		and self.animation.punch_end then

			self.object:set_animation({
				x = self.animation.punch_start,
				y = self.animation.punch_end},
				(self.animation.speed_punch or self.animation.speed_normal), 0)

			self.animation.current = "punch"
		end
	elseif type == "punch2"
	and self.animation.current ~= "punch2" then

		if self.animation.punch2_start
		and self.animation.punch2_end then

			self.object:set_animation({
				x = self.animation.punch2_start,
				y = self.animation.punch2_end},
				(self.animation.speed_punch2 or self.animation.speed_normal), 0)

			self.animation.current = "punch2"
		end
	elseif type == "shoot"
	and self.animation.current ~= "shoot" then

		if self.animation.shoot_start
		and self.animation.shoot_end then

			self.object:set_animation({
				x = self.animation.shoot_start,
				y = self.animation.shoot_end},
				(self.animation.speed_shoot or self.animation.speed_normal), 0)

			self.animation.current = "shoot"
		end
	end
end

-- check line of sight for walkers and swimmers alike
local function line_of_sight_water(self, pos1, pos2, stepsize)

	local s, pos_w = minetest.line_of_sight(pos1, pos2, stepsize)

	-- normal walking and flying mobs can see you through air
	if s == true then
		return true
	end

	-- swimming mobs can see you through water
	if s == false
	and self.fly
	and self.fly_in == "mcl_core:water_source" then

		local nod = minetest.get_node(pos_w).name

		if nod == "mcl_core:water_source"
		or nod == "mcl_core:water_flowing" then

			return true
		end

	-- just incase we have a special node for flying/swimming mobs
	elseif s == false
	and self.fly
	and self.fly_in then

		local nod = minetest.get_node(pos_w).name

		if nod == self.fly_in then
			return true
		end
	end

	return false

end

-- particle effects
local function effect(pos, amount, texture, min_size, max_size, radius, gravity)

	radius = radius or 2
	min_size = min_size or 0.5
	max_size = max_size or 1
	gravity = gravity or -10

	minetest.add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = -radius, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size,
		maxsize = max_size,
		texture = texture,
	})
end

-- check if mob is dead or only hurt
local function check_for_death(self)

	-- has health actually changed?
	if self.health == self.old_health then
		return
	end

	self.old_health = self.health

	-- still got some health? play hurt sound
	if self.health > 0 then

		if self.sounds.damage then

			minetest.sound_play(self.sounds.damage, {
				object = self.object,
				gain = 1.0,
				max_hear_distance = self.sounds.distance
			})
		end

		-- make sure health isn't higher than max
		if self.health > self.hp_max then
			self.health = self.hp_max
		end

		-- backup nametag so we can show health stats
		if not self.nametag2 then
			self.nametag2 = self.nametag or ""
		end

		self.htimer = 2

		return false
	end

	-- drop items when dead
	local obj
	local pos = self.object:getpos()

	for n = 1, #self.drops do

		if random(1, self.drops[n].chance) == 1 then

			obj = minetest.add_item(pos,
				ItemStack(self.drops[n].name .. " "
					.. random(self.drops[n].min, self.drops[n].max)))

			if obj then

				obj:setvelocity({
					x = random(-10, 10) / 9,
					y = 5,
					z = random(-10, 10) / 9,
				})
			end
		end
	end

	-- play death sound
	if self.sounds.death then

		minetest.sound_play(self.sounds.death, {
			object = self.object,
			gain = 1.0,
			max_hear_distance = self.sounds.distance
		})
	end

	-- execute custom death function
	if self.on_die then

		self.on_die(self, pos)
		self.object:remove()

		return true
	end

	-- default death function
	self.object:remove()

	effect(pos, 20, "tnt_smoke.png")

	return true
end

-- check if within physical map limits (-30911 to 30927)
local function within_limits(pos, radius)

	if  (pos.x - radius) > -30913
	and (pos.x + radius) <  30928
	and (pos.y - radius) > -30913
	and (pos.y + radius) <  30928
	and (pos.z - radius) > -30913
	and (pos.z + radius) <  30928 then
		return true -- within limits
	end

	return false -- beyond limits
end

-- is mob facing a cliff
local function is_at_cliff(self)

	if self.fear_height == 0 then -- 0 for no falling protection!
		return false
	end

	local yaw = self.object:getyaw()
	local dir_x = -sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = cos(yaw) * (self.collisionbox[4] + 0.5)
	local pos = self.object:getpos()
	local ypos = pos.y + self.collisionbox[2] -- just above floor

	if minetest.line_of_sight(
		{x = pos.x + dir_x, y = ypos, z = pos.z + dir_z},
		{x = pos.x + dir_x, y = ypos - self.fear_height, z = pos.z + dir_z}
	, 1) then

		return true
	end

	return false
end

-- get node but use fallback for nil or unknown
local function node_ok(pos, fallback)

	fallback = fallback or "mcl_core:dirt"

	local node = minetest.get_node_or_nil(pos)

	if not node then
		return minetest.registered_nodes[fallback]
	end

	if minetest.registered_nodes[node.name] then
		return node
	end

	return minetest.registered_nodes[fallback]
end

-- environmental damage (water, lava, fire, light)
local do_env_damage = function(self)

	-- feed/tame text timer (so mob 'full' messages dont spam chat)
	if self.htimer > 0 then
		self.htimer = self.htimer - 1
	end

	-- reset nametag after showing health stats
	if self.htimer < 1 and self.nametag2 then

		self.nametag = self.nametag2
		self.nametag2 = nil
	end

	local pos = self.object:getpos()

	self.time_of_day = minetest.get_timeofday()

	-- remove mob if beyond map limits
	if not within_limits(pos, 0) then
		self.object:remove()
		return
	end

	-- daylight above ground
	if self.light_damage ~= 0
	and pos.y > 0
	and self.time_of_day > 0.2
	and self.time_of_day < 0.8
	and (minetest.get_node_light(pos) or 0) > 12 then

		self.health = self.health - self.light_damage

		effect(pos, 5, "tnt_smoke.png")
	end

	-- what is mob standing in?
	pos.y = pos.y + self.collisionbox[2] + 0.1 -- foot level
	self.standing_in = node_ok(pos, "air").name
	--print ("standing in " .. self.standing_in)

	if self.water_damage ~= 0
	or self.lava_damage ~= 0 then

		local nodef = minetest.registered_nodes[self.standing_in]

		pos.y = pos.y + 1

		-- water
		if self.water_damage ~= 0
		and nodef.groups.water then

			self.health = self.health - self.water_damage

			effect(pos, 5, "bubble.png")
		end

		-- lava or fire
		if self.lava_damage ~= 0
		and (nodef.groups.lava
		or self.standing_in == "mcl_fire:basic_flame"
		or self.standing_in == "mcl_fire:permanent_flame") then

			self.health = self.health - self.lava_damage

			effect(pos, 5, "fire_basic_flame.png")
		end
	end

	check_for_death(self)
end

-- jump if facing a solid node (not fences or gates)
local do_jump = function(self)

	if self.fly
	or self.child then
		return
	end

	local pos = self.object:getpos()

	-- what is mob standing on?
	pos.y = pos.y + self.collisionbox[2] - 0.2

	local nod = node_ok(pos)

--print ("standing on:", nod.name, pos.y)

	if minetest.registered_nodes[nod.name].walkable == false then
		return
	end

	-- where is front
	local yaw = self.object:getyaw()
	local dir_x = -sin(yaw) * (self.collisionbox[4] + 0.5)
	local dir_z = cos(yaw) * (self.collisionbox[4] + 0.5)

	-- what is in front of mob?
	local nod = node_ok({
		x = pos.x + dir_x,
		y = pos.y + 0.5,
		z = pos.z + dir_z
	})

	-- thin blocks that do not need to be jumped
	if nod.name == "mcl_core:snow" then
		return
	end

--print ("in front:", nod.name, pos.y + 0.5)

	if (minetest.registered_items[nod.name].walkable
	and not nod.name:find("fence")
	and not nod.name:find("gate"))
	or self.walk_chance == 0 then

		local v = self.object:getvelocity()

		v.y = self.jump_height + 1

		self.object:setvelocity(v)

		if self.sounds.jump then

			minetest.sound_play(self.sounds.jump, {
				object = self.object,
				gain = 1.0,
				max_hear_distance = self.sounds.distance
			})
		end
	end
end

-- this is a faster way to calculate distance
local get_distance = function(a, b)

	local x, y, z = a.x - b.x, a.y - b.y, a.z - b.z

	return square(x * x + y * y + z * z)
end

-- blast damage to entities nearby (modified from TNT mod)
local function entity_physics(pos, radius)

	radius = radius * 2

	local objs = minetest.get_objects_inside_radius(pos, radius)
	local obj_pos, dist

	for n = 1, #objs do

		obj_pos = objs[n]:getpos()

		dist = get_distance(pos, obj_pos)
		if dist < 1 then dist = 1 end

		local damage = floor((4 / dist) * radius)
		local ent = objs[n]:get_luaentity()

		if objs[n]:is_player() then
			objs[n]:set_hp(objs[n]:get_hp() - damage)

		else --if ent.health then

			objs[n]:punch(objs[n], 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = damage},
			}, nil)

		end
	end
end

-- should mob follow what I'm holding ?
local function follow_holding(self, clicker)

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
local function breed(self)

	-- child takes 240 seconds before growing into adult
	if self.child == true then

		self.hornytimer = self.hornytimer + 1

		if self.hornytimer > 240 then

			self.child = false
			self.hornytimer = 0

			self.object:set_properties({
				textures = self.base_texture,
				mesh = self.base_mesh,
				visual_size = self.base_size,
				collisionbox = self.base_colbox,
			})

			-- jump when fully grown so not to fall into ground
			self.object:setvelocity({
				x = 0,
				y = self.jump_height,
				z = 0
			})
		end

		return
	end

	-- horny animal can mate for 40 seconds,
	-- afterwards horny animal cannot mate again for 200 seconds
	if self.horny == true
	and self.hornytimer < 240 then

		self.hornytimer = self.hornytimer + 1

		if self.hornytimer >= 240 then
			self.hornytimer = 0
			self.horny = false
		end
	end

	-- find another same animal who is also horny and mate if close enough
	if self.horny == true
	and self.hornytimer <= 40 then

		local pos = self.object:getpos()

		effect({x = pos.x, y = pos.y + 1, z = pos.z}, 8, "heart.png", 3, 4, 1, 0.1)

		local objs = minetest.get_objects_inside_radius(pos, 3)
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
			and ent.hornytimer <= 40 then
				num = num + 1
			end

			-- found your mate? then have a baby
			if num > 1 then

				self.hornytimer = 41
				ent.hornytimer = 41

				-- spawn baby
				minetest.after(5, function()

					local mob = minetest.add_entity(pos, self.name)
					local ent2 = mob:get_luaentity()
					local textures = self.base_texture

					if self.child_texture then
						textures = self.child_texture[1]
					end

					mob:set_properties({
						textures = textures,
						visual_size = {
							x = self.base_size.x * .5,
							y = self.base_size.y * .5,
						},
						collisionbox = {
							self.base_colbox[1] * .5,
							self.base_colbox[2] * .5,
							self.base_colbox[3] * .5,
							self.base_colbox[4] * .5,
							self.base_colbox[5] * .5,
							self.base_colbox[6] * .5,
						},
					})
					ent2.child = true
					ent2.tamed = true
					ent2.owner = self.owner
				end)

				num = 0

				break
			end
		end
	end
end

-- find and replace what mob is looking for (grass, wheat etc.)
local function replace(self, pos)

	if self.replace_rate
	and self.child == false
	and random(1, self.replace_rate) == 1 then

		local pos = self.object:getpos()

		pos.y = pos.y + self.replace_offset

-- print ("replace node = ".. minetest.get_node(pos).name, pos.y)

		if self.replace_what
		and self.replace_with
		and self.object:getvelocity().y == 0
		and #minetest.find_nodes_in_area(pos, pos, self.replace_what) > 0 then

			minetest.set_node(pos, {name = self.replace_with})

			-- when cow/sheep eats grass, replace wool and milk
			if self.gotten == true then
				self.gotten = false
				self.object:set_properties(self)
			end
		end
	end
end

-- check if daytime and also if mob is docile during daylight hours
local function day_docile(self)

	if self.docile_by_day == false then

		return false

	elseif self.docile_by_day == true
	and self.time_of_day > 0.2
	and self.time_of_day < 0.8 then

		return true
	end
end

-- path finding and smart mob routine by rnd
local function smart_mobs(self, s, p, dist, dtime)

	local s1 = self.path.lastpos

	-- is it becoming stuck?
	if abs(s1.x - s.x) + abs(s1.z - s.z) < 1.5 then
		self.path.stuck_timer = self.path.stuck_timer + dtime
	else
		self.path.stuck_timer = 0
	end

	self.path.lastpos = {x = s.x, y = s.y, z = s.z}

	-- im stuck, search for path
	if (self.path.stuck_timer > stuck_timeout and not self.path.following)
	or (self.path.stuck_timer > stuck_path_timeout
	and self.path.following) then

		self.path.stuck_timer = 0

		-- lets try find a path, first take care of positions
		-- since pathfinder is very sensitive
		local sheight = self.collisionbox[5] - self.collisionbox[2]

		-- round position to center of node to avoid stuck in walls
		-- also adjust height for player models!
		s.x = floor(s.x + 0.5)
		s.y = floor(s.y + 0.5) - sheight
		s.z = floor(s.z + 0.5)

		local ssight, sground = minetest.line_of_sight(s, {
			x = s.x, y = s.y - 4, z = s.z}, 1)

		-- determine node above ground
		if not ssight then
			s.y = sground.y + 1
		end

		local p1 = self.attack:getpos()

		p1.x = floor(p1.x + 0.5)
		p1.y = floor(p1.y + 0.5)
		p1.z = floor(p1.z + 0.5)

		self.path.way = minetest.find_path(s, p1, 16, 2, 6, "Dijkstra") --"A*_noprefetch")

		-- attempt to unstick mob that is "daydreaming"
		self.object:setpos({
			x = s.x + 0.1 * (random() * 2 - 1),
			y = s.y + 1,
			z = s.z + 0.1 * (random() * 2 - 1)
		})

		self.state = ""
		do_attack(self, self.attack)

		-- no path found, try something else
		if not self.path.way then

			self.path.following = false

			 -- lets make way by digging/building if not accessible
			if self.pathfinding == 2 then

				 -- add block and remove one block above so
				 -- there is room to jump if needed
				if s.y < p1.y then

					if not minetest.is_protected(s, "") then
						minetest.set_node(s, {name = "mcl_core:dirt"})
					end

					local sheight = math.ceil(self.collisionbox[5]) + 1

					-- assume mob is 2 blocks high so it digs above its head
					s.y = s.y + sheight

					if not minetest.is_protected(s, "") then

						local node1 = minetest.get_node(s).name

						if node1 ~= "air"
						and node1 ~= "ignore" then
							minetest.set_node(s, {name = "air"})
							minetest.add_item(s, ItemStack(node1))
						end
					end

					s.y = s.y - sheight
					self.object:setpos({x = s.x, y = s.y + 2, z = s.z})

				else -- dig 2 blocks to make door toward player direction

					local yaw1 = self.object:getyaw() + pi / 2

					local p1 = {
						x = s.x + cos(yaw1),
						y = s.y,
						z = s.z + sin(yaw1)
					}

					if not minetest.is_protected(p1, "") then

						local node1 = minetest.get_node(p1).name

						if node1 ~= "air"
						and node1 ~= "ignore" then
							minetest.add_item(p1, ItemStack(node1))
							minetest.set_node(p1, {name = "air"})
						end

						p1.y = p1.y + 1
						node1 = minetest.get_node(p1).name

						if node1 ~= "air"
						and node1 ~= "ignore" then
							minetest.add_item(p1, ItemStack(node1))
							minetest.set_node(p1, {name = "air"})
						end

					end
				end
			end

			-- will try again in 2 second
			self.path.stuck_timer = stuck_timeout - 2

			-- frustration! cant find the damn path :(
			if self.sounds.random then

				minetest.sound_play(self.sounds.random, {
					object = self.object,
					max_hear_distance = self.sounds.distance
				})
			end

		else

			-- yay i found path
			if self.sounds.attack then

				set_velocity(self, self.walk_velocity)

				minetest.sound_play(self.sounds.attack, {
					object = self.object,
					max_hear_distance = self.sounds.distance
				})
			end

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

	-- is found entity on list to attack?
	for no = 1, #list do

		if list[no] == what then
			return true
		end
	end

	return false
end

-- monster find someone to attack
local monster_attack = function(self)

	if self.type ~= "monster"
	or not damage_enabled
	or self.state == "attack"
	or day_docile(self) then
		return
	end

	local s = self.object:getpos()
	local p, sp, dist
	local player, obj, min_player
	local type, name = "", ""
	local min_dist = self.view_range + 1
	local objs = minetest.get_objects_inside_radius(s, self.view_range)

	for n = 1, #objs do

		if objs[n]:is_player() then

			if mobs.invis[ objs[n]:get_player_name() ] then

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

			s = self.object:getpos()
			p = player:getpos()
			sp = s

			-- aim higher to make looking up hills more realistic
			p.y = p.y + 1
			sp.y = sp.y + 1

			dist = get_distance(p, s)

			if dist < self.view_range then
			-- field of view check goes here

				-- choose closest player to attack
				if line_of_sight_water(self, sp, p, 2) == true
				and dist < min_dist then
					min_dist = dist
					min_player = player
				end
			end
		end
	end

	-- attack player
	if min_player then
		do_attack(self, min_player)
	end
end

-- npc, find closest monster to attack
local npc_attack = function(self)

	if self.type ~= "npc"
	or not self.attacks_monsters
	or self.state == "attack" then
		return
	end

	local s = self.object:getpos()
	local min_dist = self.view_range + 1
	local obj, min_player = nil, nil
	local objs = minetest.get_objects_inside_radius(s, self.view_range)

	for n = 1, #objs do

		obj = objs[n]:get_luaentity()

		if obj
		and obj.type == "monster" then

			local p = obj.object:getpos()

			local dist = get_distance(p, s)

			if dist < min_dist then
				min_dist = dist
				min_player = obj.object
			end
		end
	end

	if min_player then
		do_attack(self, min_player)
	end
end

-- follow player if owner or holding item, if fish outta water then flop
local follow_flop = function(self)

	-- find player to follow
	if (self.follow ~= ""
	or self.order == "follow")
	and not self.following
	and self.state ~= "attack"
	and self.state ~= "runaway" then

		local s = self.object:getpos()
		local players = minetest.get_connected_players()

		for n = 1, #players do

			if get_distance(players[n]:getpos(), s) < self.view_range
			and not mobs.invis[ players[n]:get_player_name() ] then

				self.following = players[n]

				break
			end
		end
	end

	if self.type == "npc"
	and self.order == "follow"
	and self.state ~= "attack"
	and self.owner ~= "" then

		-- npc stop following player if not owner
		if self.following
		and self.owner
		and self.owner ~= self.following:get_player_name() then
			self.following = nil
		end
	else
		-- stop following player if not holding specific item
		if self.following
		and self.following:is_player()
		and follow_holding(self, self.following) == false then
			self.following = nil
		end

	end

	-- follow that thing
	if self.following then

		local s = self.object:getpos()
		local p

		if self.following:is_player() then

			p = self.following:getpos()

		elseif self.following.object then

			p = self.following.object:getpos()
		end

		if p then

			local dist = get_distance(p, s)

			-- dont follow if out of range
			if dist > self.view_range then
				self.following = nil
			else
				local vec = {
					x = p.x - s.x,
					y = p.y - s.y,
					z = p.z - s.z
				}

				local yaw = (atan(vec.z / vec.x) + pi / 2) - self.rotate

				if p.x > s.x then
					yaw = yaw + pi
				end

				self.object:setyaw(yaw)

				-- anyone but standing npc's can move along
				if dist > self.reach
				and self.order ~= "stand" then

					if (self.jump
					and get_velocity(self) <= 0.5
					and self.object:getvelocity().y == 0)
					or (self.object:getvelocity().y == 0
					and self.jump_chance > 0) then

						do_jump(self)
					end

					set_velocity(self, self.walk_velocity)

					if self.walk_chance ~= 0 then
						set_animation(self, "walk")
					end
				else
					set_velocity(self, 0)
					set_animation(self, "stand")
				end

				return
			end
		end
	end

	-- water swimmers flop when on land
	if self.fly
	and self.fly_in == "mcl_core:water_source"
	and self.standing_in ~= self.fly_in then

		self.state = "flop"
		self.object:setvelocity({x = 0, y = -5, z = 0})

		set_animation(self, "stand")

		return
	end
end

-- dogshoot attack switch and counter function
local dogswitch = function(self, dtime)

	-- switch mode not activated
	if not self.dogshoot_switch
	or not dtime then
		return 0
	end

	self.dogshoot_count = self.dogshoot_count + dtime

	if self.dogshoot_count > self.dogshoot_count_max then

		self.dogshoot_count = 0

		if self.dogshoot_switch == 1 then
			self.dogshoot_switch = 2
		else
			self.dogshoot_switch = 1
		end
	end

	return self.dogshoot_switch
end

-- execute current state (stand, walk, run, attacks)
local do_states = function(self, dtime)

	local yaw = 0

	if self.state == "stand" then

		if random(1, 4) == 1 then

			local lp = nil
			local s = self.object:getpos()

			if self.type == "npc" then

				local objs = minetest.get_objects_inside_radius(s, 3)

				for n = 1, #objs do

					if objs[n]:is_player() then
						lp = objs[n]:getpos()
						break
					end
				end
			end

			-- look at any players nearby, otherwise turn randomly
			if lp then

				local vec = {
					x = lp.x - s.x,
					y = lp.y - s.y,
					z = lp.z - s.z
				}

				yaw = (atan(vec.z / vec.x) + pi / 2) - self.rotate

				if lp.x > s.x then
					yaw = yaw + pi
				end
			else
				yaw = (random(0, 360) - 180) / 180 * pi
			end

			self.object:setyaw(yaw)
		end

		set_velocity(self, 0)
		set_animation(self, "stand")

		-- npc's ordered to stand stay standing
		if self.type ~= "npc"
		or self.order ~= "stand" then

			if self.walk_chance ~= 0
			and random(1, 100) <= self.walk_chance
			and is_at_cliff(self) == false then

				set_velocity(self, self.walk_velocity)
				self.state = "walk"
				set_animation(self, "walk")
			end
		end

	elseif self.state == "walk" then

		local s = self.object:getpos()
		local lp = nil

		-- is there something I need to avoid?
		if self.water_damage > 0
		and self.lava_damage > 0 then

			lp = minetest.find_node_near(s, 1, {"group:water", "group:lava"})

		elseif self.water_damage > 0 then

			lp = minetest.find_node_near(s, 1, {"group:water"})

		elseif self.lava_damage > 0 then

			lp = minetest.find_node_near(s, 1, {"group:lava"})
		end

		-- if something then avoid
		if lp then

			local vec = {
				x = lp.x - s.x,
				y = lp.y - s.y,
				z = lp.z - s.z
			}

			yaw = atan(vec.z / vec.x) + 3 * pi / 2 - self.rotate

			if lp.x > s.x then
				yaw = yaw + pi
			end

			self.object:setyaw(yaw)

		-- otherwise randomly turn
		elseif random(1, 100) <= 30 then

			local yaw = (random(0, 360) - 180) / 180 * pi

			self.object:setyaw(yaw)
		end

		-- stand for great fall in front
		local temp_is_cliff = is_at_cliff(self)

		-- jump when walking comes to a halt
		if temp_is_cliff == false
		and self.jump
		and get_velocity(self) <= 0.5
		and self.object:getvelocity().y == 0 then

			do_jump(self)
		end

		if temp_is_cliff
		or random(1, 100) <= 30 then

			set_velocity(self, 0)
			self.state = "stand"
			set_animation(self, "stand")
		else
			set_velocity(self, self.walk_velocity)
			set_animation(self, "walk")
		end

	-- runaway when punched
	elseif self.state == "runaway" then

		self.runaway_timer = self.runaway_timer + 1

		-- stop after 5 seconds or when at cliff
		if self.runaway_timer > 5
		or is_at_cliff(self) then
			self.runaway_timer = 0
			set_velocity(self, 0)
			self.state = "stand"
			set_animation(self, "stand")
		else
			set_velocity(self, self.run_velocity)
			set_animation(self, "walk")
		end

		-- jump when walking comes to a halt
		if self.jump
		and get_velocity(self) <= 0.5
		and self.object:getvelocity().y == 0 then

			do_jump(self)
		end

	-- attack routines (explode, dogfight, shoot, dogshoot)
	elseif self.state == "attack" then

		-- calculate distance from mob and enemy
		local s = self.object:getpos()
		local p = self.attack:getpos() or s
		local dist = get_distance(p, s)

		-- stop attacking if player or out of range
		if dist > self.view_range
		or not self.attack
		or not self.attack:getpos()
		or self.attack:get_hp() <= 0
		or (self.attack:is_player() and mobs.invis[ self.attack:get_player_name() ]) then

			--print(" ** stop attacking **", dist, self.view_range)
			self.state = "stand"
			set_velocity(self, 0)
			set_animation(self, "stand")
			self.attack = nil
			self.v_start = false
			self.timer = 0
			self.blinktimer = 0

			return
		end

		if self.attack_type == "explode" then

			local vec = {
				x = p.x - s.x,
				y = p.y - s.y,
				z = p.z - s.z
			}

			yaw = atan(vec.z / vec.x) + pi / 2 - self.rotate

			if p.x > s.x then
				yaw = yaw + pi
			end

			self.object:setyaw(yaw)

			if dist > self.reach then

				if not self.v_start then

					self.v_start = true
					set_velocity(self, self.run_velocity)
					self.timer = 0
					self.blinktimer = 0
				else
					self.timer = 0
					self.blinktimer = 0

					if get_velocity(self) <= 0.5
					and self.object:getvelocity().y == 0 then

						do_jump(self)
					end

					set_velocity(self, self.run_velocity)
				end

				set_animation(self, "run")
			else
				set_velocity(self, 0)
				set_animation(self, "punch")

				self.timer = self.timer + dtime
				self.blinktimer = (self.blinktimer or 0) + dtime

				if self.blinktimer > 0.2 then

					self.blinktimer = 0

					if self.blinkstatus then
						self.object:settexturemod("")
					else
						self.object:settexturemod("^[brighten")
					end

					self.blinkstatus = not self.blinkstatus
				end

				if self.timer > 3 then

					local pos = self.object:getpos()
					local radius = self.explosion_radius or 1

					-- hurt player/mobs caught in blast area
					entity_physics(pos, radius)

					-- dont damage anything if area protected or next to water
					if minetest.find_node_near(pos, 1, {"group:water"})
					or minetest.is_protected(pos, "") then

						if self.sounds.explode then

							minetest.sound_play(self.sounds.explode, {
								object = self.object,
								gain = 1.0,
								max_hear_distance = 16
							})
						end

						self.object:remove()

						effect(pos, 15, "tnt_smoke.png")

						return
					end

					pos.y = pos.y - 1

					mobs:explosion(pos, radius, 0, 1, self.sounds.explode)

					self.object:remove()

					return
				end
			end

		elseif self.attack_type == "dogfight"
		or (self.attack_type == "dogshoot" and dogswitch(self, dtime) == 2)
		or (self.attack_type == "dogshoot" and dist <= self.reach and dogswitch(self) == 0) then

			if self.fly
			and dist > self.reach then

				local nod = node_ok(s)
				local p1 = s
				local me_y = floor(p1.y)
				local p2 = p
				local p_y = floor(p2.y + 1)
				local v = self.object:getvelocity()

				if nod.name == self.fly_in then

					if me_y < p_y then

						self.object:setvelocity({
							x = v.x,
							y = 1 * self.walk_velocity,
							z = v.z
						})

					elseif me_y > p_y then

						self.object:setvelocity({
							x = v.x,
							y = -1 * self.walk_velocity,
							z = v.z
						})
					end
				else
					if me_y < p_y then

						self.object:setvelocity({
							x = v.x,
							y = 0.01,
							z = v.z
						})

					elseif me_y > p_y then

						self.object:setvelocity({
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

				if abs(p1.x-s.x) + abs(p1.z - s.z) < 0.6 then
					-- reached waypoint, remove it from queue
					table.remove(self.path.way, 1)
				end

				-- set new temporary target
				p = {x = p1.x, y = p1.y, z = p1.z}
			end

			local vec = {
				x = p.x - s.x,
				y = p.y - s.y,
				z = p.z - s.z
			}

			yaw = (atan(vec.z / vec.x) + pi / 2) - self.rotate

			if p.x > s.x then
				yaw = yaw + pi
			end

			self.object:setyaw(yaw)

			-- move towards enemy if beyond mob reach
			if dist > self.reach then

				-- path finding by rnd
				if self.pathfinding -- only if mob has pathfinding enabled
				and enable_pathfinding then

					smart_mobs(self, s, p, dist, dtime)
				end

				-- jump attack
				if (self.jump
				and get_velocity(self) <= 0.5
				and self.object:getvelocity().y == 0)
				or (self.object:getvelocity().y == 0
				and self.jump_chance > 0) then

					do_jump(self)
				end

				if is_at_cliff(self) then

					set_velocity(self, 0)
					set_animation(self, "stand")
				else

					if self.path.stuck then
						set_velocity(self, self.walk_velocity)
					else
						set_velocity(self, self.run_velocity)
					end

					set_animation(self, "run")
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
						and random(1, 2) == 1 then
							set_animation(self, "punch2")
						else
							set_animation(self, "punch")
						end

						local p2 = p
						local s2 = s

						p2.y = p2.y + 1.5
						s2.y = s2.y + 1.5

						if line_of_sight_water(self, p2, s2) == true then

							-- play attack sound
							if self.sounds.attack then

								minetest.sound_play(self.sounds.attack, {
									object = self.object,
									max_hear_distance = self.sounds.distance
								})
							end

							-- punch player
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

			local dist = get_distance(p, s)
			local vec = {
				x = p.x - s.x,
				y = p.y - s.y,
				z = p.z - s.z
			}

			yaw = (atan(vec.z / vec.x) + pi / 2) - self.rotate

			if p.x > s.x then
				yaw = yaw + pi
			end

			self.object:setyaw(yaw)

			set_velocity(self, 0)

			if self.shoot_interval
			and self.timer > self.shoot_interval
			and random(1, 100) <= 60 then

				self.timer = 0
				set_animation(self, "shoot")

				-- play shoot attack sound
				if self.sounds.shoot_attack then

					minetest.sound_play(self.sounds.shoot_attack, {
						object = self.object,
						max_hear_distance = self.sounds.distance
					})
				end

				local p = self.object:getpos()

				p.y = p.y + (self.collisionbox[2] + self.collisionbox[5]) / 2

				local obj = minetest.add_entity(p, self.arrow)
				local ent = obj:get_luaentity()
				local amount = (vec.x * vec.x + vec.y * vec.y + vec.z * vec.z) ^ 0.5
				local v = ent.velocity or 1 -- or set to default
				ent.switch = 1
				ent.owner_id = tostring(self.object) -- add unique owner id to arrow

				 -- offset makes shoot aim accurate
				vec.y = vec.y + self.shoot_offset
				vec.x = vec.x * (v / amount)
				vec.y = vec.y * (v / amount)
				vec.z = vec.z * (v / amount)

				obj:setvelocity(vec)
			end
		end
	end
end

-- falling and fall damage
local falling = function(self, pos)

	if self.fly then
		return
	end

	-- floating in water (or falling)
	local v = self.object:getvelocity()

	-- going up then apply gravity
	if v.y > 0.1 then

		self.object:setacceleration({
			x = 0,
			y = self.fall_speed,
			z = 0
		})
	end

	-- in water then float up
	if minetest.registered_nodes[node_ok(pos).name].groups.liquid then

		if self.floats == 1 then

			self.object:setacceleration({
				x = 0,
				y = -self.fall_speed / (max(1, v.y) ^ 2),
				z = 0
			})
		end
	else
		-- fall downwards
		self.object:setacceleration({
			x = 0,
			y = self.fall_speed,
			z = 0
		})

		-- fall damage
		if self.fall_damage == 1
		and self.object:getvelocity().y == 0 then

			local d = self.old_y - self.object:getpos().y

			if d > 5 then

				self.health = self.health - floor(d - 5)

				effect(pos, 5, "tnt_smoke.png")

				if check_for_death(self) then
					return
				end
			end

			self.old_y = self.object:getpos().y
		end
	end
end

local mob_punch = function(self, hitter, tflp, tool_capabilities, dir)

	-- error checking when mod profiling is enabled
	if not tool_capabilities then
		print (S("[MOBS] mod profiling enabled, damage not enabled"))
		return
	end

-- is mob protected?
if self.protected and hitter:is_player()
and minetest.is_protected(self.object:getpos(), hitter:get_player_name()) then
	minetest.chat_send_player(hitter:get_player_name(), "Mob has been protected!")
	return
end


	-- weapon wear
	local weapon = hitter:get_wielded_item()
	local punch_interval = 1.4

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

	-- check for tool immunity or special damage
	for n = 1, #self.immune_to do

		if self.immune_to[n][1] == weapon:get_name() then

			damage = self.immune_to[n][2] or 0
			break
		end
	end

	-- healing
	if damage <= -1 then
		self.health = self.health - floor(damage)
		return
	end

--	print ("Mob Damage is", damage)

	-- add weapon wear
	if tool_capabilities then
		punch_interval = tool_capabilities.full_punch_interval or 1.4
	end

	if (not minetest.setting_getbool("creative_mode"))
	and weapon:get_definition()
	and weapon:get_definition().tool_capabilities then
		weapon:add_wear(floor((punch_interval / 75) * 9000))
		hitter:set_wielded_item(weapon)
	end

-- only play hit sound and show blood effects if damage is 1 or over
if damage >= 1 then

	-- weapon sounds
	if weapon:get_definition().sounds ~= nil then

		local s = random(0, #weapon:get_definition().sounds)

		minetest.sound_play(weapon:get_definition().sounds[s], {
			object = hitter,
			max_hear_distance = 8
		})
	else
		minetest.sound_play("default_punch", {
			object = hitter,
			max_hear_distance = 5
		})
	end

	-- blood_particles
	if self.blood_amount > 0
	and not disable_blood then

		local pos = self.object:getpos()

		pos.y = pos.y + (-self.collisionbox[2] + self.collisionbox[5]) * .5

		effect(pos, self.blood_amount, self.blood_texture)
	end

	-- do damage
	self.health = self.health - floor(damage)

	-- exit here if dead
	if check_for_death(self) then
		return
	end

	--[[ add healthy afterglow when hit (can cause hit lag with larger textures)
	core.after(0.1, function()
		self.object:settexturemod("^[colorize:#c9900070")

		core.after(0.3, function()
			self.object:settexturemod("")
		end)
	end) ]]

	-- knock back effect (only on full punch)
	if self.knock_back > 0
	and tflp > punch_interval then

		local v = self.object:getvelocity()
		local r = 1.4 - min(punch_interval, 1.4)
		local kb = r * 5
		local up = 2

		-- if already in air then dont go up anymore when hit
		if v.y > 0
		or self.fly then
			up = 0
		end

		-- direction error check
		dir = dir or {x = 0, y = 0, z = 0}

		self.object:setvelocity({
			x = dir.x * kb,
			y = up,
			z = dir.z * kb
		})

		self.pause_timer = r
	end

end -- END if damage

	-- if skittish then run away
	if self.runaway == true then

		local lp = hitter:getpos()
		local s = self.object:getpos()

		local vec = {
			x = lp.x - s.x,
			y = lp.y - s.y,
			z = lp.z - s.z
		}

		local yaw = atan(vec.z / vec.x) + 3 * pi / 2 - self.rotate

		if lp.x > s.x then
			yaw = yaw + pi
		end

		self.object:setyaw(yaw)
		self.state = "runaway"
		self.runaway_timer = 0
		self.following = nil
	end

	-- attack puncher and call other mobs for help
	if self.passive == false
	and self.state ~= "flop"
	and self.child == false
	and hitter:get_player_name() ~= self.owner
	and not mobs.invis[ hitter:get_player_name() ] then

		-- attack whoever punched mob
		self.state = ""
		do_attack(self, hitter)

		-- alert others to the attack
		local objs = minetest.get_objects_inside_radius(hitter:getpos(), self.view_range)
		local obj = nil

		for n = 1, #objs do

			obj = objs[n]:get_luaentity()

			if obj then

				if obj.group_attack == true
				and obj.state ~= "attack" then
					do_attack(obj, hitter)
				end
			end
		end
	end
end

local mob_activate = function(self, staticdata, dtime_s, def)

	-- remove monsters in peaceful mode, or when no data
	if (self.type == "monster" and peaceful_only)
	or not staticdata then

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

		self.base_texture = def.textures[random(1, #def.textures)]
		self.base_mesh = def.mesh
		self.base_size = self.visual_size
		self.base_colbox = self.collisionbox
	end

	-- set texture, model and size
	local textures = self.base_texture
	local mesh = self.base_mesh
	local vis_size = self.base_size
	local colbox = self.base_colbox

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
	end

	if self.health == 0 then
		self.health = random (self.hp_min, self.hp_max)
	end

	-- rnd: pathfinding init
	self.path = {}
	self.path.way = {} -- path to follow, table of positions
	self.path.lastpos = {x = 0, y = 0, z = 0}
	self.path.stuck = false
	self.path.following = false -- currently following path?
	self.path.stuck_timer = 0 -- if stuck for too long search for path
	-- end init

	self.object:set_armor_groups({immortal = 1, fleshy = self.armor})
	self.old_y = self.object:getpos().y
	self.old_health = self.health
	self.object:setyaw((random(0, 360) - 180) / 180 * pi)
	self.sounds.distance = self.sounds.distance or 10
	self.textures = textures
	self.mesh = mesh
	self.collisionbox = colbox
	self.visual_size = vis_size
	self.standing_in = ""

	-- set anything changed above
	self.object:set_properties(self)
end

local mob_step = function(self, dtime)

	local pos = self.object:getpos()
	local yaw = self.object:getyaw() or 0

	-- when lifetimer expires remove mob (except npc and tamed)
	if self.type ~= "npc"
	and not self.tamed
	and self.state ~= "attack"
	and remove_far ~= true
	and self.lifetimer < 20000 then

		self.lifetimer = self.lifetimer - dtime

		if self.lifetimer <= 0 then

			-- only despawn away from player
			local objs = minetest.get_objects_inside_radius(pos, 15)

			for n = 1, #objs do

				if objs[n]:is_player() then

					self.lifetimer = 20

					return
				end
			end

--			minetest.log("action",
--				S("lifetimer expired, removed @1", self.name))

			effect(pos, 15, "tnt_smoke.png")

			self.object:remove()

			return
		end
	end

	falling(self, pos)

	-- knockback timer
	if self.pause_timer > 0 then

		self.pause_timer = self.pause_timer - dtime

		if self.pause_timer < 1 then
			self.pause_timer = 0
		end

		return
	end

	-- run custom function (defined in mob lua file)
	if self.do_custom then

		-- when false skip going any further
		if self.do_custom(self, dtime) == false then
			return
		end
	end

	-- attack timer
	self.timer = self.timer + dtime

	if self.state ~= "attack" then

		if self.timer < 1 then
			return
		end

		self.timer = 0
	end

	-- never go over 100
	if self.timer > 100 then
		self.timer = 1
	end

	-- node replace check (cow eats grass etc.)
	replace(self, pos)

	-- mob plays random sound at times
	if self.sounds.random
	and random(1, 100) == 1 then

		minetest.sound_play(self.sounds.random, {
			object = self.object,
			max_hear_distance = self.sounds.distance
		})
	end

	-- environmental damage timer (every 1 second)
	self.env_damage_timer = self.env_damage_timer + dtime

	if (self.state == "attack" and self.env_damage_timer > 1)
	or self.state ~= "attack" then

		self.env_damage_timer = 0

		do_env_damage(self)
	end

	monster_attack(self)

	npc_attack(self)

	breed(self)

	follow_flop(self)

	do_states(self, dtime)

end

-- default function when mobs are blown up with TNT
local do_tnt = function(obj, damage)

	--print ("----- Damage", damage)

	obj.object:punch(obj.object, 1.0, {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = damage},
	}, nil)

	return false, true, {}
end

mobs.spawning_mobs = {}

-- register mob function
function mobs:register_mob(name, def)

	mobs.spawning_mobs[name] = true

minetest.register_entity(name, {

	stepheight = def.stepheight or 0.6,
	name = name,
	type = def.type,
	attack_type = def.attack_type,
	fly = def.fly,
	fly_in = def.fly_in or "air",
	owner = def.owner or "",
	order = def.order or "",
	on_die = def.on_die,
	do_custom = def.do_custom,
	jump_height = def.jump_height or 6,
	jump_chance = def.jump_chance or 0,
	drawtype = def.drawtype, -- DEPRECATED, use rotate instead
	rotate = math.rad(def.rotate or 0), --  0=front, 90=side, 180=back, 270=side2
	lifetimer = def.lifetimer or 180, -- 3 minutes
	hp_min = max(1, (def.hp_min or 5) * difficulty),
	hp_max = max(1, (def.hp_max or 10) * difficulty),
	physical = true,
	collisionbox = def.collisionbox,
	visual = def.visual,
	visual_size = def.visual_size or {x = 1, y = 1},
	mesh = def.mesh,
	makes_footstep_sound = def.makes_footstep_sound or false,
	view_range = def.view_range or 5,
	walk_velocity = def.walk_velocity or 1,
	run_velocity = def.run_velocity or 2,
	damage = max(1, (def.damage or 0) * difficulty),
	light_damage = def.light_damage or 0,
	water_damage = def.water_damage or 0,
	lava_damage = def.lava_damage or 0,
	fall_damage = def.fall_damage or 1,
	fall_speed = def.fall_speed or -10, -- must be lower than -2 (mcl_core: -10)
	drops = def.drops or {},
	armor = def.armor or 100,
	on_rightclick = def.on_rightclick,
	arrow = def.arrow,
	shoot_interval = def.shoot_interval,
	sounds = def.sounds or {},
	animation = def.animation,
	follow = def.follow,
	jump = def.jump or true,
	walk_chance = def.walk_chance or 50,
	attacks_monsters = def.attacks_monsters or false,
	group_attack = def.group_attack or false,
	--fov = def.fov or 120,
	passive = def.passive or false,
	recovery_time = def.recovery_time or 0.5,
	knock_back = def.knock_back or 3,
	blood_amount = def.blood_amount or 5,
	blood_texture = def.blood_texture or "mobs_blood.png",
	shoot_offset = def.shoot_offset or 0,
	floats = def.floats or 1, -- floats in water by default
	replace_rate = def.replace_rate,
	replace_what = def.replace_what,
	replace_with = def.replace_with,
	replace_offset = def.replace_offset or 0,
	timer = 0,
	env_damage_timer = 0, -- only used when state = "attack"
	tamed = false,
	pause_timer = 0,
	horny = false,
	hornytimer = 0,
	child = false,
	gotten = false,
	health = 0,
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
	explosion_radius = def.explosion_radius,
	custom_attack = def.custom_attack,
	double_melee_attack = def.double_melee_attack,
	dogshoot_switch = def.dogshoot_switch,
	dogshoot_count = 0,
	dogshoot_count_max = def.dogshoot_count_max or 5,
	attack_animals = def.attack_animals or false,
	specific_attack = def.specific_attack,

	on_blast = def.on_blast or do_tnt,

	on_step = mob_step,

	on_punch = mob_punch,

	on_activate = function(self, staticdata, dtime_s)
		mob_activate(self, staticdata, dtime_s, def)
	end,

	get_staticdata = function(self)

		-- remove mob when out of range unless tamed
		if remove_far
		and self.remove_ok
		and not self.tamed
		and self.lifetimer < 20000 then

			--print ("REMOVED " .. self.name)

			self.object:remove()

			return nil
		end

		self.remove_ok = true
		self.attack = nil
		self.following = nil
		self.state = "stand"

		-- used to rotate older mobs
		if self.drawtype
		and self.drawtype == "side" then
			self.rotate = math.rad(90)
		end

		local tmp = {}

		for _,stat in pairs(self) do

			local t = type(stat)

			if  t ~= 'function'
			and t ~= 'nil'
			and t ~= 'userdata' then
				tmp[_] = self[_]
			end
		end

		-- print('===== '..self.name..'\n'.. dump(tmp)..'\n=====\n')
		return minetest.serialize(tmp)
	end,

})

end -- END mobs:register_mob function

-- count how many mobs of one type are inside an area
local count_mobs = function(pos, type)

	local num = 0
	local objs = minetest.get_objects_inside_radius(pos, 32)

	for n = 1, #objs do

		if not objs[n]:is_player() then

			local obj = objs[n]:get_luaentity()

			if obj and obj.name and obj.name == type then
				num = num + 1
			end
		end
	end

	return num
end

-- global functions

function mobs:spawn_specific(name, nodes, neighbors, min_light, max_light,
	interval, chance, aoc, min_height, max_height, day_toggle, on_spawn)

	-- chance/spawn number override in minetest.conf for registered mob
	local numbers = minetest.setting_get(name)

	if numbers then
		numbers = numbers:split(",")
		chance = tonumber(numbers[1]) or chance
		aoc = tonumber(numbers[2]) or aoc

		if chance == 0 then
			print(S("[Mobs Redo] @1 has spawning disabled", name))
			return
		end

		print (S("[Mobs Redo] Chance setting for @1 changed to @2", name, chance)
			.. " (total: " .. aoc .. ")")

	end

	minetest.register_abm({

		label = name .. " spawning",
		nodenames = nodes,
		neighbors = neighbors,
		interval = interval,
		chance = chance,
		catch_up = false,

		action = function(pos, node, active_object_count, active_object_count_wider)

			-- is mob actually registered?
			if not mobs.spawning_mobs[name] then
--print ("--- mob doesn't exist", name)
				return
			end

			-- do not spawn if too many of same mob in area
			if active_object_count_wider >= aoc
			and count_mobs(pos, name) >= aoc then
--print ("--- too many entities", name, aoc)
				return
			end

			-- if toggle set to nil then ignore day/night check
			if day_toggle ~= nil then

				local tod = (minetest.get_timeofday() or 0) * 24000

				if tod > 4500 and tod < 19500 then
					-- daylight, but mob wants night
					if day_toggle == false then
--print ("--- mob needs night", name)
						return
					end
				else
					-- night time but mob wants day
					if day_toggle == true then
--print ("--- mob needs day", name)
						return
					end
				end
			end

			-- spawn above node
			pos.y = pos.y + 1

			-- only spawn away from player
			local objs = minetest.get_objects_inside_radius(pos, 10)

			for n = 1, #objs do

				if objs[n]:is_player() then
--print ("--- player too close", name)
					return
				end
			end

			-- mobs cannot spawn in protected areas when enabled
			if spawn_protected == 1
			and minetest.is_protected(pos, "") then
--print ("--- inside protected area", name)
				return
			end

			-- are light levels ok?
			local light = minetest.get_node_light(pos)
			if not light
			or light > max_light
			or light < min_light then
--print ("--- light limits not met", name, light)
				return
			end

			-- are we spawning within height limits?
			if pos.y > max_height
			or pos.y < min_height then
--print ("--- height limits not met", name, pos.y)
				return
			end

			-- are we spawning inside solid nodes?
			if minetest.registered_nodes[node_ok(pos).name].walkable == true then
--print ("--- feet in block", name, node_ok(pos).name)
				return
			end

			pos.y = pos.y + 1

			if minetest.registered_nodes[node_ok(pos).name].walkable == true then
--print ("--- head in block", name, node_ok(pos).name)
				return
			end

			-- spawn mob half block higher than ground
			pos.y = pos.y - 0.5

			local mob = minetest.add_entity(pos, name)

			if mob and mob:get_luaentity() then
--				print ("[mobs] Spawned " .. name .. " at "
--				.. minetest.pos_to_string(pos) .. " on "
--				.. node.name .. " near " .. neighbors[1])
				if on_spawn and not on_spawn(mob, pos) then
					return
				end
			else
				print (S("[mobs] @1 failed to spawn at @2",
				name, minetest.pos_to_string(pos)))
			end

		end
	})
end

-- compatibility with older mob registration
function mobs:register_spawn(name, nodes, max_light, min_light, chance, active_object_count, max_height, day_toggle)

	mobs:spawn_specific(name, nodes, {"air"}, min_light, max_light, 30,
		chance, active_object_count, -31000, max_height, day_toggle)
end

-- MarkBu's spawn function
function mobs:spawn(def)

	local name = def.name
	local nodes = def.nodes or {"group:soil", "group:stone"}
	local neighbors = def.neighbors or {"air"}
	local min_light = def.min_light or 0
	local max_light = def.max_light or 15
	local interval = def.interval or 30
	local chance = def.chance or 5000
	local active_object_count = def.active_object_count or 1
	local min_height = def.min_height or -31000
	local max_height = def.max_height or 31000
	local day_toggle = def.day_toggle
	local on_spawn = def.on_spawn

	mobs:spawn_specific(name, nodes, neighbors, min_light, max_light, interval,
		chance, active_object_count, min_height, max_height, day_toggle, on_spawn)
end

-- set content id's
local c_air = minetest.get_content_id("air")
local c_ignore = minetest.get_content_id("ignore")
local c_obsidian = minetest.get_content_id("mcl_core:obsidian")
local c_chest = minetest.get_content_id("mcl_core:chest")
local c_fire = minetest.get_content_id("mcl_fire:basic_flame")

-- explosion (cannot break protected or unbreakable nodes)
function mobs:explosion(pos, radius, fire, smoke, sound)

	radius = radius or 0
	fire = fire or 0
	smoke = smoke or 0

	-- if area protected or near map limits then no blast damage
	if minetest.is_protected(pos, "")
	or not within_limits(pos, radius) then
		return
	end

	-- explosion sound
	if sound
	and sound ~= "" then

		minetest.sound_play(sound, {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 16
		})
	end

	pos = vector.round(pos) -- voxelmanip doesn't work properly unless pos is rounded ?!?!

	local vm = VoxelManip()
	local minp, maxp = vm:read_from_map(vector.subtract(pos, radius), vector.add(pos, radius))
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()
	local p = {}
	local pr = PseudoRandom(os.time())

	for z = -radius, radius do
	for y = -radius, radius do
	local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	for x = -radius, radius do

		p.x = pos.x + x
		p.y = pos.y + y
		p.z = pos.z + z

		if (x * x) + (y * y) + (z * z) <= (radius * radius) + pr:next(-radius, radius)
		and data[vi] ~= c_air
		and data[vi] ~= c_ignore
		and data[vi] ~= c_obsidian
		and data[vi] ~= c_chest
		and data[vi] ~= c_fire then

			local n = node_ok(p).name
			local on_blast = minetest.registered_nodes[n].on_blast

			if on_blast then

				return on_blast(p)

			elseif minetest.registered_nodes[n].groups.unbreakable == 1 then

				-- do nothing
			else

				-- after effects
				if fire > 0
				and (minetest.registered_nodes[n].groups.flammable
				or random(1, 100) <= 30) then

					minetest.set_node(p, {name = "mcl_fire:basic_flame"})
				else
					minetest.set_node(p, {name = "air"})

					if smoke > 0 then
						effect(p, 2, "tnt_smoke.png")
					end
				end
			end
		end

		vi = vi + 1

	end
	end
	end
end

-- register arrow for shoot attack
function mobs:register_arrow(name, def)

	if not name or not def then return end -- errorcheck

	minetest.register_entity(name, {

		physical = false,
		visual = def.visual,
		visual_size = def.visual_size,
		textures = def.textures,
		velocity = def.velocity,
		hit_player = def.hit_player,
		hit_node = def.hit_node,
		hit_mob = def.hit_mob,
		drop = def.drop or false, -- drops arrow as registered item when true
		collisionbox = {0, 0, 0, 0, 0, 0}, -- remove box around arrows
		timer = 0,
		switch = 0,
		owner_id = def.owner_id,

		on_step = def.on_step or function(self, dtime)

			self.timer = self.timer + 1

			local pos = self.object:getpos()

			if self.switch == 0
			or self.timer > 150
			or not within_limits(pos, 0) then

				self.object:remove() ; -- print ("removed arrow")

				return
			end

			-- does arrow have a tail (fireball)
			if def.tail
			and def.tail == 1
			and def.tail_texture then

--				effect(pos, 1, def.tail_texture,
--					def.tail_size or 5,
--					def.tail_size or 10,
--					0, 0) -- 0 radius and 0 gravity to just hover

				minetest.add_particlespawner({
					amount = 1,
					time = 0.25,
					minpos = pos,
					maxpos = pos,
					minvel = {x = 0, y = 0, z = 0},
					maxvel = {x = 0, y = 0, z = 0},
					minacc = {x = 0, y = 0, z = 0},
					maxacc = {x = 0, y = 0, z = 0},
					minexptime = 0.1,
					maxexptime = 1,
					minsize = def.tail_size or 5,
					maxsize = def.tail_size or 10,
					texture = def.tail_texture,
				})
			end

			if self.hit_node then

				local node = node_ok(pos).name

				if minetest.registered_nodes[node].walkable then
				--if node ~= "air" then

					self.hit_node(self, pos, node)

					if self.drop == true then

						pos.y = pos.y + 1

						self.lastpos = (self.lastpos or pos)

						minetest.add_item(self.lastpos, self.object:get_luaentity().name)
					end

					self.object:remove() ; -- print ("hit node")

					return
				end
			end

			if self.hit_player or self.hit_mob then

				for _,player in pairs(minetest.get_objects_inside_radius(pos, 1.0)) do

					if self.hit_player
					and player:is_player() then

						self.hit_player(self, player)
						self.object:remove() ; -- print ("hit player")
						return
					end

					local entity = player:get_luaentity()
						and player:get_luaentity().name or ""

					if self.hit_mob
					and tostring(player) ~= self.owner_id
					and entity ~= self.object:get_luaentity().name
					and entity ~= "__builtin:item"
					and entity ~= "__builtin:falling_node"
					and entity ~= "gauges:hp_bar"
					and entity ~= "signs:text"
					and entity ~= "itemframes:item" then

						self.hit_mob(self, player)

						self.object:remove() ;  --print ("hit mob")

						return
					end
				end
			end

			self.lastpos = pos
		end
	})
end

-- Spawn Egg
function mobs:register_egg(mob, desc, background, addegg, no_creative)

	local grp = {}

	-- do NOT add this egg to creative inventory (e.g. dungeon master)
	if creative and no_creative == true then
		grp = {not_in_creative_inventory = 1}
	end

	local invimg = background

	if addegg == 1 then
		invimg = "mobs_chicken_egg.png^(" .. invimg ..
			"^[mask:mobs_chicken_egg_overlay.png)"
	end

	minetest.register_craftitem(mob, {

		description = desc,
		inventory_image = invimg,
		groups = grp,

		on_place = function(itemstack, placer, pointed_thing)

			local pos = pointed_thing.above

			if pos
			and within_limits(pos, 0)
			and not minetest.is_protected(pos, placer:get_player_name()) then

				pos.y = pos.y + 1

				local mob = minetest.add_entity(pos, mob)
				local ent = mob:get_luaentity()

				if not ent then
					mob:remove()
					return
				end

				if ent.type ~= "monster" then
					-- set owner and tame if not monster
					ent.owner = placer:get_player_name()
					ent.tamed = true
				end

				-- if not in creative then take item
				if not creative then
					itemstack:take_item()
				end
			end

			return itemstack
		end,
	})
end

-- capture critter (thanks to blert2112 for idea)
function mobs:capture_mob(self, clicker, chance_hand, chance_net, chance_lasso, force_take, replacewith)

	if not self.child
	and clicker:is_player()
	and clicker:get_inventory() then

		-- get name of clicked mob
		local mobname = self.name

		-- if not nil change what will be added to inventory
		if replacewith then
			mobname = replacewith
		end

		local name = clicker:get_player_name()

		-- is mob tamed?
		if self.tamed == false
		and force_take == false then

			minetest.chat_send_player(name, S("Not tamed!"))

			return
		end

		-- cannot pick up if not owner
		if self.owner ~= name
		and force_take == false then

			minetest.chat_send_player(name, S("@1 is owner!", self.owner))

			return
		end

		if clicker:get_inventory():room_for_item("main", mobname) then

			-- was mob clicked with hand, net, or lasso?
			local tool = clicker:get_wielded_item()
			local chance = 0

			if tool:is_empty() then
				chance = chance_hand

			elseif tool:get_name() == "mobs:net" then

				chance = chance_net

				tool:add_wear(4000) -- 17 uses

				clicker:set_wielded_item(tool)

			elseif tool:get_name() == "mobs:magic_lasso" then

				chance = chance_lasso

				tool:add_wear(650) -- 100 uses

				clicker:set_wielded_item(tool)
			end

			-- return if no chance
			if chance == 0 then return end

			-- calculate chance.. add to inventory if successful?
			if random(1, 100) <= chance then

				clicker:get_inventory():add_item("main", mobname)

				self.object:remove()
			else
				minetest.chat_send_player(name, S("Missed!"))
			end
		end
	end
end

local mob_obj = {}
local mob_sta = {}

-- feeding, taming and breeding (thanks blert2112)
function mobs:feed_tame(self, clicker, feed_count, breed, tame)

	if not self.follow then
		return false
	end

	-- can eat/tame with item in hand
	if follow_holding(self, clicker) then

		-- if not in creative then take item
		if not creative then

			local item = clicker:get_wielded_item()

			item:take_item()

			clicker:set_wielded_item(item)
		end

		-- increase health
		self.health = self.health + 4

		if self.health >= self.hp_max then

			self.health = self.hp_max

			if self.htimer < 1 then

				minetest.chat_send_player(clicker:get_player_name(),
					S("@1 at full health (@2)",
					self.name:split(":")[2], tostring(self.health)))

				self.htimer = 5
			end
		end

		self.object:set_hp(self.health)

		-- make children grow quicker
		if self.child == true then

			self.hornytimer = self.hornytimer + 20

			return true
		end

		-- feed and tame
		self.food = (self.food or 0) + 1
		if self.food >= feed_count then

			self.food = 0

			if breed and self.hornytimer == 0 then
				self.horny = true
			end

			self.gotten = false

			if tame then

				if self.tamed == false then
					minetest.chat_send_player(clicker:get_player_name(),
						S("@1 has been tamed!",
						self.name:split(":")[2]))
				end

				self.tamed = true

				if not self.owner or self.owner == "" then
					self.owner = clicker:get_player_name()
				end
			end

			-- make sound when fed so many times
			if self.sounds.random then

				minetest.sound_play(self.sounds.random, {
					object = self.object,
					max_hear_distance = self.sounds.distance
				})
			end
		end

		return true
	end

	local item = clicker:get_wielded_item()

	-- if mob has been tamed you can name it with a nametag
	if item:get_name() == "mobs:nametag"
	and clicker:get_player_name() == self.owner then

		local name = clicker:get_player_name()

		-- store mob and nametag stack in external variables
		mob_obj[name] = self
		mob_sta[name] = item

		local tag = self.nametag or ""

		minetest.show_formspec(name, "mobs_nametag", "size[8,4]"
			.. default.gui_bg
			.. default.gui_bg_img
			.. "field[0.5,1;7.5,0;name;" .. S("Enter name:") .. ";" .. tag .. "]"
			.. "button_exit[2.5,3.5;3,1;mob_rename;" .. S("Rename") .. "]")

	end

	return false

end

-- inspired by blockmen's nametag mod
minetest.register_on_player_receive_fields(function(player, formname, fields)

	-- right-clicked with nametag and name entered?
	if formname == "mobs_nametag"
	and fields.name
	and fields.name ~= "" then

		local name = player:get_player_name()

		if not mob_obj[name]
		or not mob_obj[name].object then
			return
		end

		-- update nametag
		mob_obj[name].nametag = fields.name

		-- if not in creative then take item
		if not creative then

			mob_sta[name]:take_item()

			player:set_wielded_item(mob_sta[name])
		end

		-- reset external variables
		mob_obj[name] = nil
		mob_sta[name] = nil

	end
end)

-- compatibility function for old entities to new modpack entities
function mobs:alias_mob(old_name, new_name)

	-- spawn egg
	minetest.register_alias(old_name, new_name)

	-- entity
	minetest.register_entity(":" .. old_name, {

		physical = false,

		on_step = function(self)

			local pos = self.object:getpos()

			minetest.add_entity(pos, new_name)

			self.object:remove()
		end
	})
end
