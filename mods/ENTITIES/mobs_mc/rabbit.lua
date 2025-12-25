--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local rabbit = {
	description = S("Rabbit"),
	type = "animal",
	spawn_class = "passive",
	spawn_in_group_min = 2,
	spawn_in_group = 3,
	passive = true,
	reach = 1,
	initial_properties = {
		hp_min = 3,
		hp_max = 3,
		collisionbox = {-0.2, -0.01, -0.2, 0.2, 0.49, 0.2},
	},
	xp_min = 1,
	xp_max = 3,
	head_swivel = "head.control",
	head_eye_height = 0.35,
	head_bone_position = vector.new( 0, 2, -.3 ), -- for minetest <= 5.8
	curiosity = 20,
	head_yaw="z",
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
	sounds = {
		random = "mobs_mc_rabbit_random",
		damage = "mobs_mc_rabbit_hurt",
		death = "mobs_mc_rabbit_death",
		attack = "mobs_mc_rabbit_attack",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	makes_footstep_sound = false,
	walk_velocity = 1,
	run_velocity = 3.7,
	follow_velocity = 1.1,
	floats = 1,
	runaway = true,
	runaway_from = {"mobs_mc:wolf"},
	jump = true,
	drops = {
		{name = "mcl_mobitems:rabbit", chance = 1, min = 0, max = 1, looting = "common",},
		{name = "mcl_mobitems:leather_piece", chance = 1, min = 0, max = 1, looting = "common",},
		{name = "mcl_mobitems:rabbit_foot", chance = 10, min = 0, max = 1, looting = "rare", looting_factor = 0.03,},
	},
	fear_height = 4,
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 20, walk_speed = 20,
		run_start = 0, run_end = 20, run_speed = 30,
	},
	child_animations = {
		stand_start = 21, stand_end = 21,
		walk_start = 21, walk_end = 41, walk_speed = 30,
		run_start = 21, run_end = 41, run_speed = 45,
	},
	-- Follow (yellow) dangelions, carrots and golden carrots
	follow = {
		"mcl_flowers:dandelion",
		"mcl_farming:carrot_item",
		"mcl_farming:carrot_item_gold",
	},
	view_range = 8,
	-- Eat carrots and reduce their growth stage by 1
	replace_rate = 10,
	replace_what = {
		{"mcl_farming:carrot", "mcl_farming:carrot_7", 0},
		{"mcl_farming:carrot_7", "mcl_farming:carrot_6", 0},
		{"mcl_farming:carrot_6", "mcl_farming:carrot_5", 0},
		{"mcl_farming:carrot_5", "mcl_farming:carrot_4", 0},
		{"mcl_farming:carrot_4", "mcl_farming:carrot_3", 0},
		{"mcl_farming:carrot_3", "mcl_farming:carrot_2", 0},
		{"mcl_farming:carrot_2", "mcl_farming:carrot_1", 0},
		{"mcl_farming:carrot_1", "air", 0},
	},
	on_rightclick = function(self, clicker)
		-- Feed, tame protect or capture
		if self:feed_tame(clicker, 1, true, false) then return end
		if mcl_mobs:protect(self, clicker) then return end
		if mcl_mobs:capture_mob(self, clicker, 0, 50, 80, false, nil) then return end
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

mcl_mobs.register_mob("mobs_mc:rabbit", rabbit)

-- The killer bunny (Only with spawn egg)
local killer_bunny = table.copy(rabbit)
killer_bunny.description = S("Killer Bunny")
killer_bunny.type = "monster"
killer_bunny.spawn_class = "hostile"
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

mcl_mobs.register_mob("mobs_mc:killer_bunny", killer_bunny)

-- Mob spawning rules.
-- Different skins depending on spawn location <- we'll get to this when the spawning algorithm is fleshed out

mcl_mobs:spawn_setup({
	name = "mobs_mc:rabbit",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = {
		"Desert",
		"FlowerForest",
		"Taiga",
		"MegaSpruceTaiga",
		"MegaTaiga",
		"ColdTaiga",
	},
	min_light = 9,
	max_light = minetest.LIGHT_MAX+1,
	chance = 40,
	interval = 30,
	aoc = 8,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max
})

--[[
local spawn = {
	name = "mobs_mc:rabbit",
	neighbors = {"air"},
	chance = 15000,
	active_object_count = 10,
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	min_height = mcl_vars.mg_overworld_min,
	max_height = mcl_vars.mg_overworld_max,
}

local spawn_desert = table.copy(spawn)
spawn_desert.nodes = { "mcl_core:sand", "mcl_core:sandstone" }
spawn_desert.on_spawn = function(self, pos)
	local texture = "mobs_mc_rabbit_gold.png"
	self.base_texture = { "mobs_mc_rabbit_gold.png" }
	self.object:set_properties({textures = self.base_texture})
end
mcl_mobs:spawn(spawn_desert)

local spawn_snow = table.copy(spawn)
spawn_snow.nodes = { "mcl_core:snow", "mcl_core:snowblock", "mcl_core:dirt_with_grass_snow" }
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
mcl_mobs:spawn(spawn_snow)

local spawn_grass = table.copy(spawn)
spawn_grass.nodes = { "mcl_core:dirt_with_grass" }
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
mcl_mobs:spawn(spawn_grass)
]]--

-- Spawn egg
mcl_mobs.register_egg("mobs_mc:rabbit", S("Rabbit"), "#995f40", "#734831", 0)

-- Note: This spawn egg does not exist in Minecraft
mcl_mobs.register_egg("mobs_mc:killer_bunny", S("Killer Bunny"), "#f2f2f2", "#ff0000", 0)
mcl_mobs:non_spawn_specific("mobs_mc:killer_bunny","overworld",9,minetest.LIGHT_MAX+1)
