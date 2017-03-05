--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local colors = {
	-- dyecolor = { woolcolor, textures }
	white = { "white", { "mobs_sheep.png" } },
	brown = { "brown", { "mobs_sheep_brown.png" } },
	grey = { "silver", { "mobs_sheep_grey.png" } },
	dark_grey = { "grey", { "mobs_sheep_dark_grey.png" } },
	blue = { "blue", { "mobs_sheep_blue.png" } },
	lightblue = { "light_blue", { "mobs_sheep_lightblue.png" } },
	dark_green = { "green", { "mobs_sheep_dark_green.png" } },
	green = { "lime", { "mobs_sheep_green.png" } },
	violet = { "purple", { "mobs_sheep_violet.png" } },
	pink = { "pink", { "mobs_sheep_pink.png" } },
	yellow = { "yellow", { "mobs_sheep_yellow.png" } },
	orange = { "orange", { "mobs_sheep_orange.png" } },
	red = { "red", { "mobs_sheep_red.png" } },
	cyan  = { "cyan", { "mobs_sheep_cyan.png" } },
	magenta = { "magenta", { "mobs_sheep_magenta.png" } },
	black = { "black", { "mobs_sheep_black.png" } },
}

-- Sheep
mobs:register_mob("mobs_mc:sheep", {
	type = "animal",
	hp_min = 8,
	hp_max = 8,
	-- FIXME: Should be 1.3 blocks high
	collisionbox = {-0.45, -0.01, -0.45, 0.45, 1.09, 0.45},
	
	visual = "mesh",
	visual_size = {x=0.6, y=0.6},
	mesh = "mobs_sheep.x",
	textures = {{"mobs_sheep.png"}},
	makes_footstep_sound = true,
	walk_velocity = 1,
	armor = 100,
	drops = {
		{name = "mcl_mobitems:mutton",
		chance = 1,
		min = 1,
		max = 2,},
		{name = "mcl_wool:white",
		chance = 1,
		min = 1,
		max = 1,},
	},
	drawtype = "front",
	lava_damage = minetest.registered_nodes["mcl_core:lava_source"].damage_per_second,
	light_damage = 0,
	fear_height = 4,
	jump_height = 4.5,
	sounds = {
		random = "mobs_sheep",
		death = "mobs_sheep",
--		damage = "mobs_sheep",
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
	follow = {"mcl_farming:wheat_item"},
	view_range = 5,

	replace_rate = 10,
	replace_what = {"mcl_core:dirt_with_grass", "mcl_core:tallgrass"},
	replace_with = "air",
	do_custom = function(self)
		if not self.initial_color_set then
			local r = math.random(0,100000)
			local textures
			if r <= 81836 then
				-- 81.836%
				self.color = colors["white"][1]
				textures = colors["white"][2]
			elseif r <= 81836 + 5000 then
				-- 5%
				self.color = colors["grey"][1]
				textures = colors["grey"][2]
			elseif r <= 81836 + 5000 + 5000 then
				-- 5%
				self.color = colors["dark_grey"][1]
				textures = colors["dark_grey"][2]
			elseif r <= 81836 + 5000 + 5000 + 5000 then
				-- 5%
				self.color = colors["black"][1]
				textures = colors["black"][2]
			elseif r <= 81836 + 5000 + 5000 + 5000 + 3000 then
				-- 3%
				self.color = colors["brown"][1]
				textures = colors["brown"][2]
			else
				-- 0.164%
				self.color = colors["pink"][1]
				textures = colors["pink"][2]
			end
			self.textures = { textures },
			self.object:set_properties({ textures = textures })
			self.drops = {
				{name = "mcl_mobitems:mutton",
				chance = 1,
				min = 1,
				max = 2,},
				{name = "mcl_wool:"..self.color,
				chance = 1,
				min = 1,
				max = 1,},
			}
			self.initial_color_set = true
		end
	end,
	on_rightclick = function(self, clicker)

		if mobs:feed_tame(self, clicker, 1, true, true) then
			return
		end

		local item = clicker:get_wielded_item()
		if item:get_name() == "mcl_tools:shears" and not self.gotten and not self.child then
			self.gotten = true
			local pos = self.object:getpos()
			minetest.sound_play("shears", {pos = pos})
			pos.y = pos.y + 0.5
			if not self.color then
				minetest.add_item(pos, ItemStack("mcl_wool:white "..math.random(1,3)))
			else
				minetest.add_item(pos, ItemStack("mcl_wool:"..self.color.." "..math.random(1,3)))
			end
			self.object:set_properties({
				textures = {"mobs_sheep_sheared.png"},
			})
			if not minetest.setting_getbool("creative_mode") then
				item:add_wear(65535/238)
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
		end
		if minetest.get_item_group(item:get_name(), "dye") == 1 and not self.gotten then
print(item:get_name(), minetest.get_item_group(item:get_name(), "dye"))
			local name = item:get_name()
			local pname = name:split(":")[2]

			self.object:set_properties({
				textures = colors[pname][2],
			})
			self.color = colors[pname][1]
			self.drops = {
				{name = "mcl_mobitems:mutton",
				chance = 1,
				min = 1,
				max = 2,},
				{name = "mcl_wool:"..self.color,
				chance = 1,
				min = 1,
				max = 1,},
			}

			if not minetest.setting_getbool("creative_mode") then
				item:take_item()
				clicker:get_inventory():set_stack("main", clicker:get_wield_index(), item)
			end
		end
	end,
})
mobs:register_spawn("mobs_mc:sheep", {"mcl_core:dirt_with_grass"}, 20, 9, 5000, 2, 31000)


-- compatibility
mobs:alias_mob("mobs:sheep", "mobs_mc:sheep")

-- spawn eggs
mobs:register_egg("mobs_mc:sheep", "Spawn Sheep", "spawn_egg_sheep.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Sheep loaded")
end
