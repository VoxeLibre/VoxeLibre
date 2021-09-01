--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### CHICKEN
--###################



mobs:register_mob("mobs_mc:chicken", {
	description = S("Chicken"),
	type = "animal",
	spawn_class = "passive",

	hp_min = 4,
	hp_max = 4,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.69, 0.2},
	skittish = true,
	fall_slow = true,
	floats = 1,
	visual = "mesh",
	mesh = "mobs_mc_chicken.b3d",
	textures = {
		{"mobs_mc_chicken.png"},
	},
	visual_size = {x=2.2, y=2.2},
	rotate = 270,
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 3,
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

	follow = "mcl_farming:wheat_seeds",
	breed_distance = 1.5,
	baby_size = 0.5,
	follow_distance = 2,
	view_range = 16,
	fear_height = 4,

	--why do chickend breed if they lay eggs??
	on_rightclick = function(self, clicker)
		--attempt to enter breed state
		if mobs.enter_breed_state(self,clicker) then
			return
		end

		--make baby grow faster
		if self.baby then
			mobs.make_baby_grow_faster(self,clicker)
			return
		end
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

	--head code
	has_head = true,
	head_bone = "head",

	swap_y_with_x = false,
	reverse_head_yaw = false,

	head_bone_pos_y = 1.675,
	head_bone_pos_z = 0,

	head_height_offset = 0.55,
	head_direction_offset = 0.0925,

	head_pitch_modifier = -math.pi/2,
	--end head code
})

--spawn
mobs:spawn_specific(
"mobs_mc:chicken",
"overworld",
"ground",
{
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
	"JungleM_shore",
	"Jungle_shore",
	"MesaPlateauFM_sandlevel",
	"MesaPlateauF_sandlevel",
	"MesaBryce_sandlevel",
	"Mesa_sandlevel",
	"Mesa",
	"FlowerForest",
	"Swampland",
	"Taiga",
	"ExtremeHills",
	"Jungle",
	"Savanna",
	"BirchForest",
	"MegaSpruceTaiga",
	"MegaTaiga",
	"ExtremeHills+",
	"Forest",
	"Plains",
	"Desert",
	"ColdTaiga",
	"IcePlainsSpikes",
	"SunflowerPlains",
	"IcePlains",
	"RoofedForest",
	"ExtremeHills+_snowtop",
	"MesaPlateauFM_grasstop",
	"JungleEdgeM",
	"ExtremeHillsM",
	"JungleM",
	"BirchForestM",
	"MesaPlateauF",
	"MesaPlateauFM",
	"MesaPlateauF_grasstop",
	"MesaBryce",
	"JungleEdge",
	"SavannaM",
},
9,
minetest.LIGHT_MAX+1,
30, 17000,
3,
mobs_mc.spawn_height.water,
mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:chicken", S("Chicken"), "mobs_mc_spawn_icon_chicken.png", 0)
