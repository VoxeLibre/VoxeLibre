local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class
local validate_vector = mcl_util.validate_vector

local MAX_DTIME = 0.25 -- todo: make user configurable?
local ACCELERATION_MIX = 1.0 -- how much of acceleration to handle in Lua instead of MTE todo: make user configurable
local ENTITY_CRAMMING_MAX = 24
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
local sqrt = math.sqrt
local node_ok = mcl_mobs.node_ok

local PATHFINDING = "gowp"
local mobs_drop_items = minetest.settings:get_bool("mobs_drop_items") ~= false
local mob_active_range = tonumber(minetest.settings:get("mcl_mob_active_range")) or 48

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

-- Function that update some helpful variables on the mobs position:
-- standing_in: node the feet of the mob are in
-- standing_height: approx. "head height" with respect to that node
-- standing_on: node below
-- standing_under: node above
-- these may be "nil" (= ignore) and are otherwise already resolved via minetest.registered_nodes
function mob_class:update_standing(pos, moveresult)
	local temp_pos = vector.offset(pos, 0, self.collisionbox[2] + 0.5, 0) -- foot level
	self.standing_in = minetest.registered_nodes[minetest.get_node(temp_pos).name] or NODE_IGNORE
	temp_pos.y = temp_pos.y - 1.5 -- below
	self.standing_on_node = minetest.get_node(temp_pos) -- to allow access to param2 in, e.g., stalker
	self.standing_on = standing_on or minetest.registered_nodes[self.standing_on_node.name] or NODE_IGNORE
	-- sometimes, we may be colliding with a node *not* below us, effectively standing on it instead (e.g., a corner)
	if not self.standing_on.walkable and moveresult and moveresult.collisions then
		-- to inspect: minetest.log("action", dump(moveresult):gsub(" *\n\\s*",""))
		for _, c in ipairs(moveresult.collisions) do
			if c.axis == "y" and c.type == "node" and c.old_velocity.y < 0 then
				self.standing_on_node = minetest.get_node(c.node_pos)
				self.standing_on = minetest.registered_nodes[self.standing_on_node.name]
				break
			end
		end
	end
	-- approximate height of head over ground:
	self.standing_height = pos.y - math.floor(temp_pos.y + 0.5) - 0.5 + self.head_eye_height * 0.9
	temp_pos.y = temp_pos.y + 2 -- at +1 = above
	self.standing_under = minetest.registered_nodes[minetest.get_node(temp_pos).name] or NODE_IGNORE
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
	local dist = self.view_range
	if factor then
		if factor == 0 then return false end
		dist = dist * factor
	end
	local p1, p2 = self.object:get_pos(), object:get_pos()
	return p1 and p2 and (vector.distance(p1, p2) <= dist)
end

function mob_class:item_drop(cooked, looting_level)
	if not mobs_drop_items then return end
	looting_level = looting_level or 0

	if (self.child and self.type ~= "monster") then return end

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
				obj = minetest.add_item(pos, ItemStack(item .. " 1"))

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
	local x, z = 0, 0
	local width = -self.collisionbox[1] + self.collisionbox[4] + 0.5
	for _,object in pairs(minetest.get_objects_inside_radius(pos, width)) do
		local ent = object:get_luaentity()
		if object:is_player() or (ent and ent.is_mob and object ~= self.object) then
			if object:is_player() and mcl_burning.is_burning(self.object) then
				mcl_burning.set_on_fire(object, 4)
			end

			local pos2 = object:get_pos()
			local vx, vz  = pos.x - pos2.x, pos.z - pos2.z
			local force = width - sqrt(vx*vx+vz*vz)
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
	self.target_vel = v
end

-- calculate mob velocity (3d)
function mob_class:get_velocity_xyz()
	local v = self.object:get_velocity()
	if not v then return 0 end
	local x, y, z = v.x, v.y, v.z
	return sqrt(x*x + y*y + z*z)
end
-- calculate mob velocity (2d)
function mob_class:get_velocity_xz()
	local v = self.object:get_velocity()
	if not v then return 0 end
	local x, z = v.x, v.z
	return sqrt(x*x + z*z)
end
-- legacy API
mob_class.get_velocity = mob_class.get_velocity_xz

