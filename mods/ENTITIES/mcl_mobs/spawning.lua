--lua locals
local math, vector, core, mcl_mobs = math, vector, core, mcl_mobs
local S = core.get_translator("mcl_mobs")
local mob_class = mcl_mobs.mob_class

local modern_lighting = core.settings:get_bool("mcl_mobs_modern_lighting", true)
local nether_threshold = tonumber(core.settings:get("mcl_mobs_nether_threshold")) or 11
local end_threshold = tonumber(core.settings:get("mcl_mobs_end_threshold")) or 0
local overworld_threshold = tonumber(core.settings:get("mcl_mobs_overworld_threshold")) or 0
local overworld_sky_threshold = tonumber(core.settings:get("mcl_mobs_overworld_sky_threshold")) or 7
local overworld_passive_threshold = tonumber(core.settings:get("mcl_mobs_overworld_passive_threshold")) or 7
local debug_time_threshold = tonumber(core.settings:get("vl_debug_time_threshold")) or 1000

local get_node                     = core.get_node
local get_node_light               = core.get_node_light
local find_nodes_in_area_under_air = core.find_nodes_in_area_under_air
local mt_get_biome_name            = core.get_biome_name
local get_connected_players        = core.get_connected_players
local registered_nodes             = core.registered_nodes

local math_min       = math.min
local math_max       = math.max
local math_random    = math.random
local math_round     = math.round
local math_floor     = math.floor
local math_ceil      = math.ceil
local math_sqrt      = math.sqrt
local math_abs       = math.abs

local vector_distance = vector.distance

local easy = {
	group_roll_probability = 0.95, -- 1 in 20 chance for each additional mob in group
	fixed_timeslice = 500,
}
local hard = { -- Placeholder for when we implement difficulty levels
	group_roll_probability = 0.80,
	fixed_timeslice = 1000,
}
local rates = easy

local pairs = pairs
local check_line_of_sight = mcl_mobs.check_line_of_sight

local profile = false
local logging = core.settings:get_bool("mcl_logging_mobs_spawn", false)
local function mcl_log(message, property)
	if property then message = message .. ": " .. dump(property) end
	mcl_util.mcl_log(message, "[Mobs spawn]", true)
end
if not logging then mcl_log = function() end end

local dbg_spawn_attempts = 0
local dbg_spawn_succ = 0
local exclude_time = 0
local note = nil

local remove_far = true

local MOB_SPAWN_ZONE_INNER = 24
local MOB_SPAWN_ZONE_INNER_SQ = MOB_SPAWN_ZONE_INNER^2 -- squared
local MOB_SPAWN_ZONE_MIDDLE = 32
local MOB_SPAWN_ZONE_OUTER = 128
local MOB_SPAWN_ZONE_OUTER_SQ = MOB_SPAWN_ZONE_OUTER^2 -- squared

-- range for mob count
local MOB_CAP_INNER_RADIUS = 32
local aoc_range = 136

local MISSING_CAP_DEFAULT = 15
local MOBS_CAP_CLOSE = 10

local SPAWN_MAPGEN_LIMIT  = mcl_vars.mapgen_limit - 150

local mob_cap = {
	hostile = tonumber(core.settings:get("mcl_mob_cap_monster")) or 70,
	passive = tonumber(core.settings:get("mcl_mob_cap_animal")) or 10,
	ambient = tonumber(core.settings:get("mcl_mob_cap_ambient")) or 15,
	water = tonumber(core.settings:get("mcl_mob_cap_water")) or 8,
	water_ambient = tonumber(core.settings:get("mcl_mob_cap_water_ambient")) or 20,
	water_underground = tonumber(core.settings:get("mcl_mob_cap_water_underground")) or 5,
	axolotl = tonumber(core.settings:get("mcl_mob_cap_axolotl")) or 2, -- TODO should be 5 when lush caves added
	player = tonumber(core.settings:get("mcl_mob_cap_player")) or 75,
	global_hostile = tonumber(core.settings:get("mcl_mob_cap_hostile")) or 300,
	global_non_hostile = tonumber(core.settings:get("mcl_mob_cap_non_hostile")) or 300,
	total = tonumber(core.settings:get("mcl_mob_cap_total")) or 500,
}

local peaceful_percentage_spawned = tonumber(core.settings:get("mcl_mob_peaceful_percentage_spawned")) or 30
local peaceful_group_percentage_spawned = tonumber(core.settings:get("mcl_mob_peaceful_group_percentage_spawned")) or 15
local hostile_group_percentage_spawned = tonumber(core.settings:get("mcl_mob_hostile_group_percentage_spawned")) or 20

mcl_log("Mob cap hostile: " .. mob_cap.hostile)
mcl_log("Mob cap water: " .. mob_cap.water)
mcl_log("Mob cap passive: " .. mob_cap.passive)

mcl_log("Percentage of peacefuls spawned: " .. peaceful_percentage_spawned)
mcl_log("Percentage of peaceful spawns are group: " .. peaceful_group_percentage_spawned)
mcl_log("Percentage of hostile spawns are group: " .. hostile_group_percentage_spawned)

--do mobs spawn?
local gamerule_doMobSpawning = true
vl_tuning.setting("gamerule:doMobSpawning", "bool", {
	description = S("Whether mobs should spawn naturally, or via global spawning logic, such as for cats, phantoms, patrols, wandering traders, or zombie sieges. Does not affect special spawning attempts, like monster spawners, raids, or iron golems."),
	default = core.settings:get_bool("mobs_spawn", true),
	formspec_desc_lines = 3,
	set = function(val) gamerule_doMobSpawning = val end,
	get = function() return gamerule_doMobSpawning end,
})

local spawn_protected = core.settings:get_bool("mobs_spawn_protected") ~= false

