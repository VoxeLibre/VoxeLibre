mcl_mobs = {}
mcl_mobs.mob_class = {}
mcl_mobs.mob_class_meta = {__index = mcl_mobs.mob_class}
mcl_mobs.registered_mobs = {}
local modname = minetest.get_current_modname()
local path = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)
mcl_mobs.fallback_node = minetest.registered_aliases["mapgen_dirt"] or "mcl_core:dirt"
--api and helpers
-- effects: sounds and particles mostly
dofile(path .. "/effects.lua")
-- physics: involuntary mob movement - particularly falling and death
dofile(path .. "/physics.lua")
-- movement: general voluntary mob movement, walking avoiding cliffs etc.
dofile(path .. "/movement.lua")
-- items: item management for mobs
dofile(path .. "/items.lua")
-- pathfinding: pathfinding to target positions
dofile(path .. "/pathfinding.lua")
-- combat: attack logic
dofile(path .. "/combat.lua")
-- the enity functions themselves
dofile(path .. "/api.lua")


--utility functions
dofile(path .. "/breeding.lua")
dofile(path .. "/spawning.lua")
dofile(path .. "/mount.lua")
dofile(path .. "/crafts.lua")
dofile(path .. "/compat.lua")

local DEFAULT_FALL_SPEED = -9.81*1.5
local MAX_MOB_NAME_LENGTH = 30

local old_spawn_icons = minetest.settings:get_bool("mcl_old_spawn_icons",false)
local extended_pet_control = minetest.settings:get_bool("mcl_extended_pet_control",true)
local difficulty = tonumber(minetest.settings:get("mob_difficulty")) or 1.0

-- get node but use fallback for nil or unknown
local node_ok = function(pos, fallback)
	fallback = fallback or mcl_mobs.fallback_node
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	return minetest.registered_nodes[fallback]
end

--#### REGISTER FUNCS

-- Code to execute before custom on_rightclick handling
local on_rightclick_prefix = function(self, clicker)
	if not clicker:is_player() then return end
	local item = clicker:get_wielded_item()
	if extended_pet_control and self.tamed and self.owner == clicker:get_player_name() then
		self:toggle_sit(clicker)
	end
	-- Name mob with nametag
	if not self.ignores_nametag and item:get_name() == "mcl_mobs:nametag" then

		local tag = item:get_meta():get_string("name")
		if tag ~= "" then
			if string.len(tag) > MAX_MOB_NAME_LENGTH then
				tag = string.sub(tag, 1, MAX_MOB_NAME_LENGTH)
			end
			self.nametag = tag

			self:update_tag()

			if not minetest.is_creative_enabled(clicker:get_player_name()) then
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
	for _,v in pairs(pos) do
		if v < wmin or v > wmax then return false end
	end
	return true
end

mcl_mobs.spawning_mobs = {}
-- register mob entity
function mcl_mobs.register_mob(name, def)

	mcl_mobs.spawning_mobs[name] = true
	mcl_mobs.registered_mobs[name] = def

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
			return math.max(min, value * difficulty)
		end
	end

	local collisionbox = def.collisionbox or {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25}
	-- Workaround for <https://github.com/minetest/minetest/issues/5966>:
	-- Increase upper Y limit to avoid mobs glitching through solid nodes.
	-- FIXME: Remove workaround if it's no longer needed.
	if collisionbox[5] < 0.79 then
		collisionbox[5] = 0.79
	end
	local final_def = {
		use_texture_alpha = def.use_texture_alpha,
		head_swivel = def.head_swivel or nil, -- bool to activate this function
		head_yaw_offset = def.head_yaw_offset or 0, -- for wonkey model bones
		head_pitch_multiplier = def.head_pitch_multiplier or 1, --for inverted pitch
		bone_eye_height = def.bone_eye_height or 1.4, -- head bone offset
		head_eye_height = def.head_eye_height or def.bone_eye_height or 0, -- how hight aproximatly the mobs head is fromm the ground to tell the mob how high to look up at the player
		curiosity = def.curiosity or 1, -- how often mob will look at player on idle
		head_yaw = def.head_yaw or "y", -- axis to rotate head on
		horrizonatal_head_height = def.horrizonatal_head_height or 0,
		wears_armor = def.wears_armor, -- a number value used to index texture slot for armor
		stepheight = def.stepheight or 0.6,
		name = name,
		description = def.description,
		type = def.type,
		attack_type = def.attack_type,
		fly = def.fly or false,
		fly_in = def.fly_in or {"air", "__airlike"},
		owner = def.owner or "",
		order = def.order or "",
		on_die = def.on_die,
		spawn_small_alternative = def.spawn_small_alternative,
		do_custom = def.do_custom,
		detach_child = def.detach_child,
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
		animation = def.animation or {},
		follow = def.follow,
		nofollow = def.nofollow,
		can_open_doors = def.can_open_doors,
		jump = def.jump ~= false,
		automatic_face_movement_max_rotation_per_sec = 300,
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
		frame_speed_multiplier = 1,
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
		attack_npcs = def.attack_npcs or false,
		specific_attack = def.specific_attack,
		runaway_from = def.runaway_from,
		owner_loyal = def.owner_loyal,
		facing_fence = false,
		is_mob = true,
		pushable = def.pushable or true,

		-- MCL2 extensions
		shooter_avoid_enemy = def.shooter_avoid_enemy,
		strafes = def.strafes,
		avoid_distance = def.avoid_distance or 9,
		do_teleport = def.do_teleport,
		spawn_class = def.spawn_class,
		can_spawn = def.can_spawn,
		ignores_nametag = def.ignores_nametag or false,
		rain_damage = def.rain_damage or 0,
		glow = def.glow,
		can_despawn = can_despawn,
		child = def.child or false,
		texture_mods = {},
		shoot_arrow = def.shoot_arrow,
		sounds_child = def.sounds_child,
		_child_animations = def.child_animations,
		pick_up = def.pick_up,
		explosion_strength = def.explosion_strength,
		suffocation_timer = 0,
		follow_velocity = def.follow_velocity or 2.4,
		instant_death = def.instant_death or false,
		fire_resistant = def.fire_resistant or false,
		fire_damage_resistant = def.fire_damage_resistant or false,
		ignited_by_sunlight = def.ignited_by_sunlight or false,
		spawn_in_group = def.spawn_in_group,
		spawn_in_group_min = def.spawn_in_group_min,
		noyaw = def.noyaw or false,
		particlespawners = def.particlespawners,
		-- End of MCL2 extensions
		on_spawn = def.on_spawn,
		on_blast = def.on_blast or function(self,damage)
			self.object:punch(self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = damage},
			}, nil)
			return false, true, {}
		end,
		do_punch = def.do_punch,
		on_breed = def.on_breed,
		on_grown = def.on_grown,
		on_pick_up = def.on_pick_up,
		on_activate = function(self, staticdata, dtime)
			--this is a temporary hack so mobs stop
			--glitching and acting really weird with the
			--default built in engine collision detection
			self.is_mob = true
			self.object:set_properties({
				collide_with_objects = false,
			})

			return self:mob_activate(staticdata, def, dtime)
		end,
		harmed_by_heal = def.harmed_by_heal,
		on_lightning_strike = def.on_lightning_strike
	}
	minetest.register_entity(name, setmetatable(final_def,mcl_mobs.mob_class_meta))

	if minetest.get_modpath("doc_identifier") ~= nil then
		doc.sub.identifier.register_object(name, "basics", "mobs")
	end

