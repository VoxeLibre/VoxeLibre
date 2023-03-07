local mob_class = mcl_mobs.mob_class
local mob_class_meta = {__index = mcl_mobs.mob_class}
local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
-- API for Mobs Redo: MineClone 2 Edition (MRM)

local PATHFINDING = "gowp"
local CRASH_WARN_FREQUENCY = 60

-- Localize
local S = minetest.get_translator("mcl_mobs")

local LOGGING_ON = minetest.settings:get_bool("mcl_logging_mobs_villager",false)
local function mcl_log (message)
	if LOGGING_ON then
		mcl_util.mcl_log (message, "[Mobs]", true)
	end
end

-- Invisibility mod check
mcl_mobs.invis = {}

local remove_far = true
local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local spawn_protected = minetest.settings:get_bool("mobs_spawn_protected") ~= false
local mobs_debug = minetest.settings:get_bool("mobs_debug", false) -- Shows helpful debug info above each mob
local spawn_logging = minetest.settings:get_bool("mcl_logging_mobs_spawn",true)

local MAPGEN_LIMIT = mcl_vars.mapgen_limit
local MAPGEN_MOB_LIMIT = MAPGEN_LIMIT - 90
-- 30927 seems to be the edge of the world, so could be closer, but this is safer


-- Peaceful mode message so players will know there are no monsters
if minetest.settings:get_bool("only_peaceful_mobs", false) then
	minetest.register_on_joinplayer(function(player)
		minetest.chat_send_player(player:get_player_name(),
			S("Peaceful mode active! No monsters will spawn."))
	end)
end

local node_ok = function(pos, fallback)
	fallback = fallback or mcl_mobs.fallback_node
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	return minetest.registered_nodes[fallback]
end

function mob_class:update_tag() --update nametag and/or the debug box
	local tag
	if mobs_debug then
		local name = self.name
		if self.nametag and self.nametag ~= "" then
			name = self.nametag
		end
		tag = "name = '"..tostring(name).."'\n"..
		"state = '"..tostring(self.state).."'\n"..
		"order = '"..tostring(self.order).."'\n"..
		"attack = "..tostring(self.attack).."\n"..
		"health = "..tostring(self.health).."\n"..
		"breath = "..tostring(self.breath).."\n"..
		"gotten = "..tostring(self.gotten).."\n"..
		"tamed = "..tostring(self.tamed).."\n"..
		"horny = "..tostring(self.horny).."\n"..
		"hornytimer = "..tostring(self.hornytimer).."\n"..
		"runaway_timer = "..tostring(self.runaway_timer).."\n"..
		"following = "..tostring(self.following).."\n"..
		"lifetimer = "..tostring(self.lifetimer)
	else
		tag = self.nametag
	end
	self.object:set_properties({
		nametag = tag,
	})
end

function mob_class:jock_to(mob, reletive_pos, rot)
	self.jockey = mob
	local jock = minetest.add_entity(self.object:get_pos(), mob)
	if not jock then return end
	jock:get_luaentity().docile_by_day = false
	jock:get_luaentity().riden_by_jock = true
	self.object:set_attach(jock, "", reletive_pos, rot)
end

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

function mob_class:mob_activate(staticdata, def, dtime)
	if not self.object:get_pos() or staticdata == "remove" then
		mcl_burning.extinguish(self.object)
		self.object:remove()
		return
	end
	if self.type == "monster"
	and minetest.settings:get_bool("only_peaceful_mobs", false) then
		mcl_burning.extinguish(self.object)
		self.object:remove()
		return
	end

	local tmp = minetest.deserialize(staticdata)

	if tmp then
		for _,stat in pairs(tmp) do
			self[_] = stat
		end
	end

	--If textures in definition change, reload textures
	if not self.base_texture or (def.textures and table.indexof(def.textures, self.base_texture) == -1) then
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

	if not self.base_selbox then
		self.base_selbox = self.selectionbox or self.base_colbox
	end

	local textures = self.base_texture
	local mesh = self.base_mesh
	local vis_size = self.base_size
	local colbox = self.base_colbox
	local selbox = self.base_selbox

	if self.gotten == true
	and def.gotten_texture then
		textures = def.gotten_texture
	end

	if self.gotten == true
	and def.gotten_mesh then
		mesh = def.gotten_mesh
	end

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

	if not self.nametag then
		self.nametag = def.nametag
	end
	if not self.custom_visual_size then
		self.visual_size = nil
		self.base_size = self.visual_size
		if self.child then
			self.visual_size = {
				x = self.visual_size.x * 0.5,
				y = self.visual_size.y * 0.5,
			}
		end
	end

	self.object:set_properties(self)
	self:set_yaw( (math.random(0, 360) - 180) / 180 * math.pi, 6)
	self:update_tag()
	self._current_animation = nil
	self:set_animation( "stand")


	if self.riden_by_jock then --- Keep this function before self.on_spawn() is run.
		self.object:remove()
		return
	end


	if self.on_spawn and not self.on_spawn_run then
		if self.on_spawn(self) then
			self.on_spawn_run = true
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




	if def.after_activate then
		def.after_activate(self, staticdata, def, dtime)
	end
end

-- execute current state (stand, walk, run, attacks)
-- returns true if mob has died
function mob_class:do_states(dtime)
	--if self.can_open_doors then check_doors(self) end

	if self.state == "stand" then
		self:do_states_stand()
	elseif self.state == PATHFINDING then
		self:check_gowp(dtime)
	elseif self.state == "walk" then
		self:do_states_walk()
	elseif self.state == "runaway" then
		-- runaway when punched
		self:do_states_runaway()
	elseif self.state == "attack" then
		-- attack routines (explode, dogfight, shoot, dogshoot)
		if self:do_states_attack(dtime) then
			return true
		end
	end
