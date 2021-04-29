--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### SHULKER
--###################

-- animation 45-80 is transition between passive and attack stance

mobs:register_mob("mobs_mc:shulker", {
	description = S("Shulker"),
	type = "monster",
	spawn_class = "hostile",
	attack_type = "projectile",
	shoot_interval = 0.5,
	arrow = "mobs_mc:shulkerbullet",
	shoot_offset = 0.5,
	passive = false,
	hp_min = 30,
	hp_max = 30,
	xp_min = 5,
	xp_max = 5,
	armor = 150,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 0.99, 0.5},
	visual = "mesh",
	mesh = "mobs_mc_shulker.b3d",
	textures = { "mobs_mc_endergolem.png", },
	-- TODO: sounds
	-- TODO: Make shulker dye-able
	visual_size = {x=3, y=3},
	walk_chance = 0,
	jump = false,
	drops = {
		{name = mobs_mc.items.shulker_shell,
		chance = 2,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.0625},
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50, punch_speed = 25,
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 45,
		walk_start = 0,		walk_end = 45,
		run_start = 0,		run_end = 45,
        punch_start = 80,  punch_end = 100,
	},
	view_range = 16,
	fear_height = 4,
})

-- bullet arrow (weapon)
mobs:register_arrow("mobs_mc:shulkerbullet", {
	visual = "sprite",
	visual_size = {x = 0.25, y = 0.25},
	textures = {"mobs_mc_shulkerbullet.png"},
	velocity = 6,

	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 4},
		}, nil)
	end,

	hit_mob = function(self, mob)
		mob:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 4},
		}, nil)
	end,

	hit_node = function(self, pos, node)
	end
})


mobs:register_egg("mobs_mc:shulker", S("Shulker"), "mobs_mc_spawn_icon_shulker.png", 0)

mobs:spawn_specific(
"mobs_mc:shulker",
"end",
"ground",
{
"End"
},
0,
minetest.LIGHT_MAX+1,
30,
5000,
2,
mobs_mc.spawn_height.end_min,
mobs_mc.spawn_height.end_max)
