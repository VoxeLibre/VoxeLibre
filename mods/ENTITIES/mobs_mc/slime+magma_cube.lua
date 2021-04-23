--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

-- Returns a function that spawns children in a circle around pos.
-- To be used as on_die callback.
-- self: mob reference
-- pos: position of "mother" mob
-- child_mod: Mob to spawn
-- children_count: Number of children to spawn
-- spawn_distance: Spawn distance from "mother" mob
-- eject_speed: Initial speed of child mob away from "mother" mob
local spawn_children_on_die = function(child_mob, children_count, spawn_distance, eject_speed)
	return function(self, pos)
		local angle, posadd, newpos, dir
		if not eject_speed then
			eject_speed = 1
		end
		local mother_stuck = minetest.registered_nodes[minetest.get_node(pos).name].walkable
		angle = math.random(0, math.pi*2)
		local children = {}
		for i=1,children_count do
			dir = {x=math.cos(angle),y=0,z=math.sin(angle)}
			posadd = vector.multiply(vector.normalize(dir), spawn_distance)
			newpos = vector.add(pos, posadd)
			-- If child would end up in a wall, use position of the "mother", unless
			-- the "mother" was stuck as well
			local speed_penalty = 1
			if (not mother_stuck) and minetest.registered_nodes[minetest.get_node(newpos).name].walkable then
				newpos = pos
				speed_penalty = 0.5
			end
			local mob = minetest.add_entity(newpos, child_mob)
			if (not mother_stuck) then
				mob:set_velocity(vector.multiply(dir, eject_speed * speed_penalty))
			end
			mob:set_yaw(angle - math.pi/2)
			table.insert(children, mob)
			angle = angle + (math.pi*2)/children_count
		end
		-- If mother was murdered, children attack the killer after 1 second
		if self.state == "attack" then
			minetest.after(1.0, function(children, enemy)
				for c=1, #children do
					local child = children[c]
					local le = child:get_luaentity()
					if le ~= nil then
						le.state = "attack"
						le.attack = enemy
					end
				end
			end, children, self.attack)
		end
	end
end

-- Slime
local slime_big = {
	type = "monster",
	spawn_class = "hostile",
	pathfinding = 1,
	group_attack = { "mobs_mc:slime_big", "mobs_mc:slime_small", "mobs_mc:slime_tiny" },
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	rotate = 270,
	collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{"mobs_mc_slime.png"}},
	visual = "mesh",
	mesh = "mobs_mc_slime.b3d",
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
	fall_damage = 0,
	view_range = 16,
	attack_type = "jump_punch",
	passive = false,
	jump_only = true,
	jump = true,
	walk_velocity = 2.5,
	run_velocity = 2.5,
	walk_chance = 0,
	jump_height = 5.2,
	fear_height = 0,
	spawn_small_alternative = "mobs_mc:slime_small",
	on_die = spawn_children_on_die("mobs_mc:slime_small", 4, 1.0, 1.5),
	use_texture_alpha = true,
}
mobs:register_mob("mobs_mc:slime_big", slime_big)

local slime_small = table.copy(slime_big)
slime_small.sounds.base_pitch = 1.15
slime_small.hp_min = 4
slime_small.hp_max = 4
slime_small.xp_min = 2
slime_small.xp_max = 2
slime_small.collisionbox = {-0.51, -0.01, -0.51, 0.51, 1.00, 0.51}
slime_small.visual_size = {x=6.25, y=6.25}
slime_small.damage = 3
slime_small.reach = 2.75
slime_small.walk_velocity = 1.3
slime_small.run_velocity = 1.3
slime_small.jump_height = 4.3
slime_small.spawn_small_alternative = "mobs_mc:slime_tiny"
slime_small.on_die = spawn_children_on_die("mobs_mc:slime_tiny", 4, 0.6, 1.0)
mobs:register_mob("mobs_mc:slime_small", slime_small)

local slime_tiny = table.copy(slime_big)
slime_tiny.sounds.base_pitch = 1.3
slime_tiny.hp_min = 1
slime_tiny.hp_max = 1
slime_tiny.xp_min = 1
slime_tiny.xp_max = 1
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
slime_tiny.spawn_small_alternative = nil
slime_tiny.on_die = nil

mobs:register_mob("mobs_mc:slime_tiny", slime_tiny)

