--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")

mobs:register_mob("mobs_mc:skeleton", {
	type = "monster",
	hp_min = 30,
	hp_max = 30,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	pathfinding = true,
	group_attack = true,
	visual = "mesh",
	mesh = "mobs_skeleton.x",
	textures = {
	{"mobs_skeleton.png"}
	},
	makes_footstep_sound = true,
	sounds = {
		random = "skeleton1",
		death = "skeletondeath",
		damage = "skeletonhurt1",
	},
	walk_velocity = 1.2,
	run_velocity = 2.4,
	damage = 1,
	armor = 200,
	drops = {
		{name = "mcl_throwing:arrow",
		chance = 1,
		min = 0,
		max = 2,},
		{name = "mcl_mobitems:bone",
		chance = 1,
		min = 0,
		max = 2,},
	},
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 85,
		hurt_end = 115,
		death_start = 117,
		death_end = 145,
		shoot_start = 50,
		shoot_end = 82,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 1,
	view_range = 16,
	attack_type = "dogshoot",
	arrow = "mcl_throwing:arrow_entity",
	shoot_interval = 2.5,
	shoot_offset = 1,
	--'dogshoot_switch' allows switching between shoot and dogfight modes inside dogshoot using timer (1 = shoot, 2 = dogfight)
	--'dogshoot_count_max' number of seconds before switching above modes.
	dogshoot_switch = 1,
	dogshoot_count_max =3,
})
mobs:register_spawn("mobs_mc:skeleton", {"group:crumbly", "group:cracky", "group:choppy", "group:snappy"}, 7, -1, 5000, 4, 31000)


mobs:register_mob("mobs_mc:skeleton2", {
	type = "monster",
	hp_max = 60,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	pathfinding = true,
	group_attack = true,
	visual = "mesh",
	mesh = "mobs_skeleton.x",
	textures = {
	{"mobs_skeleton2.png"}
	},
	makes_footstep_sound = true,
	sounds = {
		random = "skeleton1",
		death = "skeletondeath",
		damage = "skeletonhurt1",
	},
	walk_velocity = 1.2,
	run_velocity = 2.4,
	damage = 3,
	armor = 200,
	drops = {
		{name = "mcl_core:coal_lump",
		chance = 1,
		min = 0,
		max = 1,},
		{name = "mcl_mobitems:bone",
		chance = 1,
		min = 0,
		max = 2,},
		{name = "mcl_heads:wither_skeleton",
		chance = 40,
		min = 1,
		max = 1,},
	},
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 85,
		hurt_end = 115,
		death_start = 117,
		death_end = 145,
		shoot_start = 50,
		shoot_end = 82,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 0,
	light_damage = 0,
	view_range = 16,
	attack_type = "dogshoot",
	arrow = "mcl_throwing:arrow_entity",
	shoot_interval = 0.5,
	shoot_offset = 1,
	--'dogshoot_switch' allows switching between shoot and dogfight modes inside dogshoot using timer (1 = shoot, 2 = dogfight)
	--'dogshoot_count_max' number of seconds before switching above modes.
	dogshoot_switch = 1,
	dogshoot_count_max =6,
})
mobs:register_spawn("mobs_mc:skeleton2", {"group:crumbly", "group:cracky", "group:choppy", "group:snappy"}, 7, -1, 5000, 4, -3000)


local arrows = {
	{"mcl_throwing:arrow", "mcl_throwing:arrow_entity" },
}

-- compatibility
mobs:alias_mob("mobs:skeleton", "mobs_mc:skeleton")

-- spawn eggs
mobs:register_egg("mobs_mc:skeleton", "Spawn Skeleton", "spawn_egg_skeleton.png")
mobs:register_egg("mobs_mc:skeleton2", "Spawn Wither Skeleton", "spawn_egg_wither_skeleton.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Skeleton loaded")
end
