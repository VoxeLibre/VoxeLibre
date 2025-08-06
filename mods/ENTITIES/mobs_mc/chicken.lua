local S = minetest.get_translator("mobs_mc")

---
---@param self any
---@param dtime number
local function lay_egg(self, dtime)
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

	core.add_item(pos, "mcl_throwing:egg")

	core.sound_play("mobs_mc_chicken_lay_egg", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 16,
	}, true)
end

---
---@param self any
local function flap(self)
	local v = self.object:get_velocity()
	if v and (v.y < -0.01 or v.y > 0.01) then
		self:set_animation("flap")
	end
end

mcl_mobs.register_mob("mobs_mc:chicken", {
	description = S("Chicken"),
	type = "animal",
	spawn_class = "passive",
	passive = true,
	runaway = true,
	initial_properties = {
		hp_min = 4,
		hp_max = 4,
		collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.69, 0.2},
	},
	xp_min = 1,
	xp_max = 3,
	floats = 1,
	head_swivel = "head.control",
	head_eye_height = 0.5,
	head_bone_position = vector.new(0, 3.72, -.472), -- for minetest <= 5.8
	curiosity = 10,
	head_yaw="z",
	visual_size = {x=1,y=1},
	visual = "mesh",
	mesh = "mobs_mc_chicken.b3d",
	textures = {
		{"mobs_mc_chicken.png"},
	},

	makes_footstep_sound = true,
	walk_velocity = 1,
	drops = {
		{name = "mcl_mobitems:chicken",
		chance = 1,
		min = 1,
		max = 1,
		looting = "common",},
		{name = "mcl_mobitems:feather",
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
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 20, walk_speed = 25,
		run_start = 0, run_end = 20, run_speed = 50,
		flap_start = 20, flap_end = 26,
	},
	child_animations = {
		stand_start = 31, stand_end = 31,
		walk_start = 31, walk_end = 51, walk_speed = 37,
		run_start = 31, run_end = 51, run_speed = 75,
		flap_start = 51, flap_end = 57,
	},
	follow = {
		"mcl_farming:wheat_seeds",
		"mcl_farming:melon_seeds",
		"mcl_farming:pumpkin_seeds",
		"mcl_farming:beetroot_seeds",
	},
	view_range = 16,
	fear_height = 4,

	on_rightclick = function(self, clicker)
		if self:feed_tame(clicker, 1, true, false) then return end
		if mcl_mobs:protect(self, clicker) then return end
		if mcl_mobs:capture_mob(self, clicker, 0, 60, 5, false, nil) then return end
	end,

	do_custom = function(self, dtime)
		lay_egg(self, dtime)
		flap(self)
	end,
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:chicken",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"flat",
		"IcePlainsSpikes",
		"ColdTaiga",
		"ColdTaiga_beach",
		"ColdTaiga_beach_water",
		"MegaTaiga",
		"MegaSpruceTaiga",
		"ExtremeHills",
		"ExtremeHills_beach",
		"ExtremeHillsM",
		"ExtremeHills+",
		"Plains",
		"Plains_beach",
		"SunflowerPlains",
		"Taiga",
		"Taiga_beach",
		"Forest",
		"Forest_beach",
		"FlowerForest",
		"FlowerForest_beach",
		"BirchForest",
		"BirchForestM",
		"RoofedForest",
		"Savanna",
		"Savanna_beach",
		"SavannaM",
		"Jungle",
		"Jungle_shore",
		"JungleM",
		"JungleM_shore",
		"JungleEdge",
		"JungleEdgeM",
		"Swampland",
		"Swampland_shore"
	},
	min_light = 9,
	max_light = minetest.LIGHT_MAX + 1,
	chance = 100,
	interval = 30,
	aoc = 3,
	min_height = mobs_mc.water_level,
	max_height = mcl_vars.mg_overworld_max
})

mcl_mobs.register_egg("mobs_mc:chicken", S("Chicken"), "#ddc3a8", "#ff0000", 0)
