--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### ZOMBIE
--###################

local drops_common = {
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
}

local drops_zombie = table.copy(drops_common)
table.insert(drops_zombie, {
	-- Zombie Head
	-- TODO: Only drop if killed by charged creeper
	name = mobs_mc.items.head_zombie,
	chance = 200, -- 0.5%
	min = 1,
	max = 1,
})

local zombie = {
	description = S("Zombie"),
	type = "monster",
	spawn_class = "hostile",
	hostile = true,
	rotate = 270,
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	breath_max = -1,
	armor = {undead = 90, fleshy = 90},
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie.b3d",
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_zombie.png", -- texture
			"mobs_mc_empty.png", -- wielded_item
		}
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_mc_zombie_growl",
		war_cry = "mobs_mc_zombie_growl",
		death = "mobs_mc_zombie_death",
		damage = "mobs_mc_zombie_hurt",
		distance = 16,
	},

	--head code
	has_head = false,
	head_bone = "Head",

	swap_y_with_x = true,
	reverse_head_yaw = true,

	head_bone_pos_y = 2.4,
	head_bone_pos_z = 0,

	head_height_offset = 1.1,
	head_direction_offset = 0,
	head_pitch_modifier = 0,
	--end head code

	eye_height = 1.65,
	walk_velocity = 1,
	run_velocity = 3.5,
	damage = 3,
	reach = 2,
	fear_height = 4,
	pathfinding = 1,
	jump = true,
	jump_height = 4,
	group_attack = { "mobs_mc:zombie", "mobs_mc:baby_zombie", "mobs_mc:husk", "mobs_mc:baby_husk" },
	drops = drops_zombie,
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 40,		stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	ignited_by_sunlight = true,
	sunlight_damage = 2,
	view_range = 16,
	attack_type = "punch",
	punch_timer_cooloff = 0.5,
	harmed_by_heal = true,
}

mobs:register_mob("mobs_mc:zombie", zombie)

-- Baby zombie.
-- A smaller and more dangerous variant of the zombie

local baby_zombie = table.copy(zombie)
baby_zombie.description = S("Baby Zombie")
baby_zombie.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.94, 0.25}
baby_zombie.xp_min = 12
baby_zombie.xp_max = 12
baby_zombie.visual_size = {x=zombie.visual_size.x/2, y=zombie.visual_size.y/2}
baby_zombie.walk_velocity = 1.2
baby_zombie.run_velocity = 2.4
baby_zombie.child = 1

mobs:register_mob("mobs_mc:baby_zombie", baby_zombie)

-- Husk.
-- Desert variant of the zombie
local husk = table.copy(zombie)
husk.description = S("Husk")
husk.textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_husk.png", -- texture
			"mobs_mc_empty.png", -- wielded_item
		}
	}
husk.ignited_by_sunlight = false
husk.sunlight_damage = 0
husk.drops = drops_common
-- TODO: Husks avoid water

mobs:register_mob("mobs_mc:husk", husk)

-- Baby husk.
-- A smaller and more dangerous variant of the husk
local baby_husk = table.copy(husk)
baby_husk.description = S("Baby Husk")
baby_husk.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.94, 0.25}
baby_husk.xp_min = 12
baby_husk.xp_max = 12
baby_husk.visual_size = {x=zombie.visual_size.x/2, y=zombie.visual_size.y/2}
baby_husk.walk_velocity = 1.2
baby_husk.run_velocity = 2.4
baby_husk.child = 1

mobs:register_mob("mobs_mc:baby_husk", baby_husk)


-- Spawning

mobs:spawn_specific(
"mobs_mc:zombie",
"overworld",
"ground",
{
"FlowerForest_underground",
"JungleEdge_underground",
"StoneBeach_underground",
"MesaBryce_underground",
"Mesa_underground",
"RoofedForest_underground",
"Jungle_underground",
"Swampland_underground",
"MushroomIsland_underground",
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
"Desert",
"ColdTaiga",
"MushroomIsland",
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
"MushroomIslandShore",
"JungleM_shore",
"Jungle_shore",
"MesaPlateauFM_sandlevel",
"MesaPlateauF_sandlevel",
"MesaBryce_sandlevel",
"Mesa_sandlevel",
},
0,
7,
30,
6000,
4,
mobs_mc.spawn_height.overworld_min,
mobs_mc.spawn_height.overworld_max)
-- Baby zombie is 20 times less likely than regular zombies
mobs:spawn_specific(
"mobs_mc:baby_zombie",
"overworld",
"ground",
{
"FlowerForest_underground",
"JungleEdge_underground",
"StoneBeach_underground",
"MesaBryce_underground",
"Mesa_underground",
"RoofedForest_underground",
"Jungle_underground",
"Swampland_underground",
"MushroomIsland_underground",
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
"Desert",
"ColdTaiga",
"MushroomIsland",
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
"MushroomIslandShore",
"JungleM_shore",
"Jungle_shore",
"MesaPlateauFM_sandlevel",
"MesaPlateauF_sandlevel",
"MesaBryce_sandlevel",
"Mesa_sandlevel",
},
0,
7,
30,
60000,
4,
mobs_mc.spawn_height.overworld_min,
mobs_mc.spawn_height.overworld_max)


mobs:spawn_specific(
"mobs_mc:husk",
"overworld",
"ground",
{
"Desert",
"SavannaM",
"Savanna",
"Savanna_beach",
},
0,
7,
30,
6500,
4,
mobs_mc.spawn_height.overworld_min,
mobs_mc.spawn_height.overworld_max)
mobs:spawn_specific(
"mobs_mc:baby_husk",
"overworld",
"ground",
{
"Desert",
"SavannaM",
"Savanna",
"Savanna_beach",
},
0,
7,
30,
65000,
4,
mobs_mc.spawn_height.overworld_min,
mobs_mc.spawn_height.overworld_max)

-- Spawn eggs
mobs:register_egg("mobs_mc:husk", S("Husk"), "mobs_mc_spawn_icon_husk.png", 0)
mobs:register_egg("mobs_mc:zombie", S("Zombie"), "mobs_mc_spawn_icon_zombie.png", 0)
