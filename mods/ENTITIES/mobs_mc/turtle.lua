-- TURTLE
-- cora
local pi = math.pi
local atann = math.atan
local atan = function(x)
	if not x or x ~= x then
		return 0
	else
		return atann(x)
	end
end

local S = minetest.get_translator("mobs_mc")

local turtle = {
	type = "animal",
	passive = false,
	spawn_class = "passive",
	skittish = false,
	runaway = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 2,
	armor = {fleshy = 90},
	attack_type = "dogfight",
	damage = 2,
	reach = 1.5,
	jump = false,
	makes_footstep_sound = true,
	fly = true,
	fly_in = {"mcl_core:water_source","mcl_core:water_flowing"},
	breath_max = -1,
	walk_velocity = 1,
	run_velocity = 2,
	follow_velocity = 2,
	follow = followitem,
	pathfinding = 1,
	fear_height = 4,
	view_range = 16,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_turtle.b3d",
	textures = { {
		"mobs_mc_turtle.png",
	} },
	visual_size = {x=3, y=3},
	rotate = 0,
	sounds = {
	},
	drops = {
	},
	animation = {
		stand_speed = 7,
		walk_speed = 7,
		run_speed = 15,
		stand_start = 11,
		stand_end = 11,
		walk_start = 0,
		walk_end = 10,
		run_start = 0,
		run_end = 10,
		pounce_start = 11,
		pounce_end = 31,
		lay_start = 34,
		lay_end = 34,
	},
}

mcl_mobs:register_mob("mobs_mc:turtle", turtle)

-- spawning
mcl_mobs:spawn_setup({
	name      = "mobs_mc:turtle",
	biomes    = {
		"StoneBeach_ocean",
		"MesaPlateauFM_sandlevel",
		"MesaPlateauF_sandlevel",
		"MesaBryce_sandlevel",
		"Mesa_sandlevel",
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
		"MangroveSwamp_shore",
	},
	interval = 30,
	chance = 6000,
	min_height = 1,
})

-- spawn eggs
mcl_mobs:register_egg("mobs_mc:turtle", S("Turtle"), "#0000FF", "#FFaa99", 0)
