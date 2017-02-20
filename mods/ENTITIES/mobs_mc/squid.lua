-- v1.1

local l_spawn_in = {"mcl_core:water_flowing","mcl_core:water_source"}
local l_spawn_near = {"mcl_core:water_flowing","mcl_core:water_source"}
local l_spawn_chance = 500
local l_min_light = -1
local l_max_light = 30
local l_max_height = -1 -- water_level - 1

mobs:register_mob("mobs_mc:squid", {
    type = "animal",
    passive = true,
    hp_min = 10,
    hp_max = 10,
    armor = 100,
    collisionbox = {-0.4, 1.3, -1.5, 0.6, 2.3, 1.5},
    visual = "mesh",
    mesh = "mobs_squid.b3d",
    textures = {
        {"mobs_squid.png"}
    },
    sounds = {
		damage = "mobs_squid_hurt",
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
		{name = "mcl_dye:black",
		chance = 1,
		min = 1,
		max = 3,},
	},
    rotate = 180,
    visual_size = {x=4.5, y=4.5},
    makes_footstep_sound = false,
    stepheight = 0.1,
    fly = true,
    fly_in = "mcl_core:water_source",
    fall_speed = -3,
    view_range = 8,
    fall_damage = 1,
    water_damage = 0,
    lava_damage = 5,
    light_damage = 0,
    
})

--name, nodes, neighbours, minlight, maxlight, interval, chance, active_object_count, min_height, max_height
mobs:spawn_specific("mobs_mc:squid", l_spawn_in, l_spawn_near, l_min_light, l_max_light, 30, 5000, 2, -31000, l_max_height )

-- compatibility
mobs:alias_mob("mobs:squid", "mobs_mc:squid")

-- spawn eggs
mobs:register_egg("mobs_mc:squid", "Spawn Squid", "spawn_egg_squid.png")
