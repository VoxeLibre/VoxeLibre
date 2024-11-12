local S = minetest.get_translator("mobs_mc")

-- Model: pixelzone https://codeberg.org/mineclonia/mineclonia/issues/2118
-- Texture: Pixel Perfection CC-BY-SA https://github.com/NovaWostra/Pixel-Perfection-Chorus-Eddit/issues/8
-- Sounds:
-- mobs_mc_fox_bark.1.ogg derived from CC-0 https://freesound.org/people/craigsays/sounds/537587/
-- mobs_mc_fox_bark.2.ogg derived from CC-0 https://freesound.org/people/craigsays/sounds/537587/
-- mobs_mc_fox_hurt.1.ogg derived from CC-0 https://freesound.org/people/Soundburst/sounds/634005/
-- mobs_mc_fox_growl.1.ogg derived from CC-0 https://freesound.org/people/tilano408/sounds/445658/

-- TODO: carry one item, spawn with item
-- TODO: add sleeping behavior
-- TODO: pouncing - jump to attack behavior
-- TODO: use totem of undying when carried

-- Fox
local fox = {
	description = S("Fox"),
	type = "animal",
	spawn_class = "passive",
	can_despawn = true,
	hp_min = 10,
	hp_max = 10,
	xp_min = 1,
	xp_max = 3,
	passive = false,
	group_attack = false,
	spawn_in_group = 4,
	collisionbox = { -0.3, 0, -0.3, 0.3, 0.7, 0.3 },
	visual = "mesh",
	mesh = "mobs_mc_fox.b3d",
	textures = {
		{ "mobs_mc_fox.png" },
	},
	makes_footstep_sound = true,
	head_swivel = "Bone.001",
	head_yaw = "z",
	head_eye_height = 0.3,
	head_bone_position = vector.new( 0, 0.5, 0 ), -- for minetest <5.8
	curiosity = 5,
	sounds = {
		attack = "mobs_mc_fox_bark",
		war_cry = "mobs_mc_fox_growl",
		damage = "mobs_mc_fox_hurt",
		death = {name = "mobs_mc_wolf_death", gain=0.6},
		eat = "mobs_mc_animal_eat_generic",
		distance = 12,
	},
	pathfinding = 1,
	floats = 1,
	view_range = 16,
	walk_chance = 50,
	walk_velocity = 2,
	run_velocity = 3,
	damage = 2,
	reach = 1,
	attack_type = "dogfight",
	fear_height = 5,
	-- drops = { }, -- TODO: only what they are carrying
	follow = { "mcl_farming:sweet_berry" }, -- TODO: and glow berries, taming
	on_rightclick = function(self, clicker)
		if self:feed_tame(clicker, 1, true, true) then return end
		if mcl_mobs:protect(self, clicker) then return end
	end,
	on_breed = function(parent1, parent2)
		local p = math.random(1,2) == 1 and parent1 or parent2
		local pos = parent1.object:get_pos()
		if not pos then return false end
		local child = mcl_mobs.spawn_child(pos, p.name)
		if not child then return false end
		local ent_c = child:get_luaentity()
		ent_c.tamed = true
		ent_c.owner = parent1.owner
		return false
	end,
	animation = {
		stand_start = 1, stand_end = 20, stand_speed = 20,
		walk_start = 120, walk_end = 160, walk_speed = 80,
		run_start = 160, run_end = 199, run_speed = 80,
		punch_start = 80, punch_end = 105, punch_speed = 80,
		sit_start = 30 , sit_end = 50,
		sleep_start = 55, sleep_end = 75,
		--wiggle_start = 170, wiggle_end = 230,
		--die_start = 0, die_end = 0, die_speed = 0,--die_loop = 0,
	},
	jump = true,
	jump_height = 1.3, -- TODO: when attacking, allow to jump higher
	attacks_monsters = true,
	attack_animals = true,
	specific_attack = {
		"mobs_mc:chicken", "mobs_mc:rabbit",
		"mobs_mc:cod", "mobs_mc:salmon", "mobs_mc:tropical_fish"
		 -- TODO: baby turtles, monsters?
	},
	runaway_from = {
		-- they are too cute for this: "player",
		"mobs_mc:wolf",
		 -- TODO: and polar bear
	},
}

-- note: breeding code uses the convention that fox and fox_snow can breed
local fox_snow = table.copy(fox)
fox_snow.textures = { { "mobs_mc_snow_fox.png", "mobs_mc_snow_fox_sleep.png" } },

mcl_mobs.register_mob("mobs_mc:fox", fox)
mcl_mobs.register_mob("mobs_mc:fox_snow", fox_snow)
-- Spawn
mcl_mobs:spawn_specific(
"mobs_mc:fox",
"overworld",
"ground",
{
	"Taiga",
	"Taiga_beach",
	"MegaTaiga",
	"MegaSpruceTaiga",
},
0,
minetest.LIGHT_MAX+1,
30,
80,
7,
mobs_mc.water_level+3,
mcl_vars.mg_overworld_max)
-- Spawn
mcl_mobs:spawn_specific(
"mobs_mc:fox_snow",
"overworld",
"ground",
{
	"ColdTaiga",
	"ColdTaiga_beach",
},
0,
minetest.LIGHT_MAX+1,
30,
80,
7,
mobs_mc.water_level+3,
mcl_vars.mg_overworld_max)

mcl_mobs.register_egg("mobs_mc:fox", "Fox", "#ba9f8b", "#9f5219", 0)
