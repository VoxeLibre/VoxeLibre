local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class

local damage_enabled = core.settings:get_bool("enable_damage")
local mobs_griefing = core.settings:get_bool("mobs_griefing") ~= false

-- pathfinding settings
local stuck_timeout = 3 -- how long before mob gets stuck in place and starts searching
local stuck_path_timeout = 10 -- how long will mob follow path before giving up
local INVULNERABILITY_TIME_US = 500000

local enable_pathfinding = true

local TIME_TO_FORGET_TARGET = 15
local PI = math.pi
local HALFPI = PI * 0.5
local random = math.random
local min = math.min
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local cos = math.cos
local sin = math.sin
local atan2 = math.atan2
local vector_offset = vector.offset
local vector_new = vector.new
local vector_copy = vector.copy
local vector_distance = vector.distance

local DIRECT_SIGHT_ANGLE = PI / 3 -- 60 degrees

-- check if daytime and also if mob is docile during daylight hours
function mob_class:day_docile()
	return self.docile_by_day == true and self.time_of_day > 0.2 and self.time_of_day < 0.8
end

-- get this mob to attack the object
function mob_class:do_attack(object)
	if self.state == "attack" or self.state == "die" or self.state == "runaway" then
		return
	end
	if object:is_player() and not damage_enabled and not self.force_attack then
		return
	end

	self.attack = object
	self.state = "attack"

	-- TODO: Implement war_cry sound without being annoying
	--if random(0, 100) < 90 then
		--self:mob_sound("war_cry", true)
	--end
end

-- path finding and smart mob routine by rnd, line_of_sight and other edits by Elkien3
---@param s vector mob's current position
---@param p vector target's position or last known position of target
function mob_class:smart_mobs(s, p, dist, dtime)
	local s1 = self.path.lastpos

	-- is it becoming stuck?
	if abs(s1.x - s.x) + abs(s1.z - s.z) < .5 then
		self.path.stuck_timer = self.path.stuck_timer + dtime
	else
		self.path.stuck_timer = 0
	end

	self.path.lastpos = vector_copy(s)

	local use_pathfind = false
	local has_lineofsight = self.target_visible(self.object, self.attack)

	-- im stuck, search for path
	if not has_lineofsight then
		if self.path.los_switcher == true then
			use_pathfind = true
			self.path.los_switcher = false
		end -- cannot see target!
	else
		if self.path.los_switcher == false then
			self.path.los_switcher = true
			use_pathfind = false
			minetest.after(1, function(self)
				if not self.object:get_luaentity() then return end
				if has_lineofsight then self.path.following = false end
			end, self)
		end -- can see target!
	end

	if (self.path.stuck_timer > stuck_timeout and not self.path.following) then
		use_pathfind = true
		self.path.stuck_timer = 0
		minetest.after(1, function(self)
			if not self.object:get_luaentity() then return end
			if has_lineofsight then self.path.following = false end
		end, self)
	end

	if (self.path.stuck_timer > stuck_path_timeout and self.path.following) then
		use_pathfind = true
		self.path.stuck_timer = 0
		minetest.after(1, function(self)
			if not self.object:get_luaentity() then return end
			if has_lineofsight then self.path.following = false end
		end, self)
	end

	if abs(s.y - p.y) > self.initial_properties.stepheight then
		if self.path.height_switcher then
			use_pathfind = true
			self.path.height_switcher = false
		end
	else
		if not self.path.height_switcher then
			use_pathfind = false
			self.path.height_switcher = true
		end
	end

	if use_pathfind then
		-- lets try find a path, first take care of positions
		-- since pathfinder is very sensitive
		local cb = self.initial_properties.collisionbox
		local sheight = cb[5] - cb[2]

		-- round position to center of node to avoid stuck in walls
		-- also adjust height for player models!
		s.x, s.z = floor(s.x + 0.5), floor(s.z + 0.5)

		local ssight, sground = minetest.line_of_sight(s, vector_offset(s, 0, -4, 0), 1)

		-- determine node above ground
		if not ssight then s.y = sground.y + 1 end

		local p1 = vector_offset(p, 0.5, 0.5, 0.5)

		local dropheight = 12
		if self.fear_height ~= 0 then dropheight = self.fear_height end
		local jumpheight = 0
		if self.jump and self.jump_height >= 4 then
			jumpheight = min(ceil(self.jump_height * 0.25), 4)
		elseif self.initial_properties.stepheight > 0.5 then
			jumpheight = 1
		end
		self.path.way = minetest.find_path(s, p1, 16, jumpheight, dropheight, "A*_noprefetch")

		self.state = ""
		self:do_attack(self.attack)

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

					local sheight = ceil(self.initial_properties.collisionbox[5]) + 1

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
					self.object:set_pos(vector_offset(s, 0, 2, 0))
				else -- dig 2 blocks to make door toward player direction
					local yaw1 = self.object:get_yaw() + HALFPI
					local p1 = vector_offset(s, cos(yaw1), 0, sin(yaw1))

					if not minetest.is_protected(p1, "") then
						local node1 = node_ok(p1, "air").name
						local ndef1 = minetest.registered_nodes[node1]
						if node1 ~= "air" and node1 ~= "ignore"
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

						if node1 ~= "air" and node1 ~= "ignore"
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
			self:do_jump() --add jump to pathfinding
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
	if list == nil then return true end

	-- found entity on list to attack?
	for no = 1, #list do
		if list[no] == what then return true end
	end
	return false
