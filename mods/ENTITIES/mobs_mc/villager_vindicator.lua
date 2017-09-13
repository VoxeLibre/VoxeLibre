--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")
--###################
--################### VINDICATOR
--###################


mobs:register_mob("mobs_mc:vindicator", {
	type = "monster",
	physical = false,
	pathfinding = 1,
	hp_min = 24,
	hp_max = 24,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_vindicator.b3d",
    textures = {
        {
            "mobs_mc_vindicator_base.png",
            "blank.png", --no hat
            "mobs_mc_iron_axe.png",
            -- TODO: Glow when attacking (mobs_mc_vindicator.png)
        },
    },
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	damage = 13,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	attack_type = "dogfight",
	drops = {
		{name = mobs_mc.items.emerald,
		chance = 1,
		min = 0,
		max = 1,},
		{name = mobs_mc.items.iron_axe,
		chance = 11,
		min = 1,
		max = 1,},
	},
	sounds = {
		random = "Villager1",
		death = "Villagerdead",
		damage = "Villagerhurt1",
	},
	animation = {
		stand_speed = 25,
		walk_speed = 25,
		run_speed = 25,
		punch_speed = 25,
		stand_start = 40,
		stand_end = 59,
		walk_start = 0,
		walk_end = 40,
		punch_start = 90,
		punch_end = 110,
		-- TODO: Implement and fix death animation
		--die_start = 170,
		--die_end = 180,
		--die_loop = false,
	},
	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	view_range = 16,
	fear_height = 4,

})

-- spawn eggs
mobs:register_egg("mobs_mc:vindicator", S("Vindicator"), "mobs_mc_spawn_icon_vindicator.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC vindicator loaded")
end
