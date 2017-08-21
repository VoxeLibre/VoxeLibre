--License for code WTFPL and otherwise stated in readmes

-- intllib
local MP = minetest.get_modpath(minetest.get_current_modname())
local S, NS = dofile(MP.."/intllib.lua")

-- Slime
local slime_big = {
	type = "monster",
	pathfinding = 1,
	group_attack = true,
	hp_min = 16,
	hp_max = 16,
	collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{"mobs_mc_slime.png"}},
	visual = "mesh",
	mesh = "mobs_mc_slime.b3d",
	blood_texture ="mobs_mc_slime_blood.png",
	makes_footstep_sound = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
		distance = 16,
	},
	damage = 4,
	reach = 3,
	armor = 100,
	drops = {},
	-- TODO: Fix animations
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
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	walk_velocity = 2.5,
	run_velocity = 2.5,
	walk_chance = 0,
	jump_height = 5.2,
	jump_chance = 100,
	fear_height = 60,
	on_die = function(self, pos)
		local angle, posadd
		angle = math.random(0, math.pi*2)
		for i=1,4 do
			posadd = {x=math.cos(angle),y=0,z=math.sin(angle)}
			posadd = vector.normalize(posadd)
			local slime = minetest.add_entity(vector.add(pos, posadd), "mobs_mc:slime_small")
			slime:setvelocity(vector.multiply(posadd, 1.5))
			slime:setyaw(angle-math.pi/2)
			angle = angle + math.pi/2
		end
	end,
}
mobs:register_mob("mobs_mc:slime_big", slime_big)

local slime_small = table.copy(slime_big)
slime_small.hp_min = 4
slime_small.hp_max = 4
slime_small.collisionbox = {-0.51, -0.01, -0.51, 0.51, 1.00, 0.51}
slime_small.visual_size = {x=6.25, y=6.25}
slime_small.damage = 3
slime_small.reach = 2.75
slime_small.walk_velocity = 1.3
slime_small.run_velocity = 1.3
slime_small.jump_height = 4.3
slime_small.on_die = function(self, pos)
	local angle, posadd, dir
	angle = math.random(0, math.pi*2)
	for i=1,4 do
		dir = {x=math.cos(angle),y=0,z=math.sin(angle)}
		posadd = vector.multiply(vector.normalize(dir), 0.6)
		local slime = minetest.add_entity(vector.add(pos, posadd), "mobs_mc:slime_tiny")
		slime:setvelocity(dir)
		slime:setyaw(angle-math.pi/2)
		angle = angle + math.pi/2
	end
end
mobs:register_mob("mobs_mc:slime_small", slime_small)

local slime_tiny = table.copy(slime_big)
slime_tiny.hp_min = 1
slime_tiny.hp_max = 1
slime_tiny.collisionbox = {-0.2505, -0.01, -0.2505, 0.2505, 0.50, 0.2505}
slime_tiny.visual_size = {x=3.125, y=3.125}
slime_tiny.damage = 0
slime_tiny.reach = 2.5
slime_tiny.drops = {
	-- slimeball
	{name = mobs_mc.items.slimeball,
	chance = 1,
	min = 0,
	max = 2,},
}
slime_tiny.walk_velocity = 0.7
slime_tiny.run_velocity = 0.7
slime_tiny.jump_height = 3
slime_tiny.on_die = nil

mobs:register_mob("mobs_mc:slime_tiny", slime_tiny)

local smin = mobs_mc.spawn_height.overworld_min
local smax = mobs_mc.spawn_height.water - 23

mobs:spawn_specific("mobs_mc:slime_tiny", mobs_mc.spawn.solid, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 12000, 4, smin, smax)
mobs:spawn_specific("mobs_mc:slime_small", mobs_mc.spawn.solid, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 8500, 4, smin, smax)
mobs:spawn_specific("mobs_mc:slime_big", mobs_mc.spawn.solid, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 10000, 4, smin, smax)

-- Magma cube
local magma_cube_big = {
	type = "monster",
	hp_min = 16,
	hp_max = 16,
	collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{ "mobs_mc_magmacube.png" }},
	visual = "mesh",
	mesh = "mobs_mc_magmacube.b3d",
	blood_texture = "mobs_mc_magmacube_blood.png",
	makes_footstep_sound = true,
	sounds = {
		jump = "green_slime_jump",
		death = "green_slime_death",
		damage = "green_slime_damage",
		attack = "green_slime_attack",
		distance = 16,
	},
	walk_velocity = 4,
	run_velocity = 4,
	damage = 6,
	reach = 3,
	armor = 40,
	drops = {
		{name = mobs_mc.items.magma_cream,
		chance = 4,
		min = 1,
		max = 1,},
	},
	-- TODO: Fix animations
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
	water_damage = 0,
	lava_damage = 0,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	jump_height = 8,
	walk_chance = 0,
	jump_chance = 100,
	fear_height = 100000,
	on_die = function(self, pos)
		local angle, posadd
		angle = math.random(0, math.pi*2)
		for i=1,3 do
			posadd = {x=math.cos(angle),y=0,z=math.sin(angle)}
			posadd = vector.normalize(posadd)
			local mob = minetest.add_entity(vector.add(pos, posadd), "mobs_mc:magma_cube_small")
			mob:setvelocity(vector.multiply(posadd, 1.5))
			mob:setyaw(angle-math.pi/2)
			angle = angle + (math.pi*2) / 3
		end
	end,
}
mobs:register_mob("mobs_mc:magma_cube_big", magma_cube_big)