end

-- Check if target is within mob's direct sight cone
function mob_class:target_in_direct_sight(target_pos)
	local s = self.object:get_pos()
	if not s or not target_pos then return false end

	local yaw = self.object:get_yaw() or 0
	local dir_to_target = atan2(target_pos.z - s.z, target_pos.x - s.x)
	-- Convert mob yaw to same coordinate system (mob yaw 0 = +Z, we need +X based)
	local mob_facing = yaw - HALFPI

	local angle_diff = abs(dir_to_target - mob_facing)
	-- Normalize to [0, PI]
	while angle_diff > PI do
		angle_diff = angle_diff - 2 * PI
	end
	angle_diff = abs(angle_diff)
	
	return angle_diff <= DIRECT_SIGHT_ANGLE
end

-- schedule an attack after a delay with some random jitter
function mob_class:delayed_attack(target, base_delay, jitter)
	local base = base_delay or 0.5
	local j = jitter or 0.3
	local delay = base + random() * j
	core.after(delay, function(self, target)
		if not self.object:get_luaentity() then return end
		if not target or not target:get_pos() then return end
		if self.state == "attack" then return end -- already attacking something
		if not self:target_visible(self.object, target) then return end
		self:do_attack(target)
	end, self, target)
end

-- find someone to attack
function mob_class:monster_attack()
	if not damage_enabled and not self.force_attack then
		return
	end
	if self.passive ~= false or self.state == "attack" or self:day_docile() then
		return
	end

	local s = self.object:get_pos()
	local p, dist
	local player, obj, min_player
	local type, name = "", ""
	local min_dist = self.view_range + 1

	local blacklist_attack = {}

	local objs = minetest.get_objects_inside_radius(s, self.view_range)

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
				-- self.aggro made player be attacked by npc again if out of range then back in again
				-- Does it serve a purpose other than that?
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
				or (type == "animal" and self.attack_animals == true)
				or (self.extra_hostile and not self.attack_exception(player))) then
			p = player:get_pos()
			dist = vector_distance(p, s)

			local attacked_p = false
			for c=1, #blacklist_attack do
				if blacklist_attack[c] == player then
					attacked_p = true
				end
			end

			-- choose closest player to attack
			local line_of_sight = self:target_visible(self.object, player) == true
			if dist < min_dist and not attacked_p and line_of_sight then
				min_dist = dist
				min_player = player
			end
		end
	end
	if not min_player and #blacklist_attack > 0 then
		min_player=blacklist_attack[random(#blacklist_attack)]
	end
	-- attack player
	if min_player then
		local target_pos = min_player:get_pos()
		if self:target_in_direct_sight(target_pos) then
			-- Target in direct sight, attack immediately
			self:do_attack(min_player)
		else
			-- Target not in direct sight, schedule delayed attack by 0.5-1.0 seconds
			self:delayed_attack(min_player, 0.5, 0.5)
		end
	end
end


-- npc, find closest monster to attack
function mob_class:npc_attack()
	if self.type ~= "npc"
	or not self.attacks_monsters
	or self.state == "attack" then
		return
	end

	local p, obj, min_player
	local s = self.object:get_pos()
	local min_dist = self.view_range + 1
	local objs = minetest.get_objects_inside_radius(s, self.view_range)

	for n = 1, #objs do
		obj = objs[n]:get_luaentity()

		if obj and obj.type == "monster" then
			p = obj.object:get_pos()
			local dist = vector_distance(p, s)

			if dist < min_dist and self:target_visible(self.object, obj.object) then
				min_dist = dist
				min_player = obj.object
			end
		end
	end

	if min_player then
		local target_pos = min_player:get_pos()
		if self:target_in_direct_sight(target_pos) then
			-- Target in direct sight, attack immediately
			self:do_attack(min_player)
		else
			-- Target not in direct sight, delay attack by 0.2-0.5 seconds
			self:delayed_attack(min_player, 0.2, 0.3)
		end
	end
end



-- dogshoot attack switch and counter function
function mob_class:dogswitch(dtime)
	-- switch mode not activated
	if not self.dogshoot_switch or not dtime then return 0 end

	self.dogshoot_count = self.dogshoot_count + dtime

	if (self.dogshoot_switch == 1 and self.dogshoot_count > self.dogshoot_count_max)
	or (self.dogshoot_switch == 2 and self.dogshoot_count > self.dogshoot_count2_max) then

		self.dogshoot_count = 0

		if self.dogshoot_switch == 1 then
			self.dogshoot_switch = 2
		else
			self.dogshoot_switch = 1
		end
	end

	return self.dogshoot_switch
end

--- make explosion with protection and tnt mod check
---@param pos            {x: number, y: number, z: number}
---@param strength       number
---@param info_overrides table?
---@param preserve_self  boolean? If after the explosion, the entity should continue existing
function mob_class:boom(pos, strength, info_overrides, preserve_self)
	local info = {
		drop_chance     = 1.0,
		griefing        = mobs_griefing == true,
		grief_protected = false,
	}
	if info_overrides then
		mcl_util.table_merge(info, info_overrides)
	end
	mcl_explosions.explode(pos, strength, info, self.object)

	if not preserve_self then
		-- delete the object after it punched the player to avoid nil entities in e.g. mcl_shields!!
		mcl_util.remove_entity(self)
	end
end

---Returns the name of an attacker.
local function get_attacker_name(hitter)
	if not hitter then
		return nil
	end
	if hitter:is_player() then
		return "player"
	end
	local e = hitter.get_luaentity and hitter:get_luaentity()
	if e then
		if e._source_object then
			if e._source_object:is_player() then
				return "player"
			end
			local se = e._source_object:get_luaentity()
			if se and se.name then
				return se.name
			end
		end
		if e.name then
			return e.name
		end
	end
	return nil
end

-- deal damage and effects when mob punched
function mob_class:on_punch(hitter, tflp, tool_capabilities, dir)
	local is_player = hitter:is_player()
	local mob_pos = self.object:get_pos()
	local player_pos = hitter:get_pos()
	local weapon = hitter:get_wielded_item()
	local time_now = core.get_us_time()

	-- check for invulnerability time in microseconds (0.5 second)
	local time_diff = time_now - self.invul_timestamp
	if time_diff <= INVULNERABILITY_TIME_US and time_diff >= 0 then return end

	if is_player then
		-- is mob out of reach?
		if (vector.distance(mob_pos, player_pos) - self._avg_radius) > (weapon:get_definition().range or 3) then
			return
		end

		-- is mob protected?
		if self.protected and minetest.is_protected(mob_pos, hitter:get_player_name()) then return end

		mcl_potions.update_haste_and_fatigue(hitter)

		self.xp_timestamp = time_now
	else
		-- set/update 'drop xp' timestamp if hit by a player's projectiles
		local hitter_le = hitter:get_luaentity()
		local hitter_le_owner = hitter_le and hitter_le._owner
		if hitter_le_owner and core.get_player_by_name(hitter_le_owner) then
			self.xp_timestamp = time_now
		end
	end

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

	-- punch interval
	local punch_interval = 1.4

	if is_player then
		-- Instant kill mobs in creative
		if core.is_creative_enabled(hitter:get_player_name()) then self.health = 0 end

		-- exhaust attacker
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

	for group,_ in pairs((tool_capabilities.damage_groups or {}) ) do
		tmp = tflp / (tool_capabilities.full_punch_interval or 1.4)
		tmp = tmp < 0 and 0 or (tmp > 1 and 1 or tmp)
		damage = damage + (tool_capabilities.damage_groups[group] or 0) * tmp * ((armor[group] or 0) / 100.0)
	end

	-- strength and weakness effects
	local strength = mcl_potions.get_effect(hitter, "strength")
	local weakness = mcl_potions.get_effect(hitter, "weakness")
	local str_fac = strength and strength.factor or 1
	local weak_fac = weakness and weakness.factor or 1
	damage = damage * str_fac * weak_fac

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
		self.health = self.health - floor(damage)
		return
	end

	if tool_capabilities then
		punch_interval = tool_capabilities.full_punch_interval or 1.4
		if punch_interval == 0 then punch_interval = 0.001 end -- minimal interval, needed to avoid crash due to 0/0 NaN
	end

	if not tflp then
		tflp = punch_interval
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
					local wear = floor(65535/tool_capabilities.punch_attack_uses)
					weapon:add_wear(wear)
					tt.reload_itemstack_description(weapon) -- update tooltip
					hitter:set_wielded_item(weapon)
				end
			end, hitter:get_player_name())
		end
	end

	local die = false

	if damage >= 0 then
		local hv = hitter:get_velocity() or vector.zero()
		if hv.y < 0 then
			self:crit_effect()
			minetest.sound_play("mcl_criticals_hit", {object = self.object})
			local crit_mod
			local CRIT_MIN = 1.5
			local CRIT_DIFF = 1
			if is_player then
				local luck = mcl_luck.get_luck(hitter:get_player_name())
				if luck ~= 0 then
					local a, d
					if luck > 0 then
						d = -0.5
						a = d - math.abs(luck)
					elseif luck < 0 then
						a = -0.5
						d = a - math.abs(luck)
					else
						minetest.log("warning", "[mcl_mobs] luck is not a number") -- this technically can't happen, but want to catch such cases
					end
					if a then
						local x = math.random()
						crit_mod = CRIT_DIFF * (a * x) / (d - luck * x) + CRIT_MIN
					end
				end
			end
			if not crit_mod then
				crit_mod = math.random(CRIT_MIN, CRIT_MIN + CRIT_DIFF)
			end
			damage = damage * crit_mod
		end
		-- only play hit sound and show blood effects if damage is 1 or over; lower to 0.1 to ensure armor works appropriately.
		if damage >= 0.1 then
			-- weapon sounds
			if weapon:get_definition().sounds ~= nil then
				local s = random(0, #weapon:get_definition().sounds)

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

			-- give invulnerability
			self.invul_timestamp = time_now

			-- skip future functions if dead, except alerting others
			local cause     = "hit"
			local cmi_cause = { type = "punch", puncher = hitter }
			local info      = { attacker_name = get_attacker_name(hitter) }
			if self:check_for_death(cause, cmi_cause, info) then
				die = true
			end
		end
		-- knock back effect
		if self.knock_back then
			-- direction error check
			dir = dir or vector_zero()

			local v = self.object:get_velocity()
			if not v then return end
			local rate = min(tflp, punch_interval) / punch_interval
			local kb = 1.25
			if tool_capabilities.damage_groups["knockback"] then
				kb = tool_capabilities.damage_groups["knockback"]
			end
			local luaentity = hitter and hitter:get_luaentity()
			if hitter and is_player then
				local wielditem = hitter:get_wielded_item()
				kb = kb + 3 * core.get_item_group(wielditem:get_name(), "hammer")
				-- add player velocity to mob knockback
				local dir_dot = (hv.x * dir.x) + (hv.z * dir.z)
				local player_mag = ((hv.x * hv.x) + (hv.z * hv.z))^0.5
				local mob_mag = ((v.x * v.x) + (v.z * v.z))^0.5
				if dir_dot > 0 and mob_mag <= player_mag * 0.625 then
					kb = kb + player_mag / 2 -- experimentally derived constant
				end
				kb = kb * rate
				kb = kb + 3 * mcl_enchanting.get_enchantment(wielditem, "knockback")
			elseif luaentity and luaentity._knockback and die == false then
				kb = kb + luaentity._knockback
			elseif luaentity and luaentity._knockback and die == true then
				kb = kb + luaentity._knockback * 0.25
			end
			if die then
				kb = kb * 1.25
				self.vl_drops_pos = mob_pos
			end

			local up = 5.25
			-- if already in air then dont go up anymore when hit
			if abs(v.y) > 0.1 or self.fly then up = 0 end

			self._kb_turn = true
			self:turn_by(HALFPI, .1) -- knockback turn
			self.frame_speed_multiplier=2.3
			if self.animation.run_end then
				self:set_animation("run")
			elseif self.animation.walk_end then
				self:set_animation("walk")
			end
			minetest.after(0.2, function()
				if self and self.object then
					self.frame_speed_multiplier=1
					self._kb_turn = false
				end
			end)
			kb = kb * 20 -- experimentally derived constant
			self:set_velocity(0)
			self.object:add_velocity(vector_new(dir.x * kb, up, dir.z * kb ))

			self.pause_timer = 0.25
		end
	end -- END if damage

	-- if skittish then run away
	if hitter and is_player and hitter:get_pos() and not die and self.runaway == true and self.state ~= "flop" then
		local hp, sp = hitter:get_pos(), self.object:get_pos()
		self:turn_in_direction(sp.x - hp.x, sp.z - hp.z, 1)
		minetest.after(0.2,function()
			if self and self.object and hitter and is_player then
				local hp, sp = hitter:get_pos(), self.object:get_pos()
				if hp and sp then
					self:turn_in_direction(sp.x - hp.x, sp.z - hp.z, 1)
					self:set_velocity(self.run_velocity)
				end
			end
		end)
		self.state = "runaway"
		self.runaway_timer = 0
		self.following = nil
	end

	local name = hitter:get_player_name() or ""

	-- attack puncher
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
	end

	-- alert others to the attack
	local alert_pos = hitter:get_pos()
	if alert_pos then
		local objs = minetest.get_objects_inside_radius(alert_pos, self.view_range)
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
							if obj.group_attack[i] == self.name then
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

function mob_class:check_aggro(dtime)
	if not self._aggro or not self.attack then return end
	if not self._check_aggro_timer then self._check_aggro_timer = 0 end
	if self._check_aggro_timer > 5 then
		self._check_aggro_timer = 0

		if self.attack then
			-- TODO consider removing this in favour of what is done in do_states_attack
			-- Attack is dropped in do_states_attack if out of range, so won't even trigger here
			-- I do not think this code does anything. Are mobs still loaded in at 128?
			if not self.attack:get_pos() or vector_distance(self.attack:get_pos(),self.object:get_pos()) > 128 then
				self._aggro = nil
				self.attack = nil
				self.state = "stand"
			end
		end
	end
	self._check_aggro_timer = self._check_aggro_timer + dtime
end



local function clear_aggro(self)
	self.state = "stand"
	self:set_velocity( 0)
	self:set_animation( "stand")

	self.attack = nil
	self._aggro = nil

	self.force_attack = false
	self.fuse = false
	self.timer = 0
	self.blinktimer = 0
	self.path.way = nil
	self.path.last_seen_target_pos = nil
end

---Starts an explosion attack.
---@param opts { force: boolean? }?
function mob_class:fuse_start(opts)
	self.fuse       = true
	self.timer      = 0
	self.blinktimer = 0
	self:mob_sound("fuse", nil, false)
	self:set_animation("fuse")

	if opts and opts.force == true then
		self.allow_fuse_reset = false
		self.force_attack     = true
	end
end

---Returns true if the fuse for this mob is triggered.
---@return boolean
function mob_class:fuse_is_triggered()
	return self.fuse == true
end

---Resets fuse.
function mob_class:fuse_reset()
	self.fuse = false
	self.timer = 0
	self.blinktimer = 0
	self.blinkstatus = false
	self:remove_texture_mod("^[brighten")
end

function mob_class:do_states_attack(dtime)
	self.timer = self.timer + dtime
	if self.timer > 100 then self.timer = 1 end

	local s = self.object:get_pos()
	if not s then return end

	local p = self.attack:get_pos() or s
	local yaw = self.object:get_yaw() or 0

	-- stop attacking if player invisible or out of range
	if not self.attack
			or not self.attack:get_pos()
			or not self:object_in_range(self.attack)
			or self.attack:get_hp() <= 0
			or (self.attack:is_player() and mcl_mobs.invis[ self.attack:get_player_name() ]) then

		clear_aggro(self)
		return
	end

	local target_line_of_sight = self:target_visible(self.object, self.attack)

	if target_line_of_sight then
		self.path.last_seen_target_pos = vector_copy(p)
		self.target_time_lost = nil
	else
		if not self.target_time_lost then
			self.target_time_lost = os.time()
		end

		-- Check if we should give up pursuit
		local time_since_seen = os.time() - self.target_time_lost
		if time_since_seen > TIME_TO_FORGET_TARGET then
			self.target_time_lost = nil
			clear_aggro(self)
			return
		end

		if self.path.last_seen_target_pos then
			local dist_to_last_seen = vector_distance(s, self.path.last_seen_target_pos)
			if dist_to_last_seen < 0.5 then
				self.target_time_lost = nil
				clear_aggro(self)
				return
			end
			-- Pursue last seen position
			p = self.path.last_seen_target_pos
		end
	end

	-- calculate distance from mob to enemy and last seen position
	local dist = vector_distance(p, s)
	local actual_target_pos = self.attack:get_pos()
	local actual_dist = actual_target_pos and vector_distance(actual_target_pos, s) or math.huge

	if self.attack_type == "explode" then
		if target_line_of_sight and self.allow_fuse_reset then
			self:turn_in_direction(p.x - s.x, p.z - s.z, 1)
		end

		local node_break_radius = self.explosion_radius or 1
		local entity_damage_radius = self.explosion_damage_radius or (node_break_radius * 2)

		-- start timer when in reach and line of sight
		if not self:fuse_is_triggered() and dist <= self.reach and target_line_of_sight then
			self:fuse_start()
			-- stop timer if out of reach or direct line of sight
		elseif self:fuse_is_triggered() and self.allow_fuse_reset
			and (dist >= self.explosiontimer_reset_radius or not target_line_of_sight)
		then
			self:fuse_reset()
		end

		-- walk right up to player unless the timer is active
		if self:fuse_is_triggered() and (self.stop_to_explode or dist < self.reach) then
			self:set_velocity(0)
		elseif not target_line_of_sight and self.path.last_seen_target_pos then
			-- Lost sight but have last seen position, keep pursuing
			self:set_velocity(self.run_velocity)
			self:turn_in_direction(p.x - s.x, p.z - s.z, 4)
		else
			self:set_velocity(self.run_velocity)
		end

		if not self:fuse_is_triggered() then
			if self.animation and self.animation.run_start then
				self:set_animation("run")
			else
				self:set_animation("walk")
			end
		end

		if self:fuse_is_triggered() then
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
				local pos = mcl_util.get_object_center(self.object)
				local info = {
					drop_chance     = 1.0,
					griefing        = mobs_griefing == true,
					grief_protected = false,
				}
				mcl_explosions.explode(pos, self.explosion_strength, info, self.object)
				mcl_burning.extinguish(self.object)
				mcl_util.remove_entity(self)
				return true
			end
		end

	elseif self.attack_type == "dogfight"
			or (self.attack_type == "dogshoot" and self:dogswitch(dtime) == 2) and (dist >= self.avoid_distance or not self.shooter_avoid_enemy)
			or (self.attack_type == "dogshoot" and dist <= self.reach and self:dogswitch() == 0) then

		if self.fly and dist > self.reach then
			local p1, p2 = s, p
			local me_y, p_y = floor(p1.y), floor(p2.y + 1)
			local v = self.object:get_velocity()

			if self:flight_check( s) then
				if me_y < p_y then
					self.object:set_velocity(vector_new(v.x,  1 * self.walk_velocity, v.z))
				elseif me_y > p_y then
					self.object:set_velocity(vector_new(v.x, -1 * self.walk_velocity, v.z))
				end
			else
				if me_y < p_y then
					self.object:set_velocity(vector_new(v.x,  0.01, v.z))
				elseif me_y > p_y then
					self.object:set_velocity(vector_new(v.x, -0.01, v.z))
				end
			end
		end

		-- rnd: new movement direction
		if self.path.following and self.path.way and self.attack_type ~= "dogshoot" then
			-- no paths longer than 50
			if #self.path.way > 50 or dist < self.reach then
				self.path.following = false
				return
			end

			local p1 = self.path.way[1]
			if not p1 then
				self.path.following = false
				return
			end

			if abs(p1.x - s.x) + abs(p1.z - s.z) < 0.6 then
				-- reached waypoint, remove it from queue
				table.remove(self.path.way, 1)
			end

			-- set new temporary target
			p = vector_copy(p1)
		end

		self:turn_in_direction(p.x - s.x, p.z - s.z, 10)

		-- move towards enemy if beyond mob reach
		if dist > self.reach then
			-- path finding by rnd
			if enable_pathfinding and self.pathfinding then
				self:smart_mobs(s, p, dist, dtime)
			end

			if self:is_at_cliff_or_danger() then
				self:set_velocity(0)
				self:set_animation("stand")
				--self:turn_by(PI * (random() - 0.5), 10)
			else
				if self.path.stuck then
					self:set_velocity(self.walk_velocity)
				else
					self:set_velocity(self.run_velocity)
				end
				if self.animation and self.animation.run_start then
					self:set_animation("run")
				else
					self:set_animation("walk")
				end
			end
		elseif target_line_of_sight and actual_dist <= self.reach then
			-- rnd: if inside reach range and visible
			self.path.stuck = false
			self.path.stuck_timer = 0
			self.path.following = false -- not stuck anymore

			self:set_velocity(0)

			local attack_frequency = self.attack_frequency or 1

			if self.timer > attack_frequency then
				self.timer = 0

				if not self.custom_attack then
					if self.double_melee_attack and random(1, 2) == 1 then
						self:set_animation("punch2")
					else
						self:set_animation("punch")
					end

					if self:line_of_sight(vector_offset(actual_target_pos, 0, .5, 0), vector_offset(s, 0, .5, 0)) == true then
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
						if self.dealt_effect then
							mcl_potions.give_effect_by_level(self.dealt_effect.name, self.attack,
								self.dealt_effect.level, self.dealt_effect.dur)
						end
					end
				else
					self.custom_attack(self, actual_target_pos)
				end
			end
		end

	elseif self.attack_type == "shoot"
			or (self.attack_type == "dogshoot" and self:dogswitch(dtime) == 1)
			or (self.attack_type == "dogshoot" and (dist > self.reach or dist < self.avoid_distance and self.shooter_avoid_enemy) and self:dogswitch() == 0) then
		local vec = vector_new(p.x - s.x, p.y - s.y - 1, p.z - s.z)
		local dist = (vec.x*vec.x + vec.y*vec.y + vec.z*vec.z)^0.5
		self:turn_in_direction(vec.x, vec.z, 10)

		if self.strafes then
			if not self.strafe_direction then self.strafe_direction = HALFPI end
			if random(40) == 1 then self.strafe_direction = self.strafe_direction * -1 end

			local dir = -atan2(p.x - s.x, p.z - s.z)
			self.acc = vector_new(-sin(dir + self.strafe_direction) * 0.8, 0, cos(dir + self.strafe_direction) * 0.8)
			--stay away from player so as to shoot them
			if self.avoid_distance and dist < self.avoid_distance and self.shooter_avoid_enemy then
				local f = 0.3 * (self.avoid_distance - dist) / self.avoid_distance
				self.acc.x, self.acc.z = self.acc.x - sin(dir) * f, self.acc.z + cos(dir) * f
			end
		else
			self:set_velocity(0)
			self:set_animation("stand")
		end

		local p = self.object:get_pos()
		local cb = self.initial_properties.collisionbox
		p.y = p.y + (cb[2] + cb[5]) * 0.5

		if self.shoot_interval and self.timer > self.shoot_interval and random(1, 100) <= 60
				and not minetest.raycast(vector_offset(p, 0, self.shoot_offset, 0), vector_offset(self.attack:get_pos(), 0, 1.5, 0), false, false):next() then
			self.timer = 0
			self:set_animation( "shoot")

			-- play shoot attack sound
			self:mob_sound("shoot_attack")

			-- Shoot arrow
			if minetest.registered_entities[self.arrow] then
				local arrow, ent
				local v = 1
				local corr = vector.new(vec.x, 0, vec.z)
				corr = corr / corr:length()
				p = p + self.shoot_pos.x * corr
				p.y = p.y + self.shoot_pos.y

				if not self.shoot_arrow then
					self.firing = true
					minetest.after(1, function()
						self.firing = false
					end)

					arrow = vl_projectile.create(self.arrow, {
						pos = p,
						owner = self,
					})
					ent = arrow:get_luaentity()
					v = ent.velocity or v
					ent.switch = 1

					-- important for mcl_shields
					ent._shooter = self.object
					ent._saved_shooter_pos = self.object:get_pos()
					if ent.homing then
						ent._target = self.attack
					end
				end

				-- offset makes shoot aim accurate
				vec.y = vec.y + self.shoot_offset
				vec.x, vec.y, vec.z = vec.x * (v / dist), vec.y * (v / dist), vec.z * (v / dist)
				if self.shoot_arrow then
					vec = vector.normalize(vec)
					self:shoot_arrow(p, vec)
				else
					arrow:set_velocity(vec)
				end
			end
		end
	elseif self.attack_type == "custom" and self.attack_state then
		self.attack_state(self, dtime)
	end

	if self.on_attack then self.on_attack(self, dtime) end
end
