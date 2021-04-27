--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### ZOMBIE PIGMAN
--###################


local pigman = {
	description = S("Zombie Pigman"),
	-- type="animal", passive=false: This combination is needed for a neutral mob which becomes hostile, if attacked
	type = "animal",
	passive = false,
	neutral = true,
	rotate = 270,
	spawn_class = "passive",
	hostile_cooldown = 15, --seconds
	hp_min = 20,
	hp_max = 20,
	xp_min = 6,
	xp_max = 6,
	armor = {undead = 90, fleshy = 90},
	attack_type = "punch",
	group_attack = { "mobs_mc:pigman", "mobs_mc:baby_pigman" },
	damage = 9,
	reach = 2,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie_pigman.b3d",
	textures = { {
		"blank.png", --baby
		"default_tool_goldsword.png", --sword
		"mobs_mc_zombie_pigman.png", --pigman
	} },
	visual_size = {x=3, y=3},
	sounds = {
		random = "mobs_mc_zombiepig_random",
		war_cry = "mobs_mc_zombiepig_war_cry",
		death = "mobs_mc_zombiepig_death",
		damage = "mobs_mc_zombiepig_hurt",
		distance = 16,
	},

	--head code
	has_head = false,
	head_bone = "head",

	swap_y_with_x = true,
	reverse_head_yaw = true,

	head_bone_pos_y = 2.4,
	head_bone_pos_z = 0,

	head_height_offset = 1.1,
	head_direction_offset = 0,
	head_pitch_modifier = 0,
	--end head code

	jump = true,
	makes_footstep_sound = true,
	walk_velocity = .8,
	run_velocity = 2.6,
	pathfinding = 1,
	drops = {
		{name = mobs_mc.items.rotten_flesh,
		chance = 1,
		min = 1,
		max = 1,
		looting = "common"},
		{name = mobs_mc.items.gold_nugget,
		chance = 1,
		min = 0,
		max = 1,
		looting = "common"},
		{name = mobs_mc.items.gold_ingot,
		chance = 40, -- 2.5%
		min = 1,
		max = 1,
		looting = "rare"},
		{name = mobs_mc.items.gold_sword,
		chance = 100 / 8.5,
		min = 1,
		max = 1,
		looting = "rare"},
	},
	animation = {
		stand_speed = 25,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 40,
		stand_end = 80,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
		punch_start = 90,
		punch_end = 130,
	},
	lava_damage = 0,
	fire_damage = 0,
	fear_height = 4,
	view_range = 16,
	harmed_by_heal = true,
	fire_damage_resistant = true,
}

mobs:register_mob("mobs_mc:pigman", pigman)

-- Baby pigman.
-- A smaller and more dangerous variant of the pigman

local baby_pigman = table.copy(pigman)
baby_pigman.description = S("Baby Zombie Pigman")
baby_pigman.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.94, 0.25}
baby_pigman.xp_min = 13
baby_pigman.xp_max = 13
baby_pigman.visual_size = {x=pigman.visual_size.x/2, y=pigman.visual_size.y/2}
baby_pigman.textures = { {
	"mobs_mc_zombie_pigman.png", --baby
	"default_tool_goldsword.png", --sword
	"mobs_mc_zombie_pigman.png", --pigman
} }
baby_pigman.walk_velocity = 1.2
baby_pigman.run_velocity = 2.4
baby_pigman.light_damage = 0
baby_pigman.child = 1

mobs:register_mob("mobs_mc:baby_pigman", baby_pigman)

-- Regular spawning in the Nether
mobs:spawn_specific(
"mobs_mc:pigman",
"nether",
"ground",
{
"Nether"
},
0,
minetest.LIGHT_MAX+1,
30,
6000,
3,
mobs_mc.spawn_height.nether_min,
mobs_mc.spawn_height.nether_max)
-- Baby zombie is 20 times less likely than regular zombies
mobs:spawn_specific(
"mobs_mc:baby_pigman",
"nether",
"ground",
{
"Nether"
},
0,
minetest.LIGHT_MAX+1,
30,
100000,
4,
mobs_mc.spawn_height.nether_min,
mobs_mc.spawn_height.nether_max)

-- Spawning in Nether portals in the Overworld
--mobs:spawn_specific("mobs_mc:pigman", mobs_mc.spawn.nether_portal, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 500, 4, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:pigman", S("Zombie Pigman"), "mobs_mc_spawn_icon_zombie_pigman.png", 0)
