--Phantom for mcl2
--cora
--License for code WTFPL, cc0

local S = minetest.get_translator("mobs_mc")

mcl_mobs:register_mob("mobs_mc:phantom", {
	description = S("Phantom"),
	type = "monster",
	spawn_class = "passive",
	pathfinding = 1,
	hp_min = 6,
	hp_max = 6,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_phantom.b3d",
	textures = {{"mobs_mc_phantom.png","mobs_mc_phantom_e.png","mobs_mc_phantom_e_s.png"}},
	visual_size = {x=3, y=3},
	walk_velocity = 3,
	run_velocity = 5,
	desired_altitude = 19,
	keep_flying = true,
	sounds = {
		random = "mobs_mc_phantom_random",
		damage = {name="mobs_mc_phantom_hurt", gain=0.3},
		death = {name="mobs_mc_phantom_death", gain=0.6},
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	drops = {
		{name = "mcl_mobitems:leather", --TODO: phantom membrane
		chance = 1,
		min = 1,
		max = 2,
		looting = "common",},
	},
    	animation = {
		stand_speed = 50,
		walk_speed = 50,
		fly_speed = 50,
		stand_start = 0,
		stand_end = 0,
		fly_start = 0,
		fly_end = 30,
		walk_start = 0,
		walk_end = 30,
	},
	fall_damage = 0,
	fall_speed = -2.25,
	attack_type = "dogfight",
	floats = 1,
	physical = true,
	fly = true,
	makes_footstep_sound = false,
	fear_height = 0,
	view_range = 16,
})

-- spawn eggs
mcl_mobs:register_egg("mobs_mc:phantom", S("Phantom"), "mobs_mc_spawn_icon_phantom.png", 0)