-- Relative turn, primarily for random turning
-- @param angle number: realative angle, in radians
-- @param delay number: time needed to turn
-- @param dtime deprecated: ignored now, because of smooth rotations
-- @return target angle
function mob_class:turn_by(angle, delay, dtime)
	if self.noyaw then return end
	return self:set_yaw((self.object:get_yaw() or 0) + (self.rotate or 0) + angle, delay, dtime)
end
-- Turn into a direction (e.g., to the player, or away)
-- @param dx number: delta in x axis to target
-- @param dz number: delta in z axis to target
-- @param delay number: time needed to turn
-- @param dtime deprecated: ignored now, because of smooth rotations
-- @return target angle
function mob_class:turn_in_direction(dx, dz, delay, dtime)
	if self.noyaw then return end
	if not self.rotate then self.rotate = 0 end
	if abs(dx) == 0 and abs(dz) == 0 then return self.object:get_yaw() + self.rotate end
	return self:set_yaw(-atan2(dx, dz) - self.rotate, delay, dtime) + self.rotate
end
-- Absolute turn into a particular direction
-- @param yaw number: angle in radians
-- @param delay number: time needed to turn
-- @param dtime deprecated: ignored now, because of smooth rotations
-- @return target angle
function mob_class:set_yaw(yaw, delay, dtime)
	if self.noyaw then return end
	if self._kb_turn then return yaw end -- knockback in effect
	if not self.object:get_yaw() or not self.object:get_pos() then return end
	self.delay = delay or 0
	self.target_yaw = yaw % TWOPI
	return self.target_yaw
end

-- name tag easter egg, test engine capabilities for rolling
local function update_roll()
	local is_Fleckenstein = self.nametag == "Fleckenstein"
	if not is_Fleckenstein and not self.is_Fleckenstein then return end

	local rot = self.object:get_rotation()
	rot.z = is_Fleckenstein and PI or 0
	self.object:set_rotation(rot)

	if is_Fleckenstein ~= self.is_Fleckenstein then
		local pos = self.object:get_pos()
		local cbox = is_Fleckenstein and table.copy(self.collisionbox) or self.object:get_properties().collisionbox
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

-- Improved smooth rotation
-- @param dtime number: timestep length
function mob_class:smooth_rotation(dtime)
	if self.noyaw then return end -- shulker
	if not self.target_yaw then return end

	local delay = self.delay
	local initial_yaw = (self.object:get_yaw() or 0) + self.rotate
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
	if yaw ~= initial_yaw then self.object:set_yaw(yaw - self.rotate) end
	--update_roll() -- Fleckenstein easter egg
end

-- Handling of intentional acceleration by the mob
-- its best to place environmental effects afterwards
-- TODO: have mobs that acccelerate faster and that accelerate slower?
-- FIXME: what about shulkers, that move without rotating?
-- @param dtime number: timestep length
function mob_class:smooth_acceleration(dtime)
	if self.noyaw then -- no rotational smoothing
		return
	end
	local yaw = self.target_yaw or (self.object:get_yaw() or 0) + (self.rotate or 0)
	local vel = self.target_vel or 0
	local x, z = -sin(yaw) * vel, cos(yaw) * vel
	local v = self.object:get_velocity()
	local w = min(dtime * 5, 1)
	v.x, v.z = v.x + w * (x - v.x), v.z + w * (z - v.z)
	self.object:set_velocity(v)
end

-- are we flying in what we are suppose to?
function mob_class:flight_check()
	if not self.standing_in or self.standing_in.name == "ignore" then return true end -- unknown?
	if not self.fly_in then return false end
	return not not self.fly_in[self.standing_in.name] -- force boolean
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
		if self.health > self.hp_max then
			self.health = self.hp_max
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
	if self.collisionbox then
		collisionbox = table.copy(self.collisionbox)
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
		local cbox = self.collisionbox
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

