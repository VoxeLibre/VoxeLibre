--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")


--###################
--################### ZOMBIE
--###################


local zombie = {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	armor = 90,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie.b3d",
	textures = {
		{"mobs_mc_zombie.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	sounds = {
		random = "zombie1",
		death = "zombiedeath",
		damage = "zombiehurt1",
		distance = 16,
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 3,
	fear_height = 4,
	pathfinding = 1,
	jump = true,
	--jump_height = 3,
	group_attack = true,
	drops = {
		{name = mobs_mc.items.rotten_flesh,
		chance = 1,
		min = 0,
		max = 2,},
		{name = mobs_mc.items.iron_ingot,
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},
		{name = mobs_mc.items.carrot,
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},
		{name = mobs_mc.items.potato,
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},

		-- Head
		-- TODO: Only drop if killed by charged creeper
		{name = mobs_mc.items.head_zombie,
		chance = 200, -- 0.5%
		min = 1,
		max = 1,},
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 40,		stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	lava_damage = 4,
	-- TODO: Burn mob only when in direct sunlight
	light_damage = 2,
	view_range = 16,
	attack_type = "dogfight",
}

mobs:register_mob("mobs_mc:zombie", zombie)

-- Baby zombie.
-- A smaller and more dangerous variant of the zombie

local baby_zombie = table.copy(zombie)
baby_zombie.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.94, 0.25}
baby_zombie.visual_size = {x=0.75, y=0.75}
baby_zombie.walk_velocity = 1.2
baby_zombie.run_velocity = 2.4
baby_zombie.light_damage = 0

mobs:register_mob("mobs_mc:baby_zombie", baby_zombie)

-- Husk.
-- Desert variant of the zombie
local husk = table.copy(zombie)
husk.textures = {{"mobs_mc_husk.png"}}
husk.light_damage = 0
husk.water_damage = 3
-- TODO: Husks avoid water

mobs:register_mob("mobs_mc:husk", husk)

-- Baby husk.
-- A smaller and more dangerous variant of the husk
local baby_husk = table.copy(husk)
baby_husk.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.94, 0.25}
baby_husk.visual_size = {x=0.75, y=0.75}
baby_husk.walk_velocity = 1.2
baby_husk.run_velocity = 2.4

mobs:register_mob("mobs_mc:baby_husk", baby_husk)


-- Spawning

mobs:register_spawn("mobs_mc:zombie", mobs_mc.spawn.solid, 7, 0, 4000, 4, 31000)
-- Baby zombie is 20 times less likely than regular zombies
mobs:register_spawn("mobs_mc:baby_zombie", mobs_mc.spawn.solid, 7, 0, 40000, 4, 31000)
mobs:register_spawn("mobs_mc:husk", mobs_mc.spawn.desert, 7, 0, 4900, 4, 31000)
mobs:register_spawn("mobs_mc:baby_husk", mobs_mc.spawn.desert, 7, 0, 49000, 4, 31000)


-- Compatibility
mobs:alias_mob("mobs:zombie", "mobs_mc:zombie")

-- Spawn eggs
mobs:register_egg("mobs_mc:husk", S("Husk"), "mobs_mc_spawn_icon_husk.png", 0)
mobs:register_egg("mobs_mc:zombie", S("Zombie"), "mobs_mc_spawn_icon_zombie.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Zombie loaded")
end
