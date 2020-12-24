--###################
--################### ENDERDRAGON
--###################

local S = minetest.get_translator("mobs_mc")

mobs:register_mob("mobs_mc:enderdragon", {
	type = "monster",
	spawn_class = "hostile",
	pathfinding = 1,
	attacks_animals = true,
	walk_chance = 100,
	hp_max = 200,
	hp_min = 200,
	xp_min = 500,
	xp_max = 500,
	collisionbox = {-2, 3, -2, 2, 5, 2},
	physical = false,
	visual = "mesh",
	mesh = "mobs_mc_dragon.b3d",
	textures = {
		{"mobs_mc_dragon.png"},
	},
	visual_size = {x=3, y=3},
	view_range = 35,
	walk_velocity = 6,
	run_velocity = 6,
	sounds = {
		-- TODO: more sounds
		shoot_attack = "mobs_mc_ender_dragon_shoot",
		attack = "mobs_mc_ender_dragon_attack",
		distance = 60,
	},
	physical = true,
	damage = 10,
	jump = true,
	jump_height = 14,
	fly = true,
	makes_footstep_sound = false,
	dogshoot_switch = 1,
	dogshoot_count_max =5,
	dogshoot_count2_max = 5,
	passive = false,
	attack_animals = true,
	lava_damage = 0,
	fire_damage = 0,
	on_rightclick = nil,
	attack_type = "dogshoot",
	arrow = "mobs_mc:dragon_fireball",
	shoot_interval = 0.5,
	shoot_offset = -1.0,
	xp_min = 12000,
	xp_max = 12000,
	animation = {
		fly_speed = 8, stand_speed = 8,
		stand_start = 0,		stand_end = 20,
		walk_start = 0,		walk_end = 20,
		run_start = 0,		run_end = 20,
	},
	ignores_nametag = true,
	on_die = function(self, own_pos)
		if self._egg_spawn_pos then
			local pos = minetest.string_to_pos(self._egg_spawn_pos)
			--if minetest.get_node(pos).buildable_to then
				minetest.set_node(pos, {name = mobs_mc.items.dragon_egg})
				return
			--end
		end
		minetest.add_item(own_pos, mobs_mc.items.dragon_egg)
	end,
	fire_resistant = true,
})


local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

-- dragon fireball (projectile)
mobs:register_arrow("mobs_mc:dragon_fireball", {
	visual = "sprite",
	visual_size = {x = 1.25, y = 1.25},
	textures = {"mobs_mc_dragon_fireball.png"},
	velocity = 6,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 12},
		}, nil)
	end,

	hit_mob = function(self, mob)
		minetest.sound_play("tnt_explode", {pos = mob:get_pos(), gain = 1.5, max_hear_distance = 2*64}, true)
		mob:punch(self.object, 1.0, {
			full_punch_interval = 0.5,
			damage_groups = {fleshy = 12},
		}, nil)
	end,

	-- node hit, explode
	hit_node = function(self, pos, node)
		mobs:boom(self, pos, 2)
	end
})

mobs:register_egg("mobs_mc:enderdragon", S("Ender Dragon"), "mobs_mc_spawn_icon_dragon.png", 0, true)
