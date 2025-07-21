local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
local validate_vector = mcl_util.validate_vector

local gamerule_maxEntityCramming = 24
vl_tuning.setting("gamerule:maxEntityCramming", "number", {
	description = S("The maximum number of pushable entities a mob or player can push, before taking 6♥♥♥ entity cramming damage per half-second."),
	default = 24,
	formspec_desc_lines = 2,
	set = function(val) gamerule_maxEntityCramming = val end,
	get = function() return gamerule_maxEntityCramming end,
})
local gamerule_doMobLoot
vl_tuning.setting("gamerule:doMobLoot", "bool", {
	description = S("Whether mobs should drop items and experience orbs."),
	default = true,
	set = function(val) gamerule_doMobLoot = val end,
	get = function() return gamerule_doMobLoot end,
})

local CRAMMING_DAMAGE = 3
local DEATH_DELAY = 0.5
local DEFAULT_FALL_SPEED = -9.81*1.5
local PI = math.pi
local HALFPI = 0.5 * PI
local TWOPI = 2 * PI -- aka tau, but not very common
local random = math.random
local min = math.min
local max = math.max
local floor = math.floor
local abs = math.abs
local atan2 = math.atan2
local sin = math.sin
local cos = math.cos
local node_ok = mcl_mobs.node_ok

local PATHFINDING = "gowp"
local mobs_debug = minetest.settings:get_bool("mobs_debug", false)
local mobs_drop_items = minetest.settings:get_bool("mobs_drop_items") ~= false
local mob_active_range = tonumber(minetest.settings:get("mcl_mob_active_range")) or 48
local show_health = false

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
	if not pos then return true end
	for _,v in pairs(pos) do
		if v < wmin or v > wmax then return false end
	end
	return true
end

function mob_class:player_in_active_range()
	for _,p in pairs(minetest.get_connected_players()) do
		local pos = self.object:get_pos()
		if pos and vector.distance(pos, p:get_pos()) <= mob_active_range then return true end
		-- slightly larger than the mc 32 since mobs spawn on that circle and easily stand still immediately right after spawning.
	end
end

-- Return true if object is in view_range
function mob_class:object_in_range(object)
	if not object then return false end
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

function mob_class:item_drop(cooked, looting_level)

	if not mobs_drop_items then return end

	looting_level = looting_level or 0

	if (self.child and self.type ~= "monster") then
		return
	end

	local obj, item, num
	local pos = self.object:get_pos()

	self.drops = self.drops or {}

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
		if random() < chance then
			num = random(dropdef.min or 1, dropdef.max or 1)
		elseif not dropdef.looting_ignore_chance then
			do_common_looting = false
		end

		if do_common_looting then
			num = num + floor(random(0, looting_level) + 0.5)
		end

		if num > 0 then
			item = dropdef.name

			if cooked then
				local output = minetest.get_craft_result({method = "cooking", width = 1, items = {item}})
				if output and output.item and not output.item:is_empty() then
					item = output.item:get_name()
				end
			end

			for x = 1, num do
				obj = minetest.add_item(pos, ItemStack(item .. " " .. 1))

				if obj and obj:get_luaentity() then
					obj:set_velocity(vector.new((random() - 0.5) * 1.5, 6, (random() - 0.5) * 1.5))
				elseif obj then
					obj:remove() -- item does not exist
				end
			end
		end
	end

	self.drops = {}
end

