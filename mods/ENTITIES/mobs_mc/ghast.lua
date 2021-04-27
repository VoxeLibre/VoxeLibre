--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### GHAST
--###################


mobs:register_mob("mobs_mc:ghast", {
	description = S("Ghast"),
	type = "monster",
	spawn_class = "hostile",
	group_attack = true,
	hostile = true,
	fly_random_while_attack = true,
	hp_min = 10,
	hp_max = 10,
	rotate = 270,
	xp_min = 5,
	xp_max = 5,
	reach = 20,
	eye_height = 2.5,
	collisionbox = {-2, 0, -2, 2, 4, 2},
	visual = "mesh",
	mesh = "mobs_mc_ghast.b3d",
	textures = {
		{"mobs_mc_ghast.png"},
	},
	visual_size = {x=12, y=12},
	sounds = {
		shoot_attack = "mobs_fireball",
		death = "mobs_mc_zombie_death",
		attack = "mobs_fireball",
		random = "mobs_eerie",
		distance = 16,
		-- TODO: damage
		-- TODO: better death
	},

	walk_velocity = 1.6,
	run_velocity = 3.2,

	drops = {
		{name = mobs_mc.items.gunpowder, chance = 1, min = 0, max = 2, looting = "common"},
		{name = mobs_mc.items.ghast_tear, chance = 10/6, min = 0, max = 1, looting = "common", looting_ignore_chance = true},
	},
	animation = {
		stand_speed = 50, walk_speed = 50, run_speed = 50,
		stand_start = 0,		stand_end = 40,
		walk_start = 0,		walk_end = 40,
		run_start = 0,		run_end = 40,
	},

	fall_damage = 0,
	view_range = 28,
	attack_type = "projectile",
	arrow = "mobs_mc:ghast_fireball",
	floats=1,
	fly = true,
	makes_footstep_sound = false,
	fire_resistant = true,
	projectile_cooldown_min = 5,
	projectile_cooldown_max = 7,
	shoot_arrow = function(self, pos, dir)
		-- 2-4 damage per arrow
		local dmg = math.random(2,4)
		mobs.shoot_projectile_handling("mobs_mc:ghast_fireball", pos, dir, self.object:get_yaw(), self.object, 11, dmg,nil,nil,nil,-0.6)
	end,
	--[[
	do_custom = function(self)
		if self.firing == true then
			self.base_texture = {"mobs_mc_ghast_firing.png"}
			self.object:set_properties({textures=self.base_texture})
		else
			self.base_texture = {"mobs_mc_ghast.png"}
			self.object:set_properties({textures=self.base_texture})
		end
	end,
	]]--
})


mobs:spawn_specific(
"mobs_mc:ghast",
"nether",
"ground",
{
"Nether"
},
0,
minetest.LIGHT_MAX+1,
30,
18000,
2,
mobs_mc.spawn_height.nether_min,
mobs_mc.spawn_height.nether_max)

-- fireball (projectile)
mobs:register_arrow("mobs_mc:ghast_fireball", {
	visual = "sprite",
	visual_size = {x = 1, y = 1},
	textures = {"mcl_fire_fire_charge.png"},
	velocity = 15,
	collisionbox = {-.5, -.5, -.5, .5, .5, .5},
	tail = 1,
	tail_texture = "mobs_mc_spit.png^[colorize:black:255", --repurpose spit texture
	tail_size = 5,
	_is_fireball = true,

	hit_player = function(self, player)
		--[[
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 6},
		}, nil)
		]]--
		--mobs:boom(self, self.object:get_pos(), 1, true)
		mcl_explosions.explode(self.object:get_pos(), 3,{ drop_chance = 1.0 })
	end,

	hit_mob = function(self, mob)
		mob:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = self._damage},
		}, nil)
		--mobs:boom(self, self.object:get_pos(), 1, true)
		mcl_explosions.explode(self.object:get_pos(), 3,{ drop_chance = 1.0 })
	end,

	hit_node = function(self, pos, node)
		--mobs:boom(self, pos, 1, true)
		mcl_explosions.explode(self.object:get_pos(), 3,{ drop_chance = 1.0 })
	end
})




-- spawn eggs
mobs:register_egg("mobs_mc:ghast", S("Ghast"), "mobs_mc_spawn_icon_ghast.png", 0)
