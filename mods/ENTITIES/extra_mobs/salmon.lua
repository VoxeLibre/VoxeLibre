--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("extra_mobs")

--###################
--################### salmon
--###################

local salmon = {
    type = "animal",
    spawn_class = "water",
    can_despawn = true,
    passive = true,
    hp_min = 3,
    hp_max = 3,
    xp_min = 1,
    xp_max = 3,
    armor = 100,
    collisionbox = {-0.4, 0.0, -0.4, 0.4, 0.79, 0.4},
    visual = "mesh",
    mesh = "extra_mobs_salmon.b3d",
    textures = {
        {"extra_mobs_salmon.png"}
    },
    sounds = {
    },
    animation = {
		stand_start = 1,
		stand_end = 20,
		walk_start = 1,
		walk_end = 20,
		run_start = 1,
		run_end = 20,
	},
    drops = {
		{name = "mcl_fishing:salmon_raw",
		chance = 1,
		min = 1,
		max = 1,},
        {name = "mcl_dye:white",
		chance = 20,
		min = 1,
		max = 1,},
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
}

mobs:register_mob("extra_mobs:salmon", salmon)


--spawning TODO: in schools
local water = mobs_mc.spawn_height.water
mobs:spawn_specific("extra_mobs:salmon", mobs_mc.spawn.water, {mobs_mc.items.water_source}, 0, minetest.LIGHT_MAX+1, 30, 4000, 3, water-16, water)

--spawn egg
mobs:register_egg("extra_mobs:salmon", S("Salmon"), "extra_mobs_spawn_icon_salmon.png", 0)
