--MCmobs v0.2
--maikerumine

local S = minetest.get_translator("mobs_mc")

--###################
--################### WITCH
--###################

local UP = vector.new(0, 1, 0)
local wand_rotation = vector.new(0, 0, 45)
local potion_rotation = vector.new(90, 45, 90)
local part_spawn_range = { min = -.2, max = .2 }

local witch_potions = {
	{ "mcl_potions:slowness_splash", 2 },
	{ "mcl_potions:poison_splash", 1 },
	{ "mcl_potions:weakness_splash", 5 },
	{ "mcl_potions:harming_splash", 2 },
}
local witch_total_weights = 0
for _, p in ipairs(witch_potions) do -- calculate cumulative weight (CDF)
	witch_total_weights = witch_total_weights + p[2]
	p[3] = witch_total_weights
end

mcl_mobs.register_mob("mobs_mc:witch", {
	description = S("Witch"),
	type = "monster",
	spawn_class = "hostile",
	can_despawn = false,
	initial_properties = {
		hp_min = 26,
		hp_max = 26,
		collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	},
	xp_min = 5,
	xp_max = 5,
	head_eye_height = 1.5,
	visual = "mesh",
	mesh = "vl_witch.b3d",
	textures = {
		{"vl_witch.png"},
	},
	visual_size = {x=2.2, y=2.2},
	makes_footstep_sound = true,
	damage = 2,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	pathfinding = 1,
	group_attack = true,
	attack_type = "dogshoot",
	arrow = "mcl_potions:harming_splash_flying",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max = 1,
	shooter_avoid_enemy = true,
	avoid_distance = 8,
	shoot_arrow = function(self, pos, dir)
		if self.anim_locked then return end
		local target_pos
		if self.attack and self.attack:get_pos() then
			target_pos = self.attack:get_pos()
			target_pos.y = target_pos.y + 1
		else
			-- Attack in the direction we're facing
			target_pos = vector.add(pos, vector.multiply(dir, 10))
		end

		local pos = self.object:get_pos()

		if not pos or not target_pos then return end

		if math.random() > 0.8 then -- cast hex
			self:set_animation("cast")
			self.anim_locked = true
			core.after(0.3, function()
				core.add_particlespawner({
					amount = 32,
					time = 0.3,
					size = 3,
					attached = self._wand,
					pos = part_spawn_range,
					glow = 5,
					texture = {
						name = "mcl_particles_instant_effect.png^[colorize:#AF00FF",
						scale_tween = { 0.2, 1 },
						blend = "clip"
					},
					exptime = 2,
					attract = {
						kind = "point",
						strength = 2,
						origin = UP,
						origin_attached = self.attack,
					},
				})
				core.sound_play("vl_witch_attack", {
					gain = 0.6,
					pos = self.object:get_pos(),
					max_hear_distance = 64
				}, true)
			end)
			core.after(0.6, function(s)
				if not s or not s.attack then return end
				s.anim_locked = false
				local sp = s.object:get_pos()
				local ap = s.attack:get_pos()
				if not sp or not ap then return end
				s.attack:punch(s.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = { fleshy = 1 }
				}, vector.direction(sp, ap))
				mcl_util.deal_damage(s.attack, 4, {type = "magic"})
			end, self)
		else -- throw a potion
			local potion_item
			local pick = math.random()*witch_total_weights
			for _, p in ipairs(witch_potions) do
				if pick < p[3] then
					potion_item = p[1]
					break
				end
			end
			-- TODO levels?, usecases

			-- Throw from witch's hand area
			local throw_pos = vector.offset(pos + 0.4*vector.normalize(vector.cross(vector.direction(pos, target_pos), UP)), 0, .2, 0)

			-- Calculate direction to target with arc compensation
			local dir = vector.direction(throw_pos, target_pos)
			local dist = vector.distance(throw_pos, target_pos)

			-- Add upward arc for the throw
			local arc_factor = math.min(dist / 20, 0.5)
			dir.y = dir.y + arc_factor
			dir = vector.normalize(dir)

			self:set_animation("throw")
			self.anim_locked = true
			core.after(0.2, function(pi, o, tp, d)
				mcl_potions.throw_splash(pi, o, tp, d, 10)
			end, potion_item, self.object, throw_pos, dir)
			core.after(0.4, function(s)
				s.anim_locked = false
			end, self)
		end
	end,
	do_custom = function(self, dtime)
		if self.heal_cd then
			self.heal_cd = self.heal_cd - dtime
			if self.heal_cd <= 0 then self.heal_cd = nil end
		end
		if self.health < self.initial_properties.hp_max/2 and not self.heal_cd and not self.anim_locked then
			local potion = vl_held_item.create_item_entity(self.object:get_pos(), "mcl_potions:healing")
			if potion then
				potion:set_properties({ static_save = false, visual_size={x=0.1, y=0.1} })
				potion:set_attach(self.object, "Wield_L", UP, potion_rotation)
				self:set_animation("drink")
				self.anim_locked = true
				core.after(0.6, function()
					self.anim_locked = false
					self.health = self.health + 4
					if self.health > self.initial_properties.hp_max then
						self.health = self.initial_properties.hp_max
					end
					potion:remove()
				end)
				self.heal_cd = 5
			end
		end
	end,
	after_activate = function(self)
		local wand = vl_held_item.create_item_entity(self.object:get_pos(), "mcl_core:stick")
		if wand then
			wand:set_properties({ static_save = false, visual_size={x=0.1, y=0.1} })
			wand:set_attach(self.object, "Wield_R", UP, wand_rotation)
			self._wand = wand
		end
	end,
	max_drops = 3,
	drops = {
		{name = "mcl_potions:glass_bottle", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_nether:glowstone_dust", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_mobitems:gunpowder", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mesecons:redstone", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_mobitems:spider_eye", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_core:sugar", chance = 8, min = 0, max = 2, looting = "common",},
		{name = "mcl_core:stick", chance = 4, min = 0, max = 2, looting = "common",},
	},
	sound = {
		random = "vl_witch_laugh",
		distance = 32
	},
	animation = {
		stand_start = 60,
		stand_end = 70,
		stand_speed = 5,
		walk_start = 10,
		walk_end = 50,
		walk_speed = 80,
		run_start = 10,
		run_end = 50,
		run_speed = 80,
		drink_start = 70,
		drink_end = 90,
		drink_speed = 30,
		drink_loop = false,
		throw_start = 90,
		throw_end = 100,
		throw_speed = 20,
		throw_loop = false,
		cast_start = 100,
		cast_end = 115,
		cast_speed = 30,
		cast_loop = false,
	},
	view_range = 16,
	fear_height = 4,
	deal_damage = function(self, damage, mcl_reason)
		local factor = 1
		if mcl_reason.type == "magic" then factor = 0.15 end
		self.health = self.health - factor*damage
	end,
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:witch",
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
	chance = 100,
	interval = 30,
	aoc = 2,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:witch", S("Witch"), "#340000", "#51a03e")
