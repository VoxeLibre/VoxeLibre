-- v1.4

--###################
--################### GUARDIAN
--###################

local S = minetest.get_translator("mobs_mc")

mobs:register_mob("mobs_mc:guardian_elder", {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 80,
	hp_max = 80,
	breath_max = -1,
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
		random = "mobs_mc_guardian_random",
		war_cry = "mobs_mc_guardian_random",
		damage = {name="mobs_mc_guardian_hurt", gain=0.3},
		death = "mobs_mc_guardian_death",
		flop = "mobs_mc_squid_flop",
		base_pitch = 0.6,
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	drops = {
		-- TODO: Reduce # of drops when ocean monument is ready.

		-- Greatly increased amounts of prismarine
		{name = mobs_mc.items.prismarine_shard,
		chance = 1,
		min = 1,
		max = 64,},

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
		chance = 1,
		min = 1,
		max = 10,},

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
	makes_footstep_sound = false,
	fly_in = { mobs_mc.items.water_source, mobs_mc.items.river_water_source },
	jump = false,
	view_range = 16,
})

-- Spawning disabled due to size issues
-- TODO: Re-enable spawning
-- mobs:spawn_specific("mobs_mc:guardian_elder", mobs_mc.spawn.water, mobs_mc.spawn_water, 0, minetest.LIGHT_MAX+1, 30, 40000, 2, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.water-18)

-- spawn eggs
mobs:register_egg("mobs_mc:guardian_elder", S("Elder Guardian"), "mobs_mc_spawn_icon_guardian_elder.png", 0)

