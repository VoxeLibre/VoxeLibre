local mob_class = mcl_mobs.mob_class
local mob_class_meta = {__index = mcl_mobs.mob_class}
local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs

local PATHFINDING = "gowp"
local CRASH_WARN_FREQUENCY = 60
local LIFETIMER_DISTANCE = 47
local MAPGEN_LIMIT = mcl_vars.mapgen_limit
local MAPGEN_MOB_LIMIT = MAPGEN_LIMIT - 90
-- 30927 seems to be the edge of the world, so could be closer, but this is safer

local S = minetest.get_translator("mcl_mobs")

-- Invisibility mod check
mcl_mobs.invis = {}

local remove_far = true

local mobs_debug = minetest.settings:get_bool("mobs_debug", false) -- Shows helpful debug info above each mob
local spawn_logging = minetest.settings:get_bool("mcl_logging_mobs_spawn", true)
local DEVELOPMENT = minetest.settings:get_bool("mcl_development", false)

-- Peaceful mode message so players will know there are no monsters
if minetest.settings:get_bool("only_peaceful_mobs", false) then
	minetest.register_on_joinplayer(function(player)
		minetest.chat_send_player(player:get_player_name(),
			S("Peaceful mode active! No monsters will spawn."))
	end)
end

function mob_class:update_tag() --update nametag and/or the debug box
	local tag
	if mobs_debug then
		local name = self.nametag ~= "" and self.nametag or self.name
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
	self.object:set_properties({ nametag = tag })
end

function mob_class:jock_to(mob, reletive_pos, rot)
	local pos = self.object:get_pos()
	if not pos then return end

	self.jockey = mob
	local jock = mcl_mobs.spawn(pos, mob)
	if not jock then return end
	jock:get_luaentity().docile_by_day = false
	jock:get_luaentity().riden_by_jock = true
	self.object:set_attach(jock, "", reletive_pos, rot)
end

local function get_armor_by_chance()
	local armor = {helmet="",chestplate="",boots="",leggings=""}

	if math.random(100) <= 5 then
		local armor_materials = {
			gold = 48.73,
			leather = 37.06,
			chain = 12.90,
			iron = 1.27,
			diamond = 0.04,
		}

		local material = ""

		local random_number = math.random(10000)/100 -- 000.00 - 100.00

	 -- accurately by percentage pick a random armor material.
		inter = 0
		for m,chance in pairs(armor_materials) do
			inter = inter+chance
			if random_number < inter then
				material = m
				break
			end
		end

		armor.boots = "mcl_armor:boots_"..material -- 100% chance

		if math.random(100) < 75 then -- %75 chance of leggings
			armor.leggings = "mcl_armor:leggings_"..material -- 75% chance
		end
		if math.random(100) < 75 then -- %75 chance of chestplate
			armor.chestplate = "mcl_armor:chestplate_"..material
		end
		if math.random(100) < 75 then -- %75 chance of helmet
			armor.helmet = "mcl_armor:helmet_"..material
		end
	end

	return armor
end

function mob_class:get_staticdata()
	for _,p in pairs(minetest.get_connected_players()) do
		self:remove_particlespawners(p:get_player_name())
	end

	-- remove mob when out of range unless tamed
	if remove_far and self:despawn_allowed() and self.lifetimer <= 20 then
		if spawn_logging then
			minetest.log("action", "[mcl_mobs] Mob "..tostring(self.name).." despawns at "..minetest.pos_to_string(vector.round(self.object:get_pos())) .. " - out of range")
		end
		return "remove"-- nil
	end

	self.attack = nil
	self.following = nil
	self.state = "stand"

	local tmp = {}
	for tag, stat in pairs(self) do
		local t = type(stat)
		if  t ~= "function" and t ~= "nil" and t ~= "userdata" and tag ~= "_cmi_components" then tmp[tag] = self[tag] end
	end

	tmp._mcl_potions = self._mcl_potions
	if tmp._mcl_potions then
		for name_raw, data in pairs(tmp._mcl_potions) do
			local def = mcl_potions.registered_effects[name_raw:match("^_EF_(.+)$")]
			if def and def.on_save_effect then def.on_save_effect(self.object) end
		end
	end

	return minetest.serialize(tmp)
