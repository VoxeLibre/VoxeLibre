--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")
local mod_bows = minetest.get_modpath("mcl_bows") ~= nil

--###################
--################### SKELETON
--###################



local skeleton = {
	description = S("Skeleton"),
	type = "monster",
	spawn_class = "hostile",
	initial_properties = {
		hp_min = 20,
		hp_max = 20,
		breath_max = -1,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.98, 0.3},
	},
	xp_min = 6,
	xp_max = 6,
	armor = {undead = 100, fleshy = 100},
	pathfinding = 1,
	group_attack = true,
	head_swivel = "Head_Control",
	head_eye_height = 1.5,
	head_bone_position = vector.new( 0, 2.38, 0 ), -- for minetest <= 5.8
	curiosity = 6,
	visual = "mesh",
	mesh = "mobs_mc_skeleton.b3d",
	shooter_avoid_enemy = true,
	strafes = true,
	textures = { {
		"mcl_bows_bow_0.png", -- bow
		"mobs_mc_skeleton.png", -- skeleton
	} },
	makes_footstep_sound = true,
	walk_velocity = 1,
	textures = {
		{
			"mobs_mc_empty.png", -- armor
			"mobs_mc_skeleton.png", -- texture
			"mcl_bows_bow_0.png", -- wielded_item
		}
	},
	-- TODO: change random to new api when min minetest version is 5.8
	sounds = {
		random = "mobs_mc_skeleton_random",
		death = "mobs_mc_skeleton_death",
		damage = "mobs_mc_skeleton_hurt",
		distance = 16,
	},
	walk_velocity = 1.2,
	run_velocity = 2.0,
	damage = 2,
	reach = 2,
	drops = {
		{name = "mcl_bows:arrow",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
		{name = "mcl_bows:bow",
		chance = 100 / 8.5,
		min = 1,
		max = 1,
		looting = "rare",},
		{name = "mcl_mobitems:bone",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
		{name = "mcl_heads:skeleton",
		chance = 200, -- 0.5% chance
		min = 1,
		max = 1,
		conditions = {
			guarantee_if_killed_by = { "mobs_mc:stalker_overloaded" }
		}},
	},
	animation = {
		stand_speed = 15,
		stand_start = 0,
		stand_end = 40,
		walk_speed = 15,
		walk_start = 40,
		walk_end = 60,
		run_speed = 30,
		shoot_start = 70,
		shoot_end = 90,
		jockey_start = 172,
		jockey_end = 172,
		die_start = 160,
		die_end = 170,
		die_speed = 60,
		die_loop = false,
	},
	on_spawn = function(self)
		if math.random(100) == 1 then
			self:jock_to("mobs_mc:spider", vector.zero(), vector.zero())
		end
		return true
	end,
	ignited_by_sunlight = true,
	floats = 0,
	view_range = 16,
	fear_height = 4,
	attack_type = "dogshoot",
	arrow = "mcl_bows:arrow_entity",
	shoot_arrow = function(self, pos, dir)
		if mod_bows then
			if self.attack then
				self.object:set_yaw(minetest.dir_to_yaw(vector.direction(self.object:get_pos(), self.attack:get_pos())))
			end
			local dmg = math.random(2, 4)
			local arrow = self.arrow:match("^(.+)_entity$")
			local obj = mcl_bows.shoot_arrow(arrow, pos, dir, self.object:get_yaw(), self.object, nil, dmg)
			if obj then
				local ent = obj:get_luaentity()
				if ent then
					ent._plus = -2
				end
			end
		end
	end,
	shoot_interval = 2,
	shoot_offset = 1.5,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
	harmed_by_heal = true,
}

mcl_mobs.register_mob("mobs_mc:skeleton", skeleton)


--###################
--################### STRAY
--###################

local stray = table.copy(skeleton)
stray.description = S("Stray")
stray.mesh = "mobs_mc_skeleton.b3d"
stray.textures = {
	{
		"mobs_mc_stray_overlay.png",
		"mobs_mc_stray.png",
		"mcl_bows_bow_0.png",
	},
}
stray.arrow = "mcl_potions:frost_arrow_entity"
-- TODO: different sound (w/ echo)
table.insert(stray.drops, {
	name = "mcl_potions:frost_arrow",
	chance = 2,
	min = 1,
	max = 1,
	looting = "rare",
	looting_chance_function = function(lvl)
		local chance = 0.5
		for i = 1, lvl do
			if chance > 1 then
				return 1 -- TODO verify this logic, I think this is not how chance works
			end
			chance = chance + (1 - chance) / 2
		end
		return chance
	end,
})
table.insert(stray.drops, {
	name = "mcl_mobitems:shiny_ice_crystal",
	chance = 3,
	min = 1,
	max = 2,
	looting = "rare",
})

mcl_mobs.register_mob("mobs_mc:stray", stray)

-- Overworld spawn
mcl_mobs:spawn_setup({
	name = "mobs_mc:skeleton",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
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
		"RoofedForest_ocean",
		"JungleEdgeM_ocean",
		"BirchForestM_ocean",
		"BirchForest_ocean",
		"IcePlains_deep_ocean",
		"Jungle_deep_ocean",
		"Savanna_ocean",
		"MesaPlateauF_ocean",
		"ExtremeHillsM_deep_ocean",
		"Savanna_deep_ocean",
		"SunflowerPlains_ocean",
		"Swampland_deep_ocean",
		"Swampland_ocean",
		"MegaSpruceTaiga_deep_ocean",
		"ExtremeHillsM_ocean",
		"JungleEdgeM_deep_ocean",
		"SunflowerPlains_deep_ocean",
		"BirchForest_deep_ocean",
		"IcePlainsSpikes_ocean",
		"Mesa_ocean",
		"StoneBeach_ocean",
		"Plains_deep_ocean",
		"JungleEdge_deep_ocean",
		"SavannaM_deep_ocean",
		"Desert_deep_ocean",
		"Mesa_deep_ocean",
		"ColdTaiga_deep_ocean",
		"Plains_ocean",
		"MesaPlateauFM_ocean",
		"Forest_deep_ocean",
		"JungleM_deep_ocean",
		"FlowerForest_deep_ocean",
		"MegaTaiga_ocean",
		"StoneBeach_deep_ocean",
		"IcePlainsSpikes_deep_ocean",
		"ColdTaiga_ocean",
		"SavannaM_ocean",
		"MesaPlateauF_deep_ocean",
		"MesaBryce_deep_ocean",
		"ExtremeHills+_deep_ocean",
		"ExtremeHills_ocean",
		"Forest_ocean",
		"MegaTaiga_deep_ocean",
		"JungleEdge_ocean",
		"MesaBryce_ocean",
		"MegaSpruceTaiga_ocean",
		"ExtremeHills+_ocean",
		"Jungle_ocean",
		"RoofedForest_deep_ocean",
		"IcePlains_ocean",
		"FlowerForest_ocean",
		"ExtremeHills_deep_ocean",
		"MesaPlateauFM_deep_ocean",
		"Desert_ocean",
		"Taiga_ocean",
		"BirchForestM_deep_ocean",
		"Taiga_deep_ocean",
		"JungleM_ocean",
		"FlowerForest_underground",
		"JungleEdge_underground",
		"StoneBeach_underground",
		"MesaBryce_underground",
		"Mesa_underground",
		"RoofedForest_underground",
		"Jungle_underground",
		"Swampland_underground",
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
	},
	min_light = 0,
	max_light = 7,
	chance = 800,
	interval = 20,
	aoc = 2,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max
})

-- Nether spawn
mcl_mobs:spawn_setup({
	name = "mobs_mc:skeleton",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = {
		"SoulsandValley",
	},
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 800,
	interval = 30,
	aoc = 3,
	min_height = mcl_vars.mg_nether_min,
	max_height = mcl_vars.mg_nether_max
})

-- Stray spawn
-- TODO: Spawn directly under the sky
mcl_mobs:spawn_setup({
	name = "mobs_mc:stray",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"ColdTaiga",
		"IcePlainsSpikes",
		"IcePlains",
		"ExtremeHills+_snowtop",
	},
	min_light = 0,
	max_light = 7,
	chance = 1200,
	interval = 20,
	aoc = 2,
	min_height = mobs_mc.water_level,
	max_height = mcl_vars.mg_overworld_max
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:skeleton", S("Skeleton"), "#c1c1c1", "#494949", 0)

mcl_mobs.register_egg("mobs_mc:stray", S("Stray"), "#5f7476", "#dae8e7", 0)
