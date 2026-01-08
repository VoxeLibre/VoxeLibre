local S = minetest.get_translator("mobs_mc")

--###################
--################### SHEEP
--###################

local WOOL_REPLACE_RATE = 80

local colors = {
	-- group = { wool, textures }
	unicolor_white = { "mcl_wool:white", "#FFFFFF00" },
	unicolor_dark_orange = { "mcl_wool:brown", "#451A0FD0" },
	unicolor_grey = { "mcl_wool:silver", "#7B7B7BD0" },
	unicolor_darkgrey = { "mcl_wool:grey", "#303030D0" },
	unicolor_blue = { "mcl_wool:blue", "#001A9CD0" },
	unicolor_dark_green = { "mcl_wool:green", "#004000D0" },
	unicolor_green = { "mcl_wool:lime", "#308C20D0" },
	unicolor_violet = { "mcl_wool:purple" , "#30107CD0" },
	unicolor_light_red = { "mcl_wool:pink", "#BB5060D0" },
	unicolor_yellow = { "mcl_wool:yellow", "#AC7C00D0" },
	unicolor_orange = { "mcl_wool:orange", "#CC5000D0" },
	unicolor_red = { "mcl_wool:red", "#800000D0" },
	unicolor_cyan  = { "mcl_wool:cyan", "#004C5CD0" },
	unicolor_red_violet = { "mcl_wool:magenta", "#90309AD0" },
	unicolor_black = { "mcl_wool:black", "#000000E0" },
	unicolor_light_blue = { "mcl_wool:light_blue", "#5070FFD0" },
}

local rainbow_colors = {
	"unicolor_light_red",
	"unicolor_red",
	"unicolor_orange",
	"unicolor_yellow",
	"unicolor_green",
	"unicolor_dark_green",
	"unicolor_light_blue",
	"unicolor_blue",
	"unicolor_violet",
	"unicolor_red_violet"
}

local sheep_texture = function(color_group)
	if not color_group then
		color_group = "unicolor_white"
	end
	return {
		"mobs_mc_sheep_fur.png^[colorize:"..colors[color_group][2],
		"mobs_mc_sheep.png",
	}
end

local gotten_texture = { "blank.png", "mobs_mc_sheep.png" }

