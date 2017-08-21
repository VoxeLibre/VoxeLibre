--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

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
	return {"mobs_mc_sheep.png^(mobs_mc_sheep_fur.png^[colorize:"..colors[color_group][2]..")"}
end

--mcsheep
mobs:register_mob("mobs_mc:sheep", {
	type = "animal",
	hp_min = 8,
	hp_max = 8,

	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.29, 0.45},

	visual = "mesh",
	visual_size = {x=3, y=3},
	mesh = "mobs_mc_sheepfur.b3d",
	gotten_mesh = "mobs_mc_sheepnaked.b3d",
	textures = { sheep_texture("unicolor_white") },
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
	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	sounds = {
		random = "mobs_sheep",
		death = "mobs_sheep",
		damage = "mobs_sheep",
		distance = 16,
	},
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 40,		stand_end = 80,
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
		self.object:set_properties({
		mesh = "mobs_mc_sheepfur.b3d",
	})
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

		if item:get_name() == mobs_mc.items.shears and not self.gotten then
			self.gotten = true
			local pos = self.object:getpos()
			minetest.sound_play("shears", {pos = pos})
			pos.y = pos.y + 0.5
			if not self.color then
				self.color = "unicolor_white"
			end
			minetest.add_item(pos, ItemStack(colors[self.color][1].." "..math.random(1,3)))
			self.object:set_properties({
				mesh = "mobs_mc_sheepnaked.b3d",
			})
			if not minetest.settings:get_bool("creative_mode") then
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
})
mobs:spawn_specific("mobs_mc:sheep", mobs_mc.spawn.grassland, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 15000, 3, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- compatibility
mobs:alias_mob("mobs_animal:sheep", "mobs_mc:sheep")
-- spawn eggs
mobs:register_egg("mobs_mc:sheep", S("Sheep"), "mobs_mc_spawn_icon_sheep.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Sheep loaded")
end
