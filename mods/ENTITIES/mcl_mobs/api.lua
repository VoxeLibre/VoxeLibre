-- API for Mobs Redo: MineClone 2 Delux 2.0 DRM Free Early Access Super Extreme Edition

-- current state of things: Why?

-- lua locals

--localize minetest functions
local minetest_settings                     = minetest.settings
local minetest_get_objects_inside_radius    = minetest.get_objects_inside_radius
local minetest_get_modpath                  = minetest.get_modpath
local minetest_registered_nodes             = minetest.registered_nodes
local minetest_get_node                     = minetest.get_node
local minetest_get_item_group               = minetest.get_item_group
local minetest_registered_entities          = minetest.registered_entities
local minetest_line_of_sight                = minetest.line_of_sight
local minetest_after                        = minetest.after
local minetest_sound_play                   = minetest.sound_play
local minetest_add_particlespawner          = minetest.add_particlespawner
local minetest_registered_items             = minetest.registered_items
local minetest_set_node                     = minetest.set_node
local minetest_add_item                     = minetest.add_item
local minetest_get_craft_result             = minetest.get_craft_result
local minetest_find_path                    = minetest.find_path
local minetest_is_protected                 = minetest.is_protected
local minetest_is_creative_enabled          = minetest.is_creative_enabled
local minetest_find_node_near               = minetest.find_node_near
local minetest_find_nodes_in_area_under_air = minetest.find_nodes_in_area_under_air
local minetest_raycast                      = minetest.raycast
local minetest_get_us_time                  = minetest.get_us_time
local minetest_add_entity                   = minetest.add_entity
local minetest_get_natural_light            = minetest.get_natural_light
local minetest_get_node_or_nil              = minetest.get_node_or_nil

-- localize math functions
local math_pi     = math.pi
local math_sin    = math.sin
local math_cos    = math.cos
local math_abs    = math.abs
local math_min    = math.min
local math_max    = math.max
local math_atan   = math.atan
local math_random = math.random
local math_floor  = math.floor

-- localize vector functions
local vector_new    = vector.new
local vector_length = vector.length

mobs = {}
-- mob constants
local MAX_MOB_NAME_LENGTH = 30
local BREED_TIME          = 30
local BREED_TIME_AGAIN    = 300
local CHILD_GROW_TIME     = 60*20
local DEATH_DELAY         = 0.5
local DEFAULT_FALL_SPEED  = -10
local FLOP_HEIGHT         = 5.0
local FLOP_HOR_SPEED      = 1.5

local MOB_CAP   = {}
MOB_CAP.hostile = 70
MOB_CAP.passive = 10
MOB_CAP.ambient = 15
MOB_CAP.water   = 15

-- Load main settings
local damage_enabled    = minetest_settings:get_bool("enable_damage")
local disable_blood     = minetest_settings:get_bool("mobs_disable_blood")
local mobs_drop_items   = minetest_settings:get_bool("mobs_drop_items") ~= false
local mobs_griefing     = minetest_settings:get_bool("mobs_griefing") ~= false
local spawn_protected   = minetest_settings:get_bool("mobs_spawn_protected") ~= false
local remove_far        = true
local difficulty        = tonumber(minetest_settings:get("mob_difficulty")) or 1.0
local show_health       = false
local max_per_block     = tonumber(minetest_settings:get("max_objects_per_block") or 64)
local mobs_spawn_chance = tonumber(minetest_settings:get("mobs_spawn_chance") or 2.5)

-- pathfinding settings
local enable_pathfinding = true
local stuck_timeout      = 3 -- how long before mob gets stuck in place and starts searching
local stuck_path_timeout = 10 -- how long will mob follow path before giving up

-- default nodes
local node_ice       = "mcl_core:ice"
local node_snowblock = "mcl_core:snowblock"
local node_snow      = "mcl_core:snow"
mobs.fallback_node   = minetest.registered_aliases["mapgen_dirt"] or "mcl_core:dirt"

local mod_weather     = minetest_get_modpath("mcl_weather") ~= nil
local mod_explosions  = minetest_get_modpath("mcl_explosions") ~= nil
local mod_mobspawners = minetest_get_modpath("mcl_mobspawners") ~= nil
local mod_hunger      = minetest_get_modpath("mcl_hunger") ~= nil
local mod_worlds      = minetest_get_modpath("mcl_worlds") ~= nil
local mod_armor       = minetest_get_modpath("mcl_armor") ~= nil
local mod_experience  = minetest_get_modpath("mcl_experience") ~= nil


