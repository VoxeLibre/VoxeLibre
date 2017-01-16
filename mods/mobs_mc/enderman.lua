--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")


mobs:register_mob("mobs_mc:enderman", {
	type = "monster",
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
		{name = "mcl_ender_pearl:ender_pearl",
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
	replace_what = {"default:torch","default:sand","default:desert_sand","default:cobble","default:dirt","default:dirt_with_glass","default:dirt_with_dry_grass","default:wood","default:stone","default:sandstone"},
	replace_with = "air",
	replace_offset = -1,

})
mobs:register_spawn("mobs_mc:enderman", { "default:sand", "default:desert_sand"}, 5, -1, 5000, 4, 31000)




-- spawn eggs
mobs:register_egg("mobs_mc:enderman", "Spawn Enderman", "spawn_egg_overlay.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Enderman loaded")
end
