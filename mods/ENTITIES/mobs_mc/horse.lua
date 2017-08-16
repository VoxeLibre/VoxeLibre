--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")

--###################
--################### HORSE
--###################

-- Return overlay texture for horse/donkey/mule, e.g. chest, saddle or horse armor
local horse_extra_texture = function(horse)
	local base = horse._naked_texture
	local saddle = horse._saddle
	local chest  = horse._chest
	local armor = horse._horse_armor
	if armor then
		if minetest.get_item_group(armor, "horse_armor") > 0 then
			base = base .. "^" .. minetest.registered_items[armor]._horse_overlay_image
		end
	end
	if saddle then
		base = base .. "^mobs_mc_horse_saddle.png"
	end
	if chest then
		base = base .. "^mobs_mc_horse_chest.png"
	end
	return base
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
-- The base horse textures
local horse_base = {
	"mobs_mc_horse_brown.png",
	"mobs_mc_horse_darkbrown.png",
	"mobs_mc_horse_white.png",
	"mobs_mc_horse_gray.png",
	"mobs_mc_horse_black.png",
	"mobs_mc_horse_chestnut.png",
}
-- Horse marking texture overlay, to be appended to the base texture string
local horse_markings = {
	"", -- no markings
	"^mobs_mc_horse_markings_whitedots.png", -- snowflake appaloosa
	"^mobs_mc_horse_markings_blackdots.png", -- sooty
	"^mobs_mc_horse_markings_whitefield.png", -- paint
	"^mobs_mc_horse_markings_white.png", -- stockings and blaze
}

local horse_textures = {}
for b=1, #horse_base do
	for m=1, #horse_markings do
		table.insert(horse_textures, { horse_base[b] .. horse_markings[m] })
	end
end

-- Horse
local horse = {
	type = "animal",
	visual = "mesh",
	mesh = "mobs_mc_horse.b3d",
	visual_size = {x=3.0, y=3.0},
	collisionbox = {-0.69825, -0.01, -0.69825, 0.69825, 1.59, 0.69825},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50,
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40,
		run_start = 0, run_end = 40,
	},
	textures = horse_textures,
	fear_height = 4,
	fly = false,
	walk_chance = 60,
	view_range = 16,
	follow = mobs_mc.follow.horse,
	passive = true,
	hp_min = 15,
	hp_max = 30,
	floats = 1,
	lava_damage = 4,
	water_damage = 1,
	makes_footstep_sound = true,
	jump = true,
	jump_height = 5.75, -- can clear 2.5 blocks
	drops = {
		{name = mobs_mc.items.leather,
		chance = 1,
		min = 0,
		max = 2,},
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
			self.driver_attach_at = {x = 0, y = 7.5, z = -1.75}
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

		-- if driver present allow control of horse
		if self.driver then

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
		if can_breed(self.name) and (item:get_name() == mobs_mc.items.golden_apple or item:get_name() == mobs_mc.items.golden_carrot) then
			-- Breed horse with golden apple or golden carrot
			if mobs:feed_tame(self, clicker, 1, true, false) then return end
		end
		-- Feed/tame with anything else
		-- TODO: Different health bonus for feeding
		if mobs:feed_tame(self, clicker, 1, false, true) then return end
		if mobs:protect(self, clicker) then return end

		-- Make sure tamed horse is mature and being clicked by owner only
		if self.tamed and not self.child and self.owner == clicker:get_player_name() then

			local inv = clicker:get_inventory()

			-- detatch player already riding horse
			if self.driver and clicker == self.driver then

				mobs.detach(clicker, {x = 1, y = 0, z = 1})

			-- Put on saddle if tamed
			elseif not self.driver and not self._saddle
			and clicker:get_wielded_item():get_name() == mobs_mc.items.saddle then

				-- Put on saddle and take saddle from player's inventory
				local w = clicker:get_wielded_item()
				self._saddle = true
				if not minetest.settings:get_bool("creative_mode") then
					w:take_item()
					clicker:set_wielded_item(w)
				end

				-- Update texture
				if not self._naked_texture then
					-- Base horse texture without chest or saddle
					self._naked_texture = self.base_texture[1]
				end
				local tex = horse_extra_texture(self)
				self.base_texture = { tex }
				self.object:set_properties({textures = self.base_texture})

			-- Put on horse armor if tamed
			elseif can_equip_horse_armor(self.name) and not self.driver and not self._horse_armor
			and minetest.get_item_group(clicker:get_wielded_item():get_name(), "horse_armor") > 0 then


				-- Put on armor and take armor from player's inventory
				local w = clicker:get_wielded_item()
				local armor = minetest.get_item_group(w:get_name(), "horse_armor")
				self._horse_armor = w:get_name()
				if not minetest.settings:get_bool("creative_mode") then
					w:take_item()
					clicker:set_wielded_item(w)
				end

				-- Set horse armor strength
				--[[ WARNING: This goes deep into the entity data structure and depends on
				how Mobs Redo works internally. This code assumes that Mobs Redo uses
				the fleshy group for armor. ]]
				-- TODO: Change this code as soon Mobs Redo officially allows to change armor afterwards
				self.armor = armor
				local agroups = self.object:get_armor_groups()
				agroups.fleshy = self.armor
				self.object:set_armor_groups(agroups)

				-- Update texture
				if not self._naked_texture then
					-- Base horse texture without chest or saddle
					self._naked_texture = self.base_texture[1]
				end
				local tex = horse_extra_texture(self)
				self.base_texture = { tex }
				self.object:set_properties({textures = self.base_texture})


			-- Mount horse
			elseif not self.driver and self._saddle then

				self.object:set_properties({stepheight = 1.1})
				mobs.attach(self, clicker)

			-- Used to capture horse
			elseif not self.driver and clicker:get_wielded_item():get_name() ~= "" then
				mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
			end
		end
	end
}

