--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### CHICKEN
--###################



mobs:register_mob("mobs_mc:chicken", {
	type = "animal",
	spawn_class = "passive",

	hp_min = 4,
	hp_max = 4,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.69, 0.2},
	runaway = true,
	floats = 1,
	visual = "mesh",
	mesh = "mobs_mc_chicken.b3d",
	textures = {
		{"mobs_mc_chicken.png"},
	},
	visual_size = {x=2.2, y=2.2},

	makes_footstep_sound = true,
	walk_velocity = 1,
	drops = {
		{name = mobs_mc.items.chicken_raw,
		chance = 1,
		min = 1,
		max = 1,
		looting = "common",},
		{name = mobs_mc.items.feather,
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
	},
	fall_damage = 0,
	fall_speed = -2.25,
	sounds = {
		random = "mobs_mc_chicken_buck",
		damage = "mobs_mc_chicken_hurt",
		death = "mobs_mc_chicken_hurt",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	sounds_child = {
		random = "mobs_mc_chicken_child",
		damage = "mobs_mc_chicken_child",
		death = "mobs_mc_chicken_child",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},

	follow = mobs_mc.follow.chicken,
	view_range = 16,
	fear_height = 4,

	on_rightclick = function(self, clicker)
		if mobs:feed_tame(self, clicker, 1, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 60, 5, false, nil) then return end
	end,

	do_custom = function(self, dtime)

		self.egg_timer = (self.egg_timer or 0) + dtime
		if self.egg_timer < 10 then
			return
		end
		self.egg_timer = 0

		if self.child
		or math.random(1, 100) > 1 then
			return
		end

		local pos = self.object:get_pos()

		minetest.add_item(pos, mobs_mc.items.egg)

		minetest.sound_play("mobs_mc_chicken_lay_egg", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 16,
		}, true)
	end,	
	
})

--spawn
mobs:spawn_specific("mobs_mc:chicken", "overworld", "ground", 9, minetest.LIGHT_MAX+1, 30, 17000, 3, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:chicken", S("Chicken"), "mobs_mc_spawn_icon_chicken.png", 0)
