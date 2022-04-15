--lua locals
local get_node                     = minetest.get_node
local get_item_group               = minetest.get_item_group
local get_node_light               = minetest.get_node_light
local find_nodes_in_area_under_air = minetest.find_nodes_in_area_under_air
local get_biome_name               = minetest.get_biome_name
local get_objects_inside_radius    = minetest.get_objects_inside_radius
local get_connected_players        = minetest.get_connected_players
local minetest_get_perlin          = minetest.get_perlin

local math_random    = math.random
local math_floor     = math.floor
local math_ceil      = math.ceil
local math_cos       = math.cos
local math_sin       = math.sin
local math_round     = function(x) return (x > 0) and math_floor(x + 0.5) or math_ceil(x - 0.5) end

--local vector_distance = vector.distance
local vector_new      = vector.new
local vector_floor    = vector.floor

local table_copy     = table.copy
local table_remove   = table.remove

local pairs = pairs

-- range for mob count
local aoc_range = 32

--do mobs spawn?
local mobs_spawn = minetest.settings:get_bool("mobs_spawn", true) ~= false


local noise_params = {
	offset = 0,
	scale  = 3,
	spread = {
		x = 301,
		y = 50,
		z = 304,
	},
	seed = 100,
	octaves = 3,
	persistence = 0.5,
}

-- THIS IS THE BIG LIST OF ALL BIOMES - used for programming/updating mobs
-- Also used for missing parameter
-- Please update the list when adding new biomes!

local list_of_all_biomes = {

	-- underground:

	"FlowerForest_underground",
	"JungleEdge_underground",
	"ColdTaiga_underground",
	"IcePlains_underground",
	"IcePlainsSpikes_underground",
	"MegaTaiga_underground",
	"Taiga_underground",
	"ExtremeHills+_underground",
	"JungleM_underground",
	"ExtremeHillsM_underground",
	"JungleEdgeM_underground",

	-- ocean:

	"RoofedForest_ocean",
	"JungleEdgeM_ocean",
	"BirchForestM_ocean",
	"BirchForest_ocean",
	"IcePlains_deep_ocean",
	"Jungle_deep_ocean",
	"Savanna_ocean",
	"MesaPlateauF_ocean",
	"ExtremeHillsM_deep_ocean",
	"Savanna_deep_ocean",
	"SunflowerPlains_ocean",
	"Swampland_deep_ocean",
	"Swampland_ocean",
	"MegaSpruceTaiga_deep_ocean",
	"ExtremeHillsM_ocean",
	"JungleEdgeM_deep_ocean",
	"SunflowerPlains_deep_ocean",
	"BirchForest_deep_ocean",
	"IcePlainsSpikes_ocean",
	"Mesa_ocean",
	"StoneBeach_ocean",
	"Plains_deep_ocean",
	"JungleEdge_deep_ocean",
	"SavannaM_deep_ocean",
	"Desert_deep_ocean",
	"Mesa_deep_ocean",
	"ColdTaiga_deep_ocean",
	"Plains_ocean",
	"MesaPlateauFM_ocean",
	"Forest_deep_ocean",
	"JungleM_deep_ocean",
	"FlowerForest_deep_ocean",
	"MushroomIsland_ocean",
	"MegaTaiga_ocean",
	"StoneBeach_deep_ocean",
	"IcePlainsSpikes_deep_ocean",
	"ColdTaiga_ocean",
	"SavannaM_ocean",
	"MesaPlateauF_deep_ocean",
	"MesaBryce_deep_ocean",
	"ExtremeHills+_deep_ocean",
	"ExtremeHills_ocean",
	"MushroomIsland_deep_ocean",
	"Forest_ocean",
	"MegaTaiga_deep_ocean",
	"JungleEdge_ocean",
	"MesaBryce_ocean",
	"MegaSpruceTaiga_ocean",
	"ExtremeHills+_ocean",
	"Jungle_ocean",
	"RoofedForest_deep_ocean",
	"IcePlains_ocean",
	"FlowerForest_ocean",
	"ExtremeHills_deep_ocean",
	"MesaPlateauFM_deep_ocean",
	"Desert_ocean",
	"Taiga_ocean",
	"BirchForestM_deep_ocean",
	"Taiga_deep_ocean",
	"JungleM_ocean",

	-- water or beach?

	"MesaPlateauFM_sandlevel",
	"MesaPlateauF_sandlevel",
	"MesaBryce_sandlevel",
	"Mesa_sandlevel",

	-- beach:

	"FlowerForest_beach",
	"Forest_beach",
	"StoneBeach",
	"ColdTaiga_beach_water",
	"Taiga_beach",
	"Savanna_beach",
	"Plains_beach",
	"ExtremeHills_beach",
	"ColdTaiga_beach",
	"Swampland_shore",
	"MushroomIslandShore",
	"JungleM_shore",
	"Jungle_shore",

	-- dimension biome:

	"Nether",
	"End",

	-- Overworld regular:

	"Mesa",
	"FlowerForest",
	"Swampland",
	"Taiga",
	"ExtremeHills",
	"Jungle",
	"Savanna",
	"BirchForest",
	"MegaSpruceTaiga",
	"MegaTaiga",
	"ExtremeHills+",
	"Forest",
	"Plains",
	"Desert",
	"ColdTaiga",
	"MushroomIsland",
	"IcePlainsSpikes",
	"SunflowerPlains",
	"IcePlains",
	"RoofedForest",
	"ExtremeHills+_snowtop",
	"MesaPlateauFM_grasstop",
	"JungleEdgeM",
	"ExtremeHillsM",
	"JungleM",
	"BirchForestM",
	"MesaPlateauF",
	"MesaPlateauFM",
	"MesaPlateauF_grasstop",
	"MesaBryce",
	"JungleEdge",
	"SavannaM",
}

