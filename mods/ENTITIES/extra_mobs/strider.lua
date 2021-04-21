--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("extra_mobs")

--###################
--################### STRIDER
--###################


local strider = {
	type = "animal",
	passive = true,
	spawn_class = "passive",
	hp_min = 20,
	hp_max = 20,
	xp_min = 9,
	xp_max = 9,
	armor = {fleshy = 90},
	attack_type = "dogfight",
	damage = 2,
	reach = 2,
	collisionbox = {-.6, -0.01, -.6, .6, 1.94, .6},
	visual = "mesh",
	mesh = "extra_mobs_strider.b3d",
	textures = { {
		"extra_mobs_strider.png",
	} },
	visual_size = {x=3, y=3},
	sounds = {
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 2,
	run_velocity = 4,
	runaway = true,
	drops = {
		{name = "mcl_mobsitems:string",
		chance = 1,
		min = 2,
		max = 5,},
	},
	animation = {
		stand_speed = 15,
		walk_speed = 15,
		run_speed = 30,
		stand_start = 5,
		stand_end = 5,
		walk_start = 1,
		walk_end = 20,
	},
	lava_damage = 0,
	fire_damage = 0,
	light_damage = 0,
	water_damage = 5,
	fear_height = 4,
	view_range = 16,
	fire_resistant = true,
	floats_on_lava = 1,
	floats = 0,
	do_custom = function(self, dtime)

		if minetest.find_node_near(self.object:get_pos(), 2, "mcl_core:lava_source") ~= nil or minetest.find_node_near(self.object:get_pos(), 2, "mcl_core:lava_flowing") ~= nil or minetest.find_node_near(self.object:get_pos(), 2, "mcl_nether:nether_lava_source") ~= nil or minetest.find_node_near(self.object:get_pos(), 2, "mcl_nether:nether_lava_flowing") ~= nil then
			self.walk_velocity = 2
			self.run_velocity = 4
			self.base_texture[1] = "extra_mobs_strider.png"
			self.shaking = false
		else
			self.base_texture[1] = "extra_mobs_strider_cold.png"
			self.walk_velocity = .5
			self.run_velocity = 1
			self.shaking = true
		end

		self.object:set_properties({textures=self.base_texture, shaking=self.shaking, run_velocity=self.run_velocity, walk_velocity=self.walk_velocity})

		-- set needed values if not already present
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 8
			self.max_speed_reverse = 4
			self.accel = 2
			self.terrain_type = 3
			self.driver_attach_at = {x = 0, y = 5.5, z = -1.75}
			self.driver_eye_offset = {x = 0, y = 10, z = 0}
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

		local controlitem = ""
		if minetest.get_modpath("mc") then
            controlitem = "mc_warped_fungus_stick:warped_fungus_stick"
        else
            controlitem = mobs_mc.items.carrot_on_a_stick
        end
		if wielditem:get_name() ~= controlitem then
			if mobs:feed_tame(self, clicker, 1, true, true) then return end
		end

		if self.child then
			return
		end

		local item = clicker:get_wielded_item()
		if item:get_name() == mobs_mc.items.saddle and self.saddle ~= "yes" then
			self.base_texture = {
				"extra_mobs_strider.png",
				"mobs_mc_pig_saddle.png", -- saddle
			}
			self.object:set_properties({
				textures = self.base_texture
			})
			self.saddle = "yes"
			self.tamed = true
			self.drops = {
				{name = "mcl_mobitems:string",
				chance = 1,
				min = 1,
				max = 3,},
				{name = "mcl_mobitems:saddle",
				chance = 1,
				min = 1,
				max = 1,},
			}
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				local inv = clicker:get_inventory()
				local stack = inv:get_stack("main", clicker:get_wield_index())
				stack:take_item()
				inv:set_stack("main", clicker:get_wield_index(), stack)
			end
			minetest.sound_play({name = "mcl_armor_equip_leather"}, {gain=0.5, max_hear_distance=8, pos=self.object:get_pos()}, true)
			return
		end

		-- Mount or detach player
		local name = clicker:get_player_name()
		if self.driver and clicker == self.driver then
			-- Detach if already attached
			mobs.detach(clicker, {x=1, y=0, z=0})
			return

		elseif not self.driver and self.saddle == "yes" and wielditem:get_name() == controlitem then
			-- Ride pig if it has a saddle and player uses a carrot on a stick

			mobs.attach(self, clicker)

			if not minetest.is_creative_enabled(clicker:get_player_name()) then

				local inv = self.driver:get_inventory()
				-- 26 uses
				if wielditem:get_wear() > 63000 then
					-- Break carrot on a stick
					local def = wielditem:get_definition()
					if def.sounds and def.sounds.breaks then
						minetest.sound_play(def.sounds.breaks, {pos = clicker:get_pos(), max_hear_distance = 8, gain = 0.5}, true)
					end
					wielditem = {name = mobs_mc.items.fishing_rod, count = 1}
				else
					wielditem:add_wear(2521)
				end
				inv:set_stack("main",self.driver:get_wield_index(), wielditem)
			end
			return
		end
	end,
}

mobs:register_mob("extra_mobs:strider", strider)

-- Baby strider.

local baby_strider = table.copy(strider)
baby_strider.collisionbox = {-.3, -0.01, -.3, .3, 0.94, .3}
baby_strider.xp_min = 13
baby_strider.xp_max = 13
baby_strider.visual_size = {x=strider.visual_size.x/2, y=strider.visual_size.y/2}
textures = { {
	"extra_mobs_strider.png",
	"extra_mobs_trans.png",
} }
baby_strider.walk_velocity = 1.2
baby_strider.run_velocity = 2.4
baby_strider.child = 1

mobs:register_mob("extra_mobs:baby_strider", baby_strider)

-- Regular spawning in the Nether
mobs:spawn_specific(
"extra_mobs:strider",
"nether", 
"lava",
{
"Nether"
},
0, 
minetest.LIGHT_MAX+1, 
30, 
6000, 
3, 
mobs_mc.spawn_height.nether_min, 
mobs_mc.spawn_height.nether_max)

-- spawn eggs
mobs:register_egg("extra_mobs:strider", S("Strider"), "extra_mobs_spawn_icon_strider.png", 0)
