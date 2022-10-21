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

local panda = {
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
	walk_velocity = 1,
	run_velocity = 2,
	follow_velocity = 2,
	follow = followitem,
	pathfinding = 1,
	fear_height = 4,
	view_range = 16,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 0.84, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_panda.b3d",
	textures = { {
		"mobs_mc_panda.png",
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

mcl_mobs:register_mob("mobs_mc:panda", panda)

-- spawning
mcl_mobs:spawn_setup({
	name      = "mobs_mc:panda",
	biomes    = {
		"Jungle",
	},
	interval = 30,
	chance = 6000,
	min_height = 1,
})

-- spawn eggs
mcl_mobs:register_egg("mobs_mc:panda", S("Panda"), "#FFFFFF", "#000000", 0)