end

local function update_timers (self, dtime)
	-- knockback timer. set in on_punch
	if self.pause_timer > 0 then
		self.pause_timer = self.pause_timer - dtime
		return true
	end

	-- attack timer. Not anymore, it seems. Used for also occassionally processing mob step too!
	self.timer = self.timer + dtime

	if self.state ~= "attack" and self.state ~= PATHFINDING then
		if self.timer < 1 then
			return true
		end
		self.timer = 0
	end

	-- never go over 100
	if self.timer > 100 then
		self.timer = 1
	end
end

function mob_class:outside_limits()
	local pos = self.object:get_pos()
	if pos then
		local posx = math.abs(pos.x)
		local posy = math.abs(pos.y)
		local posz = math.abs(pos.z)
		if posx > MAPGEN_MOB_LIMIT or posy > MAPGEN_MOB_LIMIT or posz > MAPGEN_MOB_LIMIT then
			--minetest.log("action", "Getting close to limits of worldgen: " .. minetest.pos_to_string(pos))
			if posx > MAPGEN_LIMIT or posy > MAPGEN_LIMIT or posz > MAPGEN_LIMIT then
				minetest.log("action", "Warning mob past limits of worldgen: " .. minetest.pos_to_string(pos))
			else
				if self.state ~= "stand" then
					minetest.log("action", "Warning mob close to limits of worldgen: " .. minetest.pos_to_string(pos))
					self.state = "stand"
					self:set_animation("stand")
					self.object:set_acceleration(vector.zero())
					self.object:set_velocity(vector.zero())
				end
			end
			return true
		end
	end
end

local function on_step_work (self, dtime)
	local pos = self.object:get_pos()
	if not pos then return end

	if self:check_despawn(pos, dtime) then return true end
	if self:outside_limits() then return end

	-- Start: Death/damage processing
	-- All damage needs to be undertaken at the start. We need to exit processing if the mob dies.
	if self:check_death_and_slow_mob() then
		--minetest.log("action", "Mob is dying: ".. tostring(self.name))
		-- Do we abandon out of here now?
	end

	if self:falling(pos) then return end

	local player_in_active_range = self:player_in_active_range()

	self:check_suspend(player_in_active_range)

	if not self.fire_resistant then
		mcl_burning.tick(self.object, dtime, self)
		if not self.object:get_pos() then return end -- mcl_burning.tick may remove object immediately

		if self:check_for_death("fire", {type = "fire"}) then
			return true
		end
	end

	if self:env_damage (dtime, pos) then return end

	if self.state == "die" then return end
	-- End: Death/damage processing

	self:check_water_flow()
	self:env_danger_movement_checks (dtime)

	-- Follow code is heavy and probably shouldn't run when not in range, but we need to extract the cancel follow stuff
	self:follow()
	self:flop()

	self:check_smooth_rotation(dtime)

	if not player_in_active_range then
		self:set_animation_speed() -- set animation speed relative to velocity

		self:check_head_swivel(dtime)

		if self.jump_sound_cooloff > 0 then self.jump_sound_cooloff = self.jump_sound_cooloff - dtime end
		self:do_jump()

		self:check_runaway_from()
		self:monster_attack()
		self:npc_attack()
	end

	self:check_aggro(dtime)

	if self.do_custom and self.do_custom(self, dtime) == false then return end

	-- In certain circumstances, we abandon processing of certain functionality
	local skip_processing = false
	if update_timers(self, dtime) then
		skip_processing = true
	end

	if not skip_processing then
		self:check_breeding()

		if not player_in_active_range then
			self:check_item_pickup()
			self:set_armor_texture()

			if self.opinion_sound_cooloff > 0 then
				self.opinion_sound_cooloff = self.opinion_sound_cooloff - dtime
			end
			-- mob plays random sound at times. Should be 120. Zombie and mob farms are ridiculous
			if math.random(1, 70) == 1 then
				self:mob_sound("random", true)
			end
		end

		self:check_particlespawners(dtime)

		if self:do_states(dtime) then return end
	end

	if mobs_debug then self:update_tag() end

	if not self.object:get_luaentity() then
		return false
	end
end

local last_crash_warn_time = 0

local on_step_error_handler = function ()
	local info = debug.getinfo(1, "SnlufL")

	local current_time = os.time()
	local time_since_warning = current_time - last_crash_warn_time

	--minetest.log("previous_crash_time: " .. current_time)
	--minetest.log("last_crash_time: " .. last_crash_warn_time)
	--minetest.log("time_since_warning: " .. time_since_warning)

	if time_since_warning > CRASH_WARN_FREQUENCY then
		last_crash_warn_time = current_time
		minetest.log("A game crashing bug was prevented. Please provide debug.log information to MineClone2 dev team for investigation. (Search for: --- Bug report start)")
	end
	minetest.log("action", "--- Bug report start (please provide a few lines before this also for context) ---")
	minetest.log("action", "Stack trace: ".. tostring(debug.traceback()))
	minetest.log("action", "Bug info: ".. dump(info))
	minetest.log("action", "--- Bug report end ---")
end

-- main mob function
function mob_class:on_step(dtime)
	local status, retVal = xpcall(on_step_work, on_step_error_handler, self, dtime)
	if status then
		return retVal
	end
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
