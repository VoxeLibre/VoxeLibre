--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")

--###################
--################### GHAST
--###################


mobs:register_mob("mobs_mc:ghast", {
	type = "monster",
	pathfinding = 1,
	group_attack = true,
	hp_min = 10,
	hp_max = 10,
	collisionbox = {-2, 5, -2, 2, 9, 2},
	visual = "mesh",
	mesh = "mobs_mc_ghast.b3d",
	textures = {
		{"mobs_mc_ghast.png"},
	},
	visual_size = {x=12, y=12},
	sounds = {
		shoot = "mobs_fireball",
		death = "zombiedeath",
		damage = "ghast_damage",
		attack = "mobs_fireball",
		random = "mobs_eerie",
	},
	walk_velocity = 1.6,
	run_velocity = 3.2,
	drops = {
		{name = mobs_mc.items.gunpowder,
		chance = 1,
		min = 0,
		max = 2,},
		{name = mobs_mc.items.ghast_tear,
		chance = 1,
		min = 0,
		max = 1,},
	},
	animation = {
		stand_speed = 50, walk_speed = 50, run_speed = 50,
		stand_start = 0,		stand_end = 40,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},
	lava_damage = 4,
	light_damage = 0,
	fall_damage = 0,
	view_range = 100,
	--attack_type = "dogshoot",
	attack_type = "dogshoot",
	arrow = "mobs_monster:fireball",
	shoot_interval = 3.5,
	shoot_offset = 1,
		--'dogshoot_switch' allows switching between shoot and dogfight modes inside dogshoot using timer (1 = shoot, 2 = dogfight)
	--'dogshoot_count_max' number of seconds before switching above modes.
	dogshoot_switch = 1,
	dogshoot_count_max =1,
	passive = false,
	jump = true,
	jump_height = 4,
	floats=1,
	fly = true,
	fly_in = {"air"},
	jump_chance = 98,
	fear_height = 120,	
	blood_amount = 0,
})


mobs:spawn_specific("mobs_mc:ghast", mobs_mc.spawn.nether, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 18000, 2, mobs_mc.spawn_height.nether_min, mobs_mc.spawn_height.nether_max)

-- fireball (weapon)
mobs:register_arrow(":mobs_monster:fireball", {
	visual = "sprite",
	visual_size = {x = 0.5, y = 0.5},
	textures = {"mcl_fire_fire_charge.png"},
	velocity = 6,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 8},
		}, nil)
	end,

	-- node hit, bursts into flame
	hit_node = function(self, pos, node)
		mobs:explosion(pos, 1, 1, 0)
	end
})




-- spawn eggs
mobs:register_egg("mobs_mc:ghast", S("Ghast"), "mobs_mc_spawn_icon_ghast.png", 0)

if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Ghast loaded")
end
