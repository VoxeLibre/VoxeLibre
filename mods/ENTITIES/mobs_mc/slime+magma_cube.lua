--License for code WTFPL and otherwise stated in readmes
local S = minetest.get_translator("mobs_mc")

local MAPBLOCK_SIZE = 16

local seed = minetest.get_mapgen_setting("seed")

local slime_chunk_match
local x_modifier
local z_modifier

local function split_by_char (inputstr, sep, limit)
	if sep == nil then
		sep = "%d"
	end
	local t = {}

	local i = 0
	for str in string.gmatch(inputstr, "(["..sep.."])") do
		i = i --+ 1
		table.insert(t, tonumber(str))
		if limit and i >= limit then
			break
		end
	end
	return t
end

--Seed: "16002933932875202103" == random seed
--Seed: "1807191622654296300" == cheese
--Seed: "1" = 1
local function process_seed (seed)
	--minetest.log("seed: " .. seed)

	local split_chars = split_by_char(tostring(seed), nil, 10)

	slime_chunk_match = split_chars[1]
	x_modifier = split_chars[2]
	z_modifier = split_chars[3]

	--minetest.log("x_modifier: " .. tostring(x_modifier))
	--minetest.log("z_modifier: " .. tostring(z_modifier))
	--minetest.log("slime_chunk_match: " .. tostring(slime_chunk_match))
end

local processed = process_seed (seed)


local function convert_to_chunk_value (co_ord, modifier)
	local converted = math.floor(math.abs(co_ord) / MAPBLOCK_SIZE)

	if modifier then
		converted = (converted + modifier)
	end
	converted = converted % 10

	--minetest.log("co_ord: " .. co_ord)
	--minetest.log("converted: " .. converted)
	return converted
end

assert(convert_to_chunk_value(-16) == 1, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(-15) == 0, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(-1) == 0, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(0) == 0, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(1) == 0, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(15) == 0, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(16) == 1, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(31) == 1, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(32) == 2, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(1599) == 9, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(1600) == 0, "Incorrect convert_to_chunk_value result")

assert(convert_to_chunk_value(0,9) == 9, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(16,5) == 6, "Incorrect convert_to_chunk_value result")
assert(convert_to_chunk_value(1599,4) == 3, "Incorrect convert_to_chunk_value result")

local function calculate_chunk_value (pos, x_mod, z_mod)
	local chunk_val = math.abs(convert_to_chunk_value(pos.x, x_mod) - convert_to_chunk_value(pos.z, z_mod)) % 10
	return chunk_val
end

assert(calculate_chunk_value(vector.new(0,0,0)) == 0, "calculate_chunk_value failed")
assert(calculate_chunk_value(vector.new(0,0,0), 1, 1) == 0, "calculate_chunk_value failed")
assert(calculate_chunk_value(vector.new(0,0,0), 2, 1) == 1, "calculate_chunk_value failed")
assert(calculate_chunk_value(vector.new(64,0,16)) == (4-1), "calculate_chunk_value failed")
assert(calculate_chunk_value(vector.new(16,0,64)) == (3), "calculate_chunk_value failed")
assert(calculate_chunk_value(vector.new(-160,0,-160)) == 0, "calculate_chunk_value failed")

local function is_slime_chunk(pos)
	if not pos then return end

	local chunk_val = calculate_chunk_value (pos, x_modifier, z_modifier)
	local slime_chunk = chunk_val == slime_chunk_match

	--minetest.log("x: " ..pos.x ..  ", z:" .. pos.z)

	--minetest.log("seed slime_chunk_match: " .. tostring(slime_chunk_match))
	--minetest.log("chunk_val: " .. tostring(chunk_val))
	--minetest.log("Is slime chunk: " .. tostring(slime_chunk))
	return slime_chunk
end

local check_position = function (pos)
	return is_slime_chunk(pos)
end


