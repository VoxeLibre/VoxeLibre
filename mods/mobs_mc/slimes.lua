--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes


--dofile(minetest.get_modpath("mobs").."/api.lua")

mobs:register_mob("mobs_mc:greensmall", {
	type = "monster",
	pathfinding = true,
	group_attack = true,
	hp_max = 5,
	collisionbox = {-0.2, -0.4, -0.2, 0.2, 0.2, 0.2},
	visual_size = {x=0.5, y=0.5},
	textures = {
	{"green_slime_top.png", "green_slime_bottom.png", "green_slime_front.png", "green_slime_sides.png", "green_slime_sides.png", "green_slime_sides.png"}
	},
	visual = "cube",
	blood_texture ="green_slime_blood.png",
	rotate = 270,
	makes_footstep_sound = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
	},
	walk_velocity = .8,
	run_velocity = 2.6,
	damage = 1,
	armor = 100,
	drops = {
		{name = "mesecons_materials:glue 1",
		chance = 3,
		min = 1,
		max = 4,},
		{name = "default:grass",
		chance = 1,
		min = 1,
		max = 5,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		hurt_start = 64,
		hurt_end = 86,
		death_start = 88,
		death_end = 118,
	},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 10,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	jump_height = 4,
	jump_chance = 98,
	fear_height = 12,	
})

mobs:register_mob("mobs_mc:greenmedium", {
	type = "monster",
	pathfinding = true,
	group_attack = true,
	hp_max = 10,
	collisionbox = {-0.55, -0.55, -0.55, 0.55, 0.55, 0.55},
	visual_size = {x=1.0, y=1.0},
	textures = {
	{"green_slime_top.png", "green_slime_bottom.png", "green_slime_front.png", "green_slime_sides.png", "green_slime_sides.png", "green_slime_sides.png"}
	},
	visual = "cube",
	blood_texture ="green_slime_blood.png",
	rotate = 270,
	makes_footstep_sound = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
	},
	walk_velocity = .8,
	run_velocity = 2.0,
	damage = 2,
	armor = 100,
	drops = {
		{name = "default:mossycobble",
		chance = 2,
		min = 1,
		max = 1,},
		{name = "default:leaves",
		chance = 1,
		min = 1,
		max = 5,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		hurt_start = 64,
		hurt_end = 86,
		death_start = 88,
		death_end = 118,
	},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 10,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	jump_height = 8,
	jump_chance = 100,
	fear_height = 60,
	on_die =function(self, pos)
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:greensmall")
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:greensmall")
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:greensmall")
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:greensmall")
			ent = lavasmall:get_luaentity()
			end
})