-- count how many mobs are in an area
local function count_mobs(pos,r,mob_type)
	local num = 0
	for _,l in pairs(core.luaentities) do
		if l and l.is_mob and (mob_type == nil or l.type == mob_type) then
			local p = l.object:get_pos()
			if p and vector_distance(p,pos) < r then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_total(mob_type)
	local num = 0
	for _,l in pairs(core.luaentities) do
		if l.is_mob then
			if mob_type == nil or l.type == mob_type then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_add_entry (mobs_list, mob_cat)
	mobs_list[mob_cat] = (mobs_list[mob_cat] or 0) + 1
end

--categorise_by can be name or type or spawn_class
local function count_mobs_all(categorise_by, pos)
	local mobs_found_wide = {}
	local mobs_found_close = {}

	local num = 0
	for _,entity in pairs(core.luaentities) do
		if entity.is_mob then
			local add_entry = false
			local mob_cat = entity[categorise_by]

			if pos then
				local mob_pos = entity.object:get_pos()
				if mob_pos then
					local distance = vector.distance(pos, mob_pos)
					if distance <= MOB_SPAWN_ZONE_MIDDLE then
						count_mobs_add_entry (mobs_found_close, mob_cat)
						count_mobs_add_entry (mobs_found_wide, mob_cat)
						add_entry = true
					elseif distance <= MOB_SPAWN_ZONE_OUTER then
						count_mobs_add_entry (mobs_found_wide, mob_cat)
						add_entry = true
					end
				end
			else
				count_mobs_add_entry (mobs_found_wide, mob_cat)
				add_entry = true
			end

			if add_entry then
				num = num + 1
			end
		end
	end
	return mobs_found_close, mobs_found_wide, num
end

local function count_mobs_total_cap(mob_type)
	local num = 0
	local hostile = 0
	local non_hostile = 0
	local mob_counts_by_name = {}
	for _,l in pairs(core.luaentities) do
		if l.is_mob then
			local nametagged = l.nametag and l.nametag ~= ""
			if ( mob_type == nil or l.type == mob_type ) and not nametagged then
				mob_counts_by_name[l.name] = (mob_counts_by_name[l.name] or 0) + 1
				if l.spawn_class == "hostile" then
					hostile = hostile + 1
				else
					non_hostile = non_hostile + 1
				end
				num = num + 1
			end
		end
	end
	return num, non_hostile, hostile, mob_counts_by_name
end

local function output_mob_stats(mob_counts, total_mobs, chat_display)
	if (total_mobs) then
		local total_output = "Total mobs found: " .. total_mobs
		if chat_display then
			core.log(total_output)
		else
			core.log("action", total_output)
		end

	end
	local detailed = ""
	if mob_counts then
		for k, v1 in pairs(mob_counts) do
			detailed = detailed .. tostring(k) ..  ": " .. tostring(v1) ..  "; "
		end
	end
	if detailed and detailed ~= "" then
		if chat_display then
			core.log(detailed)
		else
			core.log("action", detailed)
		end
	end
end


-- global functions

function mcl_mobs:spawn_abm_check(pos, node, name)
	-- global function to add additional spawn checks
	-- return true to stop spawning mob
end

-- this is where all of the spawning information is kept
---@class mcl_mobs.SpawnDef
---@field name string Name of the mob. Required
---@field dimension "overworld"|"nether"|"end"
---@field type_of_spawning "ground"|"water"|"lava"
---@field biomes? string[] List of biomes the mob can spawn in
---@field biomes_lookup {[string]: boolean} Lookup table version of biomes field
---@field min_light integer
---@field max_light integer
---@field chance integer
---@field interval integer
---@field aoc integer
---@field min_height integer
---@field max_height integer
---@field day_toggle boolean
---@field check_position? fun(pos : vector.Vector): boolean
---@field on_spawn? fun()
---@type mcl_mobs.SpawnDef[]
local spawn_dictionary = {}

--this is where all of the spawning information is kept for mobs that don't naturally spawn
---@type {[string]: {[string]: {min_light: integer, max_light: integer}}}
local non_spawn_dictionary = {}

