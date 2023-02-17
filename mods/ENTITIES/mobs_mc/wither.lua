--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### WITHER
--###################

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
	attack_type = "dogshoot",
	explosion_strength = 8,
	dogshoot_stop = true,
	arrow = "mobs_mc:wither_skull",
	reach = 5,
	shoot_interval = 0.5,
	shoot_offset = -1,
	animation = {
		walk_speed = 12, run_speed = 12, stand_speed = 12,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	harmed_by_heal = true,
	do_custom = function(self)
		if self.health < (self.hp_max / 2) then
			self.base_texture = "mobs_mc_wither_half_health.png"
			self.fly = false
			self.object:set_properties({textures={self.base_texture}})
			self.armor = {undead = 80, fleshy = 80}
		end
		mcl_bossbars.update_boss(self.object, "Wither", "dark_purple")
	end,
	on_spawn = function(self)
		minetest.sound_play("mobs_mc_wither_spawn", {object=self.object, gain=1.0, max_hear_distance=64})
	end,

})

local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false
local wither_rose_soil = { "group:grass_block", "mcl_core:dirt", "mcl_core:coarse_dirt", "mcl_nether:netherrack", "group:soul_block", "mcl_mud:mud", "mcl_moss:moss" }

mcl_mobs.register_arrow("mobs_mc:wither_skull", {
	visual = "sprite",
	visual_size = {x = 0.75, y = 0.75},
	-- TODO: 3D projectile, replace tetxture
	textures = {"mobs_mc_TEMP_wither_projectile.png"},
	velocity = 6,

	-- direct hit
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 8},
		}, nil)
		mcl_mobs.mob_class.boom(self,self.object:get_pos(), 1)
	end,

	hit_mob = function(self, mob)
		mob:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 8},
		}, nil)
		mcl_mobs.mob_class.boom(self,self.object:get_pos(), 1)
		local l = mob:get_luaentity()
		if l and l.health - 8 <= 0 then
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
-- TODO: Add blue wither skull

--Spawn egg
mcl_mobs.register_egg("mobs_mc:wither", S("Wither"), "#4f4f4f", "#4f4f4f", 0, true)

mcl_wip.register_wip_item("mobs_mc:wither")
mcl_mobs:non_spawn_specific("mobs_mc:wither","overworld",0,minetest.LIGHT_MAX+1)
