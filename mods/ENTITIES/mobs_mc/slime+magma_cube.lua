--License for code WTFPL and otherwise stated in readmes
local S = minetest.get_translator("mobs_mc")

local MAPBLOCK_SIZE = 16 -- size for slime chunk logic
local SEED_OFFSET = 362 -- module specific seed
local world_seed = (minetest.get_mapgen_setting("seed") + SEED_OFFSET) % 4294967296
-- slime density, where default N=10 is every 10th chunk
local slime_ratio = tonumber(minetest.settings:get("slime_ratio")) or 10
-- use 3D chunking instead of 2d chunks
local slime_3d_chunks = minetest.settings:get_bool("slime_3d_chunks", false)
-- maximum light level, for slimes in caves only, not magma/swamps
local slime_max_light = (tonumber(minetest.settings:get("slime_max_light")) or minetest.LIGHT_MAX) + 1
-- maximum light level for swamp spawning
local swamp_light_max = 7
-- maximum height to spawn in slime chunks
local slime_chunk_spawn_max = mcl_worlds.layer_to_y(40)
local overworld_bounds = vl_worlds.get_dimension_bounds("overworld")
local underworld_bounds = vl_worlds.get_dimension_bounds("underworld")
assert(overworld_bounds)
assert(underworld_bounds)

local floor = math.floor
local max = math.max

local function is_slime_chunk(pos)
	if not pos then return end -- no position given
	if slime_ratio == 0 then return end -- no slime chunks
	if slime_ratio <= 1 then return true end -- slime everywhere
	local x = floor(pos.x / MAPBLOCK_SIZE)
	local y = slime_3d_chunks and floor(pos.y / MAPBLOCK_SIZE) or 0
	local z = floor(pos.z / MAPBLOCK_SIZE)
	return mcl_util.hash_pos(x, y, z, world_seed) / 0x100000000 * slime_ratio < 1
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
		eject_speed = eject_speed or 1
		local mndef = minetest.registered_nodes[minetest.get_node(pos).name]
		local mother_stuck = mndef and mndef.walkable
		local angle = math.random() * math.pi * 2
		local children = {}
		local spawn_count = math.random(2, 4)
		for i = 1, spawn_count do
			local dir = vector.new(math.cos(angle), 0, math.sin(angle))
			local newpos = pos + dir * spawn_distance
			-- If child would end up in a wall, use position of the "mother", unless
			-- the "mother" was stuck as well
			if not mother_stuck then
				local cndef = minetest.registered_nodes[minetest.get_node(newpos).name]
				if cndef and cndef.walkable then
					newpos = pos
					eject_speed = eject_speed * 0.5
				end
			end
			local mob = mcl_mobs.spawn(newpos, child_mob)
			if mob then
				if not mother_stuck then
					mob:set_velocity(dir * eject_speed)
				end
				mob:set_yaw(angle - math.pi/2)
				table.insert(children, mob)
			end
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

-- two different rules, underground slime chunks and regular swamp spawning
local function slime_spawn_check(pos, environmental_light, artificial_light, sky_light)
	if pos.y <= slime_chunk_spawn_max and is_slime_chunk(pos) then
		return max(artificial_light, sky_light) <= slime_max_light
	end
	return max(artificial_light, sky_light) <= swamp_light_max
end

-- Slime
local slime_big = {
	description = S("Slime - big"),
	type = "monster",
	spawn_class = "hostile",
	group_attack = { "mobs_mc:slime_big", "mobs_mc:slime_small", "mobs_mc:slime_tiny" },
	initial_properties = {
		hp_min = 16,
		hp_max = 16,
		collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02, rotate = true},
	},
	xp_min = 4,
	xp_max = 4,
	head_eye_height = 1.0,
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
	reach = 2.5,
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
	spawn_check = slime_spawn_check,
}
mcl_mobs.register_mob("mobs_mc:slime_big", slime_big)

