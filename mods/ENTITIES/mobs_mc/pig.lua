--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

mobs:register_mob("mobs_mc:pig", {
	type = "animal",
	runaway = true,
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 0.865, 0.45},
	visual = "mesh",
	mesh = "mobs_mc_pig.b3d",
	textures = {{
		"blank.png", -- baby
		"mobs_mc_pig.png", -- base
		"blank.png", -- saddle
	}},
	visual_size = {x=2.5, y=2.5},
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 3,
	drops = {
		{name = mobs_mc.items.porkchop_raw,
		chance = 1,
		min = 1,
		max = 3,},
	},
	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	sounds = {
		random = "mobs_pig",
		death = "mobs_pig_angry",
		damage = "mobs_pig",
		distance = 16,
	},
	animation = {
		stand_speed = 40,
		walk_speed = 40,
		run_speed = 50,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
	},
	follow = mobs_mc.follow.pig,
	view_range = 5,
	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 4
			self.max_speed_reverse = 2
			self.accel = 4
			self.terrain_type = 3
			self.driver_attach_at = {x = 0.0, y = 6.75, z = -1.5}
			self.driver_eye_offset = {x = 0, y = 3, z = 0}
			self.driver_scale = {x = 1/self.visual_size.x, y = 1/self.visual_size.y}
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
		-- also detach from horse properly
		if self.driver then
			mobs.detach(self.driver, {x = 1, y = 0, z = 1})
		end

	end,

	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end

		local wielditem = clicker:get_wielded_item()
		-- Feed pig
		if wielditem:get_name() ~= mobs_mc.items.carrot_on_a_stick then
			if mobs:feed_tame(self, clicker, 1, true, true) then return end
		end
		if mobs:protect(self, clicker) then return end

		if self.child then
			return
		end

		-- Put saddle on pig
		local item = clicker:get_wielded_item()
		if item:get_name() == mobs_mc.items.saddle and self.saddle ~= "yes" then
			self.base_texture = {
				"blank.png", -- baby
				"mobs_mc_pig.png", -- base
				"mobs_mc_pig_saddle.png", -- saddle
			}
			self.object:set_properties({
				textures = self.base_texture
			})
			self.saddle = "yes"
			self.tamed = true
			self.drops = {
				{name = mobs_mc.items.porkchop_raw,
				chance = 1,
				min = 1,
				max = 3,},
				{name = mobs_mc.items.saddle,
				chance = 1,
				min = 1,
				max = 1,},
			}
			if not minetest.settings:get_bool("creative_mode") then
				local inv = clicker:get_inventory()
				local stack = inv:get_stack("main", clicker:get_wield_index())
				stack:take_item()
				inv:set_stack("main", clicker:get_wield_index(), stack)
			end
			return
		end

		-- Mount or detach player
		local name = clicker:get_player_name()
		if self.driver and clicker == self.driver then
			-- Detach if already attached
			mobs.detach(clicker, {x=1, y=0, z=0})
			return

		elseif not self.driver and self.saddle == "yes" and wielditem:get_name() == mobs_mc.items.carrot_on_a_stick then
			-- Ride pig if it has a saddle and player uses a carrot on a stick

			mobs.attach(self, clicker)

			if not minetest.settings:get_bool("creative_mode") then

				local inv = self.driver:get_inventory()
				-- 26 uses
				if wielditem:get_wear() > 63000 then
					-- Break carrot on a stick
					local def = wielditem:get_definition()
					if def.sounds and def.sounds.breaks then
						minetest.sound_play(def.sounds.breaks, {pos = clicker:getpos(), max_hear_distance = 8, gain = 0.5})
					end
					wielditem = {name = mobs_mc.items.fishing_rod, count = 1}
				else
					wielditem:add_wear(2521)
				end
				inv:set_stack("main",self.driver:get_wield_index(), wielditem)
			end
			return

		-- Capture pig
		elseif not self.driver and clicker:get_wielded_item():get_name() ~= "" then
			mobs:capture_mob(self, clicker, 0, 5, 60, false, nil)
		end
	end,
})

mobs:spawn_specific("mobs_mc:pig", mobs_mc.spawn.grassland, {"air"}, 9, minetest.LIGHT_MAX+1, 30, 15000, 30, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- compatibility
mobs:alias_mob("mobs:pig", "mobs_mc:pig")

-- spawn eggs
mobs:register_egg("mobs_mc:pig", S("Pig"), "mobs_mc_spawn_icon_pig.png", 0)


if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Pig loaded")
end
