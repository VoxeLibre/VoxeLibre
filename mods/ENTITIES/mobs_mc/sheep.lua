--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### SHEEP
--###################

local colors = {
	-- group = { wool, textures }
	unicolor_white = { mobs_mc.items.wool_white, "#FFFFFF00" },
	unicolor_dark_orange = { mobs_mc.items.wool_brown, "#502A00D0" },
	unicolor_grey = { mobs_mc.items.wool_light_grey, "#5B5B5BD0" },
	unicolor_darkgrey = { mobs_mc.items.wool_grey, "#303030D0" },
	unicolor_blue = { mobs_mc.items.wool_blue, "#0000CCD0" },
	unicolor_dark_green = { mobs_mc.items.wool_green, "#005000D0" },
	unicolor_green = { mobs_mc.items.wool_lime, "#50CC00D0" },
	unicolor_violet = { mobs_mc.items.wool_purple , "#5000CCD0" },
	unicolor_light_red = { mobs_mc.items.wool_pink, "#FF5050D0" },
	unicolor_yellow = { mobs_mc.items.wool_yellow, "#CCCC00D0" },
	unicolor_orange = { mobs_mc.items.wool_orange, "#CC5000D0" },
	unicolor_red = { mobs_mc.items.wool_red, "#CC0000D0" },
	unicolor_cyan  = { mobs_mc.items.wool_cyan, "#00CCCCD0" },
	unicolor_red_violet = { mobs_mc.items.wool_magenta, "#CC0050D0" },
	unicolor_black = { mobs_mc.items.wool_black, "#000000D0" },
}

if minetest.get_modpath("mcl_wool") ~= nil then
	colors["unicolor_light_blue"] = { mobs_mc.items.wool_light_blue, "#5050FFD0" }
end

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
mobs:register_mob("mobs_mc:sheep", {
	type = "animal",
	spawn_class = "passive",
	hp_min = 8,
	hp_max = 8,

	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.29, 0.45},

	visual = "mesh",
	visual_size = {x=3, y=3},
	mesh = "mobs_mc_sheepfur.b3d",
	textures = { sheep_texture("unicolor_white") },
	gotten_texture = gotten_texture,
	color = "unicolor_white",
	makes_footstep_sound = true,
	walk_velocity = 1,
	drops = {
		{name = mobs_mc.items.mutton_raw,
		chance = 1,
		min = 1,
		max = 2,},
		{name = colors["unicolor_white"][1],
		chance = 1,
		min = 1,
		max = 1,},
	},
	fear_height = 4,
	sounds = {
		random = "mobs_sheep",
		death = "mobs_sheep",
		damage = "mobs_sheep",
		sounds = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		speed_normal = 25,	run_speed = 65,
		stand_start = 40,	stand_end = 80,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	follow = mobs_mc.follow.sheep,
	view_range = 12,

	-- Eat grass
	replace_rate = 20,
	replace_what = mobs_mc.replace.sheep,
	-- Properly regrow wool after eating grass
	on_replace = function(self, pos, oldnode, newnode)
		if not self.color or not colors[self.color] then
			self.color = "unicolor_white"
		end
		self.gotten = false
		self.base_texture = sheep_texture(self.color)
		self.object:set_properties({ textures = self.base_texture })
		self.drops = {
			{name = mobs_mc.items.mutton_raw,
			chance = 1,
			min = 1,
			max = 2,},
			{name = colors[self.color][1],
			chance = 1,
			min = 1,
			max = 1,},
		}
	end,

	-- Set random color on spawn
	do_custom = function(self)
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
				{name = mobs_mc.items.mutton_raw,
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
	end,
	
	on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()

		if mobs:feed_tame(self, clicker, 1, true, true) then return end
		if mobs:protect(self, clicker) then return end

		if item:get_name() == mobs_mc.items.shears and not self.gotten and not self.child then
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
				item:add_wear(mobs_mc.misc.shears_wear)
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
			self.drops = {
				{name = mobs_mc.items.mutton_raw,
				chance = 1,
				min = 1,
				max = 2,},
			}
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
						{name = mobs_mc.items.mutton_raw,
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
		if mobs:capture_mob(self, clicker, 0, 5, 70, false, nil) then return end
	end,
	on_breed = function(parent1, parent2)
		-- Breed sheep and choose a fur color for the child.
		local pos = parent1.object:get_pos()
		local child = mobs:spawn_child(pos, parent1.name)
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
})
mobs:spawn_specific("mobs_mc:sheep", mobs_mc.spawn.grassland, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 15000, 3, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:sheep", S("Sheep"), "mobs_mc_spawn_icon_sheep.png", 0)