function mob_class:damage_mob(damage, reason, cmi_cause)
	if not self.health then return false end
	damage = floor(damage)
	if damage <= 0 then return false end
	self.health = self.health - damage
	mcl_mobs.effect(self.object:get_pos(), 5, "mcl_particles_smoke.png", 1, 2, 2, nil)
	return self:check_for_death(reason, cmi_cause)
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
-- called about once per second
function mob_class:do_env_damage()
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

	local y_level = self.collisionbox[2]

	if self.child then
		y_level = self.collisionbox[2] * 0.5
	end

	local standin = self.standing_in
	-- wither rose effect
	if standin.name == "mcl_flowers:wither_rose" then
		mcl_potions.give_effect_by_level("withering", self.object, 2, 2)
	end

	local nodef = minetest.registered_nodes[self.standing_in]
	local nodef2 = minetest.registered_nodes[self.standing_on]
	local nodef3 = minetest.registered_nodes[self.standing_under]

	-- rain
	if self.rain_damage > 0 and mcl_burning.is_affected_by_rain(self.object) then
		self.health = self.health - self.rain_damage
		if self:check_for_death("rain", {type = "environment", pos = pos, node = self.standing_in}) then
			return true
		end
	end

	if self.water_damage > 0 and standin.groups.water then
		self.health = self.health - self.water_damage
		mcl_mobs.effect(vector.offset(pos, 0, 1, 0), 5, "mcl_particles_smoke.png", nil, nil, 1, nil)
		if self:check_for_death("water", {type = "environment", pos = pos, node = standin.name}) then
			return true
		end
	end
	if self.lava_damage > 0 and standin.groups.lava then
		self.health = self.health - self.lava_damage
		mcl_mobs.effect(vector.offset(pos, 0, 1, 0), 5, "fire_basic_flame.png", nil, nil, 1, nil)
		mcl_burning.set_on_fire(self.object, 10)
		if self:check_for_death("lava", {type = "environment", pos = pos, node = standin.name}) then
			return true
		end
	end
	if self.fire_damage > 0 and self.standing_on.groups.fire then -- magma damage
		self.health = self.health - self.fire_damage
		if self:check_for_death("fire", {type = "environment", pos = pos, node = standin.name}) then
			return true
		end
	end
	if self.fire_damage > 0 and standin.groups.fire then
		self.health = self.health - self.fire_damage
		mcl_mobs.effect(pos, 5, "fire_basic_flame.png", nil, nil, 1, nil)
		mcl_burning.set_on_fire(self.object, 5)
		if self:check_for_death("fire", {type = "environment", pos = pos, node = standin.name}) then
			return true
		end
	end
	if standin.damage_per_second ~= 0 and not (standin.groups.lava or standin.groups.fire) then
		self.health = self.health - standin.damage_per_second
		mcl_mobs.effect(vector.offset(pos, 0, 1, 0), 5, "mcl_particles_smoke.png")
		if self:check_for_death("dps", {type = "environment", pos = pos, node = standin.name}) then
			return true
		end
	end

	-- Cactus damage
	if self.standing_on.name == "mcl_core:cactus" or standin.name == "mcl_core:cactus" or self.standing_under.name == "mcl_core:cactus" then
		if self:damage_mob(2, "cactus", {type = "environment", pos = pos, node = standin.name}) then
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
				if self:damage_mob(2, "cactus", {type = "environment", pos = pos, node = standin.name}) then
					return true
				end
			end
		end
	end

	-- Drowning damage
	if self.breath_max ~= -1 then
		local drowning = false

		if self.breathes_in_water then
			if not standin.groups.water then drowning = true end
		elseif standin.drowning > 0 and self.standing_under.drowning > 0 then
			drowning = true
		end

		if drowning then
			self.breath = max(0, self.breath - 1)
			mcl_mobs.effect(pos, 2, "bubble.png", nil, nil, 1, nil)
			if self.breath <= 0 then
				local dmg = standin.drowning > 0 and standin.drowning or 4
				self:damage_effect(dmg)
				self.health = self.health - dmg
			end
			if self:check_for_death("drowning", {type = "environment", pos = pos, node = standin.name}) then
				return true
			end
		else
			self.breath = min(self.breath_max, self.breath + 1)
		end
	end

	--- suffocation inside solid node
	-- FIXME: Redundant with mcl_playerplus
	if self.suffocation
	and (standin.walkable == nil or standin.walkable)
	and (standin.collision_box == nil or standin.collision_box.type == "regular")
	and (standin.node_box == nil or standin.node_box.type == "regular")
	and (standin.groups.disable_suffocation ~= 1)
	and (standin.groups.opaque == 1) then
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

			if self:check_for_death("suffocation", {type = "environment", pos = pos, node = standin.name}) then
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
		if self:do_env_damage() then return true end
		self:replace_node(pos) -- (sheep eats grass etc.)
	end
end