-- random locals I found
local los_switcher    = false
local height_switcher = false

-- Get translator
local S = minetest.get_translator("mcl_mobs")

-- CMI support check
local use_cmi = minetest.global_exists("cmi")


-- Invisibility mod check
mobs.invis = {}
if minetest.global_exists("invisibility") then
	mobs.invis = invisibility
end


-- creative check
function mobs.is_creative(name)
	return minetest.is_creative_enabled(name)
end


local atan = function(x)
	if not x or x ~= x then
		return 0
	else
		return math_atan(x)
	end
end




-- Shows helpful debug info above each mob
local mobs_debug = minetest_settings:get_bool("mobs_debug", false)

-- Peaceful mode message so players will know there are no monsters
if minetest_settings:get_bool("only_peaceful_mobs", false) then
	minetest.register_on_joinplayer(function(player)
		minetest.chat_send_player(player:get_player_name(),
			S("Peaceful mode active! No monsters will spawn."))
	end)
end


local integer_test = {-1,1}

local collision = function(self)
				
	local pos = self.object:get_pos()

	--do collision detection from the base of the mob
	local collisionbox = self.object:get_properties().collisionbox

	pos.y = pos.y + collisionbox[2]
	
	local collision_boundary = collisionbox[4]

	local radius = collision_boundary

	if collisionbox[5] > collision_boundary then
		radius = collisionbox[5]
	end

	if self.object:get_properties().collide_with_objects == true then
		print("THIS IS A SERIOUS ERROR!")
	end

	local collision_count = 0

	for _,object in ipairs(minetest_get_objects_inside_radius(pos, radius*1.25)) do
		if object and object ~= self.object and (object:is_player() or object:get_luaentity()._cmi_is_mob == true) then--and
		--don't collide with rider, rider don't collide with thing
		--(not object:get_attach() or (object:get_attach() and object:get_attach() ~= self.object)) and 
		--(not self.object:get_attach() or (self.object:get_attach() and self.object:get_attach() ~= object)) then
			--stop infinite loop
			collision_count = collision_count + 1
			if collision_count > 100 then
				break
			end

			local pos2 = object:get_pos()
			
			local object_collisionbox = object:get_properties().collisionbox

			pos2.y = pos2.y + object_collisionbox[2]

			local object_collision_boundary = object_collisionbox[4]


			--this is checking the difference of the object collided with's possision
			--if positive top of other object is inside (y axis) of current object
			local y_base_diff = (pos2.y + object_collisionbox[5]) - pos.y

			local y_top_diff = (pos.y + collisionbox[5]) - pos2.y


			local distance = vector.distance(vector.new(pos.x,0,pos.z),vector.new(pos2.x,0,pos2.z))

			if distance <= collision_boundary + object_collision_boundary and y_base_diff >= 0 and y_top_diff >= 0 then

				local dir = vector.direction(pos,pos2)

				dir.y = 0
				
				--eliminate mob being stuck in corners
				if dir.x == 0 and dir.z == 0 then
					--slightly adjust mob position to prevent equal length
					--corner/wall sticking
					dir.x = dir.x + ((math_random()/10)*integer_test[math.random(1,2)])
					dir.z = dir.z + ((math_random()/10)*integer_test[math.random(1,2)])
				end

				local velocity = dir
				
				--0.5 is the max force multiplier
				local force = 0.5 - (0.5 * distance / (collision_boundary + object_collision_boundary))

				local vel1 = vector.multiply(velocity, -1.5)
				local vel2 = vector.multiply(velocity,  1.5)

				vel1 = vector.multiply(vel1, force)
				vel2 = vector.multiply(vel2, force)
			
				self.object:add_velocity(vel1)
				object:add_velocity(vel2)
			end
			
		end
	end
end



-- move mob in facing direction
local set_velocity = function(self, v)
	local c_x, c_y = 0, 0

	-- halt mob if it has been ordered to stay
	if self.order == "stand" then
		self.object:set_velocity({x = 0, y = 0, z = 0})
		return
	end

	local yaw = (self.object:get_yaw() or 0) + self.rotate

	self.object:add_velocity({
		x = (math_sin(yaw) * -v) + c_x,
		y = self.object:get_velocity().y,
		z = (math_cos(yaw) * v) + c_y,
	})
