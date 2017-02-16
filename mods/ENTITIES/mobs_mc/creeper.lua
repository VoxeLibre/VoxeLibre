--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")



mobs:register_mob("mobs_mc:creeper", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.6, 0.4},
	pathfinding = true,
	group_attack = true,
	visual = "mesh",
	visual_size = {x=.75, y=.75, z=.75},
	mesh = "mobs_creeper.x",
	textures = {
	{"mobs_creeper.png"}
	},
	makes_footstep_sound = false,
	sounds = {
		attack = "Fuse",
		death = "Creeperdeath",
		damage = "Creeper4",
		war_cry = "Fuse",
		explode = "explo",
	},
	walk_velocity = 1.5,
	run_velocity = 3,
	damage = 1,
	explosion_radius = 3,
	armor = 100,
	maxdrops = 3,
	drops = {
		{name = "mcl_core:gunpowder",
		chance = 1,
		min = 0,
		max = 2,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		run_start = 24,
		run_end = 49,
		hurt_start = 110,
		hurt_end = 139,
		death_start = 140,
		death_end = 189,
		look_start = 50,
		look_end = 108,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	view_range = 16,
	attack_type = "explode",
})
mobs:register_spawn("mobs_mc:creeper", {"group:crumbly", "group:cracky", "group:choppy", "group:snappy"}, 7, -1, 5000, 4, 31000)



-- compatibility
mobs:alias_mob("mobs:creeper", "mobs_mc:creeper")

-- spawn eggs
mobs:register_egg("mobs_mc:creeper", "Spawn Creeper", "spawn_egg_creeper.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Creeper loaded")
end
