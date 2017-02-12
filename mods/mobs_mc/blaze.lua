-- daufinsyd
-- My work is under the LGPL terms
-- Model and mobs_blaze.png see https://github.com/22i/minecraft-voxel-blender-models
-- blaze.lua partial copy of mobs_mc/ghast.lua



--dofile(minetest.get_modpath("mobs").."/api.lua")



mobs:register_mob("mobs_mc:blaze", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	textures = {
	{"mobs_blaze.png"}
	},
	visual = "mesh",
	mesh = "mobs_blaze.b3d",
	makes_footstep_sound = true,
	sounds = {
		random = "blaze_breath",
		death = "blaze_died",
		damage = "blaze_hurt1",
		attack = "default_punch3",
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 2.5,
	pathfinding = true,
	group_attack = true,
	armor = 80,
	drops = {
		{name = "mcl_mobitems:blaze_rod",
		chance = 1,
		min = 0,
		max = 1,},
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
	fall_damage = 0,
	light_damage = 1,
	view_range = 16,
	attack_type = "shoot",
    arrow = "mobs_monster:fireball",
    shoot_interval = 3.5,
    passive = false,
    jump = true,
	jump_height = 4,
    floats = 1,
    fly = true,
    jump_chance = 98,
    fear_height = 120,
})

mobs:register_spawn("mobs_mc:blaze", {"mcl_core:flowing_lava", "nether:rack","air"}, 17, -1, 5000, 1, -2000)

-- compatibility
mobs:alias_mob("mobs:blaze", "mobs_mc:blaze")

-- spawn eggs
mobs:register_egg("mobs_mc:blaze", "Spawn Blaze", "spawn_egg_blaze.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Blaze loaded")
end