-- count how many mobs are in an area
local function count_mobs(pos)
	local num = 0
	for _,object in pairs(get_objects_inside_radius(pos, aoc_range)) do
		if object and object:get_luaentity() and object:get_luaentity()._cmi_is_mob then
			num = num + 1
		end
	end
	return num
end


-- global functions

function mobs:spawn_abm_check(pos, node, name)
	-- global function to add additional spawn checks
	-- return true to stop spawning mob
end


--[[
	Custom elements changed:

name:
the mobs name

dimension:
"overworld"
"nether"
"end"

types of spawning:
"water"
"ground"
"lava"

biomes: tells the spawner to allow certain mobs to spawn in certain biomes
{"this", "that", "grasslands", "whatever"}


what is aoc??? objects in area

WARNING: BIOME INTEGRATION NEEDED -> How to get biome through lua??
]]--


--this is where all of the spawning information is kept
local spawn_dictionary = {}
local summary_chance = 0

function mobs:spawn_setup(def)
	if not mobs_spawn then return end

	if not def then
		minetest.log("warning", "Empty mob spawn setup definition")
		return
	end

	local name = def.name
	if not name then
		minetest.log("warning", "Missing mob name")
		return
	end

	local dimension        = def.dimension or "overworld"
	local type_of_spawning = def.type_of_spawning or "ground"
	local biomes           = def.biomes or list_of_all_biomes
	local min_light        = def.min_light or 0
	local max_light        = def.max_light or (minetest.LIGHT_MAX + 1)
	local chance           = def.chance or 1000
	local aoc              = def.aoc or aoc_range
	local min_height       = def.min_height or mcl_mapgen.overworld.min
	local max_height       = def.max_height or mcl_mapgen.overworld.max
	local day_toggle       = def.day_toggle
	local on_spawn         = def.on_spawn
	local check_position   = def.check_position

	-- chance/spawn number override in minetest.conf for registered mob
	local numbers = minetest.settings:get(name)
	if numbers then
		numbers = numbers:split(",")
		chance = tonumber(numbers[1]) or chance
		aoc = tonumber(numbers[2]) or aoc
		if chance == 0 then
			minetest.log("warning", string.format("[mobs] %s has spawning disabled", name))
			return
		end
		minetest.log("action", string.format("[mobs] Chance setting for %s changed to %s (total: %s)", name, chance, aoc))
	end

	if chance < 1 then
		chance = 1
		minetest.log("warning", "Chance shouldn't be less than 1 (mob name: " .. name ..")")
	end

	spawn_dictionary[#spawn_dictionary + 1] = {
		name             = name,
		dimension        = dimension,
                type_of_spawning = type_of_spawning,
		biomes           = biomes,
		min_light        = min_light,
		max_light        = max_light,
		chance           = chance,
		aoc              = aoc,
		min_height       = min_height,
		max_height       = max_height,
		day_toggle       = day_toggle,
		check_position   = check_position,
		on_spawn         = on_spawn,
	}
	summary_chance = summary_chance + chance
end

function mobs:spawn_specific(name, dimension, type_of_spawning, biomes, min_light, max_light, interval, chance, aoc, min_height, max_height, day_toggle, on_spawn)

	-- Do mobs spawn at all?
	if not mobs_spawn then
		return
	end

	-- chance/spawn number override in minetest.conf for registered mob
	local numbers = minetest.settings:get(name)

	if numbers then
		numbers = numbers:split(",")
		chance = tonumber(numbers[1]) or chance
		aoc = tonumber(numbers[2]) or aoc

		if chance == 0 then
			minetest.log("warning", string.format("[mobs] %s has spawning disabled", name))
			return
		end

		minetest.log("action", string.format("[mobs] Chance setting for %s changed to %s (total: %s)", name, chance, aoc))
	end

	--load information into the spawn dictionary
	local key = #spawn_dictionary + 1
	spawn_dictionary[key]               = {}
	spawn_dictionary[key]["name"]       = name
	spawn_dictionary[key]["dimension"]  = dimension
	spawn_dictionary[key]["type_of_spawning"] = type_of_spawning
	spawn_dictionary[key]["biomes"]     = biomes
	spawn_dictionary[key]["min_light"]  = min_light
	spawn_dictionary[key]["max_light"]  = max_light
	spawn_dictionary[key]["chance"]     = chance
	spawn_dictionary[key]["aoc"]        = aoc
	spawn_dictionary[key]["min_height"] = min_height
	spawn_dictionary[key]["max_height"] = max_height
	spawn_dictionary[key]["day_toggle"] = day_toggle

	summary_chance = summary_chance + chance
