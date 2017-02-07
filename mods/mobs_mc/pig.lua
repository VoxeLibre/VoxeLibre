--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")

mobs:register_mob("mobs_mc:pig", {
	type = "animal",
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-0.4, -0.01, -0.4, 0.4, 1, 0.4},
	
	visual = "mesh",
	mesh = "mobs_pig.x",
	textures = {
	{"mobs_pig.png"}
	},
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 100,
	drops = {
		{name = "mcl_mobitems:porkchop",
		chance = 1,
		min = 1,
		max = 3,},
	},
	drawtype = "front",
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	fear_height = 3,
	sounds = {
		random = "Pig2",
		death = "Pigdeath",
		damage = "Pig2",
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
	follow = {"mcl_core:apple", "mcl_farming:beetroot_item", "mcl_farming:carrot_item", "mcl_mobitems:carrot_on_a_stick"},
	view_range = 5,
	on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			return
		end
	
		local item = clicker:get_wielded_item()
		if item:get_name() == "mcl_mobitems:saddle" and self.saddle ~= "yes" then
			self.object:set_properties({
				textures = {"mobs_pig_with_saddle.png"},
			})
			self.saddle = "yes"
			self.tamed = true
			self.drops = {
				{name = "mcl_mobitems:porkchop",
				chance = 1,
				min = 1,
				max = 3,},
				{name = "mcl_mobitems:saddle",
				chance = 1,
				min = 1,
				max = 1,},
			}
			if not minetest.setting_getbool("creative_mode") then
				local inv = clicker:get_inventory()
				local stack = inv:get_stack("main", clicker:get_wield_index())
				stack:take_item()
				inv:set_stack("main", clicker:get_wield_index(), stack)
			end
			return
		end
	-- from boats mod
	local name = clicker:get_player_name()

	if self.driver and clicker == self.driver then
		self.driver = nil
		clicker:set_detach()
		mcl_core.player_attached[name] = false
		mcl_core.player_set_animation(clicker, "stand" , 30)
	elseif not self.driver and self.saddle == "yes" then
		self.driver = clicker
		clicker:set_attach(self.object, "", {x = 0, y = 19, z = 0}, {x = 0, y = 0, z = 0})
		mcl_core.player_attached[name] = true
		minetest.after(0.2, function()
			mcl_core.player_set_animation(clicker, "sit" , 30)
		end)
		----[[
			-- ridable pigs
		if self.name == "mobs_mc:pig" and self.saddle == "yes" and self.driver then
			local item = clicker:get_wielded_item()
			if item:get_name() == "mcl_mobitems:carrot_on_a_stick" then
				local yaw = self.driver:get_look_yaw() - math.pi / 2
				local velo = self.object:getvelocity()
				local v = 1.5
				if math.abs(velo.x) + math.abs(velo.z) < .6 then velo.y = 5 end
				self.state = "walk"
				self.object:setyaw(yaw)
				self.object:setvelocity({x = -math.sin(yaw) * v, y = velo.y, z = math.cos(yaw) * v})

				local inv = self.driver:get_inventory()
				-- 26 uses
				if item:get_wear() > 63000 then
					item = {name = "mcl_fishing:fishing_rod", count = 1}
				else
					item:add_wear(2521)
				end
				inv:set_stack("main", self.driver:get_wield_index(), item)
				return
			end
			end
			--]]
		--self.object:setyaw(clicker:get_look_yaw() - math.pi / 2)
	end
	--from mobs_animals
		if mobs:feed_tame(self, clicker, 8, true, true) then
			return
		end
		mobs:capture_mob(self, clicker, 0, 5, 50, false, nil)
	end,
})

mobs:register_spawn("mobs_mc:pig", {"mcl_core:dirt_with_grass"}, 20, 12, 5000, 1, 31000)
	

--api code to fix
--[[

	on_step = function(self, dtime)
		-- ridable pigs
		if self.name == "mobs:pig" and self.saddle == "yes" and self.driver then
			local item = self.driver:get_wielded_item()
			if item:get_name() == "mobs:carrotstick" then
				local yaw = self.driver:get_look_yaw() - math.pi / 2
				local velo = self.object:getvelocity()
				local v = 1.5
				if math.abs(velo.x) + math.abs(velo.z) < .6 then velo.y = 5 end
				self.state = "walk"
				self.object:setyaw(yaw)
				self.object:setvelocity({x = -math.sin(yaw) * v, y = velo.y, z = math.cos(yaw) * v})

				local inv = self.driver:get_inventory()
				local stack = inv:get_stack("main", self.driver:get_wield_index())
				stack:add_wear(100)
				if stack:get_wear() > 65400 then
					stack = {name = "fishing:pole", count = 1}
				end
				inv:set_stack("main", self.driver:get_wield_index(), stack)
				return
			end
		end
	end,
]]






-- compatibility
mobs:alias_mob("mobs:pig", "mobs_mc:pig")

-- spawn eggs
mobs:register_egg("mobs_mc:pig", "Spawn Pig", "spawn_egg_pig.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Pig loaded")
end
