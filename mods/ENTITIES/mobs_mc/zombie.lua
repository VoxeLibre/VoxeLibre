--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### ZOMBIE
--###################

local drops_common = {
	{name = "mcl_mobitems:rotten_flesh",
	chance = 1,
	min = 0,
	max = 2,
	looting = "common",},
	{name = "mcl_core:iron_ingot",
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,
	looting = "rare",
	looting_factor = 0.01 / 3,},
	{name = "mcl_farming:carrot_item",
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,
	looting = "rare",
	looting_factor = 0.01 / 3,},
	{name = "mcl_farming:potato_item",
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,
	looting = "rare",
	looting_factor = 0.01 / 3,},
}

local drops_zombie = table.copy(drops_common)
table.insert(drops_zombie, {
	name = "mcl_heads:zombie",
	chance = 200, -- 0.5%
	min = 1,
	max = 1,
	conditions = {
		guarantee_if_killed_by = { "mobs_mc:stalker_overloaded" }
	}
})

local zombie = {
	description = S("Zombie"),
	type = "monster",
	spawn_class = "hostile",
	initial_properties = {
		hp_min = 20,
		hp_max = 20,
		breath_max = -1,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.89, 0.3},
	},
	xp_min = 5,
	xp_max = 5,
	head_swivel = "head.control",
	head_eye_height = 1.4,
	head_bone_position = vector.new( 0, 6.3, 0 ), -- for minetest <= 5.8
	curiosity = 7,
	head_pitch_multiplier=-1,
	wears_armor = 1,
	armor = {undead = 90, fleshy = 90},
	visual = "mesh",
	mesh = "mobs_mc_zombie.b3d",
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_zombie.png", -- texture
		}
	},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_mc_zombie_growl",
		war_cry = "mobs_mc_zombie_growl",
		death = "mobs_mc_zombie_death",
		damage = "mobs_mc_zombie_hurt",
		distance = 16,
	},
	walk_velocity = .8,
	run_velocity = 1.8,
	damage = 3,
	reach = 2,
	fear_height = 4,
	pathfinding = 1,
	jump = true,
	jump_height = 4,
	group_attack = { "mobs_mc:zombie", "mobs_mc:baby_zombie", "mobs_mc:husk", "mobs_mc:baby_husk" },
	drops = drops_zombie,
	animation = {
		stand_start = 40, stand_end = 49, stand_speed = 2,
		walk_start = 0, walk_end = 39, speed_normal = 25,
		run_start = 0, run_end = 39, speed_run = 50,
		punch_start = 50, punch_end = 59, punch_speed = 20,
	},
	ignited_by_sunlight = true,
	sunlight_damage = 2,
	floats = 0,
	view_range = 16,
	attack_type = "dogfight",
	harmed_by_heal = true,
	attack_npcs = true,
}

mcl_mobs.register_mob("mobs_mc:zombie", zombie)

-- Baby zombie.
-- A smaller and more dangerous variant of the zombie

local baby_zombie = table.copy(zombie)
baby_zombie.description = S("Baby Zombie")
baby_zombie.head_eye_height = 0.8
baby_zombie.initial_properties.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.98, 0.25}
baby_zombie.xp_min = 12
baby_zombie.xp_max = 12
baby_zombie.walk_velocity = 1.2
baby_zombie.run_velocity = 2.4
baby_zombie.child = 1
baby_zombie.reach = 1
baby_zombie.animation = {
	stand_start = 100, stand_end = 109, stand_speed = 2,
	walk_start = 60, walk_end = 99, speed_normal = 40,
	run_start = 60, run_end = 99, speed_run = 80,
	punch_start = 109, punch_end = 119
}

mcl_mobs.register_mob("mobs_mc:baby_zombie", baby_zombie)

-- Husk.
-- Desert variant of the zombie
local husk = table.copy(zombie)
husk.description = S("Husk")
husk.textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_husk.png", -- texture
		}
	}
