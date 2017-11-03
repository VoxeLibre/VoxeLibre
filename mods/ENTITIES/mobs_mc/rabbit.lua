--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

local rabbit = {
	type = "animal",
	passive = true,
	reach = 1,

	hp_min = 3,
	hp_max = 3,
	collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.49, 0.2},

	visual = "mesh",
	mesh = "mobs_mc_rabbit.b3d",
	textures = {
        {"mobs_mc_rabbit_brown.png"},
        {"mobs_mc_rabbit_gold.png"},
        {"mobs_mc_rabbit_white.png"},
        {"mobs_mc_rabbit_white_splotched.png"},
        {"mobs_mc_rabbit_salt.png"},
        {"mobs_mc_rabbit_black.png"},
	},
	visual_size = {x=1.5, y=1.5},
	sounds = {},
	makes_footstep_sound = false,
	walk_velocity = 1,
	run_velocity = 3.7,
	floats = 1,
	runaway = true,
	jump = true,
	drops = {
		{name = mobs_mc.items.rabbit_raw, chance = 1, min = 0, max = 1},
		{name = mobs_mc.items.rabbit_hide, chance = 1, min = 0, max = 1},
		{name = mobs_mc.items.rabbit_foot, chance = 10, min = 1, max = 1},
	},
	water_damage = 1,
	lava_damage = 4,
	light_damage = 0,
	fear_height = 4,
	animation = {
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	-- Follow (yellow) dangelions, carrots and golden carrots
	follow = mobs_mc.follow.rabbit,
	view_range = 8,
	-- Eat carrots and reduce their growth stage by 1
	replace_rate = 10,
	replace_what = mobs_mc.replace.rabbit,
	on_rightclick = function(self, clicker)
		-- Feed, tame protect or capture
		if mobs:feed_tame(self, clicker, 1, true, true) then return end
		if mobs:protect(self, clicker) then return end
		if mobs:capture_mob(self, clicker, 0, 50, 80, false, nil) then return end
	end,
	do_custom = function(self)
		-- Easter egg: Change texture if rabbit is named “Toast”
		if self.nametag == "Toast" and not self._has_toast_texture then
			self._original_rabbit_texture = self.base_texture
			self.base_texture = { "mobs_mc_rabbit_toast.png" }
			self.object:set_properties({ textures = self.base_texture })
			self._has_toast_texture = true
		elseif self.nametag ~= "Toast" and self._has_toast_texture then
			self.base_texture = self._original_rabbit_texture
			self.object:set_properties({ textures = self.base_texture })
			self._has_toast_texture = false
		end
	end,
}

mobs:register_mob("mobs_mc:rabbit", rabbit)

-- The killer bunny (Only with spawn egg)
local killer_bunny = table.copy(rabbit)
killer_bunny.type = "monster"
killer_bunny.attack_type = "dogfight"
killer_bunny.specific_attack = { "player", "mobs_mc:wolf", "mobs_mc:dog" }
killer_bunny.damage = 8
killer_bunny.passive = false
-- 8 armor points
killer_bunny.armor = 50
killer_bunny.textures = { "mobs_mc_rabbit_caerbannog.png" }
killer_bunny.view_range = 16
killer_bunny.replace_rate = nil
killer_bunny.replace_what = nil
killer_bunny.on_rightclick = nil
killer_bunny.run_velocity = 6
killer_bunny.do_custom = function(self)
	if not self._killer_bunny_nametag_set then
		self.nametag = "The Killer Bunny"
		self._killer_bunny_nametag_set = true
	end
end

mobs:register_mob("mobs_mc:killer_bunny", killer_bunny)

-- Mob spawning rules.
-- Different skins depending on spawn location

local spawn = {
	name = "mobs_mc:rabbit",
	neighbors = {"air"},
	chance = 15000,
	active_object_count = 99,
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	min_height = mobs_mc.spawn_height.overworld_min,
	max_height = mobs_mc.spawn_height.overworld_max,
}

local spawn_desert = table.copy(spawn)
spawn_desert.nodes = mobs_mc.spawn.desert
spawn_desert.on_spawn = function(self, pos)
	local texture = "mobs_mc_rabbit_gold.png"
	self.base_texture = { "mobs_mc_rabbit_gold.png" }
	self.object:set_properties({textures = self.base_texture})
end
mobs:spawn(spawn_desert)

local spawn_snow = table.copy(spawn)
spawn_snow.nodes = mobs_mc.spawn.snow
spawn_snow.on_spawn = function(self, pos)
	local texture
	local r = math.random(1, 100)
	-- 80% white fur
	if r <= 80 then
		texture = "mobs_mc_rabbit_white.png"
	-- 20% black and white fur
	else
		texture = "mobs_mc_rabbit_white_splotched.png"
	end
	self.base_texture = { texture }
	self.object:set_properties({textures = self.base_texture})
end
mobs:spawn(spawn_snow)

local spawn_grass = table.copy(spawn)
spawn_grass.nodes = mobs_mc.spawn.grassland
spawn_grass.on_spawn = function(self, pos)
	local texture
	local r = math.random(1, 100)
	-- 50% brown fur
	if r <= 50 then
		texture = "mobs_mc_rabbit_brown.png"
	-- 40% salt fur
	elseif r <= 90 then
		texture = "mobs_mc_rabbit_salt.png"
	-- 10% black fur
	else
		texture = "mobs_mc_rabbit_black.png"
	end
	self.base_texture = { texture }
	self.object:set_properties({textures = self.base_texture})
end
mobs:spawn(spawn_grass)

-- Spawn egg
mobs:register_egg("mobs_mc:rabbit", S("Rabbit"), "mobs_mc_spawn_icon_rabbit.png", 0)

-- Note: This spawn egg does not exist in Minecraft
mobs:register_egg("mobs_mc:killer_bunny", S("Killer Bunny"), "mobs_mc_spawn_icon_rabbit.png^[colorize:#FF0000:192", 0) -- TODO: Update inventory image


-- compatibility
mobs:alias_mob("mobs:bunny", "mobs_mc:rabbit")

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Bunny loaded")
end