function mcl_mobs:spawn_setup(def)
	-- Validate required definition fields are present
	assert(def, "Missing spawn definition")
	assert(def.name, "Spawn definition missing entity name")
	assert(core.registered_entities[def.name], "Entity name not registered")
	local name = def.name

	-- Defaults
	def.chance = def.chance or 1000
	def.aoc = def.aoc or aoc_range
	def.dimension = def.dimension or "overworld"
	def.type_of_spawning = def.type_of_spawning or "overworld"
	def.interval = def.interval or 1
	def.min_height = def.min_height or mcl_vars.mg_overworld_min
	def.max_height = def.max_height or mcl_vars.mg_overworld_max
	def.min_light = def.min_light or 0
	def.max_light = def.max_light or core.LIGHT_MAX + 1

	-- chance/spawn number override in core.conf for registered mob
	local numbers = core.settings:get(name)
	if numbers then
		local number_parts = numbers:split(",")
		def.chance = tonumber(number_parts[1]) or def.chance
		def.aoc = tonumber(number_parts[2]) or def.aoc
		if def.chance == 0 then
			core.log("warning", string.format("[mcl_mobs] %s has spawning disabled", name))
			return
		end
		core.log("action", string.format("[mcl_mobs] Chance setting for %s changed to %s (total: %s)", name, def.chance, def.aoc))
	end

	if def.chance < 1 then
		def.chance = 1
		core.log("warning", "Chance shouldn't be less than 1 (mob name: " .. name ..")")
	end

	-- Create lookup table from biomes if one isn't provided
	if not def.biomes_lookup then
		local biomes_lookup = {}
		def.biomes_lookup = biomes_lookup
		local biomes = def.biomes
		if biomes then
			for i=1,#biomes do
				biomes_lookup[biomes[i]] = true
			end
		end
	end

	spawn_dictionary[#spawn_dictionary + 1] = def
end

function mcl_mobs:mob_light_lvl(mob_name, dimension)
	local spawn_dictionary_consolidated = {}

	if non_spawn_dictionary[mob_name] then
		local mob_dimension = non_spawn_dictionary[mob_name][dimension]
		if mob_dimension then
			--core.log("Found in non spawn dictionary for dimension")
			return mob_dimension.min_light, mob_dimension.max_light
		else
			--core.log("Found in non spawn dictionary but not for dimension")
			local overworld_non_spawn_def = non_spawn_dictionary[mob_name]["overworld"]
			if overworld_non_spawn_def then
				return overworld_non_spawn_def.min_light, overworld_non_spawn_def.max_light
			end
		end
	else
		--core.log("must be in spawning dictionary")
		for i,v in pairs(spawn_dictionary) do
			local current_mob_name = spawn_dictionary[i].name
			local current_mob_dim = spawn_dictionary[i].dimension
			if mob_name == current_mob_name then
				if not spawn_dictionary_consolidated[current_mob_name] then
					spawn_dictionary_consolidated[current_mob_name] = {}
				end
				spawn_dictionary_consolidated[current_mob_name][current_mob_dim] = {
					["min_light"] = spawn_dictionary[i].min_light,
					["max_light"] = spawn_dictionary[i].max_light
				}
			end
		end

		if spawn_dictionary_consolidated[mob_name] then
			--core.log("is in consolidated")
			local mob_dimension = spawn_dictionary_consolidated[mob_name][dimension]
			if mob_dimension then
				--core.log("found for dimension")
				return mob_dimension.min_light, mob_dimension.max_light
			else
				--core.log("not found for dimension, use overworld def")
				local mob_dimension_default = spawn_dictionary_consolidated[mob_name]["overworld"]
				if mob_dimension_default then
					return mob_dimension_default.min_light, mob_dimension_default.max_light
				end
			end
		end
	end

	core.log("action", "There are no light levels for mob (" .. tostring(mob_name) .. ") in dimension (" .. tostring(dimension) .. "). Return defaults")
	return 0, core.LIGHT_MAX+1
end

function mcl_mobs:non_spawn_specific(mob_name,dimension,min_light,max_light)
	non_spawn_dictionary[#non_spawn_dictionary + 1] = mob_name
	non_spawn_dictionary[mob_name] = {
		[dimension] = {
			min_light = min_light , max_light = max_light
		}
	}
end

---@param name string
---@param dimension string
---@param type_of_spawning string
---@param biomes string[]
---@deprecated
function mcl_mobs:spawn_specific(name, dimension, type_of_spawning, biomes, min_light, max_light, interval, chance, aoc, min_height, max_height, day_toggle, on_spawn, check_position)
	mcl_mobs:spawn_setup({
		name = name,
		dimension = dimension,
		type_of_spawning = type_of_spawning,
		biomes = biomes,
		min_light = min_light,
		max_light = max_light,
		interval = interval,
		chance = chance,
		aoc = aoc,
		min_height = min_height,
		max_height = max_height,
		day_toggle = day_toggle,
		on_spawn = on_spawn,
		check_position = check_position,
	})
end

local function get_next_mob_spawn_pos(pos)
	-- Select a distance such that distances closer to the player are selected much more often than
	-- those further away from the player. This does produce a concentration at INNER (24 blocks)
	local distance = math_random()^2 * (MOB_SPAWN_ZONE_OUTER - MOB_SPAWN_ZONE_INNER) + MOB_SPAWN_ZONE_INNER
	--print("Using spawn distance of "..tostring(distance).."  fx="..tostring(fx)..",x="..tostring(x))

	-- Choose a random direction. Rejection sampling is simple and fast (1-2 tries usually)
	local xoff, yoff, zoff, dd
	repeat
		xoff, yoff, zoff = math_random() * 2 - 1, math_random() * 2 - 1, math_random() * 2 - 1
		dd = xoff*xoff + yoff*yoff + zoff*zoff
	until (dd <= 1 and dd >= 1e-6) -- outside of uniform ball, retry
	dd = distance / math_sqrt(dd) -- distance scaling factor
	xoff, yoff, zoff = xoff * dd, yoff * dd, zoff * dd
	local goal_pos = vector.offset(pos, xoff, yoff, zoff)

	if not (math_abs(goal_pos.x) <= SPAWN_MAPGEN_LIMIT and math_abs(goal_pos.y) <= SPAWN_MAPGEN_LIMIT and math_abs(goal_pos.z) <= SPAWN_MAPGEN_LIMIT) then
		mcl_log("Pos outside mapgen limits: " .. core.pos_to_string(goal_pos))
		return nil
	end

	-- Calculate upper/lower y limits
	local d2 = xoff*xoff + zoff*zoff -- squared distance in x,z plane only
	local y1 = math_sqrt(MOB_SPAWN_ZONE_OUTER_SQ - d2) -- absolue value of distance to outer sphere

	local y_min, y_max
	if d2 >= MOB_SPAWN_ZONE_INNER_SQ then
		-- Outer region, y range has both ends on the outer sphere
		y_min = pos.y - y1
		y_max = pos.y + y1
	else
		-- Inner region, y range spans between inner and outer spheres
		local y2 = math_sqrt(MOB_SPAWN_ZONE_INNER_SQ - d2)
		if goal_pos.y > pos.y then
			-- Upper hemisphere
			y_min = pos.y + y2
			y_max = pos.y + y1
		else
			-- Lower hemisphere
			y_min = pos.y - y1
			y_max = pos.y - y2
		end
	end
	-- Limit total range of check to 32 nodes (maximum of 3 map blocks)
	y_min = math_max(math_floor(y_min), goal_pos.y - 16)
	y_max = math_min(math_ceil(y_max), goal_pos.y + 16)

	-- Ask engine for valid spawn locations
	local spawning_position_list = find_nodes_in_area_under_air(
			{x = goal_pos.x, y = y_min, z = goal_pos.z},
			{x = goal_pos.x, y = y_max, z = goal_pos.z},
			{"group:solid", "group:water", "group:lava"}
	) or {}

	-- Select only the locations at a valid distance
	local valid_positions = {}
	for i=1,#spawning_position_list do
		local check_pos = spawning_position_list[i]
		local dist = vector.distance(pos, check_pos)
		if dist >= MOB_SPAWN_ZONE_INNER and dist <= MOB_SPAWN_ZONE_OUTER then
			valid_positions[#valid_positions + 1] = check_pos
		end
	end
	spawning_position_list = valid_positions

	-- No valid locations, failed to find a position
	if #spawning_position_list == 0 then
		return nil
	end

	-- Pick a random valid location
	return spawning_position_list[math_random(1, #spawning_position_list)]
end

local function is_farm_animal(n)
	return n == "mobs_mc:pig" or n == "mobs_mc:cow" or n == "mobs_mc:sheep" or n == "mobs_mc:chicken" or n == "mobs_mc:horse" or n == "mobs_mc:donkey"
end

local function get_water_spawn(p)
	local nn = core.find_nodes_in_area(vector.offset(p,-2,-1,-2),vector.offset(p,2,-15,2),{"group:water"})
	return nn and #nn > 0 and nn[math_random(#nn)]
end

--- helper to check a single node p
local function check_room_helper(p, fly_in, fly_in_air, headroom, check_headroom)
	local node = get_node(p)
	local name = node.name
	-- fast-track very common air case:
	if fly_in_air and name == "air" then return true end
	local n_def = registered_nodes[name]
	if not n_def then return false end -- don't spawn in ignore

	-- Fast-track common cases:
	-- if fly_in "air", also include other non-walkable non-liquid nodes:
	if fly_in_air and n_def and not n_def.walkable and n_def.liquidtype == "none" then return true end
	-- other things we can fly in
	if fly_in[name] then return true end
	-- negative checks: need full node
	if not check_headroom then return false end
	-- solid block always overlaps
	if n_def.node_box == "regular" then return false end
	-- perform sub-node checks in top layer
	local boxes = core.get_node_boxes("collision_box", p, node)
	for i = 1,#boxes do
		-- headroom is measured from the bottom, hence +0.5
		if boxes[i][2] + 0.5 < headroom then
			return false
		end
	end
	return true
end

local FLY_IN_AIR = { air = true }
local function has_room(self, pos)
	local cb = self.spawnbox or self.initial_properties.collisionbox
	local fly_in = self.fly_in or FLY_IN_AIR
	local fly_in_air = not not fly_in["air"]

	-- Calculate area to check for room
	local cb_height = cb[5] - cb[2]
	local p1 = vector.new(
		math_round(pos.x + cb[1]),
		math_floor(pos.y),
		math_round(pos.z + cb[3]))
	local p2 = vector.new(
		math_round(pos.x + cb[4]),
		math_ceil(p1.y + cb_height) - 1,
		math_round(pos.z + cb[6]))

	-- Check if the entire spawn volume is free
	local p = vector.copy(pos)
	local headroom = cb_height - (p2.y - p1.y) -- headroom needed in top layer
	for y = p1.y,p2.y do
		p.y = y
		local check_headroom = headroom < 1 and y == p2.y and core.get_node_boxes
		for z = p1.z,p2.z do
			p.z = z
			for x = p1.x,p2.x do
				p.x = x
				if not check_room_helper(p, fly_in, fly_in_air, headroom, check_headroom) then
					return false
				end
			end
		end
	end
	return true
end

mcl_mobs.custom_biomecheck = nil

function mcl_mobs.register_custom_biomecheck(custom_biomecheck)
	mcl_mobs.custom_biomecheck = custom_biomecheck
end

local custom_biome_ids = {}
local custom_biome_names = {}
local next_custom_biome_id = 0

local function get_biome_name(pos)
	if mcl_mobs.custom_biomecheck then
		local biome_name = mcl_mobs.custom_biomecheck(pos)
		local biome_id = custom_biome_ids[biome_name]
		if not biome_id then
			biome_id = next_custom_biome_id
			next_custom_biome_name = biome_id + 1

			custom_biome_ids[biome_name] = biome_id
			custom_biome_names[biome_id] = biome_name
		end
		return biome_name, biome_id
	end
	local biome_data = core.get_biome_data(pos)
	local biome_id = biome_data and biome_data.biome
	local biome_name = biome_id and mt_get_biome_name(biome_id)
	return biome_name, biome_id
end

local function initial_spawn_check(state, spawn_def)
	if not spawn_def then return false end
	local mob_def = core.registered_entities[spawn_def.name]

	if mob_def.type == "monster" then
		if not state.spawn_hostile then return false end
	else
		if not state.spawn_passive then return false end
	end

	-- Make the dimention is correct
	if spawn_def.dimension ~= state.dimension then return false end
	if spawn_def.biomes and not spawn_def.biomes_lookup[state.biome] then return false end

	-- Ground mobs must spawn on solid nodes that are not leaves
	if spawn_def.type_of_spawning == "ground" and not state.is_ground then return false end

	-- Water mobs must spawn in water
	if spawn_def.type_of_spawning == "water" and not state.is_water then return false end

	-- Lava mobs must spawn in lava
	if spawn_def.type_of_spawning == "lava" and not state.is_lava then return false end

	-- Farm animals must spawn on grass
	if is_farm_animal(spawn_def.name) and not state.is_grass then return false end

	return true
end

local function spawn_check(pos, state, node, spawn_def)
	if not initial_spawn_check(state, spawn_def) then return false end

	dbg_spawn_attempts = dbg_spawn_attempts + 1

	-- Make sure the mob can spawn at this location
	if pos.y < spawn_def.min_height or pos.y > spawn_def.max_height then return false end

	-- Don't spawn if the spawn definition has a custom check and that fails
	if spawn_def.check_position and not spawn_def.check_position(pos) then return false end

	return true
end

function mcl_mobs.spawn(pos,id)
	if not pos or not id then return false end
	local def = core.registered_entities[id] or core.registered_entities["mobs_mc:"..id] or core.registered_entities["extra_mobs:"..id]
	if not def or not def.is_mob or (def.can_spawn and not def.can_spawn(pos)) then return false end
	if not has_room(def, pos) then
		local cb = def.spawnbox or def.initial_properties.collisionbox
		-- simple position adjustment for 2x2 mobs until we add something better for asymmetric cases
		-- e.g., when spawning next to a fence on one side, the 0.5 offset may not be optimal.
		local wx, wz = cb[4] - cb[1], cb[6] - cb[3]
		local retry = false
		if (wx > 1 and wx <= 2) then
			pos.x = pos.x + math_random(0,1) - 0.5
			retry = true
		end
		if (wz > 1 and wz <= 2) then
			pos.z = pos.z + math_random(0,1) - 0.5
			retry = true
		end
		if not retry or not has_room(def, pos) then
			--note = "no room for mob"
			return false
		end
	end
	if math_round(pos.y) == pos.y then -- node spawn
		pos.y = pos.y - 0.495 - def.initial_properties.collisionbox[2] -- spawn just above ground below
	end
	local start_time = core.get_us_time()
	local obj = core.add_entity(pos, def.name)
	if not obj then return end

	--note = "spawned a mob"
	exclude_time = exclude_time + core.get_us_time() - start_time
	-- initialize head bone
	if def.head_swivel and def.head_bone_position then
		if obj.get_bone_override then -- minetest >= 5.9
			obj:set_bone_override(def.head_swivel, {
				position = { vec = def.head_bone_position, absolute = true },
				rotation = { vec = vector.zero(), absolute = true }
			})
		else -- minetest < 5.9
			obj:set_bone_position(def.head_swivel, def.head_bone_position, vector.zero())
		end
	end
	return obj
end

---@class mcl_mobs.SpawnState
---@field cap_space_hostile integer
---@field cap_space_passive integer
---@field spawn_hostile boolean
---@field spawn_passive boolean
---@field is_ground boolean
---@field is_grass boolean
---@field is_water boolean
---@field is_lava boolean
---@field biome string
---@field dimension string
---@field light integer
---@field hash integer

---@param pos vector.Vector
---@param parent_state mcl_mobs.SpawnState?
---@param spawn_hostile boolean
---@param spawn_passive boolean
---@return mcl_mobs.SpawnState?, core.Node?
local function build_state_for_position(pos, parent_state, spawn_hostile, spawn_passive)
	local dimension, dim_id = mcl_worlds.pos_to_dimension(pos)

	-- Get node and make sure it's loaded and a valid spawn point
	local node = get_node(pos)
	local node_name = node.name
	if not node or node_name == "ignore" or node_name == "mcl_core:bedrock" then return end

	local node_def = core.registered_nodes[node_name] or core.nodedef_default
	local groups = node_def.groups or {}

	-- Make sure we can spawn here

	-- Check if it's ground
	local is_water = (groups.water or 0) ~= 0
	local is_lava = (groups.lava or 0) ~= 0
	local is_ground = false
	if not is_water and not is_lava then
		is_ground = (groups.solid or 0) ~= 0
		if not is_ground then
			pos.y = pos.y - 1
			node = get_node(pos)
			node_def = core.registered_nodes[node.name] or core.nodedef_default
			groups = node_def.groups or {}
			is_ground = (groups.solid or 0) ~= 0
		end
		pos.y = pos.y + 1
	end
	is_ground = is_ground and (groups.leaves or 0) == 0

	-- Check light level
	local gotten_light = get_node_light(pos)
	local light = 0

	-- Legacy lighting
	if not modern_lighting then
		light = gotten_light or 0
	else
		-- Modern lighting
		local light_node = get_node(pos)
		local sky_light = core.get_natural_light(pos) or 0
		local art_light = core.get_artificial_light(light_node.param1)

		if dimension == "nether" then
			spawn_hostile = spawn_hostile and art_light <= nether_threshold
		elseif dimension == "end" then
			spawn_hostile = spawn_hostile and art_light <= end_threshold
		elseif dimension == "overworld" then
			spawn_hostile = spawn_hostile and art_light <= overworld_threshold and sky_light <= overworld_sky_threshold
		end

		-- passive threshold is apparently the same in all dimensions ...
		spawn_passive = spawn_passive and gotten_light >= overworld_passive_threshold
	end

	-- Impossible to spawn a mob here
	if not spawn_hostile and not spawn_passive then
		--note = "can't spawn either hostile or passive mobs here"
		return
	end

	-- Get biome information
	local biome_name,biome_id = get_biome_name(pos)
	if not biome_name then return end

	-- Build spawn state data
	local state = parent_state and table.copy(parent_state) or {}
	state.biome = biome_name
	state.dimension = dimension
	state.is_ground = is_ground
	state.is_grass = (groups.grass_block or 0) ~= 0
	state.is_water = is_water
	state.is_lava = is_lava
	state.light = light
	state.spawn_passive = spawn_passive
	state.spawn_hostile = spawn_hostile

	---@type integer
	state.hash = biome_id * 8 + dim_id
	           + (is_water and 0x400 or 0) + (is_lava and 0x800 or 0) + (is_ground and 0x1000 or 0)
	           + (spawn_passive and 0x2000 or 0) + (spawn_hostile and 0x4000 or 0) + 0x8000 * (state.light or 0)
	return state,node
end

local function spawn_group(p, mob, spawn_on, amount_to_spawn, parent_state)
	-- Find possible spawn locations and shuffle the list
	local nn = find_nodes_in_area_under_air(vector.offset(p,-5,-3,-5), vector.offset(p,5,3,5), spawn_on)
	if not nn or #nn < 1 then
		nn = {p}
	elseif #nn > 1 then
		table.shuffle(nn)
	end
	--core.log("Spawn point list: "..dump(nn))

	-- Use the first amount_to_spawn positions to spawn mobs. If a spawn position is protected,
	-- it is removed from the list and not counted against the spawn amount. Only one mob will
	-- spawn in a given spot.
	local o
	while amount_to_spawn > 0 and #nn > 0 do
		-- Find the next valid group spawn point
		local sp
		while #nn > 0 and not sp do
		-- Select the next spawn position
			sp = vector.offset(nn[#nn],0,1,0)
			nn[#nn] = nil

			if spawn_protected and core.is_protected(sp, "") then
				sp = nil
			elseif not check_line_of_sight(p, sp) then
				sp = nil
			end
		end
		if not sp then return o end

		-- Get state for each new position
		local state, node = build_state_for_position(sp, parent_state, true, true)

		if state and spawn_check(sp, state, node, mob) then
			if mob.type_of_spawning == "water" then
				sp = get_water_spawn(sp)
			end

			--core.log("Using spawn point "..vector.to_string(sp))

			o = mcl_mobs.spawn(sp,mob.name)
			if o then
				amount_to_spawn = amount_to_spawn - 1
				dbg_spawn_succ = dbg_spawn_succ + 1
			end
		end
	end
	return o
end

mcl_mobs.spawn_group = spawn_group

core.register_chatcommand("spawn_mob",{
	privs = { debug = true },
	description=S("spawn_mob is a chatcommand that allows you to type in the name of a mob without 'typing mobs_mc:' all the time like so; 'spawn_mob spider'. however, there is more you can do with this special command, currently you can edit any number, boolean, and string variable you choose with this format: spawn_mob 'any_mob:var<mobs_variable=variable_value>:'. any_mob being your mob of choice, mobs_variable being the variable, and variable value being the value of the chosen variable. and example of this format: \n spawn_mob skeleton:var<passive=true>:\n this would spawn a skeleton that wouldn't attack you. REMEMBER-THIS> when changing a number value always prefix it with 'NUM', example: \n spawn_mob skeleton:var<jump_height=NUM10>:\n this setting the skelly's jump height to 10. if you want to make multiple changes to a mob, you can, example: \n spawn_mob skeleton:var<passive=true>::var<jump_height=NUM10>::var<fly=true>:\n etc."),
	func = function(n,param)
		local pos = core.get_player_by_name(n):get_pos()

		local modifiers = {}
		for capture in string.gmatch(param, "%:(.-)%:") do
			modifiers[#modifiers + 1] = ":"..capture
		end

		local mod1 = string.find(param, ":")
		local mobname = param
		if mod1 then
			mobname = string.sub(param, 1, mod1-1)
		end

		local mob = mcl_mobs.spawn(pos,mobname)
		if mob then
			for c=1, #modifiers do
				local modifs = modifiers[c]

				local mod1 = string.find(modifs, ":")
				local mod_start = string.find(modifs, "<")
				local mod_vals = string.find(modifs, "=")
				local mod_end = string.find(modifs, ">")
				local mob_entity = mob:get_luaentity()
				if string.sub(modifs, mod1+1, mod1+3) == "var" then
					if mod1 and mod_start and mod_vals and mod_end then
						local variable = string.sub(modifs, mod_start+1, mod_vals-1)
						local value = string.sub(modifs, mod_vals+1, mod_end-1)

						local number_tag = string.find(value, "NUM")
						if number_tag then
							value = tonumber(string.sub(value, 4, -1))
						end

						if value == "true" then
							value = true
						elseif value == "false" then
							value = false
						end

						if not mob_entity[variable] then
							core.log("warning", n.." mob variable "..variable.." previously unset")
						end

						mob_entity[variable] = value

					else
						core.log("warning", n.." couldn't modify "..mobname.." at "..core.pos_to_string(pos).. ", missing paramaters")
					end
				else
					core.log("warning", n.." couldn't modify "..mobname.." at "..core.pos_to_string(pos).. ", missing modification type")
				end
			end

			core.log("action", n.." spawned "..mobname.." at "..core.pos_to_string(pos))
			return true, mobname.." spawned at "..core.pos_to_string(pos)
		else
			return false, "Couldn't spawn "..mobname
		end
	end
})

local function mob_cap_space(mob_type, mob_counts_close, mob_counts_wide, cap_space_hostile, cap_space_non_hostile)
	-- Some mob examples
	--type = "monster", spawn_class = "hostile",
	--type = "animal", spawn_class = "passive",
	--local cod = { type = "animal", spawn_class = "water",

	local type_cap = mob_cap[mob_type] or MISSING_CAP_DEFAULT
	local close_zone_cap = MOBS_CAP_CLOSE

	local mob_total_wide = mob_counts_wide[mob_type]
	if not mob_total_wide then
		mob_total_wide = 0
	end

	local cap_space_wide = math_max(type_cap - mob_total_wide, 0)

	local cap_space_available
	if mob_type == "hostile" then
		cap_space_available = math_min(cap_space_hostile, cap_space_wide)
	else
		cap_space_available = math_min(cap_space_non_hostile, cap_space_wide)
	end

	local mob_total_close = mob_counts_close[mob_type]
	if not mob_total_close then
		mob_total_close = 0
	end

	local cap_space_close = math_max(close_zone_cap - mob_total_close, 0)
	cap_space_available = math_min(cap_space_available, cap_space_close)

	return cap_space_available
end

local function select_random_mob_def(spawn_table)
	if #spawn_table == 0 then return nil end

	local mob_chance_offset = math_random() * spawn_table.cumulative_chance
	-- Deliberately one less that the table size. The last item will always
	-- be chosen when all others aren't selected
	for i = 1,(#spawn_table-1) do
		local mob_def = spawn_table[i]
		local mob_chance = mob_def.chance
		if mob_chance_offset <= mob_chance then
			return mob_def
		end

		mob_chance_offset = mob_chance_offset - mob_chance
	end

	-- If we get here, return the last element in the spawn table
	return spawn_table[#spawn_table]
end

local spawn_lists = {}
local function get_spawn_list(pos, hostile_limit, passive_limit)
	-- Check capacity
	local mob_counts_close, mob_counts_wide = count_mobs_all("spawn_class", pos)
	local cap_space_hostile = mob_cap_space("hostile", mob_counts_close, mob_counts_wide, hostile_limit, passive_limit )
	local spawn_hostile = cap_space_hostile > 0

	local cap_space_passive = mob_cap_space("passive", mob_counts_close, mob_counts_wide, hostile_limit, passive_limit )
	local spawn_passive = cap_space_passive > 0 and math_random(100) < peaceful_percentage_spawned

	-- Merge light level checks with cap checks
	local state, node = build_state_for_position(pos, nil, spawn_hostile, spawn_passive)
	if not state then
		--note = note or "no valid state for position"
		return
	end

	-- Make sure it is possible to spawn a mob here
	if not state.spawn_hostile and not state.spawn_passive then
		return
	end

	-- Check the cache to see if we have already built a spawn list for this state
	local state_hash = state.hash
	local spawn_list = spawn_lists[state_hash]
	state.cap_space_hostile = cap_space_hostile
	state.cap_space_passive = cap_space_passive
	if spawn_list then
		return spawn_list, state, node
	end

	-- Build a spawn list for this state
	spawn_list = {}
	for i = 1,#spawn_dictionary do
		local def = spawn_dictionary[i]
		if initial_spawn_check(state, def) then
			spawn_list[#spawn_list + 1] = def
		end
	end

	-- Calculate cumulative chance value
	local cumulative_chance = 0
	for i = 1,#spawn_list do
		cumulative_chance = cumulative_chance + spawn_list[i].chance
	end
	spawn_list.cumulative_chance = cumulative_chance

	if logging then
		local spawn_names = {}
		for _,def in pairs(spawn_dictionary) do
			if initial_spawn_check(state, def) then
				spawn_names[#spawn_names + 1] = def.name
			end
		end

		local probabilities = {}
		for _,def in ipairs(spawn_list) do
			probabilities[def.name] = def.chance / cumulative_chance
		end

		core.log(dump({
			pos = pos,
			node = node,
			state = state,
			state_hash = state_hash,
			spawn_names = spawn_names,
			probabilities = probabilities,
		}))
	end
	spawn_lists[state_hash] = spawn_list
	return spawn_list, state, node
end

-- Spawns one mob or one group of mobs
local fail_count = 0
local function spawn_a_mob(pos, cap_space_hostile, cap_space_non_hostile, mob_counts_by_name)
	local spawning_position = get_next_mob_spawn_pos(pos)
	if not spawning_position then
		fail_count = fail_count + 1
		if logging and fail_count > 16 then
			core.log("action", "[Mobs spawn] Could not find a valid spawn position in last 16 attempts")
		end
		--note = "no valid spawn position"
		return
	end
	fail_count = 0

	-- Spawning prohibited in protected areas
	if spawn_protected and core.is_protected(spawning_position, "") then
		--note = "position protected"
		return
	end

	-- Select a mob
	local spawn_list, state, node = get_spawn_list(spawning_position, cap_space_hostile, cap_space_non_hostile)
	if not spawn_list or not state then
		--note = note or "no spawnable mobs for pos"
		return
	end
	local mob_def = select_random_mob_def(spawn_list)
	if not mob_def or not mob_def.name then
		--note = "no mob definition"
		return
	end
	local mob_def_ent = core.registered_entities[mob_def.name]

	-- Abort if we spawning this mob would put us over the mob's soft count
	if mob_def.soft_cap and (mob_counts_by_name[mob_def.name] or 0) >= mob_def.soft_cap then return end

	local cap_space_available = mob_def_ent.type == "monster" and state.cap_space_hostile or state.cap_space_passive

	-- Move up one node for lava spawns
	if mob_def.type_of_spawning == "lava" then
		spawning_position.y = spawning_position.y + 1
		node = core.get_node(spawning_position)
	end

	-- Make sure we would be spawning a mob
	if not spawn_check(spawning_position, state, node, mob_def) then
		if logging then mcl_log("Spawn check failed") end
		--note = "spawn check failed"
		return
	end

	-- Water mob special case
	if mob_def.type_of_spawning == "water" then
		spawning_position = get_water_spawn(spawning_position)
		if not spawning_position then
			if logging then
				mcl_log("[mcl_mobs] no water spawn for mob "..mob_def.name.." found at "..core.pos_to_string(vector.round(pos)))
			end
			--note = "no water"
			return
		end
	end

	if mob_def_ent.can_spawn and not mob_def_ent.can_spawn(spawning_position) then
		if logging then
			mcl_log("[mcl_mobs] mob "..mob_def.name.." refused to spawn at "..core.pos_to_string(vector.round(spawning_position)))
		end
		--note = "mob refused to spawn"
		return
	end

	--everything is correct, spawn mob
	local spawn_in_group = mob_def_ent.spawn_in_group or 4

	if spawn_in_group then
		local group_min = mob_def_ent.spawn_in_group_min or 1
		if not group_min then group_min = 1 end

		local amount_to_spawn = group_min
		for _ = group_min,spawn_in_group do
			-- Don't add mobs to groups if it would push that mob over the soft cap
			if mob_def.soft_cap then
				if (mob_counts_by_name[mob_def.name] or 0) + amount_to_spawn >= mob_def.soft_cap then break end
			end
			if math_random() <= rates.group_roll_probability then break end

			amount_to_spawn = amount_to_spawn + 1
		end
		amount_to_spawn = math_min(amount_to_spawn, cap_space_available)

		if amount_to_spawn > 1 then
			if logging then
				core.log("action", "[mcl_mobs] A group of " ..amount_to_spawn .. " " .. mob_def.name ..
					" mob spawns on " ..get_node(vector.offset(spawning_position,0,-1,0)).name ..
					" at " .. core.pos_to_string(spawning_position, 1)
				)
			end
			return spawn_group(spawning_position,mob_def,{get_node(vector.offset(spawning_position,0,-1,0)).name}, amount_to_spawn, state)
		end
	end

	if logging then
		core.log("action", "[mcl_mobs] Mob " .. mob_def.name .. " spawns on " ..
			get_node(vector.offset(spawning_position,0,-1,0)).name .." at "..
			core.pos_to_string(spawning_position, 1)
		)
	end
	return mcl_mobs.spawn(spawning_position, mob_def.name)
end

local count = 0
local function attempt_spawn()
	count = count + 1
	local players = get_connected_players()
	local total_mobs, total_non_hostile, total_hostile, mob_counts_by_name = count_mobs_total_cap()

	local cap_space_hostile = math_max(mob_cap.global_hostile - total_hostile, 0)
	local cap_space_non_hostile =  math_max(mob_cap.global_non_hostile - total_non_hostile, 0)

	if total_mobs > mob_cap.total or total_mobs >= #players * mob_cap.player then
		if logging then
			core.log("action","[mcl_mobs] global mob cap reached. no cycle spawning.")
		end
		--note = "global mob cap reached"
		return
	end --mob cap per player

	for i = 1,#players do
		local player = players[i]
		if player then
			local pos = player:get_pos()
			local dimension = mcl_worlds.pos_to_dimension(pos)
			-- ignore void and unloaded area
			if dimension ~= "void" and dimension ~= "default" then
				spawn_a_mob(pos, cap_space_hostile, cap_space_non_hostile, mob_counts_by_name)
			end
		end
	end
end

local function fixed_timeslice(timer, dtime, timeslice_us, handler)
	timer = timer + dtime * timeslice_us * 1e-6
	if timer <= 0 then return timer, 0 end

	-- Time the function
	local start_time_us = core.get_us_time()
	handler()
	local stop_time_us = core.get_us_time() + 1

	-- Measure how long this took and calculate the time until the next call
	local took = stop_time_us - start_time_us
	timer = timer - took * 1e-6

	return timer, took
end

--MAIN LOOP
local timer = 0
local start = true
local start_time
local total_time = 0
core.register_globalstep(function(dtime)
	if not gamerule_doMobSpawning then return end
	if start then
		start = false
		start_time = core.get_us_time()
	end

	--note = nil
	local next_spawn, took = fixed_timeslice(timer, dtime, rates.fixed_timeslice, attempt_spawn)
	timer = next_spawn

	if (profile or logging) and took > 0 then
		total_time = total_time + took
		core.log("Totals: "..tostring(total_time / (core.get_us_time() - start_time) * 100).."% count="..count..
			", "..tostring(total_time/count).."us per spawn attempt, took="..took.." us, note="..(note or ""))
	end
end)

local function despawn_allowed(self)
	local nametag = self.nametag and self.nametag ~= ""
	local not_busy = self.state ~= "attack" and self.following == nil
	if self.can_despawn == true then
		if not nametag and not_busy and self.tamed ~= true and self.persistent ~= true then
			return true
		end
	end
	return false
end

function mob_class:despawn_allowed()
	despawn_allowed(self)
end

assert(despawn_allowed({can_despawn=false}) == false, "despawn_allowed - can_despawn false failed")
assert(despawn_allowed({can_despawn=true}) == true, "despawn_allowed - can_despawn true failed")

assert(despawn_allowed({can_despawn=true, nametag=""}) == true, "despawn_allowed - blank nametag failed")
assert(despawn_allowed({can_despawn=true, nametag=nil}) == true, "despawn_allowed - nil nametag failed")
assert(despawn_allowed({can_despawn=true, nametag="bob"}) == false, "despawn_allowed - nametag failed")

assert(despawn_allowed({can_despawn=true, state="attack"}) == false, "despawn_allowed - attack state failed")
assert(despawn_allowed({can_despawn=true, following="blah"}) == false, "despawn_allowed - following state failed")

assert(despawn_allowed({can_despawn=true, tamed=false}) == true, "despawn_allowed - not tamed")
assert(despawn_allowed({can_despawn=true, tamed=true}) == false, "despawn_allowed - tamed")

assert(despawn_allowed({can_despawn=true, persistent=true}) == false, "despawn_allowed - persistent")
assert(despawn_allowed({can_despawn=true, persistent=false}) == true, "despawn_allowed - not persistent")

function mob_class:check_despawn(pos, dtime)
	self.lifetimer = self.lifetimer - dtime

	-- Despawning: when lifetimer expires, remove mob
	if remove_far and despawn_allowed(self) then
		if self.despawn_immediately or self.lifetimer <= 0 then
			if logging then
				core.log("action", "[mcl_mobs] Mob "..self.name.." despawns at "..core.pos_to_string(pos, 1) .. " lifetimer ran out")
			end
			mcl_burning.extinguish(self.object)
			mcl_util.remove_entity(self)
			return true
		elseif self.lifetimer <= 10 then
			if math_random(10) < 4 then
				self.despawn_immediately = true
			else
				self.lifetimer = 20
			end
		end
	end
end

core.register_chatcommand("mobstats",{
	privs = { debug = true },
	func = function(n,param)
		local pos = core.get_player_by_name(n):get_pos()
		core.chat_send_player(n,"mobs: within 32 radius of player/total loaded :"..count_mobs(pos,MOB_CAP_INNER_RADIUS) .. "/" .. count_mobs_total())
		core.chat_send_player(n,"spawning attempts since server start:" .. dbg_spawn_succ .. "/" .. dbg_spawn_attempts)

		local _, mob_counts_wide, total_mobs = count_mobs_all("name") -- Can use "type"
		output_mob_stats(mob_counts_wide, total_mobs, true)
	end
})