end

local function valid_texture(self, def_textures)
	if not self.base_texture or #self.base_texture ~= #def_textures then return false end
	if self.texture_selected then
		if #def_textures < self.texture_selected then
			self.texture_selected = nil
		else
			return true
		end
	end
	return false
end

function mob_class:mob_activate(staticdata, def, dtime)
	if not self.object:get_pos() or staticdata == "remove" then
		mcl_burning.extinguish(self.object)
		mcl_util.remove_entity(self)
		return
	end
	if self.type == "monster"
	and minetest.settings:get_bool("only_peaceful_mobs", false) then
		mcl_burning.extinguish(self.object)
		mcl_util.remove_entity(self)
		return
	end

	local tmp = minetest.deserialize(staticdata)
	if tmp then
		-- Patch incorrectly converted mobs
		if tmp.base_mesh ~= minetest.registered_entities[self.name].initial_properties.mesh then mcl_mobs.strip_staticdata(tmp) end
		for _, stat in pairs(tmp) do self[_] = stat end
	end

	if self._removed then
		self.object:remove()
		return
	end

	--If textures in definition change, reload textures
	if not valid_texture(self, def.textures) then
		if mobs_debug and staticdata ~= "" then
			core.log("warning", "Possibly corrupted staticdata: "..staticdata)
		end

		-- compatiblity with old simple mobs textures
		if type(def.textures[1]) == "string" then def.textures = {def.textures} end

		self.texture_selected = self.texture_selected or math.random(#def.textures)
		self.base_texture = def.textures[self.texture_selected]
	end

	-- Fix entity fields if missing
	self.base_colbox = self.base_colbox or def.initial_properties.collisionbox
	self.base_selbox = self.base_selbox or def.initial_properties.selectionbox or self.base_colbox
	self.base_mesh = self.base_mesh or def.initial_properties.mesh
	self.base_size = self.base_size or def.initial_properties.visual_size or self.initial_properties.visual_size

	local textures = self.base_texture
	local mesh = self.base_mesh
	local vis_size = self.base_size
	local colbox = self.base_colbox
	local selbox = self.base_selbox

	if self.gotten and def.gotten_texture then textures = def.gotten_texture end
	if self.gotten and def.gotten_mesh then mesh = def.gotten_mesh end
	if self.child then
		vis_size = { x = self.base_size.x * .5, y = self.base_size.y * .5 }
		if def.child_texture then textures = def.child_texture[1] end

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

	if self.health == 0 then self.health = math.random(self.initial_properties.hp_min, self.initial_properties.hp_max) end
	if self.breath == nil then self.breath = self.initial_properties.breath_max end

	self.path = {}
	self.path.way = {} -- path to follow, table of positions
	self.path.lastpos = vector.zero()
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
	self.object:set_properties({
		collisionbox = colbox,
		selectionbox = selbox,
		mesh = mesh,
		visual_size = vis_size,
	})
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

	self.nametag = self.nametag or def.nametag

	self.object:set_properties(self)
	self:set_yaw(math.random() * math.pi * 2, 6)
	self:update_tag()
	self._current_animation = nil
	self:set_animation("stand")

	if self.riden_by_jock then --- Keep this function before self:on_spawn()
		self.object:remove()
		return
	end

	if self.on_spawn and not self.on_spawn_run and self:on_spawn() then self.on_spawn_run = true end

	if not self.wears_armor and self.armor_list then self.armor_list = nil end

	if not self._run_armor_init and self.wears_armor then
		self.armor_list=get_armor_by_chance() -- 5% percent chance to spawn with armor. Accurate dispersion in function.
		self:set_armor_texture()
		self._run_armor_init = true
	end

	if not self._mcl_potions then self._mcl_potions = {} end
	mcl_potions._load_entity_effects(self)

	if def.after_activate then def.after_activate(self, staticdata, def, dtime) end
end

-- execute current state (stand, walk, run, attacks)
-- returns true if mob has died
function mob_class:do_states(dtime, player_in_active_range)
	--if self.can_open_doors then check_doors(self) end

	-- knockback timer. set in on_punch
	if self.pause_timer > 0 then
		self.pause_timer = self.pause_timer - dtime
		return
	end

	self:env_danger_movement_checks(player_in_active_range)

	if self.state == PATHFINDING then
		self:check_gowp(dtime)
	elseif self.state == "attack" then
		if self:do_states_attack(dtime) then return true end
	else
		if mcl_util.check_dtime_timer(self, dtime, "onstep_dostates", 1) then
			if self.state == "stand" then
				self:do_states_stand(player_in_active_range)
			elseif self.state == "walk" then
				self:do_states_walk()
			elseif self.state == "runaway" then
				self:do_states_runaway()
			end
		end
	end
end

function mob_class:outside_limits()
	local pos = self.object:get_pos()
	if not pos then return end
	local posx, posy, posz = math.abs(pos.x), math.abs(pos.y), math.abs(pos.z)
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

local function on_step_work(self, dtime, moveresult)
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

	if self:falling(pos, moveresult) then return end
	if self:step_damage(dtime, pos) then return end

	if self.state == "die" then return end
	-- End: Death/damage processing

	local player_in_active_range = self:player_in_active_range()
	self:check_suspend(player_in_active_range)
	self:check_water_flow()
	self._can_jump_cliff = not self._jumping_cliff and self:can_jump_cliff()
	self:flop()
	self:check_smooth_rotation(dtime)

	if player_in_active_range then
		self:set_animation_speed() -- set animation speed relative to velocity
		self:check_head_swivel(dtime)

		if mcl_util.check_dtime_timer(self, dtime, "onstep_engage", 0.2) then
			self:check_follow()
			self:check_runaway_from()
			self:monster_attack()
			self:npc_attack()
		end

		self:check_herd(dtime)

		if self.jump_sound_cooloff > 0 then self.jump_sound_cooloff = self.jump_sound_cooloff - dtime end
		self:do_jump()
	end

	if mcl_util.check_dtime_timer(self, dtime, "onstep_occassional", 1) then
		if player_in_active_range then
			self:check_item_pickup()
			self:set_armor_texture()
			self:step_opinion_sound(dtime)
		end
		self:check_breeding()
	end

	self:check_aggro(dtime)
	self:check_particlespawners(dtime)
	if self.do_custom and self.do_custom(self, dtime) == false then return end
	if self:do_states(dtime, player_in_active_range) then return end
	if mobs_debug then self:update_tag() end
	if not self.object:get_luaentity() then return false end
end

local last_crash_warn_time = 0

local function log_error(stack_trace, info, info2)
	minetest.log("action", "--- Bug report start (please provide a few lines before this also for context) ---")
	minetest.log("action", "Error: " .. stack_trace)
	minetest.log("action", "Bug info: " .. info)
	if info2 then minetest.log("action", "Bug info additional: " .. info2) end
	minetest.log("action", "--- Bug report end ---")
end

local function warn_user_error ()
	local current_time = os.time()
	local time_since_warning = current_time - last_crash_warn_time
	--minetest.log("previous_crash_time: " .. current_time)
	--minetest.log("last_crash_time: " .. last_crash_warn_time)
	--minetest.log("time_since_warning: " .. time_since_warning)
	if time_since_warning > CRASH_WARN_FREQUENCY then
		last_crash_warn_time = current_time
		minetest.log("A game crashing bug was prevented. Please provide debug.log information to VoxeLibre dev team for investigation. (Search for: --- Bug report start)")
	end
end

local on_step_error_handler = function()
	warn_user_error()
	local info = debug.getinfo(1, "SnlufL")
	log_error(tostring(debug.traceback()), dump(info))
end

-- main mob function
function mob_class:on_step(dtime, moveresult)
	-- allow crash in development mode
	if DEVELOPMENT then return on_step_work(self, dtime, moveresult) end
	-- Removed as bundled Lua (5.1 doesn't support xpcall)
	--local status, retVal = xpcall(on_step_work, on_step_error_handler, self, dtime)
	local status, retVal = pcall(on_step_work, self, dtime, moveresult)
	if status then return retVal end
	warn_user_error()
	local pos = self.object:get_pos()
	if pos then
		local node = minetest.get_node(pos)
		if node and node.name == "ignore" then minetest.log("warning", "Pos is ignored: " .. dump(pos)) end
	end
	log_error(dump(retVal), dump(pos), dump(self))
end

local timer = 0
local function update_lifetimer(dtime)
	timer = timer + dtime
	if timer < 1 then return end
	for _, player in pairs(minetest.get_connected_players()) do
		local pos = player:get_pos()
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, LIFETIMER_DISTANCE)) do
			local lua = obj:get_luaentity()
			if lua and lua.is_mob then
				lua.lifetimer = math.max(20, lua.lifetimer)
				lua.despawn_immediately = false
			end
		end
	end
	timer = 0
