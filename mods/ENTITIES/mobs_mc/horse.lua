--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### HORSE
--###################

-- Return overlay texture for horse/donkey/mule, e.g. chest, saddle or horse armor
local horse_extra_texture = function(horse)
	local base = horse._naked_texture
	local saddle = horse._saddle
	local chest  = horse._chest
	local armor = horse._horse_armor
	local textures = {}
	if armor and minetest.get_item_group(armor, "horse_armor") > 0 then
		textures[2] = base .. "^" .. minetest.registered_items[armor]._horse_overlay_image
	else
		textures[2] = base
	end
	if saddle then
		textures[3] = base
	else
		textures[3] = "blank.png"
	end
	if chest then
		textures[1] = base
	else
		textures[1] = "blank.png"
	end
	return textures
end

-- Helper functions to determine equipment rules
local can_equip_horse_armor = function(entity_id)
	return entity_id == "mobs_mc:horse" or entity_id == "mobs_mc:skeleton_horse" or entity_id == "mobs_mc:zombie_horse"
end
local can_equip_chest = function(entity_id)
	return entity_id == "mobs_mc:mule" or entity_id == "mobs_mc:donkey"
end
local can_breed = function(entity_id)
	return entity_id == "mobs_mc:horse" or "mobs_mc:mule" or entity_id == "mobs_mc:donkey"
end

--[[ Generate all possible horse textures.
Horse textures are a combination of a base texture and an optional marking overlay. ]]
-- The base horse textures (fur) (fur)
local horse_base = {
	"mobs_mc_horse_brown.png",
	"mobs_mc_horse_darkbrown.png",
	"mobs_mc_horse_white.png",
	"mobs_mc_horse_gray.png",
	"mobs_mc_horse_black.png",
	"mobs_mc_horse_chestnut.png",
	"mobs_mc_horse_creamy.png",
}
-- Horse marking texture overlay, to be appended to the base texture string
local horse_markings = {
	"", -- no markings
	"mobs_mc_horse_markings_whitedots.png", -- snowflake appaloosa
	"mobs_mc_horse_markings_blackdots.png", -- sooty
	"mobs_mc_horse_markings_whitefield.png", -- paint
	"mobs_mc_horse_markings_white.png", -- stockings and blaze
}

local horse_textures = {}
for b=1, #horse_base do
	for m=1, #horse_markings do
		local fur = horse_base[b]
		if horse_markings[m] ~= "" then
			fur = fur .. "^" .. horse_markings[m]
		end
		table.insert(horse_textures, {
			"blank.png", -- chest
			fur, -- base texture + markings and optional armor
			"blank.png", -- saddle
		})
	end
end

