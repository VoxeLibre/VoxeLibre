-- daufinsyd
-- My work is under the LGPL terms
-- Model and mobs_blaze.png see https://github.com/22i/minecraft-voxel-blender-models
-- blaze.lua partial copy of mobs_mc/ghast.lua

local S = minetest.get_translator("mobs_mc")

--###################
--################### BLAZE
--###################


mobs:register_mob("mobs_mc:blaze", {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 20,
	hp_max = 20,
	xp_min = 10,
	xp_max = 10,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.79, 0.3},
	rotate = -180,
	visual = "mesh",
	mesh = "mobs_mc_blaze.b3d",
	textures = {
		{"mobs_mc_blaze.png"},
	},
	armor = { fleshy = 100, snowball_vulnerable = 100, water_vulnerable = 100 },
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
		max = 1,
		looting = "common",},
	},
	animation = {
		stand_speed = 25,
		stand_start = 0,
	        stand_end = 100,
	        walk_speed = 25,
		walk_start = 0,
		walk_end = 100,
		run_speed = 50,
		run_start = 0,
		run_end = 100,
	},
	-- MC Wiki: takes 1 damage every half second while in water
	water_damage = 2,
	lava_damage = 0,
	fire_damage = 0,
	fall_damage = 0,
	fall_speed = -2.25,
	light_damage = 0,
	view_range = 16,
	attack_type = "dogshoot",
	arrow = "mobs_mc:blaze_fireball",
	shoot_interval = 3.5,
	shoot_offset = 1.0,
	passive = false,
	jump = true,
	jump_height = 4,
	fly = true,
	makes_footstep_sound = false,
	fear_height = 0,
	glow = 14,
	fire_resistant = true,
})

mobs:spawn_specific("mobs_mc:blaze", mobs_mc.spawn.nether_fortress, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 5000, 3, mobs_mc.spawn_height.nether_min, mobs_mc.spawn_height.nether_max)

-- Blaze fireball
mobs:register_arrow("mobs_mc:blaze_fireball", {
	visual = "sprite",
	visual_size = {x = 0.3, y = 0.3},
	textures = {"mcl_fire_fire_charge.png"},
	velocity = 15,

	-- Direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		if rawget(_G, "armor") and armor.last_damage_types then
			armor.last_damage_types[player:get_player_name()] = "fireball"
		end
		mcl_burning.set_on_fire(player, 5, 1, "blaze")
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 5},
		}, nil)
	end,

	hit_mob = function(self, mob)
		mcl_burning.set_on_fire(mob, 5)
		mob:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 5},
		}, nil)
	end,

	hit_object = function(self, object)
		local lua = object:get_luaentity()
		if lua then
			if lua.name == "mcl_minecarts:tnt_minecart" then
				lua:on_activate_by_rail(2)
			end
		end
	end,

	-- Node hit, make fire
	hit_node = function(self, pos, node)
		if node.name == "air" then
			minetest.set_node(pos_above, {name=mobs_mc.items.fire})
		else
			local v = self.object:get_velocity()
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
