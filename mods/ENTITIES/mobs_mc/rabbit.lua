
local S = mobs.intllib


-- Rabbit by ExeterDad

mobs:register_mob("mobs_mc:rabbit", {
	type = "animal",
	passive = true,
	reach = 1,
	hp_min = 3,
	hp_max = 3,
	armor = 100,
	collisionbox = {-0.268, -0.5, -0.268,  0.268, 0.167, 0.268},
	visual = "mesh",
	mesh = "mobs_bunny.b3d",
	drawtype = "front",
	textures = {
		{"mobs_bunny_black.png"},
		{"mobs_bunny_brown.png"},
		{"mobs_bunny_salt.png"},
		{"mobs_bunny_white.png"},
		{"mobs_bunny_gold.png"},
	},
	sounds = {},
	makes_footstep_sound = false,
	walk_velocity = 1,
	run_velocity = 2,
	runaway = true,
	jump = true,
	drops = {
		{name = "mcl_mobitems:rabbit", chance = 1, min = 0, max = 1},
		{name = "mcl_mobitems:rabbit_hide", chance = 1, min = 0, max = 1},
		{name = "mcl_mobitems:rabbit_foot", chance = 10, min = 1, max = 1},
	},
	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 2,
	animation = {
		speed_normal = 15,
		stand_start = 1,
		stand_end = 15,
		walk_start = 16,
		walk_end = 24,
		punch_start = 16,
		punch_end = 24,
	},
	follow = {"mcl_farming:carrot_item", "mcl_farming:carrot_item_gold", "mcl_flowers:dandelion"},
	view_range = 8,
	replace_rate = 10,
	replace_what = {"mcl_farming:carrot_3", "mcl_farming:carrot_2", "mcl_farming:carrot_1"},
	replace_with = "air",
	on_rightclick = function(self, clicker)

		-- feed or tame
		if mobs:feed_tame(self, clicker, 4, true, true) then
			return
		end

	end,
})


local spawn_on = {
	"mcl_core::dirt_with_grass", "mcl_core:sand", "mcl_core:snow", "mcl_core:snowblock", "mcl_core:podzol", "mcl_core:ice"
}

mobs:spawn({
	name = "mobs_mc:rabbit",
	nodes = spawn_on,
	min_light = 10,
	chance = 15000,
	min_height = 0,
	day_toggle = true,
})


mobs:register_egg("mobs_mc:rabbit", "Spawn Rabbit", "spawn_egg_rabbit.png", 0)


mobs:alias_mob("mobs:bunny", "mobs_mc:bunny") -- compatibility

