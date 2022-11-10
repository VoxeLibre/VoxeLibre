local mob_class = mcl_mobs.mob_class
local mob_class_meta = {__index = mcl_mobs.mob_class}
local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
-- API for Mobs Redo: MineClone 2 Edition (MRM)
local MAX_MOB_NAME_LENGTH = 30
local DEFAULT_FALL_SPEED = -9.81*1.5

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
local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local spawn_protected = minetest.settings:get_bool("mobs_spawn_protected") ~= false
local remove_far = true
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

-- get node but use fallback for nil or unknown
local node_ok = function(pos, fallback)
	fallback = fallback or mcl_mobs.fallback_node
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	return minetest.registered_nodes[fallback]
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
			and self:is_at_cliff_or_danger() == false then

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

	-- runaway when punched
	elseif self.state == "runaway" then

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

				if self:is_at_cliff_or_danger() then

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
function mob_class:get_staticdata()

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
function mob_class:mob_activate(staticdata, def, dtime)
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

-- main mob function
function mob_class:on_step(dtime)
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

	self:check_aggro(dtime)
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
	self:follow_flop()

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
		self:replace(pos)
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

	self:do_jump()

	self:set_armor_texture()

	self:check_runaway_from()

	if self:is_at_water_danger() and self.state ~= "attack" then
		if math.random(1, 10) <= 6 then
			self:set_velocity(0)
			self.state = "stand"
			self:set_animation( "stand")
			yaw = yaw + math.random(-0.5, 0.5)
			yaw = self:set_yaw( yaw, 8)
		end
	else
		if self.move_in_group ~= false then
			self:check_herd(dtime)
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

	if self:is_at_cliff_or_danger() then
			self:set_velocity(0)
			self.state = "stand"
			self:set_animation( "stand")
			local yaw = self.object:get_yaw() or 0
			yaw = self:set_yaw( yaw + 0.78, 8)
	end
end


-- default function when mobs are blown up with TNT
local function do_tnt(self,damage)
	self.object:punch(self.object, 1.0, {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = damage},
	}, nil)

	return false, true, {}
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
