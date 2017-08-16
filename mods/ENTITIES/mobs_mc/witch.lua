--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")

--###################
--################### WITCH
--###################




mobs:register_mob("mobs_mc:witch", {
	type = "monster",
	hp_min = 26,
	hp_max = 26,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_witch.b3d",
	textures = {
		{"mobs_mc_witch.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	damage = 2,
	reach = 2,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	pathfinding = 1,
	group_attack = true,
	attack_type = "dogshoot",
	arrow = "mobs:potion_arrow",
	shoot_interval = 2.5,
	shoot_offset = 1,
	dogshoot_switch = 1,
	dogshoot_count_max =1.8,
	max_drops = 3,
	drops = {
		{name = mobs_mc.items.glass_bottle, chance = 8, min = 0, max = 2,},
		{name = mobs_mc.items.glowstone_dust, chance = 8, min = 0, max = 2,},
		{name = mobs_mc.items.gunpowder, chance = 8, min = 0, max = 2,},
		{name = mobs_mc.items.redstone, chance = 8, min = 0, max = 2,},
		{name = mobs_mc.items.spider_eye, chance = 8, min = 0, max = 2,},
		{name = mobs_mc.items.sugar, chance = 8, min = 0, max = 2,},
		{name = mobs_mc.items.stick, chance = 4, min = 0, max = 2,},
	},
	sounds = {
		random = "Villager1",
		death = "Villagerdead",
		damage = "Villagerhurt1",
		distance = 16,
	},
	animation = {
		speed_normal = 30,
		speed_run = 60,
		stand_start = 0,
		stand_end = 0,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
		hurt_start = 85,
		hurt_end = 115,
		death_start = 117,
		death_end = 145,
		shoot_start = 50,
		shoot_end = 82,
	},
	water_damage = 1,
	lava_damage = 5,
	light_damage = 0,
	view_range = 16,
	fear_height = 4,

})

-- fireball (weapon)
mobs:register_arrow(":mobs:potion_arrow", {
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	--textures = {"vessels_glass_bottle.png"},  --TODO fix to else if default
	textures = {"mcl_potions_dragon_breath.png"},
	velocity = 6,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 2},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 2},
		}, nil)
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		--mobs:explosion(pos, 1, 1, 0)
	end
})

-- TODO: Spawn when witch works properly
--mobs:spawn_specific("mobs_mc:witch", mobs_mc.spawn.jungle, {"air"}, 0, minetest.LIGHT_MAX-6, 12, 20000, 2, mobs_mc.spawn_height.water-6, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:witch", S("Witch"), "mobs_mc_spawn_icon_witch.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC mobs loaded")
end
