--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

-- TODO: Turn villagers to zombie villager

--###################
--################### ZOMBIE VILLAGER
--###################


mobs:register_mob("mobs_mc:villager_zombie", {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	breath_max = -1,
	armor = {undead = 90, fleshy = 90},
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_villager_zombie.b3d",
	textures = {
		{"mobs_mc_zombie_butcher.png"},
		{"mobs_mc_zombie_farmer.png"},
		{"mobs_mc_zombie_librarian.png"},
		{"mobs_mc_zombie_priest.png"},
		{"mobs_mc_zombie_smith.png"},
		{"mobs_mc_zombie_villager.png"}
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	damage = 3,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	attack_type = "dogfight",
	group_attack = true,
	drops = {
		{name = mobs_mc.items.rotten_flesh,
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
		{name = mobs_mc.items.iron_ingot,
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,},
		{name = mobs_mc.items.carrot,
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,},
		{name = mobs_mc.items.potato,
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,},
	},
	sounds = {
		random = "mobs_mc_zombie_growl",
		war_cry = "mobs_mc_zombie_growl",
		death = "mobs_mc_zombie_death",
		damage = "mobs_mc_zombie_hurt",
		distance = 16,
	},
	animation = {
		speed_normal = 25,
        speed_run = 50,
		stand_start = 20,
        stand_end = 40,
		walk_start = 0,
        walk_end = 20,
		run_start = 0,
        run_end = 20,
	},
	sunlight_damage = 1,
	view_range = 16,
	fear_height = 4,
	harmed_by_heal = true,

})

mobs:spawn_specific("mobs_mc:villager_zombie", mobs_mc.spawn.village, {"air"}, 0, 7, 30, 4090, 4, mobs_mc.spawn_height.water+1, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:villager_zombie", S("Zombie Villager"), "mobs_mc_spawn_icon_zombie_villager.png", 0)