local smin = mobs_mc.spawn_height.overworld_min
local smax = mobs_mc.spawn_height.water - 23

mobs:spawn_specific(
"mobs_mc:slime_tiny", 
"overworld", 
"ground",
{
"FlowerForest_underground",
"JungleEdge_underground",
"StoneBeach_underground",
"MesaBryce_underground",
"Mesa_underground",
"RoofedForest_underground",
"Jungle_underground",
"Swampland_underground",
"MushroomIsland_underground",
"BirchForest_underground",
"Plains_underground",
"MesaPlateauF_underground",
"ExtremeHills_underground",
"MegaSpruceTaiga_underground",
"BirchForestM_underground",
"SavannaM_underground",
"MesaPlateauFM_underground",
"Desert_underground",
"Savanna_underground",
"Forest_underground",
"SunflowerPlains_underground",
"ColdTaiga_underground",
"IcePlains_underground",
"IcePlainsSpikes_underground",
"MegaTaiga_underground",
"Taiga_underground",
"ExtremeHills+_underground",
"JungleM_underground",
"ExtremeHillsM_underground",
"JungleEdgeM_underground",
},
0, 
minetest.LIGHT_MAX+1, 
30, 
12000, 
4, 
smin, 
smax)

mobs:spawn_specific(
"mobs_mc:slime_small", 
"overworld", 
"ground",
{
"FlowerForest_underground",
"JungleEdge_underground",
"StoneBeach_underground",
"MesaBryce_underground",
"Mesa_underground",
"RoofedForest_underground",
"Jungle_underground",
"Swampland_underground",
"MushroomIsland_underground",
"BirchForest_underground",
"Plains_underground",
"MesaPlateauF_underground",
"ExtremeHills_underground",
"MegaSpruceTaiga_underground",
"BirchForestM_underground",
"SavannaM_underground",
"MesaPlateauFM_underground",
"Desert_underground",
"Savanna_underground",
"Forest_underground",
"SunflowerPlains_underground",
"ColdTaiga_underground",
"IcePlains_underground",
"IcePlainsSpikes_underground",
"MegaTaiga_underground",
"Taiga_underground",
"ExtremeHills+_underground",
"JungleM_underground",
"ExtremeHillsM_underground",
"JungleEdgeM_underground",
}, 
0, 
minetest.LIGHT_MAX+1, 
30, 
8500, 
4, 
smin, 
smax)

mobs:spawn_specific(
"mobs_mc:slime_big", 
"overworld", 
"ground", 
{
"FlowerForest_underground",
"JungleEdge_underground",
"StoneBeach_underground",
"MesaBryce_underground",
"Mesa_underground",
"RoofedForest_underground",
"Jungle_underground",
"Swampland_underground",
"MushroomIsland_underground",
"BirchForest_underground",
"Plains_underground",
"MesaPlateauF_underground",
"ExtremeHills_underground",
"MegaSpruceTaiga_underground",
"BirchForestM_underground",
"SavannaM_underground",
"MesaPlateauFM_underground",
"Desert_underground",
"Savanna_underground",
"Forest_underground",
"SunflowerPlains_underground",
"ColdTaiga_underground",
"IcePlains_underground",
"IcePlainsSpikes_underground",
"MegaTaiga_underground",
"Taiga_underground",
"ExtremeHills+_underground",
"JungleM_underground",
"ExtremeHillsM_underground",
"JungleEdgeM_underground",
},
0, 
minetest.LIGHT_MAX+1, 
30, 
10000, 
4, 
smin, 
smax)

-- Magma cube
local magma_cube_big = {
	type = "monster",
	spawn_class = "hostile",
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{ "mobs_mc_magmacube.png" }},
	visual = "mesh",
	mesh = "mobs_mc_magmacube.b3d",
	makes_footstep_sound = true,
	sounds = {
		jump = "mobs_mc_magma_cube_big",
		death = "mobs_mc_magma_cube_big",
		attack = "mobs_mc_magma_cube_attack",
		distance = 16,
	},
	walk_velocity = 4,
	run_velocity = 4,
	rotate = 270,
	damage = 6,
	reach = 3,
	armor = 53,
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
    fire_damage = 0,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "jump_punch",
	passive = false,
	jump_only = true,
	jump = true,
	jump_height = 8,
	walk_chance = 0,
	fear_height = 0,
	spawn_small_alternative = "mobs_mc:magma_cube_small",
	on_die = spawn_children_on_die("mobs_mc:magma_cube_small", 3, 0.8, 1.5),
	fire_resistant = true,
}
mobs:register_mob("mobs_mc:magma_cube_big", magma_cube_big)

