local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local chance_per_block = mcl_structures.from_16x16_to_block_inverted_chance(64)
local noise_multiplier = 2
local random_offset    = 5
local struct_threshold = chance_per_block
local mcl_structures_get_perlin_noise_level = mcl_structures.get_perlin_noise_level
local minetest_find_nodes_in_area = minetest.find_nodes_in_area
local min_y = mcl_worlds.layer_to_y(40)
local max_y = mcl_worlds.layer_to_y(49)
local fossils = {
	"mcl_structures_fossil_skull_1.mts", -- 4×5×5
	"mcl_structures_fossil_skull_2.mts", -- 5×5×5
	"mcl_structures_fossil_skull_3.mts", -- 5×5×7
	"mcl_structures_fossil_skull_4.mts", -- 7×5×5
	"mcl_structures_fossil_spine_1.mts", -- 3×3×13
	"mcl_structures_fossil_spine_2.mts", -- 5×4×13
	"mcl_structures_fossil_spine_3.mts", -- 7×4×13
	"mcl_structures_fossil_spine_4.mts", -- 8×5×13
}
local nodes_for_fossil = {"mcl_core:sandstone", "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite", "mcl_core:stone_with_coal", "mcl_core:dirt", "mcl_core:gravel"}

function spawn_fossil(pos, rotation, pr, placer)
	-- Generates one out of 8 possible fossil pieces
	local def = {
		pos       = {x = pos.x, y = pos.y - 1, z = pos.z},
		schematic = modpath .. "/schematics/" .. fossils[pr:next(1, #fossils)],
		rotation  = rotation,
		pr        = pr,
	}
	mcl_structures.place_schematic(def)
end

mcl_mapgen.register_mapgen_block(function(minp, maxp, seed)
	local p1 = table.copy(minp)
	local y1 = p1.y
	if y1 > max_y then return end
	local p2 = table.copy(maxp)
	local y2 = p2.y
	if y2 < min_y then return end
	local pr = PseudoRandom(seed + random_offset)
	local random_number = pr:next(1, chance_per_block)
	p1.y = math.max(y1, min_y)
	local noise = mcl_structures_get_perlin_noise_level(p1) * noise_multiplier
	if (random_number + noise) < struct_threshold then return end
	p2.y = math.min(y2, max_y)
	local nodes = minetest_find_nodes_in_area(p1, p2, nodes_for_fossil, false)
	if #nodes < 100 then return end
	spawn_fossil(p1, nil, pr)
end, 1000)

mcl_structures.register_structure({name = 'fossil', place_function = spawn_fossil})