-- collision function borrowed amended from jordan4ibanez open_ai mod
function mob_class:collision()
	local pos = self.object:get_pos()
	if not pos then return 0,0 end
	local vel = self.object:get_velocity()
	local x, z = 0, 0
	local cb = self.initial_properties.collisionbox
	local width = -cb[1] + cb[4] + 0.5
	for _,object in pairs(minetest.get_objects_inside_radius(pos, width)) do
		local ent = object:get_luaentity()
		if object:is_player() or (ent and ent.is_mob and object ~= self.object) then
			if object:is_player() and mcl_burning.is_burning(self.object) then
				mcl_burning.set_on_fire(object, 4)
			end

			local pos2 = object:get_pos()
			local vx, vz  = pos.x - pos2.x, pos.z - pos2.z
			local force = width - (vx*vx+vz*vz)^0.5
			if force > 0 then
				force = force * force * (object:is_player() and 2 or 1) -- players push more
				-- minetest.log("mob push force "..force.." "..tostring(self.name).." by "..tostring(ent and ent.name or "player"))
				x = x + vx * force
				z = z + vz * force
			end
		end
	end
	return x, z
end

function mob_class:check_death_and_slow_mob()
	local d = 0.7
	local dying = self:check_dying()
	if dying then d = 0.92 end

	local v = self.object:get_velocity()
	if v then
		--diffuse object velocity
		self.object:set_velocity(vector.new(v.x*d, v.y, v.z*d))
	end
	return dying
end

-- move mob in facing direction
function mob_class:set_velocity(v)
	local c_x, c_z = 0, 0
	-- can mob be pushed, if so calculate direction
	if self.pushable then
		c_x, c_z = self:collision()
	end
	if v > 0 then
		local yaw = (self.object:get_yaw() or 0) + self.rotate
		local x = ((-sin(yaw) * v) + c_x) * .4
		local z = (( cos(yaw) * v) + c_z) * .4
		if not self.acc then
			self.acc = vector.new(x, 0, z)
		else
			self.acc.x, self.acc.y, self.acc.z = x, 0, z
		end
	else -- allow standing mobs to be pushed
		if not self.acc then
			self.acc = vector.new(c_x * .2, 0, c_z * .2)
		else
			self.acc.x, self.acc.y, self.acc.z = c_x * .2, 0, c_z * .2
		end
	end
end

-- calculate mob velocity (2d)
function mob_class:get_velocity()
	local v = self.object:get_velocity()
	if not v then return 0 end
	return (v.x*v.x + v.z*v.z)^0.5
end

function mob_class:update_roll()
	local is_Fleckenstein = self.nametag == "Fleckenstein"
	if not is_Fleckenstein and not self.is_Fleckenstein then return end

	local rot = self.object:get_rotation()
	rot.z = is_Fleckenstein and PI or 0
	self.object:set_rotation(rot)

	if is_Fleckenstein ~= self.is_Fleckenstein then
		local pos = self.object:get_pos()
		local cbox = is_Fleckenstein and table.copy(self.initial_properties.collisionbox) or self.object:get_properties().collisionbox
		pos.y = pos.y + (cbox[2] + cbox[5])
		cbox[2], cbox[5] = -cbox[5], -cbox[2]
		-- This leads to child mobs having the wrong collisionbox
		-- and seeing as it seems to be nothing but an easter egg
		-- i've put it inside the if. Which just makes it be upside
		-- down lol.
		self.object:set_properties({collisionbox = cbox})
		self.object:set_pos(pos)
	end
	self.is_Fleckenstein = is_Fleckenstein
end

-- Relative turn, primarily for random turning
-- @param dtime deprecated: ignored now, because of smooth rotations
function mob_class:turn_by(angle, delay, dtime)
	if self.noyaw then return end -- shulker
	return self:set_yaw((self.object:get_yaw() or 0) + angle, delay, dtime)
end
-- Turn into a direction (e.g., to the player, or away)
-- @param dtime deprecated: ignored now, because of smooth rotations
function mob_class:turn_in_direction(dx, dz, delay, dtime)
	if self.noyaw then return end -- shulker
	if not self.rotate then self.rotate = 0 end
	if abs(dx) == 0 and abs(dz) == 0 then return self.object:get_yaw() + self.rotate end
	return self:set_yaw(-atan2(dx, dz) - self.rotate, delay, dtime) + self.rotate
