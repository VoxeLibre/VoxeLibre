--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### POLARBEAR
--###################


mobs:register_mob("mobs_mc:polar_bear", {
	description = S("Polar Bear"),
	type = "animal",
	spawn_class = "passive",
	runaway = false,
	passive = false,
	hp_min = 30,
	hp_max = 30,
	xp_min = 1,
	xp_max = 3,
        breath_max = -1,
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 1.39, 0.7},
	visual = "mesh",
	mesh = "mobs_mc_polarbear.b3d",
	textures = {
		{"mobs_mc_polarbear.png"},
	},
	visual_size = {x=3.0, y=3.0},
	makes_footstep_sound = true,
	damage = 6,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	group_attack = true,
	attack_type = "punch",
	drops = {
		-- 3/4 chance to drop raw fish (poor approximation)
		{name = mobs_mc.items.fish_raw,
		chance = 2,
		min = 0,
		max = 2,
		looting = "common",},
		-- 1/4 to drop raw salmon
		{name = mobs_mc.items.salmon_raw,
		chance = 4,
		min = 0,
		max = 2,
		looting = "common",},

	},
	floats = 1,
	fear_height = 4,
	sounds = {
		random = "mobs_mc_bear_random",
		attack = "mobs_mc_bear_attack",
		damage = "mobs_mc_bear_hurt",
		death = "mobs_mc_bear_death",
		war_cry = "mobs_mc_bear_growl",
		distance = 16,
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},

	view_range = 16,
})


mobs:spawn_specific(
"mobs_mc:polar_bear",
"overworld",
"ground",
{
"ColdTaiga",
"IcePlainsSpikes",
"IcePlains",
"ExtremeHills+_snowtop",
},
0,
minetest.LIGHT_MAX+1,
30,
7000,
3,
mobs_mc.spawn_height.overworld_min,
mobs_mc.spawn_height.overworld_max)

-- spawn egg
mobs:register_egg("mobs_mc:polar_bear", S("Polar Bear"), "mobs_mc_spawn_icon_polarbear.png", 0)
