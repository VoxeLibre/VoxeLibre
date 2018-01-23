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

local drops_common = {
	{name = mobs_mc.items.rotten_flesh,
	chance = 1,
	min = 0,
	max = 2,},
	{name = mobs_mc.items.iron_ingot,
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,},
	{name = mobs_mc.items.carrot,
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,},
	{name = mobs_mc.items.potato,
	chance = 120, -- 2.5% / 3
	min = 1,
	max = 1,},
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
		random = "mobs_mc_zombie_idle",
		war_cry = "mobs_mc_zombie_idle",
		death = "mobs_mc_zombie_death",
		damage = "mobs_mc_zombie_hurt",
		distance = 16,
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 3,
	reach = 2,
	fear_height = 4,
	pathfinding = 1,
	jump = true,
	--jump_height = 3,
	group_attack = true,
	drops = drops_zombie,
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
baby_zombie.visual_size = {x=zombie.visual_size.x/2, y=zombie.visual_size.y/2}
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
husk.drops = drops_common
-- TODO: Husks avoid water

mobs:register_mob("mobs_mc:husk", husk)

-- Baby husk.
-- A smaller and more dangerous variant of the husk
local baby_husk = table.copy(husk)
baby_husk.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.94, 0.25}
baby_husk.visual_size = {x=zombie.visual_size.x/2, y=zombie.visual_size.y/2}
baby_husk.walk_velocity = 1.2
baby_husk.run_velocity = 2.4

mobs:register_mob("mobs_mc:baby_husk", baby_husk)


-- Spawning

mobs:spawn_specific("mobs_mc:zombie", mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 6000, 4, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)
-- Baby zombie is 20 times less likely than regular zombies
mobs:spawn_specific("mobs_mc:baby_zombie", mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 60000, 4, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)
mobs:spawn_specific("mobs_mc:husk", mobs_mc.spawn.desert, {"air"}, 0, 7, 30, 6500, 4, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)
mobs:spawn_specific("mobs_mc:baby_husk", mobs_mc.spawn.desert, {"air"}, 0, 7, 30, 65000, 4, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- Compatibility
mobs:alias_mob("mobs:zombie", "mobs_mc:zombie")

-- Spawn eggs
mobs:register_egg("mobs_mc:husk", S("Husk"), "mobs_mc_spawn_icon_husk.png", 0)
mobs:register_egg("mobs_mc:zombie", S("Zombie"), "mobs_mc_spawn_icon_zombie.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Zombie loaded")
end
