--MCmobs v0.4
--maikerumine

local S = minetest.get_translator("mobs_mc")

--###################
--################### VINDICATOR
--###################


mcl_mobs.register_mob("mobs_mc:vindicator", {
	description = S("Vindicator"),
	type = "monster",
	spawn_class = "hostile",
	physical = false,
	pathfinding = 1,
	initial_properties = {
		hp_min = 24,
		hp_max = 24,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	},
	xp_min = 6,
	xp_max = 6,
	visual = "mesh",
	mesh = "mobs_mc_vindicator.b3d",
	head_swivel = "head.control",
	head_eye_height = 1.5,
	head_bone_position = vector.new( 0, 2.2, 0 ), -- for minetest <= 5.8
	curiosity = 10,
	textures = {
		{
			"mobs_mc_vindicator.png",
			"blank.png", --no hat
			"default_tool_steelaxe.png",
			-- TODO: Glow when attacking (mobs_mc_vindicator.png)
		},
	},
	visual_size = {x=2.75, y=2.75},
	makes_footstep_sound = true,
	damage = 13,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	attack_type = "dogfight",
	attack_npcs = true,
	drops = {
		{name = "mcl_core:emerald",
		chance = 1,
		min = 0,
		max = 1,
		looting = "common",},
		{name = "mcl_tools:axe_iron",
		chance = 100 / 8.5,
		min = 1,
		max = 1,
		looting = "rare",},
	},
	-- TODO: sounds
	animation = {
		stand_speed = 25,
		stand_start = 40,
		stand_end = 59,
		walk_speed = 25,
		walk_start = 0,
		walk_end = 40,
		run_speed = 25,
		punch_speed = 25,
		punch_start = 90,
		punch_end = 110,
		die_speed = 15,
		die_start = 170,
		die_end = 180,
		die_loop = false,
	},
	view_range = 16,
	fear_height = 4,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:vindicator", S("Vindicator"), "#959b9b", "#275e61", 0)
mcl_mobs:non_spawn_specific("mobs_mc:vindicator","overworld",0,7)