local slime_small = table.copy(slime_big)
slime_small.description = S("Slime - small")
slime_small.sounds.base_pitch = 1.15
slime_small.initial_properties = table.copy(slime_big.initial_properties)
slime_small.initial_properties.hp_min = 4
slime_small.initial_properties.hp_max = 4
slime_small.xp_min = 2
slime_small.xp_max = 2
slime_small.head_eye_height = 0.5
slime_small.initial_properties.collisionbox = {-0.51, -0.01, -0.51, 0.51, 1.00, 0.51, rotate = true}
slime_small.visual_size = {x=6.25, y=6.25}
slime_small.damage = 3
slime_small.reach = 2.25
slime_small.walk_velocity = 1.8
slime_small.run_velocity = 1.8
slime_small.jump_height = 4.3
slime_small.spawn_small_alternative = "mobs_mc:slime_tiny"
slime_small.on_die = spawn_children_on_die("mobs_mc:slime_tiny", 0.6, 1.0)
mcl_mobs.register_mob("mobs_mc:slime_small", slime_small)

local slime_tiny = table.copy(slime_big)
slime_tiny.description = S("Slime - tiny")
slime_tiny.sounds.base_pitch = 1.3
slime_tiny.initial_properties = table.copy(slime_big.initial_properties)
slime_tiny.initial_properties.hp_min = 1
slime_tiny.initial_properties.hp_max = 1
slime_tiny.xp_min = 1
slime_tiny.xp_max = 1
slime_tiny.head_eye_height = 0.25
slime_tiny.initial_properties.collisionbox = {-0.2505, -0.01, -0.2505, 0.2505, 0.50, 0.2505, rotate = true}
slime_tiny.visual_size = {x=3.125, y=3.125}
slime_tiny.damage = 1
slime_tiny.reach = 2
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
	"MangroveSwamp_underground",
	"BambooJungle_underground",
	"BambooJungleM_underground",
	"BambooJungleEdge_underground",
	"BambooJungleEdgeM_underground",
}

local cave_min = overworld_bounds.min
local cave_max = water_level - 23

local swampy_biomes = {"Swampland", "MangroveSwamp"}
local swamp_min = water_level
local swamp_max = water_level + 27

mcl_mobs:spawn_setup({
	name = "mobs_mc:slime_tiny",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = cave_biomes,
	min_light = 0,
	max_light = slime_max_light,
	chance = 1000,
	interval = 30,
	aoc = 4,
	min_height = cave_min,
	max_height = cave_max,
	check_position = is_slime_chunk
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:slime_tiny",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = swampy_biomes,
	min_light = 0,
	max_light = swamp_light_max,
	chance = 1000,
	interval = 30,
	aoc = 4,
	min_height = swamp_min,
	max_height = swamp_max
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:slime_small",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = cave_biomes,
	min_light = 0,
	max_light = slime_max_light,
	interval = 30,
	chance = 1000,
	aoc = 4,
	min_height = cave_min,
	max_height = cave_max,
	check_position = is_slime_chunk
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:slime_small",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = swampy_biomes,
	min_light = 0,
	max_light = swamp_light_max,
	interval = 30,
	chance = 1000,
	aoc = 4,
	min_height = swamp_min,
	max_height = swamp_max
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:slime_big",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = cave_biomes,
	min_light = 0,
	max_light = slime_max_light,
	chance = 1000,
	interval = 30,
	aoc = 4,
	min_height = cave_min,
	max_height = cave_max,
	check_position = is_slime_chunk
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:slime_big",
	dimension = "overworld",
	type_of_spawning = "ground",
	biomes = swampy_biomes,
	min_light = 0,
	max_light = swamp_light_max,
	chance = 1000,
	interval = 30,
	aoc = 4,
	min_height = swamp_min,
	max_height = swamp_max
})