end



-- calculate mob velocity
local get_velocity = function(self)

	local v = self.object:get_velocity()
	if v then
		return (v.x * v.x + v.z * v.z) ^ 0.5
	end

	return 0
end


-- set and return valid yaw
local set_yaw = function(self, yaw, delay, dtime)

	if not yaw or yaw ~= yaw then
		yaw = 0
	end

	delay = delay or 0

	if delay == 0 then
		if self.shaking and dtime then
			yaw = yaw + (math_random() * 2 - 1) * 5 * dtime
		end
		self.object:set_yaw(yaw)
		update_roll(self)
		return yaw
	end

	self.target_yaw = yaw
	self.delay = delay

	return self.target_yaw
end

-- global function to set mob yaw
function mobs:yaw(self, yaw, delay, dtime)
	set_yaw(self, yaw, delay, dtime)
end


-- set defined animation
local set_animation = function(self, anim, fixed_frame)
	if not self.animation or not anim then
		return
	end
	if self.state == "die" and anim ~= "die" and anim ~= "stand" then
		return
	end

	self.animation.current = self.animation.current or ""

	if (anim == self.animation.current
	or not self.animation[anim .. "_start"]
	or not self.animation[anim .. "_end"]) and self.state ~= "die" then
		return
	end

	self.animation.current = anim

	local a_start = self.animation[anim .. "_start"]
	local a_end
	if fixed_frame then
		a_end = a_start
	else
		a_end = self.animation[anim .. "_end"]
	end

	self.object:set_animation({
		x = a_start,
		y = a_end},
		self.animation[anim .. "_speed"] or self.animation.speed_normal or 15,
		0, self.animation[anim .. "_loop"] ~= false)
end


-- above function exported for mount.lua
function mobs:set_animation(self, anim)
	set_animation(self, anim)
end

mobs.death_effect = function(pos, yaw, collisionbox, rotate)
	local min, max
	if collisionbox then
		min = {x=collisionbox[1], y=collisionbox[2], z=collisionbox[3]}
		max = {x=collisionbox[4], y=collisionbox[5], z=collisionbox[6]}
	else
		min = { x = -0.5, y = 0, z = -0.5 }
		max = { x = 0.5, y = 0.5, z = 0.5 }
	end
	if rotate then
		min = vector.rotate(min, {x=0, y=yaw, z=math_pi/2})
		max = vector.rotate(max, {x=0, y=yaw, z=math_pi/2})
		min, max = vector.sort(min, max)
		min = vector.multiply(min, 0.5)
		max = vector.multiply(max, 0.5)
	end

	minetest_add_particlespawner({
		amount = 50,
		time = 0.001,
		minpos = vector.add(pos, min),
		maxpos = vector.add(pos, max),
		minvel = vector.new(-5,-5,-5),
		maxvel = vector.new(5,5,5),
		minexptime = 1.1,
		maxexptime = 1.5,
		minsize = 1,
		maxsize = 2,
		collisiondetection = false,
		vertical = false,
		texture = "mcl_particles_mob_death.png^[colorize:#000000:255",
	})

	minetest_sound_play("mcl_mobs_mob_poof", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 8,
	}, true)
end


-- execute current state (stand, walk, run, attacks)
-- returns true if mob has died
local do_states = function(self, dtime)
	local yaw = self.object:get_yaw() or 0


end



-- get entity staticdata
local mob_staticdata = function(self)

