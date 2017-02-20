--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")


mobs:register_mob("mobs_mc:enderman", {
	type = "monster",
	hp_min = 40,
	hp_max = 40,
	collisionbox = {-0.4, -2.4, -0.4, 0.4, 1.8, 0.4},
	
	visual = "mesh",
	mesh = "mobs_sand_monster.b3d",
	textures = {
	{"mobs_endermen.png"}
	},
	visual_size = {x=1.2, y=2.5},
	makes_footstep_sound = true,
	sounds = {
		random = "mobs_sandmonster",
		death = "green_slime_death",
		damage = "Creeperdeath",
	},
	walk_velocity = 3.2,
	run_velocity = 5.4,
	damage = 1,
	armor = 100,
	drops = {
		{name = "mcl_throwing:ender_pearl",
		chance = 1,
		min = 0,
		max = 1,},
	},
	animation = {
		speed_normal = 45,
		speed_run = 15,
		stand_start = 0,
		stand_end = 39,
		walk_start = 41,
		walk_end = 72,
		run_start = 74,
		run_end = 105,
		punch_start = 74,
		punch_end = 105,
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	replace_rate = 1,
	replace_what = {"mcl_flowers:allium", "mcl_flowers:azure_bluet", "mcl_flowers:blue_orchid", "mcl_flowers:dandelion", "mcl_flowers:tulip_orange", "mcl_flowers:tulip_red", "mcl_flowers:tulip_pink", "mcl_flowers:tulip_white", "mcl_flowers:oxeye_daisy", "mcl_flowers:poppy", "mcl_core:cactus", "mcl_core:clay", "mcl_core:coarse_dirt", "mcl_core:dirt", "mcl_core:dirt_with_grass", "mcl_core:gravel", "mcl_farming:melon", "mcl_farming:pumpkin_face", "mcl_core:mycelium", "mcl_core:podzol", "mcl_farming:mushroom_red", "mcl_farming:mushroom_brown", "mcl_core:redsand", "mcl_core:sand", "mcl_tnt:tnt", "mcl_nether:netherrack"},
	replace_with = "air",
	replace_offset = -1,

})
mobs:register_spawn("mobs_mc:enderman", { "group:solid"}, 7, -1, 5000, 4, 31000)




-- spawn eggs
mobs:register_egg("mobs_mc:enderman", "Spawn Enderman", "spawn_egg_enderman.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Enderman loaded")
end