end
-- set and return valid yaw
-- @param dtime deprecated: ignored now, because of smooth rotations
function mob_class:set_yaw(yaw, delay, dtime)
	if self.noyaw then return end
	if self._kb_turn then return yaw end -- knockback in effect
	if not self.object:get_yaw() or not self.object:get_pos() then return end
	self.delay = delay or 0
	self.target_yaw = yaw % TWOPI
	return self.target_yaw
end

-- improved smooth rotation
function mob_class:check_smooth_rotation(dtime)
	if not self.target_yaw then return end

	local delay = self.delay
	local initial_yaw = self.object:get_yaw() or 0
	local yaw -- resulting yaw for this tick
	if delay and delay > 1 then
		local dif = (self.target_yaw - initial_yaw + PI) % TWOPI - PI
		yaw = (initial_yaw + dif / delay) % TWOPI
		self.delay = delay - 1
	else
		yaw = self.target_yaw
	end

	if self.shaking then
		yaw = yaw + (random() * 2 - 1) / 72 * dtime
	end
	--[[ needed? if self.acc then
		local change = yaw - initial_yaw
		local si, co = sin(change), cos(change)
		self.acc.x, self.acc.y = co * self.acc.x - si * self.acc.y, si * self.acc.x + co * self.acc.y
	end ]]--
	self.object:set_yaw(yaw)
	self:update_roll()
end

-- are we flying in what we are suppose to? (taikedz)
function mob_class:flight_check()
	local nod = self.standing_in
	if nod == "ignore" then return true end
	return not not self.fly_in[nod] -- force boolean
end

-- check if mob is dead or only hurt
function mob_class:check_for_death(cause, cmi_cause)

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
		if self.health > self.initial_properties.hp_max then
			self.health = self.initial_properties.hp_max
		end

		-- play damage sound if health was reduced and make mob flash red.
		if damaged then
			self:add_texture_mod("^[colorize:#d42222:175")
			minetest.after(1, function(self)
				if self and self.object then
					self:remove_texture_mod("^[colorize:#d42222:175")
				end
			end, self)
			self:mob_sound("damage")
		end

		-- backup nametag so we can show health stats
		if not self.nametag2 then
			self.nametag2 = self.nametag or ""
		end

		if show_health
		and (cmi_cause and cmi_cause.type == "punch") then

			self.htimer = 2
			self.nametag = "♥ " .. self.health .. " / " .. self.initial_properties.hp_max

			self:update_tag()
		end

		return false
	end

	self:mob_sound("death")

	local function death_handle(self)
		if cmi_cause and cmi_cause["type"] then
			--minetest.log("cmi_cause: " .. tostring(cmi_cause["type"]))
		end
		--minetest.log("cause: " .. tostring(cause))

		-- TODO other env damage shouldn't drop xp
		-- "rain", "water", "drowning", "suffocation"

		if not gamerule_doMobLoot then return end

		-- dropped cooked item if mob died in fire or lava
		if cause == "lava" or cause == "fire" then
			self:item_drop(true, 0)
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
			self:item_drop(cooked, looting)

			if ((not self.child) or self.type ~= "animal") and (minetest.get_us_time() - self.xp_timestamp <= math.huge) then
				local pos = self.object:get_pos()
				local xp_amount = random(self.xp_min, self.xp_max)

				if not mcl_sculk.handle_death(pos, xp_amount) then
					--minetest.log("Xp not thrown")
					if minetest.is_creative_enabled("") ~= true then
						mcl_experience.throw_xp(pos, xp_amount)
					end
				else
					--minetest.log("xp thrown")
				end
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

		if on_die_exit == true then
			self.state = "die"
			mcl_burning.extinguish(self.object)
			mcl_util.remove_entity(self)
			return true
		end
	end

	if self.jockey or self.riden_by_jock then
		self.riden_by_jock = nil
		self.jockey = nil
	end


	local collisionbox
	if self.initial_properties.collisionbox then
		collisionbox = table.copy(self.initial_properties.collisionbox)
	end

	self.state = "die"
	self.attack = nil
	self.v_start = false
	self.fall_speed = DEFAULT_FALL_SPEED
	self.timer = 0
	self.blinktimer = 0
	self:remove_texture_mod("^[colorize:#FF000040")
	self:remove_texture_mod("^[brighten")
	self.passive = true

	self.object:set_properties({
		pointable = false,
		collide_with_objects = false,
	})

	self:set_velocity(0)
	local acc = self.object:get_acceleration()
	if acc then
		acc.x, acc.y, acc.z = 0, DEFAULT_FALL_SPEED, 0
		self.object:set_acceleration(acc)
	end

	local length
	-- default death function and die animation (if defined)
	if self.instant_death then
		length = 0
	elseif self.animation and self.animation.die_start and self.animation.die_end then
		local frames = self.animation.die_end - self.animation.die_start
		local speed = self.animation.die_speed or 15
		length = max(frames / speed, 0) + DEATH_DELAY
		self:set_animation( "die")
	else
		length = 1 + DEATH_DELAY
		self:set_animation( "stand", true)
	end


	-- Remove body after a few seconds and drop stuff
	local kill = function(self)
		if not self.object:get_luaentity() then
			return
		end
		death_handle(self)
		local dpos = self.object:get_pos()
		local cbox = self.initial_properties.collisionbox
		local yaw = self.object:get_rotation().y
		mcl_burning.extinguish(self.object)
		mcl_util.remove_entity(self)
		mcl_mobs.death_effect(dpos, yaw, cbox, not self.instant_death)
	end

	if length <= 0 then
		kill(self)
	else
		minetest.after(length, kill, self)
	end

	return true