-- Magma cube
local magma_cube_big = {
	description = S("Magma Cube - big"),
	type = "monster",
	spawn_class = "hostile",
	initial_properties = {
		hp_min = 16,
		hp_max = 16,
		collisionbox = {-1.02, -0.01, -1.02, 1.02, 2.03, 1.02, rotate = true},
	},
	xp_min = 4,
	xp_max = 4,
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
	reach = 2.35,
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
magma_cube_small.description = S("Magma Cube - small")
magma_cube_small.sounds.jump = "mobs_mc_magma_cube_small"
magma_cube_small.sounds.death = "mobs_mc_magma_cube_small"
magma_cube_small.initial_properties = table.copy(magma_cube_big.initial_properties)
magma_cube_small.initial_properties.hp_min = 4
magma_cube_small.initial_properties.hp_max = 4
magma_cube_small.xp_min = 2
magma_cube_small.xp_max = 2
magma_cube_small.initial_properties.collisionbox = {-0.51, -0.01, -0.51, 0.51, 1.00, 0.51, rotate = true}
magma_cube_small.visual_size = {x=6.25, y=6.25}
magma_cube_small.damage = 3
magma_cube_small.reach = 2.1
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
magma_cube_tiny.description = S("Magma Cube - tiny")
magma_cube_tiny.sounds.jump = "mobs_mc_magma_cube_small"
magma_cube_tiny.sounds.death = "mobs_mc_magma_cube_small"
magma_cube_tiny.sounds.base_pitch = 1.25
magma_cube_tiny.initial_properties = table.copy(magma_cube_big.initial_properties)
magma_cube_tiny.initial_properties.hp_min = 1
magma_cube_tiny.initial_properties.hp_max = 1
magma_cube_tiny.xp_min = 1
magma_cube_tiny.xp_max = 1
magma_cube_tiny.initial_properties.collisionbox = {-0.2505, -0.01, -0.2505, 0.2505, 0.50, 0.2505, rotate = true}
magma_cube_tiny.visual_size = {x=3.125, y=3.125}
magma_cube_tiny.walk_velocity = 1.02
magma_cube_tiny.run_velocity = 1.02
magma_cube_tiny.jump_height = 4
magma_cube_tiny.damage = 3
magma_cube_tiny.reach = 2
magma_cube_tiny.armor = 50
magma_cube_tiny.drops = {}
magma_cube_tiny.spawn_small_alternative = nil
magma_cube_tiny.on_die = nil

mcl_mobs.register_mob("mobs_mc:magma_cube_tiny", magma_cube_tiny)


local magma_cube_biomes = {"Nether", "BasaltDelta"}
local nether_min = underworld_bounds.min
local nether_max = underworld_bounds.max

mcl_mobs:spawn_setup({
	name = "mobs_mc:magma_cube_tiny",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = magma_cube_biomes,
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 100,
	interval = 30,
	aoc = 4,
	min_height = nether_min,
	max_height = nether_max
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:magma_cube_small",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = magma_cube_biomes,
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 100,
	interval = 30,
	aoc = 4,
	min_height = nether_min,
	max_height = nether_max
})

mcl_mobs:spawn_setup({
	name = "mobs_mc:magma_cube_big",
	dimension = "nether",
	type_of_spawning = "ground",
	biomes = magma_cube_biomes,
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	chance = 100,
	interval = 30,
	aoc = 4,
	min_height = nether_min,
	max_height = nether_max
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:magma_cube_big", S("Magma Cube"), "#350000", "#fcfc00")

-- non_spawn_specific is typically for mobs who don't spawn in the overworld, or mobs that don't spawn
-- naturally. However, slimes are a particular case where they spawn under different conditions in the same
-- dimension.
mcl_mobs:non_spawn_specific("mobs_mc:slime_big","overworld",0,minetest.LIGHT_MAX+1)
mcl_mobs:non_spawn_specific("mobs_mc:magma_cube_big","overworld",0, minetest.LIGHT_MAX+1)
mcl_mobs.register_egg("mobs_mc:slime_big", S("Slime"), "#52a03e", "#7ebf6d")

-- FIXME: add spawn eggs for small and tiny slimes and magma cubes

