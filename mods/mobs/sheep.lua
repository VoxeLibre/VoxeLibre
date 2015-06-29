
mobs:register_mob("mobs:sheep", {
	type = "animal",
	hp_max = 8,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 1, 0.5},
	textures = {"creatures_sheep.png"},
	visual = "mesh",
	mesh = "creatures_sheep.x",
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 3,
	armor = 100,
	drops = {
		{name = "mobs:meat_raw_sheep",
		chance = 2,
		min = 1,
		max = 2,},
	},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 8,
	animation = {
		speed_normal = 17,
		speed_run = 25,
		stand_start = 0,
		stand_end = 80,
		walk_start = 81,
		walk_end = 100,
	},
	follow = "farming:wheat_harvested",
	view_range = 6,
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		if item:get_name() == "farming:wheat_harvested" then
			if not self.tamed then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				self.tamed = true
				self.object:set_hp(self.object:get_hp() + 3)
				if self.object:get_hp() > 15 then self.object:set_hp(15) end
			else
				if not minetest.setting_getbool("creative_mode") and self.naked then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				self.food = (self.food or 0) + 1
				if self.food >= 8 then
					self.food = 0
					self.naked = false
					self.object:set_properties({
						textures = {"creatures_sheep.png"},
					})
				end
				self.object:set_hp(self.object:get_hp() + 3)
				if self.object:get_hp() > 15 then self.object:set_hp(15) return end
				if not self.naked then
					item:take_item()
					clicker:set_wielded_item(item)
				end
			end
			return
		end
		if item:get_name() == "default:shears" and not self.naked then
			self.naked = true
				clicker:get_inventory():add_item("main", ItemStack("wool:white "..math.random(1,3)))
				minetest.sound_play("default_snow_footstep", {object = self.object, gain = 0.5,})
			self.object:set_properties({
				textures = {"creatures_sheep_shaved.png"},
			})
		end
	end,
})