husk.ignited_by_sunlight = false
husk.sunlight_damage = 0
husk.drops = drops_common
-- TODO: Husks avoid water

mcl_mobs.register_mob("mobs_mc:husk", husk)

-- Baby husk.
-- A smaller and more dangerous variant of the husk
local baby_husk = table.copy(baby_zombie)
baby_husk.description = S("Baby Husk")
baby_husk.textures = {{
	"mobs_mc_empty.png", -- wielded_item
	"mobs_mc_husk.png", -- texture
}}
baby_husk.ignited_by_sunlight = false
baby_husk.sunlight_damage = 0
baby_husk.drops = drops_common

mcl_mobs.register_mob("mobs_mc:baby_husk", baby_husk)


-- Spawning

mcl_mobs:spawn_setup({
	name = "mobs_mc:zombie",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"FlowerForest_underground",
		"JungleEdge_underground",
		"StoneBeach_underground",
		"MesaBryce_underground",
		"Mesa_underground",
		"RoofedForest_underground",
		"Jungle_underground",
		"Swampland_underground",
		"BirchForest_underground",
		"Plains_underground",
		"MesaPlateauF_underground",
		"ExtremeHills_underground",
		"MegaSpruceTaiga_underground",
		"BirchForestM_underground",
		"SavannaM_underground",
		"MesaPlateauFM_underground",
		"Desert_underground",
		"Savanna_underground",
		"Forest_underground",
		"SunflowerPlains_underground",
		"ColdTaiga_underground",
		"IcePlains_underground",
		"IcePlainsSpikes_underground",
		"MegaTaiga_underground",
		"Taiga_underground",
		"ExtremeHills+_underground",
		"JungleM_underground",
		"ExtremeHillsM_underground",
		"JungleEdgeM_underground",
		"Mesa",
		"FlowerForest",
		"Swampland",
		"Taiga",
		"ExtremeHills",
		"Jungle",
		"Savanna",
		"BirchForest",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"ExtremeHills+",
		"Forest",
		"Plains",
		"ColdTaiga",
		"IcePlainsSpikes",
		"SunflowerPlains",
		"IcePlains",
		"RoofedForest",
		"ExtremeHills+_snowtop",
		"MesaPlateauFM_grasstop",
		"JungleEdgeM",
		"ExtremeHillsM",
		"JungleM",
		"BirchForestM",
		"MesaPlateauF",
		"MesaPlateauFM",
		"MesaPlateauF_grasstop",
		"MesaBryce",
		"JungleEdge",
		"SavannaM",
		"FlowerForest_beach",
		"Forest_beach",
		"StoneBeach",
		"ColdTaiga_beach_water",
		"Taiga_beach",
		"Savanna_beach",
		"Plains_beach",
		"ExtremeHills_beach",
		"ColdTaiga_beach",
		"Swampland_shore",
		"JungleM_shore",
		"Jungle_shore",
		"MesaPlateauFM_sandlevel",
		"MesaPlateauF_sandlevel",
		"MesaBryce_sandlevel",
		"Mesa_sandlevel",
		"BambooJungle",
		"BambooJungleM",
		"BambooJungleEdge",
		"BambooJungleEdgeM",
		"BambooJungle_underground",
		"BambooJungleM_underground",
		"BambooJungleEdge_underground",
		"BambooJungleEdgeM_underground",
		"BambooJungle_ocean",
		"BambooJungleM_ocean",
		"BambooJungleEdge_ocean",
		"BambooJungleEdgeM_ocean",
		"BambooJungle_deep_ocean",
		"BambooJungleM_deep_ocean",
		"BambooJungleEdge_deep_ocean",
		"BambooJungleEdgeM_deep_ocean",
		"BambooJungle_shore",
		"BambooJungleM_shore",
		"BambooJungleEdge_shore",
		"BambooJungleEdgeM_shore",
	},
	min_light = 0,
	max_light = 7,
	chance = 1500,
	interval = 30,
	aoc = 4,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max
})
-- Baby zombie is 20 times less likely than regular zombies
mcl_mobs:spawn_setup({
	name = "mobs_mc:baby_zombie",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"FlowerForest_underground",
		"JungleEdge_underground",
		"StoneBeach_underground",
		"MesaBryce_underground",
		"Mesa_underground",
		"RoofedForest_underground",
		"Jungle_underground",
		"Swampland_underground",
		"BirchForest_underground",
		"Plains_underground",
		"MesaPlateauF_underground",
		"ExtremeHills_underground",
		"MegaSpruceTaiga_underground",
		"BirchForestM_underground",
		"SavannaM_underground",
		"MesaPlateauFM_underground",
		"Desert_underground",
		"Savanna_underground",
		"Forest_underground",
		"SunflowerPlains_underground",
		"ColdTaiga_underground",
		"IcePlains_underground",
		"IcePlainsSpikes_underground",
		"MegaTaiga_underground",
		"Taiga_underground",
		"ExtremeHills+_underground",
		"JungleM_underground",
		"ExtremeHillsM_underground",
		"JungleEdgeM_underground",
		"Mesa",
		"FlowerForest",
		"Swampland",
		"Taiga",
		"ExtremeHills",
		"Jungle",
		"Savanna",
		"BirchForest",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"ExtremeHills+",
		"Forest",
		"Plains",
		"ColdTaiga",
		"IcePlainsSpikes",
		"SunflowerPlains",
		"IcePlains",
		"RoofedForest",
		"ExtremeHills+_snowtop",
		"MesaPlateauFM_grasstop",
		"JungleEdgeM",
		"ExtremeHillsM",
		"JungleM",
		"BirchForestM",
		"MesaPlateauF",
		"MesaPlateauFM",
		"MesaPlateauF_grasstop",
		"MesaBryce",
		"JungleEdge",
		"SavannaM",
		"FlowerForest_beach",
		"Forest_beach",
		"StoneBeach",
		"ColdTaiga_beach_water",
		"Taiga_beach",
		"Savanna_beach",
		"Plains_beach",
		"ExtremeHills_beach",
		"ColdTaiga_beach",
		"Swampland_shore",
		"JungleM_shore",
		"Jungle_shore",
		"MesaPlateauFM_sandlevel",
		"MesaPlateauF_sandlevel",
		"MesaBryce_sandlevel",
		"Mesa_sandlevel",
		"BambooJungle",
		"BambooJungleM",
		"BambooJungleEdge",
		"BambooJungleEdgeM",
		"BambooJungle_underground",
		"BambooJungleM_underground",
		"BambooJungleEdge_underground",
		"BambooJungleEdgeM_underground",
		"BambooJungle_ocean",
		"BambooJungleM_ocean",
		"BambooJungleEdge_ocean",
		"BambooJungleEdgeM_ocean",
		"BambooJungle_deep_ocean",
		"BambooJungleM_deep_ocean",
		"BambooJungleEdge_deep_ocean",
		"BambooJungleEdgeM_deep_ocean",
		"BambooJungle_shore",
		"BambooJungleM_shore",
		"BambooJungleEdge_shore",
		"BambooJungleEdgeM_shore",
	},
	min_light = 0,
	max_light = 7,
	chance = 50,
	interval = 30,
	aoc = 4,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max
})


mcl_mobs:spawn_setup({
	name = "mobs_mc:husk",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"Desert",
	},
	min_light = 0,
	max_light = 7,
	chance = 3400,
	interval = 30,
	aoc = 4,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max
})
mcl_mobs:spawn_setup({
	name = "mobs_mc:baby_husk",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"Desert",
	},
	min_light = 0,
	max_light = 7,
	chance = 120,
	interval = 30,
	aoc = 4,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max
})

-- Spawn eggs
mcl_mobs.register_egg("mobs_mc:husk", S("Husk"), "#777361", "#ded88f", 0)
mcl_mobs.register_egg("mobs_mc:zombie", S("Zombie"), "#00afaf", "#799c66", 0)