-- Returns a function that spawns children in a circle around pos.
-- To be used as on_die callback.
-- self: mob reference
-- pos: position of "mother" mob
-- child_mod: Mob to spawn
-- spawn_distance: Spawn distance from "mother" mob
-- eject_speed: Initial speed of child mob away from "mother" mob
local spawn_children_on_die = function(child_mob, spawn_distance, eject_speed)
	return function(self, pos)
		local posadd, newpos, dir
		if not eject_speed then
			eject_speed = 1
		end
		local mndef = minetest.registered_nodes[minetest.get_node(pos).name]
		local mother_stuck = mndef and mndef.walkable
		local angle = math.random(0, math.pi*2)
		local children = {}
		local spawn_count = math.random(2, 4)
		for i = 1, spawn_count do
			dir = vector.new(math.cos(angle), 0, math.sin(angle))
			posadd = vector.normalize(dir) * spawn_distance
			newpos = pos + posadd
			-- If child would end up in a wall, use position of the "mother", unless
			-- the "mother" was stuck as well
			if not mother_stuck then
				local cndef = minetest.registered_nodes[minetest.get_node(newpos).name]
				if cndef and cndef.walkable then
					newpos = pos
					eject_speed = eject_speed * 0.5
				end
			end
			local mob = minetest.add_entity(newpos, child_mob)
			if not mother_stuck then
				mob:set_velocity(dir * eject_speed)
			end
			mob:set_yaw(angle - math.pi/2)
			table.insert(children, mob)
			angle = angle + (math.pi*2) / spawn_count
		end
		-- If mother was murdered, children attack the killer after 1 second
		if self.state == "attack" then
			minetest.after(1.0, function(children, enemy)
				local le
				for c = 1, #children do
					le = children[c]:get_luaentity()
					if le then
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
	description = S("Slime"),
	type = "monster",
	spawn_class = "hostile",
	group_attack = { "mobs_mc:slime_big", "mobs_mc:slime_small", "mobs_mc:slime_tiny" },
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{"mobs_mc_slime.png", "mobs_mc_slime.png"}},
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
		jump_speed = 17,
		stand_speed = 17,
		walk_speed = 17,
		jump_start = 1,
		jump_end = 20,
		stand_start = 1,
		stand_end = 20,
		walk_start = 1,
		walk_end = 20,
	},
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	walk_velocity = 1.9,
	run_velocity = 1.9,
	walk_chance = 0,
	jump_height = 5.2,
	fear_height = 0,
	spawn_small_alternative = "mobs_mc:slime_small",
	on_die = spawn_children_on_die("mobs_mc:slime_small", 1.0, 1.5),
	use_texture_alpha = true,
}
mcl_mobs.register_mob("mobs_mc:slime_big", slime_big)

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
slime_small.walk_velocity = 1.8
slime_small.run_velocity = 1.8
slime_small.jump_height = 4.3
slime_small.spawn_small_alternative = "mobs_mc:slime_tiny"
slime_small.on_die = spawn_children_on_die("mobs_mc:slime_tiny", 0.6, 1.0)
mcl_mobs.register_mob("mobs_mc:slime_small", slime_small)

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
	{name = "mcl_mobitems:slimeball",
	chance = 1,
	min = 0,
	max = 2,},
}
slime_tiny.walk_velocity = 1.7
slime_tiny.run_velocity = 1.7
slime_tiny.jump_height = 3
slime_tiny.spawn_small_alternative = nil
slime_tiny.on_die = nil

mcl_mobs.register_mob("mobs_mc:slime_tiny", slime_tiny)

local water_level = mobs_mc.water_level

local cave_biomes = {
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
	"MangroveSwamp_underground"
}

local cave_min = mcl_vars.mg_overworld_min
local cave_max = water_level - 23

local swampy_biomes = {"Swampland", "MangroveSwamp"}
local swamp_light_max = 7
local swamp_min = water_level
local swamp_max = water_level + 27

mcl_mobs:spawn_specific(
"mobs_mc:slime_tiny",
"overworld",
"ground",
cave_biomes,
0,
minetest.LIGHT_MAX+1,
30,
12000,
4,
cave_min,
cave_max,
nil, nil, check_position)

mcl_mobs:spawn_specific(
"mobs_mc:slime_tiny",
"overworld",
"ground",
swampy_biomes,
0,
swamp_light_max,
30,
12000,
4,
swamp_min,
swamp_max)

mcl_mobs:spawn_specific(
"mobs_mc:slime_small",
"overworld",
"ground",
cave_biomes,
0,
minetest.LIGHT_MAX+1,
30,
8500,
4,
cave_min,
cave_max,
nil, nil, check_position)

mcl_mobs:spawn_specific(
"mobs_mc:slime_small",
"overworld",
"ground",
swampy_biomes,
0,
swamp_light_max,
30,
8500,
4,
swamp_min,
swamp_max)

mcl_mobs:spawn_specific(
"mobs_mc:slime_big",
"overworld",
"ground",
cave_biomes,
0,
minetest.LIGHT_MAX+1,
30,
10000,
4,
cave_min,
cave_max,
nil, nil, check_position)

