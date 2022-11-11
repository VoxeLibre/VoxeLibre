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
	if self:check_despawn(pos) then return true end

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
	self:set_animation_speed()
	self:check_smooth_rotation()
	self:check_head_swivel()

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

	if self:do_states(dtime) then
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
	self:check_water_flow()

	if self:is_at_cliff_or_danger() then
			self:set_velocity(0)
			self.state = "stand"
			self:set_animation( "stand")
			local yaw = self.object:get_yaw() or 0
			yaw = self:set_yaw( yaw + 0.78, 8)
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