end -- END mcl_mobs.register_mob function


-- register arrow for shoot attack
function mcl_mobs.register_arrow(name, def)

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
		end,
		collisionbox = def.collisionbox or {0, 0, 0, 0, 0, 0},
		automatic_face_movement_dir = def.rotate
			and (def.rotate - (math.pi / 180)) or false,

		on_activate = def.on_activate,

		on_step = def.on_step or function(self, dtime)

			self.timer = self.timer + 1

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

				if minetest.registered_nodes[node].walkable then

					self.hit_node(self, pos, node)

					if self.drop == true then

						pos.y = pos.y + 1

						self.lastpos = (self.lastpos or pos)

						minetest.add_item(self.lastpos, self.object:get_luaentity().name)
					end

					self.object:remove();

					return
				end
			end

			if self.hit_player or self.hit_mob or self.hit_object then

				for _,player in pairs(minetest.get_objects_inside_radius(pos, 1.5)) do

					if self.hit_player
					and player:is_player() then

						self.hit_player(self, player)
						self.object:remove();
						return
					end

					local entity = player:get_luaentity()

					if entity
					and self.hit_mob
					and entity.is_mob == true
					and tostring(player) ~= self.owner_id
					and entity.name ~= self.object:get_luaentity().name then
						self.hit_mob(self, player)
						self.object:remove();
						return
					end

					if entity
					and self.hit_object
					and (not entity.is_mob)
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
function mcl_mobs.register_egg(mob, desc, background_color, overlay_color, addegg, no_creative)

	local grp = {spawn_egg = 1}

	-- do NOT add this egg to creative inventory (e.g. dungeon master)
	if no_creative == true then
		grp.not_in_creative_inventory = 1
	end

	local invimg = "(spawn_egg.png^[multiply:" .. background_color ..")^(spawn_egg_overlay.png^[multiply:" .. overlay_color .. ")"
	if old_spawn_icons then
		local mobname = mob:gsub("mobs_mc:","")
		local fn = "mobs_mc_spawn_icon_"..mobname..".png"
		if mcl_util.file_exists(minetest.get_modpath("mobs_mc").."/textures/"..fn) then
			invimg = fn
		end
	end
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
			local under = minetest.get_node(pointed_thing.under)
			local def = minetest.registered_nodes[under.name]
			if def and def.on_rightclick then
				return def.on_rightclick(pointed_thing.under, under, placer, itemstack)
			end

			if pos
			and within_limits(pos, 0)
			and not minetest.is_protected(pos, placer:get_player_name()) then

				local name = placer:get_player_name()
				local privs = minetest.get_player_privs(name)
				if under.name == "mcl_mobspawners:spawner" then
					if minetest.is_protected(pointed_thing.under, name) then
						minetest.record_protection_violation(pointed_thing.under, name)
						return itemstack
					end
					if not privs.maphack then
						minetest.chat_send_player(name, S("You need the “maphack” privilege to change the mob spawner."))
						return itemstack
					end
					mcl_mobspawners.setup_spawner(pointed_thing.under, itemstack:get_name())
					if not minetest.is_creative_enabled(name) then
						itemstack:take_item()
					end
					return itemstack
				end

				if not minetest.registered_entities[mob] then
					return itemstack
				end

				if minetest.settings:get_bool("only_peaceful_mobs", false)
						and minetest.registered_entities[mob].type == "monster" then
					minetest.chat_send_player(name, S("Only peaceful mobs allowed!"))
					return itemstack
				end

				pos.y = pos.y - 0.5

				local mob = minetest.add_entity(pos, mob)
				local entityname = itemstack:get_name()
				minetest.log("action", "Player " ..name.." spawned "..entityname.." at "..minetest.pos_to_string(pos))
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
				if not minetest.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
			end

			return itemstack
		end,
	})

end
