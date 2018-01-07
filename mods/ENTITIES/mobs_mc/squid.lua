-- v1.1

--###################
--################### SQUID
--###################

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

mobs:register_mob("mobs_mc:squid", {
    type = "animal",
    passive = true,
    hp_min = 10,
    hp_max = 10,
    armor = 100,
    -- FIXME: If the squid is near the floor, it turns black
    collisionbox = {-0.4, 0.1, -0.4, 0.4, 0.9, 0.4},
    visual = "mesh",
    mesh = "mobs_mc_squid.b3d",
    textures = {
        {"mobs_mc_squid.png"}
    },
    sounds = {
		damage = "mobs_mc_squid_hurt",
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
		max = 3,},
	},
    visual_size = {x=1.75, y=1.75},
    makes_footstep_sound = false,
    stepheight = 0.1,
    fly = true,
    fly_in = { mobs_mc.items.water_source, mobs_mc.items.river_water_source },
    jump = false,
    fall_speed = 0.5,
    view_range = 16,
    water_damage = 0,
    lava_damage = 4,
    light_damage = 0,
    runaway = true,
    fear_height = 4,
    blood_texture = "mobs_mc_squid_blood.png",
})

-- Spawn near the water surface

local water = mobs_mc.spawn_height.water
--name, nodes, neighbours, minlight, maxlight, interval, chance, active_object_count, min_height, max_height
mobs:spawn_specific("mobs_mc:squid", mobs_mc.spawn.water, {mobs_mc.items.water_source}, 0, minetest.LIGHT_MAX+1, 30, 5500, 3, water-16, water)

-- compatibility
mobs:alias_mob("mobs:squid", "mobs_mc:squid")

-- spawn eggs
mobs:register_egg("mobs_mc:squid", S("Squid"), "mobs_mc_spawn_icon_squid.png", 0)
