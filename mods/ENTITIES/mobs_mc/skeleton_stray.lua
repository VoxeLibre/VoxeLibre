--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")


--###################
--################### STRAY SKELETON
--###################



mobs:register_mob("mobs_mc:stray", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	pathfinding = 1,
	group_attack = true,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.98, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_stray.b3d",
	textures = {
		{"mobs_mc_stray.png^mobs_mc_stray_bow.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		random = "skeleton1",
		death = "skeletondeath",
		damage = "skeletonhurt1",
		distance = 16,
	},
	walk_velocity = 1.2,
	run_velocity = 2.4,
	damage = 2,
	drops = {
		{name = mobs_mc.items.arrow,
		chance = 1,
		min = 0,
		max = 2,},
		{name = mobs_mc.items.bow,
		chance = 11,
		min = 1,
		max = 1,},
		{name = mobs_mc.items.bone,
		chance = 1,
		min = 0,
		max = 2,},
		{name = "mobs_mc:skeleton_head",
		chance = 50,
		min = 0,
		max = 1,},
	},
	animation = {
		stand_start = 0,
		stand_end = 40,
		speed_stand = 5,
		walk_start = 40,
		walk_end = 60,
		speed_walk = 50,
		shoot_start = 70,
		shoot_end = 90,
		punch_start = 70,
		punch_end = 90,
		die_start = 120,
		die_end = 130,
		speed_die = 5,
		hurt_start = 100,
		hurt_end = 120,
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 1,
	fear_height = 4,
	view_range = 16,
	attack_type = "dogshoot",
	arrow = "mobs_mc:arrow_entity",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max =3,
	blood_amount = 0,
})

--spawn
mobs:spawn_specific("mobs_mc:stray", mobs_mc.spawn.snow, {"air"}, minetest.LIGHT_MAX+1, minetest.LIGHT_MAX+1, 20, 19000, 2, -110, 31000)

-- spawn eggs
mobs:register_egg("mobs_mc:stray", S("Stray"), "mobs_mc_spawn_icon_stray.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Stray Skeleton loaded")
end