end

minetest.register_globalstep(function(dtime)
	update_lifetimer(dtime)
end)

minetest.register_chatcommand("clearmobs", {
	privs = { maphack = true },
	params = "[all|monster|passive|<mob name> [<range>|nametagged|tamed]]",
	description = S("Removes specified mobs except nametagged and tamed ones. For the second parameter, use nametagged/tamed to select only nametagged/tamed mobs, or a range to specify a maximum distance from the player."),
	func = function(player, param)
		local default = false
		if not param or param == "" then
			default = true
			minetest.chat_send_player(player,
					S("Default usage. Clearing hostile mobs. For more options please type: /help clearmobs"))
		end
		local mob, unsafe = param:match("^([%w]+)[ ]?([%w%d]*)$")
		local all, nametagged, tamed = false, false, false
		local mob_name, mob_type, range

		-- Param 1 resolve
		if mob and mob ~= "" then
			if mob == "all" then
				all = true
			elseif mob == "passive" or mob == "monster" then
				mob_type = mob
			elseif mob then
				mob_name = mob
			end
			--minetest.log ("mob: [" .. mob .. "]")
		else
			if default then mob_type = "monster" end
		end

		-- Param 2 resolve
		if unsafe and unsafe ~= "" then
			--minetest.log ("unsafe: [" .. unsafe .. "]")
			if unsafe == "nametagged" then
				nametagged = true
			elseif unsafe == "tamed" then
				tamed = true
			end

			local num = tonumber(unsafe)
			if num then range = num end
		end

		local p = minetest.get_player_by_name(player)
		for _,o in pairs(minetest.luaentities) do
			if o and o.is_mob then
				local mob_match = false

				if all then
					--minetest.log("Match - All mobs specified")
					mob_match = true
				elseif mob_type then
					--minetest.log("Match - o.type: ".. tostring(o.type))
					--minetest.log("mob_type: ".. tostring(mob_type))
					if mob_type == "monster" and o.type == mob_type then
						--minetest.log("Match - monster")
						mob_match = true
					elseif mob_type == "passive" and o.type ~= "monster" and o.type ~= "npc" then
						--minetest.log("Match - passive")
						mob_match = true
					else
						--minetest.log("No match for type.")
					end
				elseif mob_name and (o.name == mob_name or string.find(o.name, mob_name)) then
					--minetest.log("Match - mob_name = ".. tostring(o.name))
					mob_match = true
				else
					--minetest.log("No match - o.type = ".. tostring(o.type))
					--minetest.log("No match - mob_name = ".. tostring(o.name))
					--minetest.log("No match - mob_type = ".. tostring(mob_name))
				end

				if mob_match then
					local in_range = (not range or range <= 0) or vector.distance(p:get_pos(), o.object:get_pos()) <= range
					if nametagged then
						if o.nametag then o.object:remove() end
					elseif tamed then
						if o.tamed then o.object:remove() end
					elseif in_range and (not o.nametag or o.nametag == "") and not o.tamed then
						o.object:remove()
					end
				end
			end
		end
	end
})