mobs:register_mob("mobs_mc:greenbig", {
	type = "monster",
	pathfinding = true,
	group_attack = true,
	hp_max = 25,
	collisionbox = {-0.75, -0.75, -0.75, 0.75, 0.75, 0.75},
	visual_size = {x=1.5, y=1.5},
	textures = {
	{"green_slime_top.png", "green_slime_bottom.png", "green_slime_front.png", "green_slime_sides.png", "green_slime_sides.png", "green_slime_sides.png"}
	},
	visual = "cube",
	blood_texture ="green_slime_blood.png",
	rotate = 270,
	makes_footstep_sound = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 2,
	armor = 100,
	drops = {
		{name = "default:leaves",
		chance = 2,
		min = 1,
		max = 1,},
		{name = "default:papyrus",
		chance = 1,
		min = 1,
		max = 5,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		hurt_start = 64,
		hurt_end = 86,
		death_start = 88,
		death_end = 118,
	},
	drawtype = "front",
	water_damage = 0,
	lava_damage = 10,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	jump_height = 8,
	jump_chance = 100,
	fear_height = 60,
	on_die =function(self, pos)
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:greenmedium")
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:greenmedium")
			ent = lavasmall:get_luaentity()
			end
})
mobs:register_spawn("mobs_mc:greensmall", {"default:flowing_water", "default:mossycobble"}, 7, -1, 5000, 4, 31000)
mobs:register_spawn("mobs_mc:greenmedium", {"default:flowing_water", "default:mossycobble"}, 7, -1, 5000, 4, 31000)
mobs:register_spawn("mobs_mc:greenbig", {"default:flowing_water", "default:mossycobble"}, 7, -1, 5000, 4, 31000)




mobs:register_mob("mobs_mc:lavasmall", {
	type = "monster",
	pathfinding = true,
	group_attack = true,
	hp_max = 15,
	collisionbox = {-0.2, -0.4, -0.2, 0.2, 0.2, 0.2},
	visual_size = {x=0.5, y=0.5},
	textures = {
	{"lava_slime_top.png", "lava_slime_bottom.png", "lava_slime_front.png", "lava_slime_sides.png", "lava_slime_sides.png", "lava_slime_sides.png"}
	},
	visual = "cube",
	blood_texture ="lava_slime_blood.png",
	rotate = 270,
	makes_footstep_sound = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
	},
	walk_velocity = .8,
	run_velocity = 2.6,
	damage = 1,
	armor = 100,
	drops = {
		{name = "tnt:gunpowder",
		chance = 3,
		min = 1,
		max = 1,},
		{name = "default:coal",
		chance = 1,
		min = 1,
		max = 5,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		hurt_start = 64,
		hurt_end = 86,
		death_start = 88,
		death_end = 118,
	},
	drawtype = "front",
	water_damage = 10,
	lava_damage = 0,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	jump_height = 4,
	jump_chance = 98,
	fear_height = 12,	
})

mobs:register_mob("mobs_mc:lavabig", {
	type = "monster",
	pathfinding = true,
	group_attack = true,
	hp_max = 15,
	collisionbox = {-0.75, -0.75, -0.75, 0.75, 0.75, 0.75},
	visual_size = {x=1.5, y=1.5},
	textures = {
	{"lava_slime_top.png", "lava_slime_bottom.png", "lava_slime_front.png", "lava_slime_sides.png", "lava_slime_sides.png", "lava_slime_sides.png"}
	},
	visual = "cube",
	blood_texture ="lava_slime_blood.png",
	rotate = 270,
	makes_footstep_sound = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
	},
	walk_velocity = .8,
	run_velocity = 1.6,
	damage = 2,
	armor = 100,
	drops = {
		{name = "tnt:gunpowder",
		chance = 2,
		min = 1,
		max = 1,},
		{name = "mobs_mc:lavasmall",
		chance = 1,
		min = 1,
		max = 5,},
	},
	animation = {
		speed_normal = 24,
		speed_run = 48,
		stand_start = 0,
		stand_end = 23,
		walk_start = 24,
		walk_end = 47,
		run_start = 48,
		run_end = 62,
		hurt_start = 64,
		hurt_end = 86,
		death_start = 88,
		death_end = 118,
	},
	drawtype = "front",
	water_damage = 10,
	lava_damage = 0,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	jump_height = 8,
	jump_chance = 100,
	fear_height = 60,
	on_die =function(self, pos)
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:lavasmall")
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:lavasmall")
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:lavasmall")
		lavasmall = minetest.add_entity(self.object:getpos(), "mobs_mc:lavasmall")
			ent = lavasmall:get_luaentity()
			end
})

mobs:register_spawn("mobs_mc:lavasmall", {"nether:rack", "default:lava"}, 7, -1, 5000, 4, 31000)
mobs:register_spawn("mobs_mc:lavabig", {"nether:rack", "default:lava"}, 7, -1, 5000, 4, 31000)

-- compatibility
mobs:alias_mob("mobs:lavasmall", "mobs_mc:lavasmall")
mobs:alias_mob("mobs:lavabig", "mobs_mc:lavabig")
mobs:alias_mob("mobs:greensmall", "mobs_mc:greensmall")
mobs:alias_mob("mobs:greenmediuml", "mobs_mc:greenmedium")
mobs:alias_mob("mobs:greenbig", "mobs_mc:greenbig")

mobs:alias_mob("slimes:lavasmall", "mobs_mc:lavasmall")
mobs:alias_mob("slimes:lavabig", "mobs_mc:lavabig")
mobs:alias_mob("slimes:greensmall", "mobs_mc:greensmall")
mobs:alias_mob("slimes:greenmediuml", "mobs_mc:greenmedium")
mobs:alias_mob("slimes:greenbig", "mobs_mc:greenbig")


-- spawn eggs
mobs:register_egg("mobs_mc:lavabig", "Magma Cube", "spawn_egg_magma_cube.png")
mobs:register_egg("mobs_mc:greenbig", "Green Slime", "spawn_egg_slime.png")


if minetest.setting_get("log_mods") then
	minetest.log("action", "MC Slimes loaded")
end