--[[
	-- remove mob when out of range unless tamed
	if remove_far
	and self.can_despawn
	and self.remove_ok
	and ((not self.nametag) or (self.nametag == ""))
	and self.lifetimer <= 20 then

		minetest.log("action", "Mob "..name.." despawns in mob_staticdata at "..minetest.pos_to_string(self.object.get_pos(), 1))
		mcl_burning.extinguish(self.object)
		self.object:remove()

		return ""-- nil
	end
--]]
	self.remove_ok = true
	self.attack = nil
	self.following = nil
	self.state = "stand"

	if use_cmi then
		self.serialized_cmi_components = cmi.serialize_components(self._cmi_components)
	end

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

	-- remove monsters in peaceful mode
	if self.type == "monster"
	and minetest_settings:get_bool("only_peaceful_mobs", false) then
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

		self.base_texture = def.textures[math_random(1, #def.textures)]
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
		self.health = math_random (self.hp_min, self.hp_max)
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

	-- set anything changed above
	self.object:set_properties(self)
	set_yaw(self, (math_random(0, 360) - 180) / 180 * math_pi, 6)

	--update_tag(self)
	--set_animation(self, "stand")

	-- run on_spawn function if found
	if self.on_spawn and not self.on_spawn_run then
		if self.on_spawn(self) then
			self.on_spawn_run = true --  if true, set flag to run once only
		end
	end

	-- run after_activate
	if def.after_activate then
		def.after_activate(self, staticdata, def, dtime)
	end

	if use_cmi then
		self._cmi_components = cmi.activate_components(self.serialized_cmi_components)
		cmi.notify_activate(self.object, dtime)
	end
end


local mob_step = function(self, dtime)

	--do not continue if non-existent
	if not self or not self.object or not self.object:get_luaentity() then
		return false
	end

	--if self.state == "die" then
	--	print("need custom die stop moving thing")
	--	return
	--end

	-- can mob be pushed, if so calculate direction -- do this first to prevent issues
	if self.pushable then
		collision(self)
	end

	do_states(self, dtime)




	--if not self.fire_resistant then
	--	mcl_burning.tick(self.object, dtime)
	--end

	--if use_cmi then
		--cmi.notify_step(self.object, dtime)
	--end

	--local pos = self.object:get_pos()
	--local yaw = 0

	--if mobs_debug then
		--update_tag(self)
	--end



	--if self.jump_sound_cooloff > 0 then
	--	self.jump_sound_cooloff = self.jump_sound_cooloff - dtime
	--end

	--if self.opinion_sound_cooloff > 0 then
	--	self.opinion_sound_cooloff = self.opinion_sound_cooloff - dtime
	--end

	--if falling(self, pos) then
		-- Return if mob died after falling
	--	return
	--end

	-- smooth rotation by ThomasMonroe314

	--[[
	if self.delay and self.delay > 0 then

		local yaw = self.object:get_yaw() or 0

		if self.delay == 1 then
			yaw = self.target_yaw
		else
			local dif = math_abs(yaw - self.target_yaw)

			if yaw > self.target_yaw then

				if dif > math_pi then
					dif = 2 * math_pi - dif -- need to add
					yaw = yaw + dif / self.delay
				else
					yaw = yaw - dif / self.delay -- need to subtract
				end

			elseif yaw < self.target_yaw then

				if dif > math_pi then
					dif = 2 * math_pi - dif
					yaw = yaw - dif / self.delay -- need to subtract
				else
					yaw = yaw + dif / self.delay -- need to add
				end
			end

			if yaw > (math_pi * 2) then yaw = yaw - (math_pi * 2) end
			if yaw < 0 then yaw = yaw + (math_pi * 2) end
		end

		self.delay = self.delay - 1
		if self.shaking then
			yaw = yaw + (math_random() * 2 - 1) * 5 * dtime
		end
		self.object:set_yaw(yaw)
		--update_roll(self)
	end
	]]--

	-- end rotation

	-- run custom function (defined in mob lua file)
	--if self.do_custom then

		-- when false skip going any further
		--if self.do_custom(self, dtime) == false then
		--	return
		--end
	--end

	-- knockback timer
	--if self.pause_timer > 0 then

	--	self.pause_timer = self.pause_timer - dtime

	--	return
	--end

	-- attack timer
	--self.timer = self.timer + dtime

	--[[
	if self.state ~= "attack" then

		if self.timer < 1 then
			print("returning>>error code 1")
			return
		end

		self.timer = 0
	end
	]]--

	-- never go over 100
	--if self.timer > 100 then
	--	self.timer = 1
	--end

	-- mob plays random sound at times
	--if math_random(1, 70) == 1 then
	--	mob_sound(self, "random", true)
	--end

	-- environmental damage timer (every 1 second)
	--self.env_damage_timer = self.env_damage_timer + dtime

	--if (self.state == "attack" and self.env_damage_timer > 1)
	--or self.state ~= "attack" then
	--
	--	self.env_damage_timer = 0
	--
	--	-- check for environmental damage (water, fire, lava etc.)
	--	if do_env_damage(self) then
	--		return
	--	end
	--
		-- node replace check (cow eats grass etc.)
	--	replace(self, pos)
	--end

	--monster_attack(self)

	--npc_attack(self)

	--breed(self)

	--do_jump(self)

	--runaway_from(self)


	--if is_at_water_danger(self) and self.state ~= "attack" then
	--	if math_random(1, 10) <= 6 then
	--		set_velocity(self, 0)
	--		self.state = "stand"
	--		set_animation(self, "stand")
	--		yaw = yaw + math_random(-0.5, 0.5)
	--		yaw = set_yaw(self, yaw, 8)
	--	end
	--end

	
	-- Add water flowing for mobs from mcl_item_entity
	--[[
	local p, node, nn, def
	p = self.object:get_pos()
	node = minetest_get_node_or_nil(p)
	if node then
		nn = node.name
		def = minetest_registered_nodes[nnenable_physicss if not on/in flowing liquid
		self._flowing = false
		enable_physics(self.object, self, true)
		return
	end

	--Mob following code.
	follow_flop(self)


	if is_at_cliff_or_danger(self) then
			set_velocity(self, 0)
			self.state = "stand"
			set_animation(self, "stand")
			local yaw = self.object:get_yaw() or 0
			yaw = set_yaw(self, yaw + 0.78, 8)
	end

	-- Despawning: when lifetimer expires, remove mob
	if remove_far
	and self.can_despawn == true
	and ((not self.nametag) or (self.nametag == ""))
	and self.state ~= "attack"
	and self.following == nil then

		self.lifetimer = self.lifetimer - dtime
		if self.despawn_immediately or self.lifetimer <= 0 then
			minetest.log("action", "Mob "..self.name.." despawns in mob_step at "..minetest.pos_to_string(pos, 1))
			mcl_burning.extinguish(self.object)
			self.object:remove()
		elseif self.lifetimer <= 10 then
			if math_random(10) < 4 then
				self.despawn_immediately = true
			else
				self.lifetimer = 20
			end
		end
	end
	]]--
end


-- default function when mobs are blown up with TNT
local do_tnt = function(obj, damage)

	obj.object:punch(obj.object, 1.0, {
		full_punch_interval = 1.0,
		damage_groups = {fleshy = damage},
	}, nil)

	return false, true, {}
end


mobs.spawning_mobs = {}

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

local create_mob_on_rightclick = function(on_rightclick)
	return function(self, clicker)
		local stop = on_rightclick_prefix(self, clicker)
		if (not stop) and (on_rightclick) then
			on_rightclick(self, clicker)
		end
	end
end

-- register mob entity
function mobs:register_mob(name, def)

	mobs.spawning_mobs[name] = true

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
		return math_max(min, value * difficulty)
	end
end

local collisionbox = def.collisionbox or {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}
-- Workaround for <https://github.com/minetest/minetest/issues/5966>:
-- Increase upper Y limit to avoid mobs glitching through solid nodes.
-- FIXME: Remove workaround if it's no longer needed.
if collisionbox[5] < 0.79 then
	collisionbox[5] = 0.79
end


























































minetest.register_entity(name, {

	use_texture_alpha = def.use_texture_alpha,
	stepheight = def.stepheight or 0.6,
	name = name,
	type = def.type,
	attack_type = def.attack_type,
	fly = def.fly,
	fly_in = def.fly_in or {"air", "__airlike"},
	owner = def.owner or "",
	order = def.order or "",
	on_die = def.on_die,
	spawn_small_alternative = def.spawn_small_alternative,
	do_custom = def.do_custom,
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
	animation = def.animation,
	follow = def.follow,
	jump = def.jump ~= false,
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
	specific_attack = def.specific_attack,
	runaway_from = def.runaway_from,
	owner_loyal = def.owner_loyal,
	facing_fence = false,
	_cmi_is_mob = true,
	pushable = def.pushable or true,


	-- MCL2 extensions
	teleport = teleport,
	do_teleport = def.do_teleport,
	spawn_class = def.spawn_class,
	ignores_nametag = def.ignores_nametag or false,
	rain_damage = def.rain_damage or 0,
	glow = def.glow,
	can_despawn = can_despawn,
	child = def.child or false,
	texture_mods = {},
	shoot_arrow = def.shoot_arrow,
        sounds_child = def.sounds_child,
	explosion_strength = def.explosion_strength,
	suffocation_timer = 0,
	follow_velocity = def.follow_velocity or 2.4,
	instant_death = def.instant_death or false,
	fire_resistant = def.fire_resistant or false,
	fire_damage_resistant = def.fire_damage_resistant or false,
	ignited_by_sunlight = def.ignited_by_sunlight or false,
	-- End of MCL2 extensions

	on_spawn = def.on_spawn,

	on_blast = def.on_blast or do_tnt,

	on_step = mob_step,

	do_punch = def.do_punch,

	on_punch = mob_punch,

	on_breed = def.on_breed,

	on_grown = def.on_grown,

	on_detach_child = mob_detach_child,

	on_activate = function(self, staticdata, dtime)
		--this is a temporary hack so mobs stop
		--glitching and acting really weird with the
		--default built in engine collision detection
		self.object:set_properties({
			collide_with_objects = false,
		})
		self.object:set_acceleration(vector_new(0,-9.81, 0))
		return mob_activate(self, staticdata, def, dtime)
	end,

	get_staticdata = function(self)
		return mob_staticdata(self)
	end,

	harmed_by_heal = def.harmed_by_heal,

})

if minetest_get_modpath("doc_identifier") ~= nil then
	doc.sub.identifier.register_object(name, "basics", "mobs")
end

end -- END mobs:register_mob function


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

				if minetest_registered_nodes[node].walkable then

					self.hit_node(self, pos, node)

					if self.drop == true then

						pos.y = pos.y + 1

						self.lastpos = (self.lastpos or pos)

						minetest_add_item(self.lastpos, self.object:get_luaentity().name)
					end

					self.object:remove();

					return
				end
			end

			if self.hit_player or self.hit_mob or self.hit_object then

				for _,player in pairs(minetest_get_objects_inside_radius(pos, 1.5)) do

					if self.hit_player
					and player:is_player() then

						self.hit_player(self, player)
						self.object:remove();
						return
					end

					local entity = player:get_luaentity()

					if entity
					and self.hit_mob
					and entity._cmi_is_mob == true
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name then
						self.hit_mob(self, player)
						self.object:remove();
						return
					end

					if entity
					and self.hit_object
					and (not entity._cmi_is_mob)
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
	})
end

-- Register spawn eggs

-- Note: This also introduces the “spawn_egg” group:
-- * spawn_egg=1: Spawn egg (generic mob, no metadata)
-- * spawn_egg=2: Spawn egg (captured/tamed mob, metadata)
function mobs:register_egg(mob, desc, background, addegg, no_creative)

	local grp = {spawn_egg = 1}

	-- do NOT add this egg to creative inventory (e.g. dungeon master)
	if no_creative == true then
		grp.not_in_creative_inventory = 1
	end

	local invimg = background

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
			local under = minetest_get_node(pointed_thing.under)
			local def = minetest_registered_nodes[under.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, under, placer, itemstack)
			end

			if pos
			--and within_limits(pos, 0)
			and not minetest_is_protected(pos, placer:get_player_name()) then

				local name = placer:get_player_name()
				local privs = minetest.get_player_privs(name)
				if mod_mobspawners and under.name == "mcl_mobspawners:spawner" then
					if minetest_is_protected(pointed_thing.under, name) then
						minetest.record_protection_violation(pointed_thing.under, name)
						return itemstack
					end
					if not privs.maphack then
						minetest.chat_send_player(name, S("You need the “maphack” privilege to change the mob spawner."))
						return itemstack
					end
					mcl_mobspawners.setup_spawner(pointed_thing.under, itemstack:get_name())
					if not mobs.is_creative(name) then
						itemstack:take_item()
					end
					return itemstack
				end

				if not minetest_registered_entities[mob] then
					return itemstack
				end

				if minetest_settings:get_bool("only_peaceful_mobs", false)
						and minetest_registered_entities[mob].type == "monster" then
					minetest.chat_send_player(name, S("Only peaceful mobs allowed!"))
					return itemstack
				end

				pos.y = pos.y - 0.5

				local mob = minetest_add_entity(pos, mob)
				minetest.log("action", "Mob spawned: "..name.." at "..minetest.pos_to_string(pos))
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
				if not mobs.is_creative(placer:get_player_name()) then
					itemstack:take_item()
				end
			end

			return itemstack
		end,
	})

end


