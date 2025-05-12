--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
assert(overworld_bounds)

--###################
--################### ZOMBIE VILLAGER
--###################

local professions = {
	farmer = "mobs_mc_villager_farmer.png",
	fisherman = "mobs_mc_villager_farmer.png",
	fletcher = "mobs_mc_villager_farmer.png",
	shepherd = "mobs_mc_villager_farmer.png",
	librarian = "mobs_mc_villager_librarian.png",
	cartographer = "mobs_mc_villager_librarian.png",
	armorer = "mobs_mc_villager_smith.png",
	leatherworker = "mobs_mc_villager_butcher.png",
	butcher = "mobs_mc_villager_butcher.png",
	weapon_smith = "mobs_mc_villager_smith.png",
	tool_smith = "mobs_mc_villager_smith.png",
	cleric = "mobs_mc_villager_priest.png",
	nitwit = "mobs_mc_villager.png",
}

mcl_mobs.register_mob("mobs_mc:villager_zombie", {
	description = S("Zombie Villager"),
	type = "monster",
	spawn_class = "hostile",
	spawn_in_group = 1,
	initial_properties = {
		hp_min = 20,
		hp_max = 20,
		breath_max = -1,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	},
	xp_min = 5,
	xp_max = 5,
	armor = {undead = 90, fleshy = 90},
	visual = "mesh",
	mesh = "mobs_mc_villager_zombie.b3d",
	head_swivel = "Head_Control",
	head_bone_position = vector.new( 0, 2.35, 0 ), -- for minetest <= 5.8
	head_eye_height = 1.5,
	curiosity = 2,
	textures = {
		{"mobs_mc_zombie_butcher.png"},
		{"mobs_mc_zombie_farmer.png"},
		{"mobs_mc_zombie_librarian.png"},
		{"mobs_mc_zombie_priest.png"},
		{"mobs_mc_zombie_smith.png"},
		{"mobs_mc_zombie_villager.png"},
	},
	visual_size = {x=2.75, y=2.75},
	makes_footstep_sound = true,
	damage = 3,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 1.8,
	attack_type = "dogfight",
	group_attack = true,
	drops = {
		{name = "mcl_mobitems:rotten_flesh",
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
		{name = "mcl_core:iron_ingot",
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,},
		{name = "mcl_farming:carrot_item",
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,},
		{name = "mcl_farming:potato_item",
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,},
	},
	sounds = {
		random = "mobs_mc_zombie_growl",
		war_cry = "mobs_mc_zombie_growl",
		death = "mobs_mc_zombie_death",
		damage = "mobs_mc_zombie_hurt",
		distance = 16,
	},
	animation = {
		speed_normal = 25,
        speed_run = 50,
		stand_start = 20,
        stand_end = 40,
		walk_start = 0,
        walk_end = 20,
		run_start = 0,
        run_end = 20,
	},
	on_rightclick = function(self, clicker)
		if not self._curing and clicker and clicker:is_player() then
			local wielditem = clicker:get_wielded_item()
			-- ToDo: Only cure if zombie villager has the weakness effect
			if wielditem:get_name() == "mcl_core:apple_gold" then
				wielditem:take_item()
				clicker:set_wielded_item(wielditem)
				self._curing = math.random(3 * 60, 5 * 60)
				self.shaking = true
				self.persistent = true
			end
		end
	end,
	do_custom = function(self, dtime)
		if self._curing then
			self._curing = self._curing - dtime
			local obj = self.object
			if self._curing <= 0 then
				local villager_obj = minetest.add_entity(obj:get_pos(), "mobs_mc:villager")
				local villager = villager_obj:get_luaentity()
				local yaw = obj:get_yaw()
				villager_obj:set_yaw(yaw)
				villager.target_yaw = yaw
				villager.nametag = self.nametag
				villager._profession = "unemployed"
				self._curing = nil
				mcl_burning.extinguish(obj)
				obj:remove()
				return false
			end
		end
	end,
	sunlight_damage = 2,
	ignited_by_sunlight = true,
	floats = 0,
	view_range = 16,
	fear_height = 4,
	harmed_by_heal = true,
	attack_npcs = true,
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:villager_zombie",
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
		"BambooJungle",
		"BambooJungleM",
		"BambooJungleEdge",
		"BambooJungleEdgeM",
		"BambooJungle_underground",
		"BambooJungleM_underground",
		"BambooJungleEdge_underground",
		"BambooJungleEdgeM_underground",
		"BambooJungle_ocean",
		"BambooJungleM_ocean",
		"BambooJungleEdge_ocean",
		"BambooJungleEdgeM_ocean",
		"BambooJungle_deep_ocean",
		"BambooJungleM_deep_ocean",
		"BambooJungleEdge_deep_ocean",
		"BambooJungleEdgeM_deep_ocean",
		"BambooJungle_shore",
		"BambooJungleM_shore",
		"BambooJungleEdge_shore",
		"BambooJungleEdgeM_shore",
	},
	min_light = 0,
	max_light = 7,
	chance = 50,
	interval = 30,
	aoc = 4,
	min_height = overworld_bounds.min,
	max_height = overworld_bounds.max,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:villager_zombie", S("Zombie Villager"), "#563d33", "#799c66", 0)
