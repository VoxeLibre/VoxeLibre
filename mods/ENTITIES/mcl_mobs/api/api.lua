-- API for Mobs Redo: MineClone 2 Delux 2.0 DRM Free Early Access Super Extreme Edition

-- mobs library
mobs = {}

-- lua locals - can grab from this to easily plop them into the api lua files

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
local vector_add    = vector.add
local vector_length = vector.length
local vector_direction = vector.direction
local vector_normalize = vector.normalize
local vector_multiply = vector.multiply
local vector_divide  = vector.divide

-- mob constants
local BREED_TIME          = 30
local BREED_TIME_AGAIN    = 300
local CHILD_GROW_TIME     = 60*20
local DEATH_DELAY         = 0.5
local DEFAULT_FALL_SPEED  = -10
local FLOP_HEIGHT         = 5.0
local FLOP_HOR_SPEED      = 1.5
local GRAVITY             = minetest_settings:get("movement_gravity")-- + 9.81


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
	return minetest_is_creative_enabled(name)
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


local api_path = minetest.get_modpath(minetest.get_current_modname()).."/api/mob_functions/"

--ignite all parts of the api
dofile(api_path .. "ai.lua")
dofile(api_path .. "animation.lua")
dofile(api_path .. "collision.lua")
dofile(api_path .. "environment.lua")
dofile(api_path .. "interaction.lua")
dofile(api_path .. "movement.lua")
dofile(api_path .. "set_up.lua")
dofile(api_path .. "attack_type_instructions.lua")
dofile(api_path .. "sound_handling.lua")
dofile(api_path .. "death_logic.lua")
dofile(api_path .. "mob_effects.lua")
dofile(api_path .. "projectile_handling.lua")
dofile(api_path .. "breeding.lua")
dofile(api_path .. "head_logic.lua")


mobs.spawning_mobs = {}




-- register mob entity
function mobs:register_mob(name, def)

	local collisionbox = def.collisionbox or {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}

	-- Workaround for <https://github.com/minetest/minetest/issues/5966>:
	-- Increase upper Y limit to avoid mobs glitching through solid nodes.
	-- FIXME: Remove workaround if it's no longer needed.

	if collisionbox[5] < 0.79 then
		collisionbox[5] = 0.79
	end

	mobs.spawning_mobs[name] = true

	local function scale_difficulty(value, default, min, special)
		if (not value) or (value == default) or (value == special) then
			return default
		else
			return math_max(min, value * difficulty)
		end
	end

	minetest.register_entity(name, {
		description = def.description,
		use_texture_alpha = def.use_texture_alpha,
		stepheight = def.stepheight or 0.6,
		stepheight_backup = def.stepheight or 0.6,
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
		rotate = def.rotate or 0, --  0=front, 90=side, 180=back, 270=side2
		hp_min = scale_difficulty(def.hp_min, 5, 1),
		hp_max = scale_difficulty(def.hp_max, 10, 1),
		xp_min = def.xp_min or 1,
		xp_max = def.xp_max or 5,
		breath_max = def.breath_max or 6,
		breathes_in_water = def.breathes_in_water or false,
		physical = true,
		collisionbox = collisionbox,
		collide_with_objects = def.collide_with_objects or false,
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
		on_rightclick = mobs.create_mob_on_rightclick(def.on_rightclick),
		arrow = def.arrow,
		shoot_interval = def.shoot_interval,
		sounds = def.sounds or {},
		animation = def.animation,
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
		state_timer = 0,
		env_damage_timer = 0,
		tamed = false,
		pause_timer = 0,
		gotten = false,
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

		--j4i stuff
		yaw = 0,
		automatic_face_movement_dir = def.rotate or 0,  --  0=front, 90=side, 180=back, 270=side2
		automatic_face_movement_max_rotation_per_sec = 360, --degrees
		backface_culling = true,
		walk_timer = 0,
		stand_timer = 0,
		current_animation = "",
		gravity = GRAVITY,
		swim = def.swim,
		swim_in = def.swim_in or {mobs_mc.items.water_source, "mcl_core:water_flowing", mobs_mc.items.river_water_source},
		pitch_switch = "static",
		jump_only = def.jump_only,
		hostile = def.hostile,
		neutral = def.neutral,
		attacking = nil,
		visual_size_origin = def.visual_size or {x = 1, y = 1, z = 1},
		punch_timer_cooloff = def.punch_timer_cooloff or 0.5,
		death_animation_timer = 0,
		hostile_cooldown = def.hostile_cooldown or 15,
		tilt_fly = def.tilt_fly,
		tilt_swim = def.tilt_swim,
		fall_slow = def.fall_slow,
		projectile_cooldown_min = def.projectile_cooldown_min or 2,
		projectile_cooldown_max = def.projectile_cooldown_max or 6,
		skittish = def.skittish,

		minimum_follow_distance = def.minimum_follow_distance or 0.5, --make mobs not freak out when underneath

		memory = 0, -- memory timer if chasing/following
		fly_random_while_attack = def.fly_random_while_attack,

		--for spiders
		always_climb = def.always_climb,

		--despawn mechanic variables
		lifetimer_reset = 30, --30 seconds
		lifetimer = 30, --30 seconds

		--breeding stuff
		breed_timer = 0,
		breed_lookout_timer = 0,
		breed_distance = def.breed_distance or 1.5, --how far away mobs have to be to begin actual breeding
		breed_lookout_timer_goal = 30, --30 seconds (this timer is for how long the mob looks for a mate)
		breed_timer_cooloff = 5*60, -- 5 minutes (this timer is for how long the mob has to wait before being bred again)
		bred = false,
		follow = def.follow, --this item is also used for the breeding mechanism
		follow_distance = def.follow_distance or 2,
		baby_size = def.baby_size or 0.5,
		baby = false,
		grow_up_timer = 0,
		grow_up_goal  = 20*60, --in 20 minutes the mob grows up
		special_breed_timer = 0, --this is used for the AHEM AHEM part of breeding

		backup_visual_size = def.visual_size,
		backup_collisionbox = collisionbox,
		backup_selectionbox = def.selectionbox or def.collisionbox,


		--fire timer
		burn_timer = 0,

		ignores_cobwebs = def.ignores_cobwebs,
		breath = def.breath_max or 6,

		random_sound_timer_min = 3,
		random_sound_timer_max = 10,


		--head code variables
		--defaults are for the cow's default
		--because I don't know what else to set them
		--to :P

		has_head = def.has_head or false,
		head_bone = def.head_bone,

		--you must use these to adjust the mob's head positions

		--has_head is used as a logic gate (quick easy check)
		has_head = def.has_head or false,
		--head_bone is the actual bone in the model which the head
		--is attached to for animation
		head_bone = def.head_bone or "head",

		--this part controls the base position of the head calculations
		--localized to the mob's visual yaw when gotten (self.object:get_yaw())
		--you can enable the debug in /mob_functions/head_logic.lua by uncommenting the
		--particle spawner code
		head_height_offset =  def.head_height_offset or 1.0525,
		head_direction_offset = def.head_direction_offset or 0.5,

		--this part controls the visual of the head
		head_bone_pos_y = def.head_bone_pos_y or 3.6,
		head_bone_pos_z = def.head_bone_pos_z or -0.6,
		head_pitch_modifier = def.head_pitch_modifier or 0,

		--these variables are switches in case the model
		--moves the wrong way
		swap_y_with_x = def.swap_y_with_x or false,
		reverse_head_yaw = def.reverse_head_yaw or false,

		--END HEAD CODE VARIABLES

		--end j4i stuff

		-- MCL2 extensions
		teleport = mobs.teleport,
		do_teleport = def.do_teleport,
		spawn_class = def.spawn_class,
		ignores_nametag = def.ignores_nametag or false,
		rain_damage = def.rain_damage or 0,
		glow = def.glow,
		--can_despawn = can_despawn,
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
		eye_height = def.eye_height or 1.5,
		defuse_reach = def.defuse_reach or 4,
		-- End of MCL2 extensions

		on_spawn = def.on_spawn,

		--on_blast = def.on_blast or do_tnt,

		on_step  = mobs.mob_step,

		--do_punch = def.do_punch,

		on_punch = mobs.mob_punch,

		--on_breed = def.on_breed,

		--on_grown = def.on_grown,

		--on_detach_child = mob_detach_child,

		on_activate = function(self, staticdata, dtime)
			self.object:set_acceleration(vector_new(0,-GRAVITY, 0))
			return mobs.mob_activate(self, staticdata, def, dtime)
		end,

		get_staticdata = function(self)
			return mobs.mob_staticdata(self)
		end,

		--harmed_by_heal = def.harmed_by_heal,
	})

	if minetest_get_modpath("doc_identifier") ~= nil then
		doc.sub.identifier.register_object(name, "basics", "mobs")
	end