local magma_cube_small = table.copy(magma_cube_big)
magma_cube_small.sounds.jump = "mobs_mc_magma_cube_small"
magma_cube_small.sounds.death = "mobs_mc_magma_cube_small"
magma_cube_small.hp_min = 4
magma_cube_small.hp_max = 4
magma_cube_small.xp_min = 2
magma_cube_small.xp_max = 2
magma_cube_small.collisionbox = {-0.51, -0.01, -0.51, 0.51, 1.00, 0.51}
magma_cube_small.visual_size = {x=6.25, y=6.25}
magma_cube_small.damage = 3
magma_cube_small.reach = 2.75
magma_cube_small.walk_velocity = .8
magma_cube_small.run_velocity = 2.6
magma_cube_small.jump_height = 6
magma_cube_small.damage = 4
magma_cube_small.reach = 2.75
magma_cube_small.armor = 66
magma_cube_small.spawn_small_alternative = "mobs_mc:magma_cube_tiny"
magma_cube_small.on_die = spawn_children_on_die("mobs_mc:magma_cube_tiny", 4, 0.6, 1.0)
mobs:register_mob("mobs_mc:magma_cube_small", magma_cube_small)

local magma_cube_tiny = table.copy(magma_cube_big)
magma_cube_tiny.sounds.jump = "mobs_mc_magma_cube_small"
magma_cube_tiny.sounds.death = "mobs_mc_magma_cube_small"
magma_cube_tiny.sounds.base_pitch = 1.25
magma_cube_tiny.hp_min = 1
magma_cube_tiny.hp_max = 1
magma_cube_tiny.xp_min = 1
magma_cube_tiny.xp_max = 1
magma_cube_tiny.collisionbox = {-0.2505, -0.01, -0.2505, 0.2505, 0.50, 0.2505}
magma_cube_tiny.visual_size = {x=3.125, y=3.125}
magma_cube_tiny.walk_velocity = 1.02
magma_cube_tiny.run_velocity = 1.02
magma_cube_tiny.jump_height = 4
magma_cube_tiny.damage = 3
magma_cube_tiny.reach = 2.5
magma_cube_tiny.armor = 50
magma_cube_tiny.drops = {}
magma_cube_tiny.spawn_small_alternative = nil
magma_cube_tiny.on_die = nil

mobs:register_mob("mobs_mc:magma_cube_tiny", magma_cube_tiny)


local mmin = mobs_mc.spawn_height.nether_min
local mmax = mobs_mc.spawn_height.nether_max

mobs:spawn_specific(
"mobs_mc:magma_cube_tiny", 
"nether", 
"ground",
{
"Nether"
},
0, 
minetest.LIGHT_MAX+1, 
30, 
15000, 
4, 
mmin, 
mmax)


mobs:spawn_specific(
"mobs_mc:magma_cube_small", 
"nether", 
"ground",
{
"Nether"
},
0, 
minetest.LIGHT_MAX+1, 
30, 
15500, 
4, 
mmin, 
mmax)

mobs:spawn_specific(
"mobs_mc:magma_cube_big", 
"nether", 
"ground",
{
"Nether"
},	
0, 
minetest.LIGHT_MAX+1, 
30, 
16000, 
4, 
mmin, 
mmax)

--mobs:spawn_specific("mobs_mc:magma_cube_tiny", mobs_mc.spawn.nether_fortress, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 11000, 4, mmin, mmax)
--mobs:spawn_specific("mobs_mc:magma_cube_small", mobs_mc.spawn.nether_fortress, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 11100, 4, mmin, mmax)
--mobs:spawn_specific("mobs_mc:magma_cube_big", mobs_mc.spawn.nether_fortress, {"air"}, 0, minetest.LIGHT_MAX+1, 30, 11200, 4, mmin, mmax)


-- spawn eggs
mobs:register_egg("mobs_mc:magma_cube_big", S("Magma Cube"), "mobs_mc_spawn_icon_magmacube.png")
mobs:register_egg("mobs_mc:slime_big", S("Slime"), "mobs_mc_spawn_icon_slime.png")
