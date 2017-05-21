-- daufinsyd
-- My work is under the LGPL terms
-- Model and mobs_blaze.png see https://github.com/22i/minecraft-voxel-blender-models
-- blaze.lua partial copy of mobs_mc/ghast.lua



--dofile(minetest.get_modpath("mobs").."/api.lua")



mobs:register_mob("mobs_mc:blaze", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.4, 0.4, -0.4, 0.4, 1.9, 0.4},
	textures = {
	{"mobs_blaze.png"}
	},
	visual = "mesh",
	mesh = "mobs_blaze.b3d",
	makes_footstep_sound = true,
	sounds = {
		random = "blaze_breath",
		death = "blaze_died",
		damage = "blaze_hurt1",
		attack = "default_punch3",
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 2.5,
	pathfinding = 1,
	group_attack = true,
	armor = 80,
	drops = {
		{name = "mcl_mobitems:blaze_rod",
		chance = 1,
		min = 0,
		max = 1,},
	},
	animation = {
		stand_start = 1,
		stand_end = 40,
		walk_start = 1,
		walk_end = 40,
		run_start = 1,
		run_end = 40,
        shoot_start = 1,
        shoot_end = 40,
	},
	drawtype = "front",
	-- MC Wiki: 1 damage every half second
	water_damage = 2,
	lava_damage = 0,
	fall_damage = 0,
	light_damage = 0,
	view_range = 16,
	attack_type = "shoot",
    arrow = "mobs_mc:blaze_fireball",
    shoot_interval = 3.5,
    passive = false,
    jump = true,
	jump_height = 4,
    floats = 1,
    fly = true,
    jump_chance = 98,
    fear_height = 120,
})

mobs:register_spawn("mobs_mc:blaze", {"mcl_core:lava_flowing", "mcl_nether:netherrack","air"}, 30, -1, 5000, 1, -1000)

-- Blaze fireball
mobs:register_arrow("mobs_mc:blaze_fireball", {
	visual = "sprite",
	visual_size = {x = 0.3, y = 0.3},
	textures = {"mcl_fire_fire_charge.png"},
	velocity = 12,

	-- Direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 5},
		}, nil)
		mcl_hunger.exhaust(player:get_player_name(), mcl_hunger.EXHAUST_DAMAGE)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 5},
		}, nil)
	end,

	-- Node hit, make fire
	hit_node = function(self, pos, node)
		local pos_above = {x=pos.x, y=pos.y+1, z=pos.z}
		if minetest.registered_nodes[minetest.get_node(pos_above).name].buildable_to then
			minetest.set_node(pos_above, {name="mcl_fire:fire"})
		end
	end
})

-- spawn eggs
mobs:register_egg("mobs_mc:blaze", "Spawn Blaze", "spawn_egg_blaze.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Blaze loaded")
end
