--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")


--dofile(minetest.get_modpath("mobs").."/api.lua")

--###################
--################### CHICKEN
--###################



mobs:register_mob("mobs_mc:chicken", {
	type = "animal",

	hp_min = 4,
	hp_max = 4,
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
		max = 1,},
		{name = mobs_mc.items.feather,
		chance = 1,
		min = 0,
		max = 2,},
	},
	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	fall_damage = 0,
	fall_speed = -2.25,
	sounds = {
		random = "mobs_chicken",
		death = "Chickenhurt1", -- TODO: replace
		damage = "Chickenhurt1", -- TODO: replace
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

		local pos = self.object:getpos()

		minetest.add_item(pos, mobs_mc.items.egg)

		minetest.sound_play("mobs_mc_chicken_lay_egg", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 16,
		})
	end,	
	
})

--spawn
mobs:spawn_specific("mobs_mc:chicken", mobs_mc.spawn.grassland, {"air"}, 9, minetest.LIGHT_MAX+1, 30, 17000, 3, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:chicken", S("Chicken"), "mobs_mc_spawn_icon_chicken.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC chicken loaded")
end
