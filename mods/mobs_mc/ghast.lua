--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")

mobs:register_mob("mobs_mc:ghast", {
	type = "monster",
	pathfinding = true,
	group_attack = true,
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-1.45, -1.45, -1.45 ,1.45, 1.45, 1.45},
	visual_size = {x=3.0, y=3.0},
	textures = {
	{"ghast_white.png", "ghast_white.png", "ghast_front.png", "ghast_white.png", "ghast_white.png", "ghast_white.png"}
	},
	visual = "cube",
	blood_texture ="mobs_blood.png",
	rotate = 270,
	makes_footstep_sound = true,
	sounds = {
		shoot = "mobs_fireball",
		death = "zombiedeath",
		damage = "ghast_damage",
		attack = "mobs_fireball",
		random = "mobs_eerie",
	},
	walk_velocity = .8,
	run_velocity = 2.6,
	damage = 1,
	armor = 100,
	drops = {
		{name = "mcl_mobitems:ghast_tear",
		chance = 1,
		min = 0,
		max = 1,},
		{name = "mcl_core:gunpowder",
		chance = 1,
		min = 0,
		max = 2,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		hurt_start = 64,
		hurt_end = 86,
		death_start = 88,
		death_end = 118,
	},
	drawtype = "front",
	water_damage = 10,
	lava_damage = 0,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	--attack_type = "dogshoot",
	attack_type = "dogshoot",
	arrow = "mobs_monster:fireball",
	shoot_interval = 3.5,
	shoot_offset = 1,
		--'dogshoot_switch' allows switching between shoot and dogfight modes inside dogshoot using timer (1 = shoot, 2 = dogfight)
	--'dogshoot_count_max' number of seconds before switching above modes.
	dogshoot_switch = 1,
	dogshoot_count_max =1,
	passive = false,
	jump = true,
	jump_height = 4,
	floats=1,
	fly = true,
	jump_chance = 98,
	fear_height = 120,	
})


mobs:register_spawn("mobs_mc:ghast", {"mcl_core:flowing_lava", "nether:rack","air"}, 17, -1, 5000, 1, -2000)

-- fireball (weapon)
mobs:register_arrow(":mobs_monster:fireball", {
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	textures = {"mobs_fireball.png"},
	velocity = 6,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		mobs:explosion(pos, 1, 1, 0)
	end
})




-- spawn eggs
mobs:register_egg("mobs_mc:ghast", "Spawn Ghast", "spawn_egg_ghast.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Ghast loaded")
end
