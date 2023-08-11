--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### WITHER
--###################

mobs_mc.wither_count_overworld = 0
mobs_mc.wither_count_nether = 0
mobs_mc.wither_count_end = 0

mcl_mobs.register_mob("mobs_mc:wither", {
	description = S("Wither"),
	type = "monster",
	spawn_class = "hostile",
	hp_max = 300,
	hp_min = 300,
	xp_min = 50,
	xp_max = 50,
	armor = {undead = 80, fleshy = 100},
	-- This deviates from MC Wiki's size, which makes no sense
	collisionbox = {-0.9, 0.4, -0.9, 0.9, 2.45, 0.9},
	visual = "mesh",
	mesh = "mobs_mc_wither.b3d",
	textures = {
		{"mobs_mc_wither.png"},
	},
	visual_size = {x=4, y=4},
	makes_footstep_sound = true,
	view_range = 16,
	fear_height = 4,
	walk_velocity = 2,
	run_velocity = 4,
	sounds = {
		shoot_attack = "mobs_mc_ender_dragon_shoot",
		attack = "mobs_mc_ender_dragon_attack",
		-- TODO: sounds
		distance = 60,
	},
	jump = true,
	jump_height = 10,
	fly = true,
	makes_footstep_sound = false,
	dogshoot_switch = 1,
	dogshoot_count_max = 1,
	attack_animals = true,
	can_despawn = false,
	drops = {
		{name = "mcl_mobitems:nether_star",
		chance = 1,
		min = 1,
		max = 1},
	},
	lava_damage = 0,
	fire_damage = 0,
	attack_type = "shoot",
	explosion_strength = 8,
	dogshoot_stop = true,
	arrow = "mobs_mc:wither_skull",
	reach = 5,
	shoot_interval = 0.5,
	shoot_offset = -0.5,
	animation = {
		walk_speed = 12, run_speed = 12, stand_speed = 12,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	harmed_by_heal = true,
	is_boss = true,
	do_custom = function(self, dtime)
		self._custom_timer = self._custom_timer + dtime
		if self._custom_timer > 1 then
			self.health = math.min(self.health + 1, self.hp_max)
			self._custom_timer = self._custom_timer - 1
		end

		local spawner = minetest.get_player_by_name(self._spawner)
		if spawner then
			self._death_timer = 0
			local pos = self.object:get_pos()
			local spw = spawner:get_pos()
			local dist = vector.distance(pos, spw)
			if dist > 60 then -- teleport to the player who spawned the wither
				local R = 10
				pos.x = spw.x + math.random(-R, R)
				pos.y = spw.y + math.random(-R, R)
				pos.z = spw.z + math.random(-R, R)
				self.object:set_pos(pos)
			end
		else
			self._death_timer = self._death_timer + self.health - self._health_old
			if self.health == self._health_old then self._death_timer = self._death_timer + dtime end
			if self._death_timer > 100 then
				self.object:remove()
				return false
			end
			self._health_old = self.health
		end

		local dim = mcl_worlds.pos_to_dimension(self.object:get_pos())
		if dim == "overworld" then mobs_mc.wither_count_overworld = mobs_mc.wither_count_overworld + 1
		elseif dim == "nether" then mobs_mc.wither_count_nether = mobs_mc.wither_count_nether + 1
		elseif dim == "end" then mobs_mc.wither_count_end = mobs_mc.wither_count_end + 1 end

		local rand_factor
		if self.health < (self.hp_max / 2) then
			self.base_texture = "mobs_mc_wither_half_health.png"
			self.fly = false
			self._arrow_resistant = true
			rand_factor = 3
		else
			self.base_texture = "mobs_mc_wither.png"
			self.fly = true
			self._arrow_resistant = false
			rand_factor = 10
		end
		self.object:set_properties({textures={self.base_texture}})
		mcl_bossbars.update_boss(self.object, "Wither", "dark_purple")
		if math.random(1, rand_factor) < 2 then
			self.arrow = "mobs_mc:wither_skull_strong"
		else
			self.arrow = "mobs_mc:wither_skull"
		end
	end,
	do_punch = function(self, hitter, tflp, tool_capabilities, dir)
		local ent = hitter:get_luaentity()
		if ent and self._arrow_resistant and (string.find(ent.name, "arrow") or string.find(ent.name, "rocket")) then return false end
		return true
	end,
	deal_damage = function(self, damage, mcl_reason)
		if self._arrow_resistant and mcl_reason.type == "magic" then return end
		self.health = self.health - damage
	end,
	on_spawn = function(self)
		minetest.sound_play("mobs_mc_wither_spawn", {object=self.object, gain=1.0, max_hear_distance=64})
	end,

})

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local wither_rose_soil = { "group:grass_block", "mcl_core:dirt", "mcl_core:coarse_dirt", "mcl_nether:netherrack", "group:soul_block", "mcl_mud:mud", "mcl_moss:moss" }

mcl_mobs.register_arrow("mobs_mc:wither_skull", {
	visual = "cube",
	visual_size = {x = 0.3, y = 0.3},
	textures = {
		"mobs_mc_wither_projectile.png^[verticalframe:6:0", -- top
		"mobs_mc_wither_projectile.png^[verticalframe:6:1", -- bottom
		"mobs_mc_wither_projectile.png^[verticalframe:6:2", -- left
		"mobs_mc_wither_projectile.png^[verticalframe:6:3", -- right
		"mobs_mc_wither_projectile.png^[verticalframe:6:4", -- back
		"mobs_mc_wither_projectile.png^[verticalframe:6:5", -- front
	},
	velocity = 6,
	rotate = 90,

	-- direct hit
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 8},
		}, nil)
		mcl_mobs.effect_functions["withering"](player, 0.5, 10)
		mcl_mobs.mob_class.boom(self,self.object:get_pos(), 1)
		if player:get_hp() <= 0 then
			self._shooter:get_luaentity().health = self._shooter:get_luaentity().health + 5
		end
	end,

	hit_mob = function(self, mob)
		mob:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 8},
		}, nil)
		mcl_mobs.effect_functions["withering"](mob, 0.5, 10)
		mcl_mobs.mob_class.boom(self,self.object:get_pos(), 1)
		local l = mob:get_luaentity()
		if l and l.health - 8 <= 0 then
			self._shooter:get_luaentity().health = self._shooter:get_luaentity().health + 5
			local n = minetest.find_node_near(mob:get_pos(),2,wither_rose_soil)
			if n then
				local p = vector.offset(n,0,1,0)
				if minetest.get_node(p).name == "air" then
					if not ( mobs_griefing and minetest.place_node(p,{name="mcl_flowers:wither_rose"}) ) then
						minetest.add_item(p,"mcl_flowers:wither_rose")
					end
				end
			end
		end
	end,

	-- node hit, explode
	hit_node = function(self, pos, node)
		mcl_mobs.mob_class.boom(self,pos, 1)
	end
})
mcl_mobs.register_arrow("mobs_mc:wither_skull_strong", {
	visual = "cube",
	visual_size = {x = 0.35, y = 0.35},
	textures = {
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:0", -- top
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:1", -- bottom
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:2", -- left
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:3", -- right
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:4", -- back
		"mobs_mc_wither_projectile_strong.png^[verticalframe:6:5", -- front
	},
	velocity = 4,
	rotate = 90,

	-- direct hit
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 12},
		}, nil)
		mcl_mobs.effect_functions["withering"](player, 0.5, 10)
		local pos = self.object:get_pos()
		if mobs_griefing and not minetest.is_protected(pos, "") then
			mcl_explosions.explode(pos, 1, { drop_chance = 1.0, max_blast_resistance = 0, }, self.object)
		else
			mcl_mobs.mob_class.safe_boom(self, pos, 1) --need to call it this way bc self is the "arrow" object here
		end
		if player:get_hp() <= 0 then
			self._shooter:get_luaentity().health = self._shooter:get_luaentity().health + 5
		end
	end,

	hit_mob = function(self, mob)
		mob:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 12},
		}, nil)
		mcl_mobs.effect_functions["withering"](mob, 0.5, 10)
		local pos = self.object:get_pos()
		if mobs_griefing and not minetest.is_protected(pos, "") then
			mcl_explosions.explode(pos, 1, { drop_chance = 1.0, max_blast_resistance = 0, }, self.object)
		else
			mcl_mobs.mob_class.safe_boom(self, pos, 1) --need to call it this way bc self is the "arrow" object here
		end
		local l = mob:get_luaentity()
		if l and l.health - 8 <= 0 then
			self._shooter:get_luaentity().health = self._shooter:get_luaentity().health + 5
			local n = minetest.find_node_near(mob:get_pos(),2,wither_rose_soil)
			if n then
				local p = vector.offset(n,0,1,0)
				if minetest.get_node(p).name == "air" then
					if not ( mobs_griefing and minetest.place_node(p,{name="mcl_flowers:wither_rose"}) ) then
						minetest.add_item(p,"mcl_flowers:wither_rose")
					end
				end
			end
		end
	end,

	-- node hit, explode
	hit_node = function(self, pos, node)
		if mobs_griefing and not minetest.is_protected(pos, "") then
			mcl_explosions.explode(pos, 1, { drop_chance = 1.0, max_blast_resistance = 0, }, self.object)
		else
			mcl_mobs.mob_class.safe_boom(self, pos, 1) --need to call it this way bc self is the "arrow" object here
		end
	end
})

--Spawn egg
mcl_mobs.register_egg("mobs_mc:wither", S("Wither"), "#4f4f4f", "#4f4f4f", 0, true)

mcl_wip.register_wip_item("mobs_mc:wither")
mcl_mobs:non_spawn_specific("mobs_mc:wither","overworld",0,minetest.LIGHT_MAX+1)