end

local two_pi = 2 * math.pi
local function get_next_mob_spawn_pos(pos)
	local distance = math_random(25, 32)
	local angle = math_random() * two_pi
	return {
		x = math_round(pos.x + distance * math_cos(angle)),
		y = pos.y,
		z = math_round(pos.z + distance * math_sin(angle))
	}
end

local function decypher_limits(posy)
	posy = math_floor(posy)
	return posy - 32, posy + 32
end

--a simple helper function for mob_spawn
local function biome_check(biome_list, biome_goal)
	for _, data in pairs(biome_list) do
		if data == biome_goal then
			return true
		end
	end

	return false
end


if mobs_spawn then

	local perlin_noise

	local function spawn_a_mob(pos, dimension, y_min, y_max)
		local dimension = dimension or mcl_worlds.pos_to_dimension(pos)
		local goal_pos = get_next_mob_spawn_pos(pos)
		local spawning_position_list = find_nodes_in_area_under_air(
			{x = goal_pos.x, y = y_min, z = goal_pos.z},
			{x = goal_pos.x, y = y_max, z = goal_pos.z},
			{"group:solid", "group:water", "group:lava"}
		)
		if #spawning_position_list <= 0 then return end
		local spawning_position = spawning_position_list[math_random(1, #spawning_position_list)]

		--hard code mob limit in area to 5 for now
		if count_mobs(spawning_position) >= 5 then return end

		local gotten_node = get_node(spawning_position).name
		local gotten_biome = minetest.get_biome_data(spawning_position)
		if not gotten_node or not gotten_biome then return end
		gotten_biome = get_biome_name(gotten_biome.biome) --makes it easier to work with

		--add this so mobs don't spawn inside nodes
		spawning_position.y = spawning_position.y + 1

		--only need to poll for node light if everything else worked
		local gotten_light = get_node_light(spawning_position)

		local is_water = get_item_group(gotten_node, "water") ~= 0
		local is_lava  = get_item_group(gotten_node, "lava") ~= 0
		local is_ground = not (is_water or is_lava)
		if not is_ground then
			spawning_position.y = spawning_position.y - 1
		end

		local mob_def

		--create a disconnected clone of the spawn dictionary
		--prevents memory leak
		local mob_library_worker_table = table_copy(spawn_dictionary)

		--grab mob that fits into the spawning location
		--randomly grab a mob, don't exclude any possibilities
		perlin_noise = perlin_noise or minetest_get_perlin(noise_params)
		local noise = perlin_noise:get_3d(spawning_position)
		local current_summary_chance = summary_chance
		while #mob_library_worker_table > 0 do
			local mob_chance_offset = (math_round(noise * current_summary_chance + 12345) % current_summary_chance) + 1
			local mob_index = 1
			local mob_chance = mob_library_worker_table[mob_index].chance
			local step_chance = mob_chance
			while step_chance < mob_chance_offset do
				mob_index = mob_index + 1
				mob_chance = mob_library_worker_table[mob_index].chance
				step_chance = step_chance + mob_chance
			end
			local mob_def = mob_library_worker_table[mob_index]
			if mob_def
				and spawning_position.y >= mob_def.min_height
				and spawning_position.y <= mob_def.max_height
				and mob_def.dimension == dimension
				and biome_check(mob_def.biomes, gotten_biome)
				and gotten_light >= mob_def.min_light
				and gotten_light <= mob_def.max_light
				and (is_ground or mob_def.type_of_spawning ~= "ground")
				and (mob_def.check_position and mob_def.check_position(spawning_position) or true)
				then
					--everything is correct, spawn mob
					local object = minetest.add_entity(spawning_position, mob_def.name)
					if object then
						return mob_def.on_spawn and mob_def.on_spawn(object, pos)
					end
			end
			current_summary_chance = current_summary_chance - mob_chance
			table_remove(mob_library_worker_table, mob_index)
		end
	end


	--MAIN LOOP

	local timer = 0
	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer < 10 then return end
		timer = 0
		for _, player in pairs(get_connected_players()) do
			local pos = player:get_pos()
			local dimension = mcl_worlds.pos_to_dimension(pos)
			-- ignore void and unloaded area
			if dimension ~= "void" and dimension ~= "default" then
				local y_min, y_max = decypher_limits(pos.y)
				for i = 1, math_random(1, 4) do
					spawn_a_mob(pos, dimension, y_min, y_max)
				end
			end
		end
	end)
end
