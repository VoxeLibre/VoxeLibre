SLIME_SIZE = 1
SLIME_BOX = math.sqrt(2*math.pow(SLIME_SIZE, 2))/2
GRAVITY = 9.8


mobs:register_mob("mobs:slime", {
	type = "monster",
	hp_max = 8,
	--collisionbox = {-0.4, -1.0, -0.4, 0.4, 0.8, 0.4},
	collisionbox = {-SLIME_BOX, -SLIME_SIZE/2, -SLIME_BOX, SLIME_BOX, SLIME_SIZE/2, SLIME_BOX},
	visual = "cube",
	textures = {
			"slime_top.png",
			"slime_bottom.png",
			"slime_front.png",
			"slime_sides.png",
			"slime_sides.png",
			"slime_sides.png",
		},
	--visual_size = {x = 1.1, y = 1.1},
	makes_footstep_sound = true,
	view_range = 20,
	walk_velocity = 0.2,
	randomsound= "slime_random",
	run_velocity = 0.2,
	on_rightclick = nil,
	jump = 1,
	damage = 1,
	drops = {
		{name = "mesecons_materials:glue",
		chance = 1,
		min = 1,
		max = 4,},
	},
	armor = 100,
	drawtype = "front",
	lava_damage = 15,
	light_damage = 0,
	attack_type = "dogfight",
})