local magma_cube_small = table.copy(magma_cube_big)
magma_cube_small.hp_min = 4
magma_cube_small.hp_max = 4
magma_cube_small.collisionbox = {-0.51, -0.01, -0.51, 0.51, 1.00, 0.51}
magma_cube_small.visual_size = {x=6.25, y=6.25}
magma_cube_small.damage = 3
magma_cube_small.reach = 2.75
magma_cube_small.walk_velocity = .8
magma_cube_small.run_velocity = 2.6
magma_cube_small.jump_height = 6
magma_cube_small.damage = 4
magma_cube_small.reach = 2.75
magma_cube_small.armor = 70
magma_cube_small.on_die = function(self, pos)
	local angle, posadd, dir
	angle = math.random(0, math.pi*2)
	for i=1,4 do
		dir = vector.normalize({x=math.cos(angle),y=0,z=math.sin(angle)})
		posadd = vector.multiply(dir, 0.6)
		local mob = minetest.add_entity(vector.add(pos, posadd), "mobs_mc:magma_cube_tiny")
		mob:setvelocity(dir)
		mob:setyaw(angle-math.pi/2)
		angle = angle + math.pi/2
	end
end
mobs:register_mob("mobs_mc:magma_cube_small", magma_cube_small)

local magma_cube_tiny = table.copy(magma_cube_big)
magma_cube_tiny.hp_min = 1
magma_cube_tiny.hp_max = 1
magma_cube_tiny.collisionbox = {-0.2505, -0.01, -0.2505, 0.2505, 0.50, 0.2505}
magma_cube_tiny.visual_size = {x=3.125, y=3.125}
magma_cube_tiny.walk_velocity = 1.02
magma_cube_tiny.run_velocity = 1.02
magma_cube_tiny.jump_height = 4
magma_cube_tiny.damage = 3
magma_cube_tiny.reach = 2.5
magma_cube_tiny.armor = 85
magma_cube_tiny.drops = {}
magma_cube_tiny.on_die = nil

mobs:register_mob("mobs_mc:magma_cube_tiny", magma_cube_tiny)


local mmin = mobs_mc.spawn_height.nether_min
local mmax = mobs_mc.spawn_height.nether_max

mobs:spawn_specific("mobs_mc:magma_cube_tiny", mobs_mc.spawn.nether, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 15000, 4, mmin, mmax)
mobs:spawn_specific("mobs_mc:magma_cube_small", mobs_mc.spawn.nether, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 15500, 4, mmin, mmax)
mobs:spawn_specific("mobs_mc:magma_cube_big", mobs_mc.spawn.nether, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 16000, 4, mmin, mmax)

mobs:spawn_specific("mobs_mc:magma_cube_tiny", mobs_mc.spawn.nether_fortress, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 11000, 4, mmin, mmax)
mobs:spawn_specific("mobs_mc:magma_cube_small", mobs_mc.spawn.nether_fortress, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 11100, 4, mmin, mmax)
mobs:spawn_specific("mobs_mc:magma_cube_big", mobs_mc.spawn.nether_fortress, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 11200, 4, mmin, mmax)


-- Compability
mobs:alias_mob("mobs_mc:greensmall", "mobs_mc:slime_tiny")
mobs:alias_mob("mobs_mc:greenmedium", "mobs_mc:slime_small")
mobs:alias_mob("mobs_mc:greenbig", "mobs_mc:slime_big")
mobs:alias_mob("mobs_mc:lavasmall", "mobs_mc:magma_cube_tiny")
mobs:alias_mob("mobs_mc:lavamedium", "mobs_mc:magma_cube_small")
mobs:alias_mob("mobs_mc:lavabig", "mobs_mc:magma_cube_big")

-- spawn eggs
mobs:register_egg("mobs_mc:magma_cube_big", S("Magma Cube"), "mobs_mc_spawn_icon_magmacube.png")
mobs:register_egg("mobs_mc:slime_big", S("Slime"), "mobs_mc_spawn_icon_slime.png")


if minetest.settings:get_bool("log_mods") then
	minetest.log("action", "MC Slimes loaded")
end