function mob_class:check_entity_cramming()
	local p = self.object:get_pos()
	if not p then return end
	local mobs = {}
	for o in minetest.objects_inside_radius(p, 0.5) do
		local l = o:get_luaentity()
		if l and l.is_mob and l.health > 0 then table.insert(mobs,l) end
	end
	local clear = #mobs < ENTITY_CRAMMING_MAX
	local ncram = {}
	for i = 1,#mobs do
		local l = mobs[i]
		if l then
			if clear then
				l.cram = nil
			elseif not l.cram and not self.child then
				ncram[#ncram] = l
			elseif l.cram then
				l:damage_mob(CRAMMING_DAMAGE, "cramming", { type = "cramming" })
			end
		end
	end
	for i,l in pairs(ncram) do
		l.cram = i > ENTITY_CRAMMING_MAX or nil
	end
end

-- Handle gravity, floating, falling and fall damage
-- @param pos vector: Position
-- @param dtime number: timestep length
-- @param moveresult table: minetest engine movement result (collisions)
-- @return true if mob died
function mob_class:gravity_and_floating(pos, dtime, moveresult)
	if self._just_portaled then
		self.start_fall_y = nil -- reset fall damage
	end
	if self.fly and self.state ~= "die" then return end
	if self.standing_in == NODE_IGNORE then -- not emerged yet, do not fall
		self.object:set_velocity(vector.zero())
		return false
	end
	-- self.object:set_properties({ nametag = "on: "..self.standing_on.name.."\nin: "..self.standing_in.name.."\n "..tostring(self.standing_height) })

	-- Gravity
	local acc = vector.new(0, not self.fly and moveresult and moveresult.touching_ground and 0 or self.fall_speed, 0)
	self.visc = 1
	local vel = self.object:get_velocity() or vector.zero()
	local standbody = self.standing_in
	if standbody.groups.water then
		self.visc = 0.4
		if self.floats > 0 then --and minetest.registered_nodes[node_ok(vector.offset(pos, 0, self.collisionbox[5] - 0.25, 0)).name].groups.water then
			local w = (self.standing_under.groups.water and 0 or self.standing_height) -- <1 is submerged, >1 is out
			if w > 0.95 and w < 1.05 then
				acc.y = 0 -- stabilize floating
			else
				acc.y = self.fall_speed * max(-1, min(1, w - 1)) -- -1 to +1
			end
		end
		self.start_fall_y = nil -- otherwise might receive fall damage on the next jump?
	elseif standbody.groups.lava then
		self.visc = 0.5
		if self.floats_on_lava > 0 then
			local w = self.standing_under.groups.water and 0 or self.standing_height -- 0 is submerged, 1 is out
			-- todo: relative to body height?
			if w > 0.95 and w < 1.05 then
				acc.y = 0
			else
				acc.y = self.fall_speed * max(-1, min(1, w - 1)) -- -1 to +1
			end
		end
		self.start_fall_y = nil -- otherwise might receive fall damage on the next jump?
	else
		-- fall damage onto solid ground (bouncy ground will yield vel.y > 0)
		if self.fall_damage == 1 and vel.y == 0 then
			local d = self.start_fall_y and (self.start_fall_y - self.object:get_pos().y) or 0
			if d > 5 then
				local ndef_on = self.standing_on
				if ndef_on and ndef_on.walkable then
					local damage = d - 5
					local add = ndef_on.fall_damage_add_percent
					if add then
						damage = damage + damage * (add/100)
					end
					if self:damage_mob(damage, "falling", {type = "environment"}) then
						return true
					end
					self.start_fall_y = nil
				end
			else
				self.start_fall_y = self.object:get_pos().y
			end
		end
	end
	self.acceleration = acc
end

--- Limit the velocity and acceleration of a mob applied by MTE
-- This is an attempt to solve mobs trampolining on water.
-- The problem is when a large timestep occurs, acceleration and velocity is applied
-- by the minetest engine (MTE) for a long timestep. If a mob enters or leaves water
-- during this time (or a similar transition occurs), this can become wildly inaccurate.
-- A mob slightly above water will fall deep into water, or may fly high into
-- the air because of updrift.
function mob_class:limit_vel_acc_for_large_dtime(pos, dtime, moveresult)
	-- hack not in use:
	if ACCELERATION_MIX == 0 and dtime < MAX_DTIME then return pos end
	local edtime, rdtime = dtime, 0 -- effective dtime and reverted dtime
	if dtime >= MAX_DTIME then
		edtime, rdtime = MAX_DTIME, dtime - MAX_DTIME
	end

	local vel = self.object:get_velocity()
	local acc = self.object:get_acceleration()
	-- revert excess movement and acceleration from MTE
	if rdtime > 0 and not (moveresult and moveresult.collides) then
		vel = vel - acc * rdtime
		pos = pos - (vel - acc * rdtime * 0.5) * rdtime -- at average velocity during excess
	end
	-- apply the missing lua part of acceleration:
	if ACCELERATION_MIX > 0 and self.acceleration then
		local dx, dy, dz = self.acceleration.x, self.acceleration.y, self.acceleration.z
		-- use collision information:
		if moveresult and moveresult.collisions then
			for _, c in ipairs(moveresult.collisions) do
				if c.axis == "y" then
					if c.old_velocity.y < 0 and dy < 0 then dy = 0 end
					if c.old_velocity.y > 0 and dy > 0 then dy = 0 end
				elseif c.axis == "x" then
					if c.old_velocity.x < 0 and dx < 0 then dx = 0 end
					if c.old_velocity.x > 0 and dx > 0 then dx = 0 end
				elseif c.axis == "z" then
					if c.old_velocity.z < 0 and dz < 0 then dz = 0 end
					if c.old_velocity.z > 0 and dz > 0 then dz = 0 end
				end
			end
		end
		vel.x = vel.x + dx * edtime * ACCELERATION_MIX
		vel.y = vel.y + dy * edtime * ACCELERATION_MIX
		vel.z = vel.z + dz * edtime * ACCELERATION_MIX
		-- because we cannot check for collission, we simply allow the extra acceleration to lag a timestep:
		-- pos = pos + self.acceleration * edtime * 0.5 * rdtime
	end
	self.object:set_velocity(vel)
	self.object:set_pos(pos)
	return pos
end

--- Update velocity and acceleration at the end of our movement logic
-- 
function mob_class:update_vel_acc(dtime)
	local vel = self.object:get_velocity()
	--vel.x, vel.y, vel.z = vel.x * visc, (vel.y + acc.y * dtime) * visc, vel.z * visc
	vel.y = max(min(vel.y, -self.fall_speed), self.fall_speed)

	-- Cap dtime to reduce bopping on water (hence we also do not use minetest acceleration)
	-- but the minetest engine already applied the current velocity on the full timestep
	dtime = min(dtime, MAX_DTIME)

	-- Slowdown in liquids:
	if self.visc then
		-- TODO: only on y, or also apply to vel.x, vel.z, acceleration?
		vel.y = vel.y * self.visc^(dtime*10)
		-- vel = vel * self.visc^(dtime*10)
	end

	-- acceleration:
	if self.acceleration and ACCELERATION_MIX < 1 then
		self.object:set_acceleration(self.acceleration * (1 - ACCELERATION_MIX))
		-- the remaining part is applied after the dtime step
	end

	self.object:set_velocity(vel)
end

-- Add water flowing for mobs from mcl_item_entity
function mob_class:check_water_flow(dtime, pos)
	local def = self.standing_in
	-- Move item around on flowing liquids
	if def and def.liquidtype == "flowing" then

		--[[ Get flowing direction (function call from flowlib), if there's a liquid.
		NOTE: According to Qwertymine, flowlib.quickflow is only reliable for liquids with a flowing distance of 7.
		Luckily, this is exactly what we need if we only care about water, which has this flowing distance. ]]
		local vec = flowlib.quick_flow(pos, minetest.get_node(pos))
		-- Just to make sure we don't manipulate the speed for no reason
		if vec.x ~= 0 or vec.y ~= 0 or vec.z ~= 0 then
			-- Minecraft Wiki: Flowing speed is "about 1.39 meters per second"
			local f = 8 -- but we have acceleration ehre, not velocity. Was: 1.39
			-- Set new item moving speed into the direciton of the liquid
			self.acceleration = self.acceleration + vector.new(vec.x * f, -0.22, vec.z * f)
			--self.physical_state = true
			--self._flowing = true
			--self.object:set_properties({ physical = true })
			return
		end
	--elseif self._flowing == true then
	--	-- Disable flowing physics if not on/in flowing liquid
	--	self._flowing = false
	--	return
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
		self:set_animation("stand", true)
		if self.object:get_velocity() then
			self.object:set_velocity(vector.zero())
		end
		return true
	end
end
