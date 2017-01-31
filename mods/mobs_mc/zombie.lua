--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")



mobs:register_mob("mobs_mc:zombie", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1.9, 0.4},
	textures = {
	{"mobs_zombie.png"}
	},
	visual = "mesh",
	mesh = "mobs_zombie.x",
	makes_footstep_sound = true,
	sounds = {
		random = "zombie1",
		death = "zombiedeath",
		damage = "zombiehurt1",
		attack = "default_punch3",
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 3,
	pathfinding = true,
	group_attack = true,
	armor = 80,
	drops = {
		{name = "mcl_mobitems:rotten_flesh",
		chance = 1,
		min = 0,
		max = 2,},
		{name = "mcl_core:steel_ingot",
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},
		{name = "mcl_core:shovel_steel",
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},
		{name = "mcl_core:sword_steel",
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},
		{name = "farming:carrot",
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},
		{name = "farming:potato",
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		hurt_start = 64,
		hurt_end = 86,
		death_start = 88,
		death_end = 118,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 1,
	view_range = 16,
	attack_type = "dogfight",
})
mobs:register_spawn("mobs_mc:zombie", {"group:crumbly", "group:cracky", "group:choppy", "group:snappy"}, 7, -1, 5000, 4, 31000)


-- compatibility
mobs:alias_mob("mobs:zombie", "mobs_mc:zombie")

-- spawn eggs
mobs:register_egg("mobs_mc:zombie", "Spawn Zombie", "spawn_egg_zombie.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Zombie loaded")
end