mobs:register_mob("mobs_mc:horse", horse)

-- Skeleton horse
local skeleton_horse = table.copy(horse)
skeleton_horse.textures = {{"mobs_mc_horse_skeleton.png"}}
skeleton_horse.drops = {
	{name = mobs_mc.items.bone,
	chance = 1,
	min = 0,
	max = 2,},
}
skeleton_horse.sounds = {
	random = "skeleton1",
	death = "skeletondeath",
	damage = "skeletonhurt1",
	distance = 16,
}
skeleton_horse.blood_amount = 0
mobs:register_mob("mobs_mc:skeleton_horse", skeleton_horse)

-- Zombie horse
local zombie_horse = table.copy(horse)
zombie_horse.textures = {{"mobs_mc_horse_zombie.png"}}
zombie_horse.drops = {
	{name = mobs_mc.items.rotten_flesh,
	chance = 1,
	min = 0,
	max = 2,},
}
zombie_horse.sounds = {
	random = "mobs_mc_zombie_idle",
	war_cry = "mobs_mc_zombie_idle",
	death = "mobs_mc_zombie_death",
	damage = "mobs_mc_zombie_hurt",
	distance = 16,
}
mobs:register_mob("mobs_mc:zombie_horse", zombie_horse)

-- Donkey
local d = 0.86 -- donkey scale
local donkey = table.copy(horse)
donkey.textures = {{"mobs_mc_donkey.png"}}
donkey.animation = {
	speed_normal = 25,
	stand_start = 0, stand_end = 0,
	walk_start = 0, walk_end = 40,
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
mule.textures = {{"mobs_mc_mule.png"}}
mule.visual_size = { x=horse.visual_size.x*m, y=horse.visual_size.y*m }
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
mobs:spawn_specific("mobs_mc:horse", mobs_mc.spawn.grassland_savanna, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 15000, 12, mobs_mc.spawn_height.water+3, mobs_mc.spawn_height.overworld_max)
mobs:spawn_specific("mobs_mc:donkey", mobs_mc.spawn.grassland_savanna, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 15000, 12, mobs_mc.spawn_height.water+3, mobs_mc.spawn_height.overworld_max)

-- compatibility
mobs:alias_mob("mobs:horse", "mobs_mc:horse")

-- spawn eggs
mobs:register_egg("mobs_mc:horse", S("Horse"), "mobs_mc_spawn_icon_horse.png", 0)
mobs:register_egg("mobs_mc:skeleton_horse", S("Skeleton Horse"), "mobs_mc_spawn_icon_horse_skeleton.png", 0)
mobs:register_egg("mobs_mc:zombie_horse", S("Zombie Horse"), "mobs_mc_spawn_icon_horse_zombie.png", 0)
mobs:register_egg("mobs_mc:donkey", S("Donkey"), "mobs_mc_spawn_icon_donkey.png", 0)
mobs:register_egg("mobs_mc:mule", S("Mule"), "mobs_mc_spawn_icon_mule.png", 0)


if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Horse loaded")
end
