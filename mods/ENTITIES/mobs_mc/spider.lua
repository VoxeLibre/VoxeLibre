--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### SPIDER
--###################


-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)

local spider = {
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	docile_by_day = true,
	attack_type = "dogfight",
	pathfinding = 1,
	damage = 2,
	reach = 2,
	hp_min = 16,
	hp_max = 16,
	armor = {fleshy = 100, arthropod = 100},
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 0.89, 0.7},
	visual = "mesh",
	mesh = "mobs_mc_spider.b3d",
	textures = {
		{"mobs_mc_spider.png^(mobs_mc_spider_eyes.png^[makealpha:0,0,0)"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_spider",
		attack = "mobs_spider",
		-- TODO: sounds: walk, death
		distance = 16,
	},
	walk_velocity = 1.3,
	run_velocity = 2.8,
	jump = true,
	jump_height = 4,
	view_range = 16,
	floats = 1,
	drops = {
		{name = mobs_mc.items.string, chance = 1, min = 0, max = 2,},
		{name = mobs_mc.items.spider_eye, chance = 3, min = 1, max = 1,},
	},
	specific_attack = { "player", "mobs_mc:iron_golem" },
	fear_height = 4,
	animation = {
		stand_speed = 10,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 20,
		stand_end = 40,
		walk_start = 0,
		walk_end = 20,
		run_start = 0,
		run_end = 20,
	},
}
mobs:register_mob("mobs_mc:spider", spider)

-- Cave spider
local cave_spider = table.copy(spider)
cave_spider.textures = { {"mobs_mc_cave_spider.png^(mobs_mc_spider_eyes.png^[makealpha:0,0,0)"} }
-- TODO: Poison damage
-- TODO: Revert damage to 2
cave_spider.damage = 3 -- damage increased to undo non-existing poison
cave_spider.hp_min = 1
cave_spider.hp_max = 12
cave_spider.collisionbox = {-0.35, -0.01, -0.35, 0.35, 0.49, 0.35}
cave_spider.visual_size = {x=1.66666, y=1.5}
cave_spider.walk_velocity = 1.3
cave_spider.run_velocity = 3.2
mobs:register_mob("mobs_mc:cave_spider", cave_spider)


mobs:spawn_specific("mobs_mc:spider", mobs_mc.spawn.solid, {"air"}, 0, 7, 30, 17000, 2, mobs_mc.spawn_height.overworld_min, mobs_mc.spawn_height.overworld_max)

-- spawn eggs
mobs:register_egg("mobs_mc:spider", S("Spider"), "mobs_mc_spawn_icon_spider.png", 0)
mobs:register_egg("mobs_mc:cave_spider", S("Cave Spider"), "mobs_mc_spawn_icon_cave_spider.png", 0)
