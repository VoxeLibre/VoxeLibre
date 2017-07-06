--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")
--###################
--################### ZOMBIE PIGMAN
--###################


local pigman = {
	-- type="animal", passive=false: This combination is needed for a neutral mob which becomes hostile, if attacked
	type = "animal",
	passive = false,
	hp_min = 20,
	hp_max = 20,
	armor = 90,
	attack_type = "dogfight",
	group_attack = true,
	damage = 9,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_zombie_pigman.b3d",
	textures = {{"mobs_mc_zombie_pigman.png^mobs_mc_zombie_pigman_sword.png"}},
	visual_size = {x=3, y=3},
	sounds = {
		random = "zombie1", -- TODO: replace
		death = "zombiedeath", -- TODO: replace
		damage = "zombiehurt1", -- TODO: replace
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = .8,
	run_velocity = 2.6,
	pathfinding = 1,
	drops = {
		{name = mobs_mc.items.rotten_flesh,
		chance = 1,
		min = 1,
		max = 1,},
		{name = mobs_mc.items.gold_nugget,
		chance = 1,
		min = 0,
		max = 1,},
		{name = mobs_mc.items.gold_ingot,
		chance = 40, -- 2.5%
		min = 1,
		max = 1,},
		{name = mobs_mc.items.gold_sword,
		chance = 12, -- 8.333%, approximation to 8.5%
		min = 1,
		max = 1,},
	},
	animation = {
		stnd_speed = 25, walk_speed = 25, run_speed = 50, punch_speed = 25,
		stand_start = 40, stand_end = 80,
		walk_start = 0,	walk_end = 40,
		run_start = 0, run_end = 40,
		punch_start = 90, punch_end = 130,
	},
	water_damage = 1,
	lava_damage = 0,
	light_damage = 0,
	fear_height = 4,
	view_range = 16,
}

mobs:register_mob("mobs_mc:pigman", pigman)

-- Baby pigman.
-- A smaller and more dangerous variant of the pigman

local baby_pigman = table.copy(pigman)
baby_pigman.collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.94, 0.25}
baby_pigman.visual_size = {x=0.5, y=0.5}
baby_pigman.textures = {{"mobs_mc_zombie_pigman.png"}}
baby_pigman.walk_velocity = 1.2
baby_pigman.run_velocity = 2.4
baby_pigman.light_damage = 0

mobs:register_mob("mobs_mc:baby_pigman", baby_pigman)

-- Baby zombie is 20 times less likely than regular zombies
mobs:register_spawn("mobs_mc:baby_pigman", mobs_mc.spawn.nether, minetest.LIGHT_MAX+1, 0, 100000, 4, 31000)

--mobs:register_spawn("mobs_mc:pigman", {"nether:rack"},  17, -1, 5000, 3, -2000)
mobs:register_spawn("mobs_mc:pigman", mobs_mc.spawn.nether, minetest.LIGHT_MAX+1, 0, 6000, 3, -2000)
mobs:register_spawn("mobs_mc:pigman", mobs_mc.spawn.nether_portal, minetest.LIGHT_MAX+1, 0, 500, 4, 31000)
mobs:spawn_specific("mobs_mc:pigman", mobs_mc.spawn.nether_portal, {"air", "mcl_portals:nether_air"},0, minetest.LIGHT_MAX+1, 7, 9000, 2, -31000, 31000)

-- compatibility
mobs:alias_mob("mobs:pigman", "mobs_mc:pigman")

-- spawn eggs
mobs:register_egg("mobs_mc:pigman", S("Zombie Pigman"), "mobs_mc_spawn_icon_zombie_pigman.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Pigmen loaded")
end
