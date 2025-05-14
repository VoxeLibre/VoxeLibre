--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
assert(overworld_bounds)

local function spawn_check(pos, environmental_light, artificial_light, sky_light)
	local date = os.date("*t")
	local maxlight
	if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
		maxlight = 6
	else
		maxlight = 3
	end

	return artificial_light <= maxlight
end

mcl_mobs.register_mob("mobs_mc:bat", {
	description = S("Bat"),
	type = "animal",
	spawn_class = "ambient",
	can_despawn = true,
	spawn_in_group = 8,
	passive = true,
	initial_properties = {
		hp_min = 6,
		hp_max = 6,
		collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	},
	visual = "mesh",
	mesh = "mobs_mc_bat.b3d",
	textures = {
		{"mobs_mc_bat.png"},
	},
	visual_size = {x=1, y=1},
	sounds = {
		random = "mobs_mc_bat_idle",
		damage = "mobs_mc_bat_hurt",
		death = "mobs_mc_bat_death",
		distance = 16,
	},
	walk_velocity = 4.5,
	run_velocity = 6.0,
	-- TODO: Hang upside down
	animation = {
		stand_speed = 80,
		stand_start = 0,
		stand_end = 40,
		walk_speed = 80,
		walk_start = 0,
		walk_end = 40,
		run_speed = 80,
		run_start = 0,
		run_end = 40,
		die_speed = 60,
		die_start = 40,
		die_end = 80,
		die_loop = false,
	},
	walk_chance = 100,
	fall_damage = 0,
	view_range = 16,
	fear_height = 0,

	jump = false,
	fly = true,
	makes_footstep_sound = false,
	spawn_check = spawn_check,
})


-- Spawning

--[[ If the game has been launched between the 20th of October and the 3rd of November system time,
-- the maximum spawn light level is increased. ]]
local date = os.date("*t")
local maxlight
if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
	maxlight = 6
else
	maxlight = 3
end

-- Spawn on solid blocks at or below Sea level and the selected light level
mcl_mobs:spawn_setup({
	name = "mobs_mc:bat",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"FlowerForest_underground",
		"JungleEdge_underground",
		"StoneBeach_underground",
		"MesaBryce_underground",
		"Mesa_underground",
		"RoofedForest_underground",
		"Jungle_underground",
		"Swampland_underground",
		"MushroomIsland_underground",
		"BirchForest_underground",
		"Plains_underground",
		"MesaPlateauF_underground",
		"ExtremeHills_underground",
		"MegaSpruceTaiga_underground",
		"BirchForestM_underground",
		"SavannaM_underground",
		"MesaPlateauFM_underground",
		"Desert_underground",
		"Savanna_underground",
		"Forest_underground",
		"SunflowerPlains_underground",
		"ColdTaiga_underground",
		"IcePlains_underground",
		"IcePlainsSpikes_underground",
		"MegaTaiga_underground",
		"Taiga_underground",
		"ExtremeHills+_underground",
		"JungleM_underground",
		"ExtremeHillsM_underground",
		"JungleEdgeM_underground",
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
		"MushroomIsland",
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
	min_light = 0,
	max_light = maxlight,
	chance = 100,
	interval = 20,
	aoc = 2,
	min_height = overworld_bounds.min,
	max_height = mobs_mc.water_level - 1,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:bat", S("Bat"), "#4c3e30", "#0f0f0f", 0)