end -- END mobs:register_mob function


















































-- register arrow for shoot attack
function mobs:register_arrow(name, def)

	-- errorcheck
	if not name or not def then
		print("failed to register arrow entity")
		return
	end

	minetest.register_entity(name.."_entity", {

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
		speed = def.speed or nil,
		on_step = function(self)

			local vel = self.object:get_velocity()

			local pos = self.object:get_pos()

			if self.timer > 150
			or not mobs.within_limits(pos, 0) then
				mcl_burning.extinguish(self.object)
				self.object:remove();
				return
			end

			-- does arrow have a tail (fireball)
			if def.tail
			and def.tail == 1
			and def.tail_texture then

				--do this to prevent clipping through main entity sprite
				local pos_adjustment = vector_multiply(vector_normalize(vel), -1)
				local divider = def.tail_distance_divider or 1
				pos_adjustment = vector_divide(pos_adjustment, divider)
				local new_pos = vector_add(pos, pos_adjustment)
				minetest.add_particle({
					pos = new_pos,
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

				local node = minetest_get_node(pos).name

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

						if self.hit_player then
							self.hit_player(self, player)
						else
							mobs.arrow_hit(self, player)
						end

						self.object:remove();
						return
					end

					--[[
					local entity = player:get_luaentity()

					if entity
					and self.hit_mob
					and entity._cmi_is_mob == true
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name
					and (self._shooter and entity.name ~= self._shooter:get_luaentity().name) then

						--self.hit_mob(self, player)
						self.object:remove();
						return
					end
					]]--

					--[[
					if entity
					and self.hit_object
					and (not entity._cmi_is_mob)
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name
					and (self._shooter and entity.name ~= self._shooter:get_luaentity().name) then

						--self.hit_object(self, player)
						self.object:remove();
						return
					end
					]]--
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

				local mob = minetest_add_entity(pos, mob)
				minetest.log("action", "Mob spawned: "..name.." at "..minetest.pos_to_string(pos))
				local ent = mob:get_luaentity()

				-- don't set owner if monster or sneak pressed
				--[[
				if ent.type ~= "monster"
				and not placer:get_player_control().sneak then
					ent.owner = placer:get_player_name()
					ent.tamed = true
				end
				]]--

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


