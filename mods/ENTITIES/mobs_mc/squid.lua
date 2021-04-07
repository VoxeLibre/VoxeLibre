-- v1.1

--###################
--################### SQUID
--###################

local S = minetest.get_translator("mobs_mc")

mobs:register_mob("mobs_mc:squid", {
    type = "animal",
    spawn_class = "water",
    can_despawn = true,
    passive = true,
    hp_min = 10,
    hp_max = 10,
    xp_min = 1,
    xp_max = 3,
    armor = 100,
    -- FIXME: If the squid is near the floor, it turns black
    collisionbox = {-0.4, 0.0, -0.4, 0.4, 0.9, 0.4},
    visual = "mesh",
    mesh = "mobs_mc_squid.b3d",
    textures = {
        {"mobs_mc_squid.png"}
    },
    sounds = {
		damage = {name="mobs_mc_squid_hurt", gain=0.3},
		death = {name="mobs_mc_squid_death", gain=0.4},
		flop = "mobs_mc_squid_flop",
		-- TODO: sounds: random
		distance = 16,
    },
    animation = {
		stand_start = 1,
		stand_end = 60,
		walk_start = 1,
		walk_end = 60,
		run_start = 1,
		run_end = 60,
	},
    drops = {
		{name = mobs_mc.items.black_dye,
		chance = 1,
		min = 1,
		max = 3,
		looting = "common",},
	},
    visual_size = {x=3, y=3},
    makes_footstep_sound = false,
    fly = true,
    fly_in = { mobs_mc.items.water_source, mobs_mc.items.river_water_source },
    breathes_in_water = true,
    jump = false,
    view_range = 16,
    runaway = true,
    fear_height = 4,
})

-- TODO: Behaviour: squirt

-- Spawn near the water surface

local water = mobs_mc.spawn_height.water
--name, nodes, neighbours, minlight, maxlight, interval, chance, active_object_count, min_height, max_height
mobs:spawn_specific("mobs_mc:squid", "overworld", "water", 0, minetest.LIGHT_MAX+1, 30, 5500, 3, water-16, water)

-- spawn eggs
mobs:register_egg("mobs_mc:squid", S("Squid"), "mobs_mc_spawn_icon_squid.png", 0)
