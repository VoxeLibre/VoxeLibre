--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")


--###################
--################### WITHER SKELETON
--###################



mobs:register_mob("mobs_mc:witherskeleton", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	pathfinding = 1,
	group_attack = true,
	collisionbox = {-0.35, -0.01, -0.35, 0.35, 2.39, 0.35},
	visual = "mesh",
	mesh = "mobs_mc_witherskeleton.b3d",
	textures = {
		{"mobs_mc_wither_skeleton.png^mobs_mc_wither_skeleton_sword.png"},
	},
	visual_size = {x=3.6, y=3.6},
	makes_footstep_sound = true,
	sounds = {
		random = "skeleton1",
		death = "skeletondeath",
		damage = "skeletonhurt1",
		distance = 16,
	},
	walk_velocity = 1.2,
	run_velocity = 2.4,
	damage = 7,
	reach = 2,
	drops = {
		{name = mobs_mc.items.coal,
		chance = 1,
		min = 0,
		max = 1,},
		{name = mobs_mc.items.bone,
		chance = 1,
		min = 0,
		max = 2,},

		-- Head
		{name = mobs_mc.items.head_wither_skeleton,
		chance = 40, -- 2.5% chance
		min = 1,
		max = 1,},
	},
	animation = {
		stand_start = 0,
		stand_end = 40,
		stand_speed = 5,
		walk_start = 40,
		walk_end = 60,
		walk_speed = 15,
		run_start = 40,
		run_end = 60,
		run_speed = 30,
		shoot_start = 70,
		shoot_end = 90,
		punch_start = 70,
		punch_end = 90,
		-- TODO: Implement and fix death animation
		--die_start = 120,
		--die_end = 130,
		--die_loop = false,

		-- Not supported yet
		hurt_start = 100,
		hurt_end = 120,
	},
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	arrow = "mobs_mc:arrow_entity",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max =0.5,
	blood_amount = 0,
	fear_height = 4,
})

--spawn
mobs:spawn_specific("mobs_mc:witherskeleton", mobs_mc.spawn.nether_fortress, {"air"}, 0, 7, 30, 5000, 5, mobs_mc.spawn_height.nether_min, mobs_mc.spawn_height.nether_max)

-- spawn eggs
mobs:register_egg("mobs_mc:witherskeleton", S("Wither Skeleton"), "mobs_mc_spawn_icon_witherskeleton.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Wither Skeleton loaded")
end
