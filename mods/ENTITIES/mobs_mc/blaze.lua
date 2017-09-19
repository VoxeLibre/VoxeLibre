-- daufinsyd
-- My work is under the LGPL terms
-- Model and mobs_blaze.png see https://github.com/22i/minecraft-voxel-blender-models
-- blaze.lua partial copy of mobs_mc/ghast.lua

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

--dofile(minetest.get_modpath("mobs").."/api.lua")
--###################
--################### BLAZE
--###################


mobs:register_mob("mobs_mc:blaze", {
	type = "monster",
	hp_min = 20,
	hp_max = 20,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.79, 0.3},
	rotate = -180,
	visual = "mesh",
	mesh = "mobs_mc_blaze.b3d",
	textures = {
		{"mobs_mc_blaze.png"},
	},
	visual_size = {x=3, y=3},
	sounds = {
		random = "mobs_mc_blaze_breath",
		death = "mobs_mc_blaze_died",
		damage = "mobs_mc_blaze_hurt",
		distance = 16,
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 6,
	reach = 2,
	pathfinding = 1,
	drops = {
		{name = mobs_mc.items.blaze_rod,
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
	-- MC Wiki: takes 1 damage every half second while in water
	water_damage = 2,
	lava_damage = 0,
	fall_damage = 0,
	fall_speed = -2.25,
	light_damage = 0,
	view_range = 16,
	attack_type = "dogshoot",
	arrow = "mobs_mc:blaze_fireball",
	shoot_interval = 3.5,
	passive = false,
	jump = true,
	jump_height = 4,
	fly = true,
	jump_chance = 98,
	fear_height = 120,
	blood_amount = 0,
})

mobs:spawn_specific("mobs_mc:blaze", mobs_mc.spawn.nether_fortress, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 5000, 3, mobs_mc.spawn_height.nether_min, mobs_mc.spawn_height.nether_max)

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
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 5},
		}, nil)
	end,

	-- Node hit, make fire
	hit_node = function(self, pos, node)
		if node.name == "air" then
			minetest.set_node(pos_above, {name=mobs_mc.items.fire})
		else
			local v = self.object:getvelocity()
			v = vector.normalize(v)
			local crashpos = vector.subtract(pos, v)
			local crashnode = minetest.get_node(crashpos)
			-- Set fire if node is air, or a replacable flammable node (e.g. a plant)
			if crashnode.name == "air" or
					(minetest.registered_nodes[crashnode.name].buildable_to and minetest.get_item_group(crashnode.name, "flammable") >= 1) then
				minetest.set_node(crashpos, {name=mobs_mc.items.fire})
			end
		end
	end
})

-- spawn eggs
mobs:register_egg("mobs_mc:blaze", S("Blaze"), "mobs_mc_spawn_icon_blaze.png", 0)






if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Blaze loaded")
end