-- Horse
local horse = {
	type = "animal",
	spawn_class = "passive",
	visual = "mesh",
	mesh = "mobs_mc_horse.b3d",
	visual_size = {x=3.0, y=3.0},
	collisionbox = {-0.69825, -0.01, -0.69825, 0.69825, 1.59, 0.69825},
	animation = {
		stand_speed = 25,
		stand_start = 0,
		stand_end = 0,
		walk_speed = 25,
		walk_start = 0,
		walk_end = 40,
		run_speed = 60,
		run_start = 0,
		run_end = 40,
	},
	textures = horse_textures,
	sounds = {
		random = "mobs_mc_horse_random",
		-- TODO: Separate damage sound
		damage = "mobs_mc_horse_death",
		death = "mobs_mc_horse_death",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	fear_height = 4,
	fly = false,
	walk_chance = 60,
	view_range = 16,
	follow = mobs_mc.follow.horse,
	passive = true,
	hp_min = 15,
	hp_max = 30,
	xp_min = 1,
	xp_max = 3,
	floats = 1,
	makes_footstep_sound = true,
	jump = true,
	jump_height = 5.75, -- can clear 2.5 blocks
	drops = {
		{name = mobs_mc.items.leather,
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
	},

	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self._regentimer then
			self._regentimer = 0
		end
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 7
			self.max_speed_reverse = 2
			self.accel = 6
			self.terrain_type = 3
			self.driver_attach_at = {x = 0, y = 4.17, z = -1.75}
			self.driver_eye_offset = {x = 0, y = 3, z = 0}
			self.driver_scale = {x = 1/self.visual_size.x, y = 1/self.visual_size.y}
		end

		-- Slowly regenerate health
		self._regentimer = self._regentimer + dtime
		if self._regentimer >= 4 then
			if self.health < self.hp_max then
				self.health = self.health + 1
			end
			self._regentimer = 0
		end

		-- Some weird human is riding. Buck them off?
		if self.driver and not self.tamed and self.buck_off_time <= 0 then
			if math.random() < 0.2 then
				mobs.detach(self.driver, {x = 1, y = 0, z = 1})
				-- TODO bucking animation
			else
				-- Nah, can't be bothered. Think about it again in one second
				self.buck_off_time = 20
			end
		end

		-- Tick the timer for trying to buck the player off
		if self.buck_off_time then
			if self.driver then
				self.buck_off_time = self.buck_off_time - 1
			else
				-- Player isn't riding anymore so no need to count
				self.buck_off_time = nil
			end
		end

		-- if driver present and horse has a saddle allow control of horse
		if self.driver and self._saddle then

			mobs.drive(self, "walk", "stand", false, dtime)

			return false -- skip rest of mob functions
		end

		return true
	end,

	on_die = function(self, pos)

		-- drop saddle when horse is killed while riding
		if self._saddle then
			minetest.add_item(pos, mobs_mc.items.saddle)
		end
		-- also detach from horse properly
		if self.driver then
			mobs.detach(self.driver, {x = 1, y = 0, z = 1})
		end

	end,

	on_rightclick = function(self, clicker)

		-- make sure player is clicking
		if not clicker or not clicker:is_player() then
			return
		end

		local item = clicker:get_wielded_item()
		local iname = item:get_name()
		local heal = 0

		-- Taming
		self.temper = self.temper or (math.random(1,100))

		if not self.tamed then
			local temper_increase = 0

			-- Feeding, intentionally not using mobs:feed_tame because horse taming is
			-- different and more complicated
			if (iname == mobs_mc.items.sugar) then
				temper_increase = 3
			elseif (iname == mobs_mc.items.wheat) then
				temper_increase = 3
			elseif (iname == mobs_mc.items.apple) then
				temper_increase = 3
			elseif (iname == mobs_mc.items.golden_carrot) then
				temper_increase = 5
			elseif (iname == mobs_mc.items.golden_apple) then
				temper_increase = 10
			-- Trying to ride
			elseif not self.driver then
				self.object:set_properties({stepheight = 1.1})
				mobs.attach(self, clicker)
				self.buck_off_time = 40 -- TODO how long does it take in minecraft?
				if self.temper > 100 then
					self.tamed = true -- NOTE taming can only be finished by riding the horse
					if not self.owner or self.owner == "" then
						self.owner = clicker:get_player_name()
					end
				end
				temper_increase = 5

			-- Clicking on the horse while riding ==> unmount
			elseif self.driver and self.driver == clicker then
				mobs.detach(clicker, {x = 1, y = 0, z = 1})
			end

			-- If nothing happened temper_increase = 0 and addition does nothing
			self.temper = self.temper + temper_increase

			return
		end

		if can_breed(self.name) then
			-- Breed horse with golden apple or golden carrot
			if (iname == mobs_mc.items.golden_apple) then
				heal = 10
			elseif (iname == mobs_mc.items.golden_carrot) then
				heal = 4
			end
			if heal > 0 and mobs:feed_tame(self, clicker, heal, true, false) then
				return
			end
		end
		-- Feed with anything else
		-- TODO heal amounts don't work
		if (iname == mobs_mc.items.sugar) then
			heal = 1
		elseif (iname == mobs_mc.items.wheat) then
			heal = 2
		elseif (iname == mobs_mc.items.apple) then
			heal = 3
		elseif (iname == mobs_mc.items.hay_bale) then
			heal = 20
		end
		if heal > 0 and mobs:feed_tame(self, clicker, heal, false, false) then
			return
		end

		-- Make sure tamed horse is mature and being clicked by owner only
		if self.tamed and not self.child and self.owner == clicker:get_player_name() then

			local inv = clicker:get_inventory()

			-- detatch player already riding horse
			if self.driver and clicker == self.driver then

				mobs.detach(clicker, {x = 1, y = 0, z = 1})

			-- Put on saddle if tamed
			elseif not self.driver and not self._saddle
			and iname == mobs_mc.items.saddle then

				-- Put on saddle and take saddle from player's inventory
				local w = clicker:get_wielded_item()
				self._saddle = true
				if not minetest.is_creative_enabled(clicker:get_player_name()) then
					w:take_item()
					clicker:set_wielded_item(w)
				end

				-- Update texture
				if not self._naked_texture then
					-- Base horse texture without chest or saddle
					self._naked_texture = self.base_texture[2]
				end
				local tex = horse_extra_texture(self)
				self.base_texture = tex
				self.object:set_properties({textures = self.base_texture})
				minetest.sound_play({name = "mcl_armor_equip_leather"}, {gain=0.5, max_hear_distance=12, pos=self.object:get_pos()}, true)

			-- Put on horse armor if tamed
			elseif can_equip_horse_armor(self.name) and not self.driver and not self._horse_armor
			and minetest.get_item_group(iname, "horse_armor") > 0 then


				-- Put on armor and take armor from player's inventory
				local armor = minetest.get_item_group(iname, "horse_armor")
				self._horse_armor = iname
				local w = clicker:get_wielded_item()
				if not minetest.is_creative_enabled(clicker:get_player_name()) then
					w:take_item()
					clicker:set_wielded_item(w)
				end

				-- Set horse armor strength
				self.armor = armor
				local agroups = self.object:get_armor_groups()
				agroups.fleshy = self.armor
				self.object:set_armor_groups(agroups)

				-- Update texture
				if not self._naked_texture then
					-- Base horse texture without chest or saddle
					self._naked_texture = self.base_texture[2]
				end
				local tex = horse_extra_texture(self)
				self.base_texture = tex
				self.object:set_properties({textures = self.base_texture})
				local def = w:get_definition()
				if def.sounds and def.sounds._mcl_armor_equip then
					minetest.sound_play({name = def.sounds._mcl_armor_equip}, {gain=0.5, max_hear_distance=12, pos=self.object:get_pos()}, true)
				end

			-- Mount horse
			elseif not self.driver and self._saddle then

				self.object:set_properties({stepheight = 1.1})
				mobs.attach(self, clicker)

			end
		end
	end,

	on_breed = function(parent1, parent2)
		local pos = parent1.object:get_pos()
		local child = mobs:spawn_child(pos, parent1.name)
		if child then
			local ent_c = child:get_luaentity()
			local p = math.random(1, 2)
			local child_texture
			-- Randomly pick one of the parents for the child texture
			if p == 1 then
				if parent1._naked_texture then
					child_texture = parent1._naked_texture
				else
					child_texture = parent1.base_texture[2]
				end
			else
				if parent2._naked_texture then
					child_texture = parent2._naked_texture
				else
					child_texture = parent2.base_texture[2]
				end
			end
			local splt = string.split(child_texture, "^")
			if #splt >= 2 then
				-- Randomly mutate base texture (fur) and markings
				-- with chance of 1/9 each
				local base = splt[1]
				local markings = splt[2]
				local mutate_base = math.random(1, 9)
				local mutate_markings = math.random(1, 9)
				if mutate_base == 1 then
					local b = math.random(1, #horse_base)
					base = horse_base[b]
				end
				if mutate_markings == 1 then
					local m = math.random(1, #horse_markings)
					markings = horse_markings[m]
				end
				child_texture = base
				if markings ~= "" then
					child_texture = child_texture .. "^" .. markings
				end
			end
			ent_c.base_texture = { "blank.png", child_texture, "blank.png" }
			ent_c._naked_texture = child_texture

			child:set_properties({textures = ent_c.base_texture})
			return false
		end
	end,
}

mobs:register_mob("mobs_mc:horse", horse)

-- Skeleton horse
local skeleton_horse = table.copy(horse)
skeleton_horse.breath_max = -1
skeleton_horse.armor = {undead = 100, fleshy = 100}
skeleton_horse.textures = {{"blank.png", "mobs_mc_horse_skeleton.png", "blank.png"}}
skeleton_horse.drops = {
	{name = mobs_mc.items.bone,
	chance = 1,
	min = 0,
	max = 2,},
}
skeleton_horse.sounds = {
	random = "mobs_mc_skeleton_random",
	death = "mobs_mc_skeleton_death",
	damage = "mobs_mc_skeleton_hurt",
	eat = "mobs_mc_animal_eat_generic",
	base_pitch = 0.95,
	distance = 16,
}
skeleton_horse.harmed_by_heal = true
mobs:register_mob("mobs_mc:skeleton_horse", skeleton_horse)

-- Zombie horse
local zombie_horse = table.copy(horse)
zombie_horse.breath_max = -1
zombie_horse.armor = {undead = 100, fleshy = 100}
zombie_horse.textures = {{"blank.png", "mobs_mc_horse_zombie.png", "blank.png"}}
zombie_horse.drops = {
	{name = mobs_mc.items.rotten_flesh,
	chance = 1,
	min = 0,
	max = 2,},
}
zombie_horse.sounds = {
	random = "mobs_mc_horse_random",
	-- TODO: Separate damage sound
	damage = "mobs_mc_horse_death",
	death = "mobs_mc_horse_death",
	eat = "mobs_mc_animal_eat_generic",
	base_pitch = 0.5,
	distance = 16,
}
zombie_horse.harmed_by_heal = true
mobs:register_mob("mobs_mc:zombie_horse", zombie_horse)

-- Donkey
local d = 0.86 -- donkey scale
local donkey = table.copy(horse)
donkey.textures = {{"blank.png", "mobs_mc_donkey.png", "blank.png"}}
donkey.animation = {
	speed_normal = 25,
	stand_start = 0, stand_end = 0,
	walk_start = 0, walk_end = 40,
}
donkey.sounds = {
	random = "mobs_mc_donkey_random",
	damage = "mobs_mc_donkey_hurt",
	death = "mobs_mc_donkey_death",
	eat = "mobs_mc_animal_eat_generic",
	distance = 16,
}
donkey.visual_size = { x=horse.visual_size.x*d, y=horse.visual_size.y*d }
donkey.collisionbox = {
	horse.collisionbox[1] * d,
	horse.collisionbox[2] * d,
	horse.collisionbox[3] * d,
	horse.collisionbox[4] * d,
	horse.collisionbox[5] * d,
	horse.collisionbox[6] * d,
}
donkey.jump = true
donkey.jump_height = 3.75 -- can clear 1 block height

mobs:register_mob("mobs_mc:donkey", donkey)

-- Mule
local m = 0.94
local mule = table.copy(donkey)
mule.textures = {{"blank.png", "mobs_mc_mule.png", "blank.png"}}
mule.visual_size = { x=horse.visual_size.x*m, y=horse.visual_size.y*m }
mule.sounds = table.copy(donkey.sounds)
mule.sounds.base_pitch = 1.15
mule.collisionbox = {
	horse.collisionbox[1] * m,
	horse.collisionbox[2] * m,
	horse.collisionbox[3] * m,
	horse.collisionbox[4] * m,
	horse.collisionbox[5] * m,
	horse.collisionbox[6] * m,
}
mobs:register_mob("mobs_mc:mule", mule)

--===========================
--Spawn Function
mobs:spawn_specific(
"mobs_mc:horse",
"overworld",
"ground",
{
"FlowerForest",
"Swampland",
"Taiga",
"ExtremeHills",
"BirchForest",
"MegaSpruceTaiga",
"MegaTaiga",
"ExtremeHills+",
"Forest",
"Plains",
"ColdTaiga",
"SunflowerPlains",
"RoofedForest",
"MesaPlateauFM_grasstop",
"ExtremeHillsM",
"BirchForestM",
},
0, 
minetest.LIGHT_MAX+1, 
30, 
15000, 
4, 
mobs_mc.spawn_height.water+3, 
mobs_mc.spawn_height.overworld_max)


mobs:spawn_specific(
"mobs_mc:donkey", 
"overworld", 
"ground",
{
"Mesa",
"MesaPlateauFM_grasstop",
"MesaPlateauF",
"MesaPlateauFM",
"MesaPlateauF_grasstop",
"MesaBryce",
},
0, 
minetest.LIGHT_MAX+1, 
30, 
15000, 
4, 
mobs_mc.spawn_height.water+3, 
mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:horse", S("Horse"), "mobs_mc_spawn_icon_horse.png", 0)
mobs:register_egg("mobs_mc:skeleton_horse", S("Skeleton Horse"), "mobs_mc_spawn_icon_horse_skeleton.png", 0)
--mobs:register_egg("mobs_mc:zombie_horse", S("Zombie Horse"), "mobs_mc_spawn_icon_horse_zombie.png", 0)
mobs:register_egg("mobs_mc:donkey", S("Donkey"), "mobs_mc_spawn_icon_donkey.png", 0)
mobs:register_egg("mobs_mc:mule", S("Mule"), "mobs_mc_spawn_icon_mule.png", 0)
