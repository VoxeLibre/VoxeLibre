local S = minetest.get_translator("mobs_mc")

--###################
--################### LLAMA
--###################

local carpets = {
	-- group = { carpet , short_texture_name }
	unicolor_white = { "mcl_wool:white_carpet", "white" },
	unicolor_dark_orange = { "mcl_wool:brown_carpet", "brown" },
	unicolor_grey = { "mcl_wool:silver_carpet", "light_gray" },
	unicolor_darkgrey = { "mcl_wool:grey_carpet", "gray" },
	unicolor_blue = { "mcl_wool:blue_carpet", "blue" },
	unicolor_dark_green = { "mcl_wool:green_carpet", "green" },
	unicolor_green = { "mcl_wool:lime_carpet", "lime" },
	unicolor_violet = { "mcl_wool:purple_carpet", "purple" },
	unicolor_light_red = { "mcl_wool:pink_carpet", "pink" },
	unicolor_yellow = { "mcl_wool:yellow_carpet", "yellow" },
	unicolor_orange = { "mcl_wool:orange_carpet", "orange" },
	unicolor_red = { "mcl_wool:red_carpet", "red" },
	unicolor_cyan = { "mcl_wool:cyan_carpet", "cyan" },
	unicolor_red_violet = { "mcl_wool:magenta_carpet", "magenta" },
	unicolor_black = { "mcl_wool:black_carpet", "black" },
	unicolor_light_blue = { "mcl_wool:light_blue_carpet", "light_blue" },
}

mobs:register_mob("mobs_mc:llama", {
	description = S("Llama"),
	type = "animal",
	spawn_class = "passive",
	rotate = 270,
	neutral = true,
	group_attack = true,
	attack_type = "projectile",
	shoot_arrow = function(self, pos, dir)
		-- 2-4 damage per arrow
		local dmg = 1
		mobs.shoot_projectile_handling("mobs_mc:spit", pos, dir, self.object:get_yaw(), self.object, nil, dmg)		
	end,
	hp_min = 15,
	hp_max = 30,
	xp_min = 1,
	xp_max = 3,
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
		-- TODO: Add llama carpet textures (Pixel Perfection seems to use verbatim copy from Minecraft :-( )
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	runaway = true,
	walk_velocity = 1,
	run_velocity = 4.4,
	follow_velocity = 4.4,
	breed_distance = 1.5,
	baby_size = 0.5,
	follow_distance = 2,
	floats = 1,
	reach = 6,
	drops = {
		{name = mobs_mc.items.leather,
		chance = 1,
		min = 0,
		max = 2,
		looting = "common",},
	},
	fear_height = 4,
	sounds = {
		random = "mobs_mc_llama",
		eat = "mobs_mc_animal_eat_generic",
		-- TODO: Death and damage sounds
		distance = 16,
	},
	animation = {
		speed_normal = 24,
		run_speed = 60,
		run_start = 0,
		run_end = 40,
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
	follow = mobs_mc.items.hay_bale,
	view_range = 16,
	do_custom = function(self, dtime)

		-- set needed values if not already present
		if not self.v2 then
			self.v2 = 0
			self.max_speed_forward = 4
			self.max_speed_reverse = 2
			self.accel = 4
			self.terrain_type = 3
			self.driver_attach_at = {x = 0, y = 4.17, z = -1.5}
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

		--owner is broken for this
		--we'll make the owner this guy
		--attempt to enter breed state
		if mobs.enter_breed_state(self,clicker) then
			self.tamed = true
			self.owner = clicker:get_player_name()
			return
		end		

		--ignore other logic
		--make baby grow faster
		if self.baby then
			mobs.make_baby_grow_faster(self,clicker)
			return
		end


		-- Make sure tamed llama is mature and being clicked by owner only
		if self.tamed and not self.child and self.owner == clicker:get_player_name() then

			local item = clicker:get_wielded_item()
			--safety catch
			if not item then
				return
			end



			--put chest on carpeted llama
			if self.carpet and not self.chest and item:get_name() == "mcl_chests:chest" then
				if not minetest.is_creative_enabled(clicker:get_player_name()) then
					item:take_item()
					clicker:set_wielded_item(item)
				end

				self.base_texture = table.copy(self.base_texture)
				self.base_texture[1] = "mobs_mc_llama_chest.png"
				self.object:set_properties({
					textures = self.base_texture,
				})
				self.chest = true

				return --don't attempt to ride
			end


			-- Place carpet
			--TODO: Re-enable this code when carpet textures arrived.
			if minetest.get_item_group(item:get_name(), "carpet") == 1 then

				for group, carpetdata in pairs(carpets) do
					if minetest.get_item_group(item:get_name(), group) == 1 then
						if not minetest.is_creative_enabled(clicker:get_player_name()) then
							item:take_item()
							clicker:set_wielded_item(item)

							--shoot off old carpet
							if self.carpet then
								minetest.add_item(self.object:get_pos(), self.carpet)
							end
						end

						local substr = carpetdata[2]
						local tex_carpet = "mobs_mc_llama_decor_"..substr..".png"

						self.base_texture = table.copy(self.base_texture)
						self.base_texture[2] = tex_carpet
						self.object:set_properties({
							textures = self.base_texture,
						})
						self.carpet = item:get_name()
						self.drops = {
							{name = mobs_mc.items.leather,
							chance = 1,
							min = 0,
							max = 2,},
							{name = item:get_name(),
							chance = 1,
							min = 1,
							max = 1,},
						}
						return
					end
				end
			end

			if self.carpet then
				-- detatch player already riding llama
				if self.driver and clicker == self.driver then

					mobs.detach(clicker, {x = 1, y = 0, z = 1})

				-- attach player to llama
				elseif not self.driver then

					self.object:set_properties({stepheight = 1.1})
					mobs.attach(self, clicker)
				end
			end

		end
	end,

	--[[
	TODO: Enable this code when carpet textures arrived.
	on_breed = function(parent1, parent2)
		-- When breeding, make sure the child has no carpet
		local pos = parent1.object:get_pos()
		local child, parent
		if math.random(1,2) == 1 then
			parent = parent1
		else
			parent = parent2
		end
		child = mobs:spawn_child(pos, parent.name)
		if child then
			local ent_c = child:get_luaentity()
			ent_c.base_texture = table.copy(ent_c.base_texture)
			ent_c.base_texture[2] = "blank.png"
			child:set_properties({textures = ent_c.base_texture})
			ent_c.tamed = true
			ent_c.carpet = nil
			ent_c.owner = parent.owner
			return false
		end
	end,
	]]

})

--spawn
mobs:spawn_specific(
"mobs_mc:llama",
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
5,
mobs_mc.spawn_height.water+15,
mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:llama", S("Llama"), "mobs_mc_spawn_icon_llama.png", 0)


-- llama spit
mobs:register_arrow("mobs_mc:spit", {
	visual = "sprite",
	visual_size = {x = 0.3, y = 0.3},
	textures = {"mobs_mc_spit.png"},
	velocity = 1,
	speed = 1,
	tail = 1,
	tail_texture = "mobs_mc_spit.png",
	tail_size = 2,
	tail_distance_divider = 4,

	hit_player = function(self, player)
		if rawget(_G, "armor") and armor.last_damage_types then
			armor.last_damage_types[player:get_player_name()] = "spit"
		end
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = self._damage},
		}, nil)
	end,

	hit_mob = function(self, mob)		
		mob:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = _damage},
		}, nil)
	end,

	hit_node = function(self, pos, node)
		--does nothing
	end
})