end

-- Deal light damage to mob, returns true if mob died
function mob_class:deal_light_damage(pos, damage)
	if not ((mcl_weather.rain.raining or mcl_weather.state == "snow") and mcl_weather.is_outdoor(pos)) then
		self.health = self.health - damage

		mcl_mobs.effect(pos, 5, "mcl_particles_smoke.png")

		if self:check_for_death("light", {type = "light"}) then
			return true
		end
	end
end

-- environmental damage (water, lava, fire, light etc.)
function mob_class:do_env_damage()
	-- feed/tame text timer (so mob 'full' messages dont spam chat)
	if self.htimer > 0 then
		self.htimer = self.htimer - 1
	end

	-- reset nametag after showing health stats
	if self.htimer < 1 and self.nametag2 then

		self.nametag = self.nametag2
		self.nametag2 = nil

		self:update_tag()
	end

	local pos = self.object:get_pos()
	if not pos then return end

	self.time_of_day = minetest.get_timeofday()

	-- remove mob if beyond map limits
	if not within_limits(pos, 0) then
		mcl_burning.extinguish(self.object)
		mcl_util.remove_entity(self)
		return true
	end

	-- Simple light damage
	if (self.light_damage or 0) > 0 and mcl_burning.is_affected_by_sunlight(self.object, 12) then
		if self:deal_light_damage(pos, self.light_damage) then
			return true
		end
	end

	-- Sunlight burning/igniting mobs
	if (self.sunlight_damage ~= 0 or self.ignited_by_sunlight) and mcl_burning.is_affected_by_sunlight(self.object) then
		if not (self.armor_list and (self.armor_list.helmet or "") ~= "") then
			if self.ignited_by_sunlight and not mcl_burning.is_affected_by_rain(self.object) then
				if (#mcl_burning.get_touching_nodes(self.object, "group:puts_out_fire", self) == 0) then
					mcl_burning.set_on_fire(self.object, 10)
				end
			else
				self:deal_light_damage(pos, self.sunlight_damage)
			end
		end
	end

	local y_level = self.initial_properties.collisionbox[2]

	if self.child then
		y_level = self.initial_properties.collisionbox[2] * 0.5
	end

	-- what is mob standing in?
	pos.y = pos.y + y_level + 0.25 -- foot level
	local pos2 = vector.new(pos.x, pos.y-1, pos.z)
	self.standing_in = node_ok(pos, "air").name
	self.standing_on = node_ok(pos2, "air").name

	local pos3 = vector.offset(pos, 0, 1, 0)
	self.standing_under = node_ok(pos3, "air").name

	-- don't fall when on ignore, just stand still
	if self.standing_in == "ignore" then
		self.object:set_velocity(vector.zero())
	-- wither rose effect
	elseif self.standing_in == "mcl_flowers:wither_rose" then
		mcl_potions.give_effect_by_level("withering", self.object, 2, 2)
	end

	local nodef = minetest.registered_nodes[self.standing_in]
	local nodef2 = minetest.registered_nodes[self.standing_on]
	local nodef3 = minetest.registered_nodes[self.standing_under]

	-- rain
	if self.rain_damage > 0 and mcl_burning.is_affected_by_rain(self.object) then
		self.health = self.health - self.rain_damage

		if self:check_for_death("rain", {type = "environment",
				pos = pos, node = self.standing_in}) then
			return true
		end
	end

	pos.y = pos.y + 1 -- for particle effect position

	-- water damage
	if self.water_damage > 0 and nodef.groups.water then
		self.health = self.health - self.water_damage
		mcl_mobs.effect(pos, 5, "mcl_particles_smoke.png", nil, nil, 1, nil)
		if self:check_for_death("water", {type = "environment", pos = pos, node = self.standing_in}) then
			return true
		end
	elseif self.lava_damage > 0 and (nodef.groups.lava) then
		-- lava damage
		if self.lava_damage ~= 0 then
			self.health = self.health - self.lava_damage
			mcl_mobs.effect(pos, 5, "fire_basic_flame.png", nil, nil, 1, nil)
			mcl_burning.set_on_fire(self.object, 10)

			if self:check_for_death("lava", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		end
	elseif self.fire_damage > 0 and (nodef2.groups.fire) then
		-- magma damage
		self.health = self.health - self.fire_damage
		if self:check_for_death("fire", {type = "environment", pos = pos, node = self.standing_in}) then
			return true
		end
	elseif self.fire_damage > 0 and (nodef.groups.fire) then
		-- fire damage
		self.health = self.health - self.fire_damage
		mcl_mobs.effect(pos, 5, "fire_basic_flame.png", nil, nil, 1, nil)
		mcl_burning.set_on_fire(self.object, 5)
		if self:check_for_death("fire", {type = "environment", pos = pos, node = self.standing_in}) then
			return true
		end
	elseif nodef.damage_per_second ~= 0 and not nodef.groups.lava and not nodef.groups.fire then
		-- damage_per_second node check
		self.health = self.health - nodef.damage_per_second
		mcl_mobs.effect(pos, 5, "mcl_particles_smoke.png")
		if self:check_for_death("dps", {type = "environment", pos = pos, node = self.standing_in}) then
			return true
		end
	end

	-- Cactus damage
	if self.standing_on == "mcl_core:cactus" or self.standing_in == "mcl_core:cactus" or self.standing_under == "mcl_core:cactus" then
		self:damage_mob("cactus", 2)
		if self:check_for_death("cactus", {type = "environment", pos = pos, node = self.standing_in}) then
			return true
		end
	else
		local near = minetest.find_node_near(pos, 1, "mcl_core:cactus")
		if near then
			-- is mob touching the cactus?
			local dist = vector.distance(pos, near)
			local threshold  = 1.04 -- small mobs
			-- medium mobs
			if self.name == "mobs_mc:spider" or
				self.name == "mobs_mc:iron_golem" or
				self.name == "mobs_mc:horse" or
				self.name == "mobs_mc:donkey" or
				self.name == "mobs_mc:mule" or
				self.name == "mobs_mc:polar_bear" or
				self.name == "mobs_mc:cave_spider" or
				self.name == "mobs_mc:skeleton_horse" or
				self.name == "mobs_mc:zombie_horse" or
				self.name == "mobs_mc:strider" or
				self.name == "mobs_mc:hoglin" or
				self.name == "mobs_mc:zoglin" then
				threshold = 1.165
			elseif self.name == "mobs_mc:slime_big" or
				self.name == "mobs_mc:magma_cube_big" or
				self.name == "mobs_mc:ghast" or
				self.name == "mobs_mc:guardian_elder" or
				self.name == "mobs_mc:wither" or
				self.name == "mobs_mc:ender_dragon" then
				threshold = 1.25
			end
			if dist < threshold then
				self:damage_mob("cactus", 2)
				if self:check_for_death("cactus", {type = "environment", pos = pos, node = self.standing_in}) then
					return true
				end
			end
		end
	end

	-- Drowning damage
	if self.initial_properties.breath_max ~= -1 then
		local drowning = false

		if self.breathes_in_water then
			if minetest.get_item_group(self.standing_in, "water") == 0 then
				drowning = true
			end
		elseif nodef.drowning > 0 and nodef3.drowning > 0 then
			drowning = true
		end

		if drowning then
			self.breath = max(0, self.breath - 1)
			mcl_mobs.effect(pos, 2, "bubble.png", nil, nil, 1, nil)
			if self.breath <= 0 then
				local dmg
				if nodef.drowning > 0 then
					dmg = nodef.drowning
				else
					dmg = 4
				end
				self:damage_effect(dmg)
				self.health = self.health - dmg
			end
			if self:check_for_death("drowning", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		else
			self.breath = min(self.initial_properties.breath_max, self.breath + 1)
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

			if self:check_for_death("suffocation", {type = "environment",
					pos = pos, node = self.standing_in}) then
				return true
			end
		end
	else
		self.suffocation_timer = 0
	end

	return self:check_for_death("unknown", {type = "unknown"})
end

function mob_class:step_damage (dtime, pos)
	if not self.fire_resistant then
		mcl_burning.tick(self.object, dtime, self)
		if not self.object:get_pos() then return true end -- mcl_burning.tick may remove object immediately

		if self:check_for_death("fire", {type = "fire"}) then
			return true
		end
	end

	-- environmental damage timer (every 1 second)
	self.env_damage_timer = self.env_damage_timer + dtime

	if self.env_damage_timer > 1 then
		self.env_damage_timer = 0

		self:check_entity_cramming()

		-- check for environmental damage (water, fire, lava etc.)
		if self:do_env_damage() then
			return true
		end

		self:replace_node(pos) -- (sheep eats grass etc.)
	end
end

function mob_class:damage_mob(reason,damage)
	if not self.health then return end
	damage = floor(damage)
	if damage > 0 then
		self.health = self.health - damage

		mcl_mobs.effect(self.object:get_pos(), 5, "mcl_particles_smoke.png", 1, 2, 2, nil)

		if self:check_for_death(reason, {type = reason}) then
			return true
		end
	end
end

function mob_class:check_entity_cramming()
	local p = self.object:get_pos()
	if not p then return end
	local oo = minetest.get_objects_inside_radius(p,1)
	local mobs = {}
	for _,o in pairs(oo) do
		local l = o:get_luaentity()
		if l and l.is_mob and l.health > 0 then table.insert(mobs,l) end
	end
	local clear = #mobs < gamerule_maxEntityCramming
	local ncram = {}
	for _,l in pairs(mobs) do
		if l then
			if clear then
				l.cram = nil
			elseif l.cram == nil and not self.child then
				table.insert(ncram,l)
			elseif l.cram then
				l:damage_mob("cramming",CRAMMING_DAMAGE)
			end
		end
	end
	for i,l in pairs(ncram) do
		if i > gamerule_maxEntityCramming then
			l.cram = true
		else
			l.cram = nil
		end
	end
end

-- falling and fall damage
-- returns true if mob died
function mob_class:falling(pos, moveresult)
	if self.fly and self.state ~= "die" then return end
	if not self.fall_speed then self.fall_speed = DEFAULT_FALL_SPEED end

	-- Gravity
	local v = self.object:get_velocity()
	if v then
		if v.y > 0 or (v.y <= 0 and v.y > self.fall_speed) then
			-- fall downwards at set speed
			if moveresult and moveresult.touching_ground then
				-- when touching ground, retain a minimal gravity to keep the touching_ground flag
				-- but also to not get upwards acceleration with large dtime when on bouncy ground
				self.object:set_acceleration(vector.new(0, self.fall_speed * 0.01, 0))
			else
				self.object:set_acceleration(vector.new(0, self.fall_speed, 0))
			end
		else
			-- stop accelerating once max fall speed hit
			self.object:set_acceleration(vector.zero())
		end
	end

	if mcl_portals ~= nil then
		if mcl_portals.nether_portal_cooloff(self.object) then
			return false -- mob has teleported through Nether portal - it's 99% not falling
		end
	end

	local registered_node = minetest.registered_nodes[node_ok(pos).name]

	if registered_node.groups.lava then
		if self.floats_on_lava == 1 then
			self.object:set_acceleration(vector.new(0, -self.fall_speed / max(1, v.y^2), 0))
		end
	end

	-- in water then float up
	if registered_node.groups.water then
		if self.floats == 1 and minetest.registered_nodes[node_ok(vector.offset(pos,0,self.initial_properties.collisionbox[5] -0.25,0)).name].groups.water then
			self.object:set_acceleration(vector.new(0, -self.fall_speed / max(1, v.y^2), 0))
		end
	else
		-- fall damage onto solid ground
		if self.fall_damage == 1 and self.object:get_velocity().y == 0 then
			local n = node_ok(vector.offset(pos,0,-1,0)).name
			local d = (self.old_y or 0) - self.object:get_pos().y

			if d > 5 and n ~= "air" and n ~= "ignore" then
				local add = minetest.get_item_group(self.standing_on, "fall_damage_add_percent")
				local damage = d - 5
				if add ~= 0 then
					damage = damage + damage * (add/100)
				end
				self:damage_mob("fall",damage)
			end

			self.old_y = self.object:get_pos().y
		end
	end
end

function mob_class:check_water_flow()
	-- Add water flowing for mobs from mcl_item_entity
	local p = self.object:get_pos()
	local node = minetest.get_node_or_nil(p)
	local def = node and minetest.registered_nodes[node.name]

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
			self.object:set_acceleration(vector.zero())
			self.object:set_velocity(vector.new(newv.x, -0.22, newv.z))

			self.physical_state = true
			self._flowing = true
			self.object:set_properties({ physical = true })
			return
		end
	elseif self._flowing == true then
		-- Disable flowing physics if not on/in flowing liquid
		self._flowing = false
		return
	end
end

function mob_class:check_dying()
	if ((self.state and self.state=="die") or self:check_for_death()) and not self.animation.die_end then
		local rot = self.object:get_rotation()
		if rot then
			rot.z = ((HALFPI - rot.z) * .2) + rot.z
			self.object:set_rotation(rot)
		end
		return true
	end
end

function mob_class:check_suspend(player_in_active_range)
	local pos = self.object:get_pos()

	if pos and not player_in_active_range then
		local node_under = node_ok(vector.offset(pos,0,-1,0)).name

		self:set_animation( "stand", true)

		local acc = self.object:get_acceleration()
		if acc then
			if acc.y > 0 or node_under ~= "air" then
				self.object:set_acceleration(vector.zero())
				self.object:set_velocity(vector.zero())
			end
		end
		return true
	end
end
