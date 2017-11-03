-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--###################
--################### LLAMA
--###################

mobs:register_mob("mobs_mc:llama", {
	type = "animal",
	hp_min = 15,
	hp_max = 30,
	passive = false,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.86, 0.45},
	visual = "mesh",
	mesh = "mobs_mc_llama.b3d",
	textures = { -- 1: chest -- 2: decor (carpet) -- 3: llama base texture
		{"blank.png", "blank.png", "mobs_mc_llama_brown.png"},
		{"blank.png", "blank.png", "mobs_mc_llama_creamy.png"},
		{"blank.png", "blank.png", "mobs_mc_llama_gray.png"},
		{"blank.png", "blank.png", "mobs_mc_llama_white.png"},
		{"blank.png", "blank.png", "mobs_mc_llama.png"},
		-- TODO: Implement carpet (aka decor) on llama
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	runaway = true,
	walk_velocity = 1,
	run_velocity = 4.4,
	floats = 1,
	drops = {
		{name = mobs_mc.items.leather,
		chance = 1,
		min = 0,
		max = 2,},
	},
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	sounds = {
		random = "mobs_mc_llama",
		-- TODO: Death and damage sounds
		distance = 16,
	},
	animation = {
		speed_normal = 24,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 40,
		hurt_start = 118,
		hurt_end = 154,
		death_start = 154,
		death_end = 179,
		eat_start = 49,
		eat_end = 78,
		look_start = 78,
		look_end = 108,
	},
	follow = mobs_mc.items.horse,
	view_range = 16,
	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 4
			self.max_speed_reverse = 2
			self.accel = 4
			self.terrain_type = 3
			self.driver_attach_at = {x = 0, y = 7.5, z = -1.5}
			self.driver_eye_offset = {x = 0, y = 3, z = 0}
			self.driver_scale = {x = 1/self.visual_size.x, y = 1/self.visual_size.y}
		end

		-- if driver present allow control of llama
		if self.driver then

			mobs.drive(self, "walk", "stand", false, dtime)

			return false -- skip rest of mob functions
		end

		return true
	end,

	on_die = function(self, pos)

		-- detach from llama properly
		if self.driver then
			mobs.detach(self.driver, {x = 1, y = 0, z = 1})
		end

	end,

	on_rightclick = function(self, clicker)

		-- Make sure player is clicking
		if not clicker or not clicker:is_player() then
			return
		end

		local item = clicker:get_wielded_item()
		if item:get_name() == mobs_mc.items.hay_bale then
			-- Breed with hay bale
			if mobs:feed_tame(self, clicker, 1, true, false) then return end
		else
			-- Feed with anything else
			if mobs:feed_tame(self, clicker, 1, false, true) then return end
		end
		if mobs:protect(self, clicker) then return end

		-- Make sure tamed llama is mature and being clicked by owner only
		if self.tamed and not self.child and self.owner == clicker:get_player_name() then

			local inv = clicker:get_inventory()

			-- detatch player already riding llama
			if self.driver and clicker == self.driver then

				mobs.detach(clicker, {x = 1, y = 0, z = 1})

			-- attach player to llama
			elseif not self.driver then

				self.object:set_properties({stepheight = 1.1})
				mobs.attach(self, clicker)
			end

		-- Used to capture llama
		elseif not self.driver and clicker:get_wielded_item():get_name() ~= "" then
			mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
		end
	end

})

--spawn
mobs:spawn_specific("mobs_mc:llama", mobs_mc.spawn.savanna, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 15000, 5, mobs_mc.spawn_height.water+15, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:llama", S("Llama"), "mobs_mc_spawn_icon_llama.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Llama loaded")
end
