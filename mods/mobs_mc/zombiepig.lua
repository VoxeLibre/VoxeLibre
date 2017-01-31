--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")


mobs:register_mob("mobs_mc:pigman", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.3, -1.0, -0.3, 0.3, 0.8, 0.3},
	visual = "mesh",
	mesh = "3d_armor_character.b3d",
	textures = {{"Original_Zombiepig_Man_by_Fedora_P.png",
			"3d_armor_trans.png",
				minetest.registered_items["mcl_core:sword_gold"].inventory_image,
			}},

	makes_footstep_sound = true,
	walk_velocity = .8,
	run_velocity = 2.6,
	damage = 2,
	armor = 80,
	pathfinding = true,
	group_attack = true,
	drops = {
		{name = "mcl_mobitems:rotten_flesh",
		chance = 1,
		min = 0,
		max = 1,},
		{name = "mcl_core:gold_nugget",
		chance = 1,
		min = 0,
		max = 1,},
		{name = "mcl_core:gold_ingot",
		chance = 40,
		min = 1,
		max = 1,},
		{name = "mcl_core:sword_gold",
		-- approximation to 8.5%
		chance = 11,
		min = 1,
		max = 1,},
	},
		sounds = {
		random = "Pig2",
		death = "Pigdeath",
		damage = "zombiehurt1",
		attack = "default_punch3",
	},
	--[[
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
	]]
	animation = {
		speed_normal = 30,		speed_run = 30,
		stand_start = 0,		stand_end = 79,
		walk_start = 168,		walk_end = 187,
		run_start = 168,		run_end = 187,
		punch_start = 200,		punch_end = 219,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 1,
	fear_height = 3,
	view_range = 16,
	attack_type = "dogfight",
})
mobs:register_spawn("mobs_mc:pigman", {"nether:rack"},  17, -1, 5000, 3, -2000)
mobs:register_spawn("mobs_mc:pigman", {"nether:portal"}, 15, -1, 500, 4, 31000)
mobs:register_spawn("mobs_mc:pigman", {"mcl_core:obsidian"}, 17, -1, 1900, 1, 31000)


-- compatibility
mobs:alias_mob("mobs:pigman", "mobs_mc:pigman")

-- spawn eggs
mobs:register_egg("mobs_mc:pigman", "Spawn Zombie Pigman", "spawn_egg_zombie_pigman.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Pigmen loaded")
end
