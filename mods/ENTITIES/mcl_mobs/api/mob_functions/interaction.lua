local math_floor = math.floor
local vector_direction = vector.direction

mobs.feed_tame = function(self)
    return nil
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

-- I have no idea what this does
mobs.create_mob_on_rightclick = function(on_rightclick)
	return function(self, clicker)
		local stop = on_rightclick_prefix(self, clicker)
		if (not stop) and (on_rightclick) then
			on_rightclick(self, clicker)
		end
	end
end


-- deal damage and effects when mob punched
mobs.mob_punch = function(self, hitter, tflp, tool_capabilities, dir)

	--neutral passive mobs switch to neutral hostile
	if self.neutral then

		--drop in variables for attacking (stops crash)
		self.attacking   = hitter
		self.punch_timer = 0

		self.hostile = true
		--hostile_cooldown timer is initialized here
		self.hostile_cooldown_timer = self.hostile_cooldown

		--initialize the group attack (check for other mobs in area, make them neutral hostile)
		if self.group_attack then
			mobs.group_attack_initialization(self)
		end
	end


	--[[
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
		if self.protected and minetest_is_protected(self.object:get_pos(), hitter:get_player_name()) then
			return
		end

		-- set/update 'drop xp' timestamp if hitted by player
		self.xp_timestamp = minetest_get_us_time()
	end


	-- punch interval
	local weapon = hitter:get_wielded_item()
	local punch_interval = 1.4

	-- exhaust attacker
	if mod_hunger and is_player then
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

	if use_cmi then
		damage = cmi.calculate_damage(self.object, hitter, tflp, tool_capabilities, dir)
	else

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
		self.health = self.health - math_floor(damage)
		return
	end

	if use_cmi then

		local cancel =  cmi.notify_punch(self.object, hitter, tflp, tool_capabilities, dir, damage)

		if cancel then return end
	end

	if tool_capabilities then
		punch_interval = tool_capabilities.full_punch_interval or 1.4
	end

	-- add weapon wear manually
	-- Required because we have custom health handling ("health" property)
	if minetest_is_creative_enabled("") ~= true
	and tool_capabilities then
		if tool_capabilities.punch_attack_uses then
			-- Without this delay, the wear does not work. Quite hacky ...
			minetest_after(0, function(name)
				local player = minetest.get_player_by_name(name)
				if not player then return end
				local weapon = hitter:get_wielded_item(player)
				local def = weapon:get_definition()
				if def.tool_capabilities and def.tool_capabilities.punch_attack_uses then
					local wear = math_floor(65535/tool_capabilities.punch_attack_uses)
					weapon:add_wear(wear)
					hitter:set_wielded_item(weapon)
				end
			end, hitter:get_player_name())
		end
	end

	local die = false

	-- only play hit sound and show blood effects if damage is 1 or over; lower to 0.1 to ensure armor works appropriately.
	if damage >= 0.1 then

		-- weapon sounds
		if weapon:get_definition().sounds ~= nil then

			local s = math_random(0, #weapon:get_definition().sounds)

			minetest_sound_play(weapon:get_definition().sounds[s], {
				object = self.object, --hitter,
				max_hear_distance = 8
			}, true)
		else
			minetest_sound_play("default_punch", {
				object = self.object,
				max_hear_distance = 5
			}, true)
		end

		damage_effect(self, damage)

		-- do damage
		self.health = self.health - damage

		-- skip future functions if dead, except alerting others
		if check_for_death(self, "hit", {type = "punch", puncher = hitter}) then
			die = true
		end

		-- knock back effect (only on full punch)
		if not die
		and self.knock_back
		and tflp >= punch_interval then

			local v = self.object:get_velocity()
			local r = 1.4 - math_min(punch_interval, 1.4)
			local kb = r * 2.0
			local up = 2

			-- if already in air then dont go up anymore when hit
			if v.y ~= 0
			or self.fly then
				up = 0
			end

			-- direction error check
			dir = dir or {x = 0, y = 0, z = 0}

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

			self.object:set_velocity({
				x = dir.x * kb,
				y = dir.y * kb + up * 2,
				z = dir.z * kb
			})

			self.pause_timer = 0.25
		end
	end -- END if damage

	-- if skittish then run away
	if not die and self.runaway == true and self.state ~= "flop" then

		local lp = hitter:get_pos()
		local s = self.object:get_pos()
		local vec = {
			x = lp.x - s.x,
			y = lp.y - s.y,
			z = lp.z - s.z
		}

		local yaw = (atan(vec.z / vec.x) + 3 * math_pi / 2) - self.rotate

		if lp.x > s.x then
			yaw = yaw + math_pi
		end

		yaw = set_yaw(self, yaw, 6)
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
	and not mobs.invis[ name ] then

		if not die then
			-- attack whoever punched mob
			self.state = ""
			do_attack(self, hitter)
		end

		-- alert others to the attack
		local objs = minetest_get_objects_inside_radius(hitter:get_pos(), self.view_range)
		local obj = nil

		for n = 1, #objs do

			obj = objs[n]:get_luaentity()

			if obj then

				-- only alert members of same mob or friends
				if obj.group_attack
				and obj.state ~= "attack"
				and obj.owner ~= name then
					if obj.name == self.name then
						do_attack(obj, hitter)
					elseif type(obj.group_attack) == "table" then
						for i=1, #obj.group_attack do
							if obj.name == obj.group_attack[i] then
								do_attack(obj, hitter)
								break
							end
						end
					end
				end

				-- have owned mobs attack player threat
				if obj.owner == name and obj.owner_loyal then
					do_attack(obj, self.object)
				end
			end
		end
	end
	]]--
end

--do internal per mob projectile calculations
mobs.shoot_projectile = function(self)

	local pos1 = self.object:get_pos()
	--add mob eye height
	pos1.y = pos1.y + self.eye_height

	local pos2 = self.attacking:get_pos()
	--add player eye height
	pos2.y = pos2.y + self.attacking:get_properties().eye_height

	--get direction
	local dir = vector_direction(pos1,pos2)

	--call internal shoot_arrow function
	self.shoot_arrow(self,pos1,dir)
end