--mcsheep
mcl_mobs.register_mob("mobs_mc:sheep", {
	description = S("Sheep"),
	type = "animal",
	spawn_class = "passive",
	passive = true,
	initial_properties = {
		hp_min = 8,
		hp_max = 8,
		collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.29, 0.45},
	},
	xp_min = 1,
	xp_max = 3,
	head_swivel = "head.control",
	head_eye_height = 1.0,
	head_bone_position = vector.new( 0, 3.3, -.9 ), -- for minetest <= 5.8
	curiosity = 6,
	head_yaw="z",
	visual = "mesh",
	mesh = "mobs_mc_sheepfur.b3d",
	textures = { sheep_texture("unicolor_white") },
	gotten_texture = gotten_texture,
	color = "unicolor_white",
	makes_footstep_sound = true,
	walk_velocity = 1,
	runaway = true,
	runaway_from = {"mobs_mc:wolf"},
	drops = {
		{name = "mcl_mobitems:mutton",
		chance = 1,
		min = 1,
		max = 2,
		looting = "common",},
		{name = colors["unicolor_white"][1],
		chance = 1,
		min = 1,
		max = 1,
		looting = "common",},
	},
	fear_height = 4,
	sounds = {
		random = "mobs_mc_sheep_random",
		death = "mobs_sheep",
		damage = "mobs_mc_sheep_damage",
		sounds = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 30,
		run_start = 0, run_end = 40, run_speed = 40,
		eat_start = 40, eat_end = 80, eat_loop = false,
	},
	child_animations = {
		stand_start = 81, stand_end = 81,
		walk_start = 81, walk_end = 121, walk_speed = 45,
		run_start = 81, run_end = 121, run_speed = 60,
		eat_start = 121, eat_start = 161, eat_loop = false,
	},
	follow = { "mcl_farming:wheat_item", "mcl_shepherd:shepherd_staff" },
	view_range = 12,

	-- Eat grass
	replace_rate = WOOL_REPLACE_RATE,
	replace_delay = 1.3,
	replace_what = {
		{ "mcl_core:dirt_with_grass", "mcl_core:dirt", -1 },
		{ "mcl_flowers:tallgrass", "air", 0 },
	},
	-- Properly regrow wool after eating grass
	on_replace = function(self, pos, oldnode, newnode)
		if not self.color or not colors[self.color] then
			self.color = "unicolor_white"
		end
		self.base_texture = sheep_texture(self.color)

		self.drops = {
			{name = "mcl_mobitems:mutton",
			 chance = 1,
			 min = 1,
			 max = 2,},
			{name = colors[self.color][1],
			 chance = 1,
			 min = 1,
			 max = 1,},
		}

		self.state = "eat"
		self:set_animation("eat")
		self:set_velocity(0)



		minetest.after(self.replace_delay, function()
			if self and self.object and self.object:get_velocity() and self.health > 0 then
				self.object:set_velocity(vector.zero())
				self.gotten = false
				self.object:set_properties({ textures = self.base_texture })
				minetest.sound_play({name = "mobs_mc_animal_eat_generic", gain = 0.4},
					{pos = pos, max_hear_distance = 16}, true)
			end
		end)

		minetest.after(2.5, function()
			if self and self.object and self.state == 'eat' and self.health > 0 then
				self.state = "walk"
			end
		end)

	end,

	-- Set random color on spawn
	do_custom = function(self, dtime)
		if not self.initial_color_set then
			local r = math.random(0,100000)
			local textures
			if r <= 81836 then
				-- 81.836%
				self.color = "unicolor_white"
			elseif r <= 81836 + 5000 then
				-- 5%
				self.color = "unicolor_grey"
			elseif r <= 81836 + 5000 + 5000 then
				-- 5%
				self.color = "unicolor_darkgrey"
			elseif r <= 81836 + 5000 + 5000 + 5000 then
				-- 5%
				self.color = "unicolor_black"
			elseif r <= 81836 + 5000 + 5000 + 5000 + 3000 then
				-- 3%
				self.color = "unicolor_dark_orange"
			else
				-- 0.164%
				self.color = "unicolor_light_red"
			end
			self.base_texture = sheep_texture(self.color)
			self.object:set_properties({ textures = self.base_texture })
			self.drops = {
				{name = "mcl_mobitems:mutton",
				chance = 1,
				min = 1,
				max = 2,},
				{name = colors[self.color][1],
				chance = 1,
				min = 1,
				max = 1,},
			}
			self.initial_color_set = true
		end

        local special_names = {
          ["AFCMS"] = true,
          ["AncientMariner"] = true,
          ["chmodsayshello"] = true,
          ["Codiac"] = true,
          ["cora"] = true,
          ["davedevils"] = true,
          ["DarkReaven"] = true,
          ["Diminixed"] = true,		 		 		  
          ["epCode"] = true,
          ["Exhale&TimUnwin"] = true,
          ["Faerraven"] = true,
          ["Fleckenstein"] = true,
          ["FossFanatic"] = true,
          ["Herowl"] = true,
          ["iliekprogrammar"] = true,
          ["Jester"] = true,
          ["Jordach"] = true,
          ["jordan4ibanez"] = true,
          ["kabou"] = true,
          ["kay27"] = true,
          ["kno10"] = true,
          ["MrRar"] = true,
		  ["MysticTempest"] = true,
          ["Nicu"] = true,
          ["NO11"] = true,
          ["PrairieWind"] = true,
          ["rudzik8"] = true,
          ["SmokeyDope"] = true,
          ["SumianVoice"] = true,
          ["teknomunk"] = true,
          ["Wuzzy"] = true,
}
        local is_special_name = special_names[self.nametag] ~= nil

		if self.color_change_timer then
			local old_color = self.color
			if is_special_name then
				self.color_change_timer = self.color_change_timer - dtime
				if self.color_change_timer < 0 then
					self.color_change_timer = 0.5
					self.color_index = (self.color_index + 1) % #rainbow_colors
					self.color = rainbow_colors[self.color_index + 1]
				end
			else
				self.color_change_timer = nil
				self.color_index = nil
				self.color = self.initial_color
			end

			if old_color ~= self.color then
				self.base_texture = sheep_texture(self.color)
				self.object:set_properties({textures = self.base_texture})
			end
		elseif is_special_name then
			self.initial_color = self.color
			self.color_change_timer = 0
			self.color_index = -1
		end
	end,

	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()

		if self:feed_tame(clicker, 1, true, false) then return end
		if mcl_mobs:protect(self, clicker) then return end

		if minetest.get_item_group(item:get_name(), "shears") > 0 and not self.gotten and not self.child then
			self.gotten = true
			local pos = self.object:get_pos()
			minetest.sound_play("mcl_tools_shears_cut", {pos = pos}, true)
			pos.y = pos.y + 0.5
			if not self.color then
				self.color = "unicolor_white"
			end
			minetest.add_item(pos, ItemStack(colors[self.color][1].." "..math.random(1,3)))
			self.base_texture = gotten_texture
			self.object:set_properties({
				textures = self.base_texture,
			})
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				item:add_wear(mobs_mc.shears_wear)
				tt.reload_itemstack_description(item) -- update tooltip
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
			return
		end
		-- Dye sheep
		if minetest.get_item_group(item:get_name(), "dye") == 1 and not self.gotten then
			minetest.log("verbose", "[mobs_mc] " ..item:get_name() .. " " .. minetest.get_item_group(item:get_name(), "dye"))
			for group, colordata in pairs(colors) do
				if minetest.get_item_group(item:get_name(), group) == 1 then
					if not minetest.is_creative_enabled(clicker:get_player_name()) then
						item:take_item()
						clicker:set_wielded_item(item)
					end
					self.base_texture = sheep_texture(group)
					self.object:set_properties({
						textures = self.base_texture,
					})
					self.color = group
					self.drops = {
						{name = "mcl_mobitems:mutton",
						chance = 1,
						min = 1,
						max = 2,},
						{name = colordata[1],
						chance = 1,
						min = 1,
						max = 1,},
					}
					break
				end
			end
			return
		end
		if mcl_mobs:capture_mob(self, clicker, 0, 5, 70, false, nil) then return end
	end,
	on_breed = function(parent1, parent2)
		-- Breed sheep and choose a fur color for the child.
		local pos = parent1.object:get_pos()
		local child = mcl_mobs.spawn_child(pos, parent1.name)
		if child then
			local ent_c = child:get_luaentity()
			local color1 = parent1.color
			local color2 = parent2.color

			local dye1 = mcl_dye.unicolor_to_dye(color1)
			local dye2 = mcl_dye.unicolor_to_dye(color2)
			local output
			-- Check if parent colors could be mixed as dyes
			if dye1 and dye2 then
				output = minetest.get_craft_result({items = {dye1, dye2}, method="normal"})
			end
			local mixed = false
			if output and not output.item:is_empty() then
				-- Try to mix dyes and use that as new fur color
				local new_dye = output.item:get_name()
				local groups = minetest.registered_items[new_dye].groups
				for k, v in pairs(groups) do
					if string.sub(k, 1, 9) == "unicolor_" then
						ent_c.color = k
						ent_c.base_texture = sheep_texture(k)
						mixed = true
						break
					end
				end
			end

			-- Colors not mixable
			if not mixed then
				-- Choose color randomly from one of the parents
				local p = math.random(1, 2)
				if p == 1 and color1 then
					ent_c.color = color1
				else
					ent_c.color = color2
				end
				ent_c.base_texture = sheep_texture(ent_c.color)
			end
			child:set_properties({textures = ent_c.base_texture})
			ent_c.initial_color_set = true
			ent_c.tamed = true
			ent_c.owner = parent1.owner
			return false
		end
	end,
	after_activate = function(self)
		if self.gotten then return end
		self.base_texture = sheep_texture(self.color)
		self.object:set_properties({textures = self.base_texture})
	end,
})
mcl_mobs:spawn_setup({
	name = "mobs_mc:sheep",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"flat",
		"IcePlainsSpikes",
		"ColdTaiga",
		"ColdTaiga_beach",
		"ColdTaiga_beach_water",
		"MegaTaiga",
		"MegaSpruceTaiga",
		"ExtremeHills",
		"ExtremeHills_beach",
		"ExtremeHillsM",
		"ExtremeHills+",
		"ExtremeHills+_snowtop",
		"StoneBeach",
		"Plains",
		"Plains_beach",
		"SunflowerPlains",
		"Taiga",
		"Taiga_beach",
		"Forest",
		"Forest_beach",
		"FlowerForest",
		"FlowerForest_beach",
		"BirchForest",
		"BirchForestM",
		"RoofedForest",
		"Savanna",
		"Savanna_beach",
		"SavannaM",
		"Jungle",
		"Jungle_shore",
		"JungleM",
		"JungleM_shore",
		"JungleEdge",
		"JungleEdgeM",
		"Swampland",
		"Swampland_shore",
		"BambooJungle",
		"BambooJungleM",
		"BambooJungleEdge",
		"BambooJungleEdgeM",
		"BambooJungle_shore",
		"BambooJungleM_shore",
		"BambooJungleEdge_shore",
		"BambooJungleEdgeM_shore",
	},
	min_light = 9,
	max_light = minetest.LIGHT_MAX+1,
	chance = 120,
	interval = 30,
	aoc = 3,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:sheep", S("Sheep"), "#e7e7e7", "#ffb5b5", 0)
