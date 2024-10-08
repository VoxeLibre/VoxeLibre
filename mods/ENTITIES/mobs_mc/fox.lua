local S = minetest.get_translator("mobs_mc")

-- TODO: sounds
-- TODO: carry one item, spawn with item
-- TODO: add sleeping behavior
-- TODO: snow color depending on biome not randomly
-- TODO: pouncing - jump to attack behavior
-- TODO: use totem of undying when carried

-- Fox
local fox = {
	description = S("Fox"),
	type = "animal",
	spawn_class = "passive",
	can_despawn = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	passive = false,
	group_attack = false,
	spawn_in_group = 4,
	collisionbox = { -0.3, 0, -0.3, 0.3, 0.7, 0.3 },
	visual = "mesh",
	mesh = "mobs_mc_fox.b3d",
	textures = {
		{ "mobs_mc_fox.png", "mobs_mc_fox_sleep.png" },
		{ "mobs_mc_snow_fox.png", "mobs_mc_snow_fox_sleep.png" }
	},
	makes_footstep_sound = true,
	head_swivel = "Bone.001",
	bone_eye_height = 0.5,
	head_eye_height = 0.1,
	horizontal_head_height = 0,
	curiosity = 5,
	head_yaw = "z",
	sounds = { }, -- FIXME
	pathfinding = 1,
	floats = 1,
	view_range = 16,
	walk_chance = 50,
	walk_velocity = 2,
	run_velocity = 3,
	damage = 2,
	reach = 1,
	attack_type = "dogfight",
	fear_height = 5,
	-- drops = { }, -- TODO: only what they are carrying
	follow = { "mcl_farming:sweet_berry" }, -- TODO: and glow berries, taming
	animation = {
		stand_start = 1, stand_end = 20, stand_speed = 20,
		walk_start = 120, walk_end = 160, walk_speed = 80,
		run_start = 160, run_end = 199, run_speed = 80,
		punch_start = 80, punch_end = 105, punch_speed = 80,
		sit_start = 30 , sit_end = 50,
		sleep_start = 55, sleep_end = 75,
		--wiggle_start = 170, wiggle_end = 230,
		--die_start = 0, die_end = 0, die_speed = 0,--die_loop = 0,
	},
	jump = true,
	jump_height = 8,
	attacks_monsters = true,
	attack_animals = true,
	specific_attack = {
		"mobs_mc:chicken", "mobs_mc:rabbit",
		"mobs_mc:cod", "mobs_mc:salmon", "mobs_mc:tropical_fish"
		 -- TODO: baby turtles, monsters?
	},
	runaway_from = {
		-- they are too cute for this: "player",
		"mobs_mc:wolf",
		 -- TODO: and polar bear
	},
}

mcl_mobs.register_mob("mobs_mc:fox", fox)
-- Spawn
mcl_mobs:spawn_specific(
"mobs_mc:fox",
"overworld",
"ground",
{
	"Taiga",
	"Taiga_beach",
	"MegaTaiga",
	"MegaSpruceTaiga",
	"ColdTaiga",
	"ColdTaiga_beach",
},
0,
minetest.LIGHT_MAX+1,
30,
80,
7,
mobs_mc.water_level+3,
mcl_vars.mg_overworld_max)


mcl_mobs.register_egg("mobs_mc:fox", "Fox", "#ba9f8b", "#9f5219", 0)
