-- v1.4

--###################
--################### GUARDIAN
--###################

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

mobs:register_mob("mobs_mc:guardian_elder", {
	type = "monster",
	hp_min = 80,
	hp_max = 80,
    	passive = false,
	attack_type = "dogfight",
	pathfinding = 1,
	view_range = 16,
	walk_velocity = 2,
	run_velocity = 4,
	damage = 8,
	reach = 3,
	collisionbox = {-0.99875, 0.5, -0.99875, 0.99875, 2.4975, 0.99875},
	visual = "mesh",
	mesh = "mobs_mc_guardian.b3d",
	textures = {
		{"mobs_mc_guardian_elder.png"},
	},
	visual_size = {x=7, y=7},
	sounds = {
		damage = "mobs_mc_squid_hurt",
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	drops = {
		{name = mobs_mc.items.prismarine_shard,
		chance = 1,
		min = 0,
		max = 2,},
		-- TODO: Only drop if killed by player
		{name = mobs_mc.items.wet_sponge,
		chance = 1,
		min = 1,
		max = 1,},

		-- The following drops are approximations
		-- Fish / prismarine crystal
		{name = mobs_mc.items.fish_raw,
		chance = 4,
		min = 1,
		max = 1,},
		{name = mobs_mc.items.prismarine_crystals,
		chance = 4,
		min = 1,
		max = 1,},

		-- Rare drop: fish
		{name = mobs_mc.items.fish_raw,
		chance = 160, -- 2.5% / 4
		min = 1,
		max = 1,},
		{name = mobs_mc.items.salmon_raw,
		chance = 160,
		min = 1,
		max = 1,},
		{name = mobs_mc.items.clownfish_raw,
		chance = 160,
		min = 1,
		max = 1,},
		{name = mobs_mc.items.pufferfish_raw,
		chance = 160,
		min = 1,
		max = 1,},
	},
	fly = true,
	fly_in = { mobs_mc.items.water_source, mobs_mc.items.river_water_source },
	stepheight = 0.1,
	jump = false,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	view_range = 16,
	blood_amount = 0,
})

mobs:spawn_specific("mobs_mc:guardian_elder", mobs_mc.spawn.water, mobs_mc.spawn_water, 0, minetest.LIGHT_MAX+1, 30, 40000, 2, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.water-18)

-- spawn eggs
mobs:register_egg("mobs_mc:guardian_elder", S("Elder Guardian"), "mobs_mc_spawn_icon_guardian_elder.png", 0)