mcl_mobs:spawn_specific(
"mobs_mc:slime_big",
"overworld",
"ground",
swampy_biomes,
0,
swamp_light_max,
30,
10000,
4,
swamp_min,
swamp_max)

-- Magma cube
local magma_cube_big = {
	description = S("Magma Cube"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 16,
	hp_max = 16,
	xp_min = 4,
	xp_max = 4,
	collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02},
	visual_size = {x=12.5, y=12.5},
	textures = {{ "mobs_mc_magmacube.png", "mobs_mc_magmacube.png" }},
	visual = "mesh",
	mesh = "mobs_mc_magmacube.b3d",
	makes_footstep_sound = true,
	sounds = {
		jump = "mobs_mc_magma_cube_big",
		death = "mobs_mc_magma_cube_big",
		attack = "mobs_mc_magma_cube_attack",
		distance = 16,
	},
	walk_velocity = 2.5,
	run_velocity = 2.5,
	damage = 6,
	reach = 3,
	armor = 53,
	drops = {
		{name = "mcl_mobitems:magma_cream",
		chance = 4,
		min = 1,
		max = 1,},
	},
	-- TODO: Fix animations
	animation = {
		jump_speed = 20,
		stand_speed = 20,
		walk_speed = 20,
		jump_start = 1,
		jump_end = 40,
		stand_start = 1,
		stand_end = 1,
		walk_start = 1,
		walk_end = 40,
	},
	water_damage = 0,
	lava_damage = 0,
        fire_damage = 0,
	light_damage = 0,
	fall_damage = 0,
	view_range = 16,
	attack_type = "dogfight",
	passive = false,
	jump = true,
	jump_height = 8,
	walk_chance = 0,
	fear_height = 0,
	spawn_small_alternative = "mobs_mc:magma_cube_small",
	on_die = spawn_children_on_die("mobs_mc:magma_cube_small", 0.8, 1.5),
	fire_resistant = true,
}
mcl_mobs.register_mob("mobs_mc:magma_cube_big", magma_cube_big)

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
magma_cube_small.run_velocity = 2.0
magma_cube_small.jump_height = 6
magma_cube_small.damage = 4
magma_cube_small.reach = 2.75
magma_cube_small.armor = 66
magma_cube_small.spawn_small_alternative = "mobs_mc:magma_cube_tiny"
magma_cube_small.on_die = spawn_children_on_die("mobs_mc:magma_cube_tiny", 0.6, 1.0)
mcl_mobs.register_mob("mobs_mc:magma_cube_small", magma_cube_small)

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

mcl_mobs.register_mob("mobs_mc:magma_cube_tiny", magma_cube_tiny)


local magma_cube_biomes = {"Nether", "BasaltDelta"}
local nether_min = mcl_vars.mg_nether_min
local nether_max = mcl_vars.mg_nether_max

mcl_mobs:spawn_specific(
"mobs_mc:magma_cube_tiny",
"nether",
"ground",
magma_cube_biomes,
0,
minetest.LIGHT_MAX+1,
30,
15000,
4,
nether_min,
nether_max)

mcl_mobs:spawn_specific(
"mobs_mc:magma_cube_small",
"nether",
"ground",
magma_cube_biomes,
0,
minetest.LIGHT_MAX+1,
30,
15500,
4,
nether_min,
nether_max)

mcl_mobs:spawn_specific(
"mobs_mc:magma_cube_big",
"nether",
"ground",
magma_cube_biomes,
0,
minetest.LIGHT_MAX+1,
30,
16000,
4,
nether_min,
nether_max)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:magma_cube_big", S("Magma Cube"), "#350000", "#fcfc00")

-- non_spawn_specific is typically for mobs who don't spawn in the overworld, or mobs that don't spawn
-- naturally. However, slimes are a particular case where they spawn under different conditions in the same
-- dimension.
mcl_mobs:non_spawn_specific("mobs_mc:slime_big","overworld",0,minetest.LIGHT_MAX+1)
mcl_mobs:non_spawn_specific("mobs_mc:magma_cube_big","overworld",0, minetest.LIGHT_MAX+1)
mcl_mobs.register_egg("mobs_mc:slime_big", S("Slime"), "#52a03e", "#7ebf6d")

-- FIXME: add spawn eggs for small and tiny slimes and magma cubes
