--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")

--mcsheep
mobs:register_mob("mobs_mc:sheep", {
	type = "animal",
	hp_min = 8,
	hp_max = 8,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 1.5, 0.5},
	
	visual = "mesh",
	mesh = "mobs_sheep.x",
	textures = {
	{"mobs_sheep.png"}
	},
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 100,
	drops = {
		{name = "mcl_mobs:mutton_raw",
		chance = 1,
		min = 1,
		max = 2,},
		{name = "mcl_wool:white",
		chance = 1,
		min = 1,
		max = 1,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fear_height = 3,
	sounds = {
		random = "Sheep3",
		death = "Sheep3",
		damage = "Sheep3",
	},
	animation = {
		speed_normal = 24,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 49,
		hurt_start = 118,
		hurt_end = 154,
		death_start = 154,
		death_end = 179,
		eat_start = 49,
		eat_end = 78,
		look_start = 78,
		look_end = 108,
	},
	follow = "farming:wheat",
	view_range = 5,
	
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		if item:get_name() == "farming:wheat" then
			if not self.tamed then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				self.tamed = true
			elseif self.naked then
				if not minetest.setting_getbool("creative_mode") then
					item:take_item()
					clicker:set_wielded_item(item)
				end
				self.food = (self.food or 0) + 1
				if self.food >= 4 then
					self.food = 0
					self.naked = false
					self.object:set_properties({
						textures = {"sheep.png"},
					})
				end
			end
			return
		end
		if item:get_name() == "mobs:shears" and not self.naked then
			self.naked = true
			local pos = self.object:getpos()
			minetest.sound_play("shears", {pos = pos})
			pos.y = pos.y + 0.5
			if not self.color then
				minetest.add_item(pos, ItemStack("mcl_wool:white "..math.random(1,3)))
			else
				minetest.add_item(pos, ItemStack("mcl_wool:"..self.color.." "..math.random(1,3)))
			end
			self.object:set_properties({
				textures = {"sheep_sheared.png"},
			})
			if not minetest.setting_getbool("creative_mode") then
				item:add_wear(300)
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
		end
		if minetest.get_item_group(item:get_name(), "dye") == 1 and not self.naked then
print(item:get_name(), minetest.get_item_group(item:get_name(), "dye"))
			local name = item:get_name()
			local pname = name:split(":")[2]

			self.object:set_properties({
				textures = {"mobs_sheep_"..pname..".png"},
			})
			self.color = pname
			self.drops = {
				{name = "mcl_mobs:mutton_raw",
				chance = 1,
				min = 1,
				max = 2,},
				{name = "mcl_wool:"..self.color,
				chance = 1,
				min = 1,
				max = 1,},
			}
		end
	end,
})
--mobs:register_spawn("mobs_mc:sheep", {"mcl_core:dirt_with_grass"}, 20, 12, 5000, 2, 31000)


-- compatibility
mobs:alias_mob("mobs:sheep", "mobs_mc:sheep")

-- spawn eggs
mobs:register_egg("mobs_mc:sheep", "Spawn Sheep", "spawn_egg_sheep.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Sheep loaded")
end
