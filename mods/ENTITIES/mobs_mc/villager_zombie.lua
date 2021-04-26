--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

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

mobs:register_mob("mobs_mc:villager_zombie", {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	breath_max = -1,
	armor = {undead = 90, fleshy = 90},
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_villager_zombie.b3d",
	textures = {
		{"mobs_mc_empty.png", "mobs_mc_zombie_butcher.png", "mobs_mc_empty.png"},
		{"mobs_mc_empty.png", "mobs_mc_zombie_farmer.png", "mobs_mc_empty.png"},
		{"mobs_mc_empty.png", "mobs_mc_zombie_librarian.png", "mobs_mc_empty.png"},
		{"mobs_mc_empty.png", "mobs_mc_zombie_priest.png", "mobs_mc_empty.png"},
		{"mobs_mc_empty.png", "mobs_mc_zombie_smith.png", "mobs_mc_empty.png"},
		{"mobs_mc_empty.png", "mobs_mc_zombie_villager.png", "mobs_mc_empty.png"},
	},
	visual_size = {x=2.75, y=2.75},
	makes_footstep_sound = true,
	damage = 3,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	attack_type = "dogfight",
	group_attack = true,
	drops = {
		{name = mobs_mc.items.rotten_flesh,
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
		{name = mobs_mc.items.iron_ingot,
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,},
		{name = mobs_mc.items.carrot,
		chance = 120, -- 2.5% / 3
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.01 / 3,},
		{name = mobs_mc.items.potato,
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
				local texture = self.base_texture[1]:gsub("zombie", "villager")
				if texture == "mobs_mc_villager_villager.png" then
					texture = "mobs_mc_villager.png"
				end
				local textures = {texture}
				villager.base_texture = textures
				villager_obj:set_properties({textures = textures})
				local matches = {}
				for prof, tex in pairs(professions) do
					if texture == tex then
						table.insert(matches, prof)
					end
				end
				villager._profession = matches[math.random(#matches)]
				self._curing = nil
				mcl_burning.extinguish(obj)
				obj:remove()
				return false
			end
		end
	end,
	sunlight_damage = 2,
	ignited_by_sunlight = true,
	view_range = 16,
	fear_height = 4,
	harmed_by_heal = true,
})

mobs:spawn_specific(
"mobs_mc:villager_zombie",
"overworld",
"ground",
{
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
"MushroomIslandShore",
"JungleM_shore",
"Jungle_shore",
"MesaPlateauFM_sandlevel",
"MesaPlateauF_sandlevel",
"MesaBryce_sandlevel",
"Mesa_sandlevel",
},
0,
7,
30,
4090,
4,
mobs_mc.spawn_height.overworld_min,
mobs_mc.spawn_height.overworld_max)
--mobs:spawn_specific("mobs_mc:villager_zombie", "overworld", "ground", 0, 7, 30, 60000, 4, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:villager_zombie", S("Zombie Villager"), "mobs_mc_spawn_icon_zombie_villager.png", 0)
