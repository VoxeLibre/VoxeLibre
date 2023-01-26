--lua locals
local math, vector, minetest, mcl_mobs = math, vector, minetest, mcl_mobs
local mob_class = mcl_mobs.mob_class

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

local vector_distance = vector.distance
local vector_new      = vector.new
local vector_floor    = vector.floor

local table_copy     = table.copy
local table_remove   = table.remove
local pairs = pairs

local LOGGING_ON = minetest.settings:get_bool("mcl_logging_mobs_spawning", true)
local function mcl_log (message)
	if LOGGING_ON then
		mcl_util.mcl_log (message, "[Mobs spawn]", true)
	end
end


local dbg_spawn_attempts = 0
local dbg_spawn_succ = 0
local dbg_spawn_counts = {}

local WAIT_FOR_SPAWN_ATTEMPT = 10

local MOB_SPAWN_ZONE_INNER = 24
local MOB_SPAWN_ZONE_MIDDLE = 32
local MOB_SPAWN_ZONE_OUTER = 128 --TODO not used yet. Should replace aoc

-- range for mob count
local MOB_CAP_INNER_RADIUS = 32
local aoc_range = 136
local remove_far = true

local mob_cap = {
	monster = tonumber(minetest.settings:get("mcl_mob_cap_monster")) or 70,
	animal = tonumber(minetest.settings:get("mcl_mob_cap_animal")) or 10,
	ambient = tonumber(minetest.settings:get("mcl_mob_cap_ambient")) or 15,
	water = tonumber(minetest.settings:get("mcl_mob_cap_water")) or 5, --currently unused
	water_ambient = tonumber(minetest.settings:get("mcl_mob_cap_water_ambient")) or 20, --currently unused
	player = tonumber(minetest.settings:get("mcl_mob_cap_player")) or 75,
	total = tonumber(minetest.settings:get("mcl_mob_cap_total")) or 500,
}

--do mobs spawn?
local mobs_spawn = minetest.settings:get_bool("mobs_spawn", true) ~= false
local spawn_protected = minetest.settings:get_bool("mobs_spawn_protected") ~= false
local logging = minetest.settings:get_bool("mcl_logging_mobs_spawn",true)

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
	"MangroveSwamp_underground",

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
	"MangroveSwamp_ocean",
	"MangroveSwamp_deep_ocean",

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
	"BambooJungleM_shore",
	"BambooJungle_shore",
	"MangroveSwamp_shore",

	-- dimension biome:

	"Nether",
	"BasaltDelta",
	"CrimsonForest",
	"WarpedForest",
	"SoulsandValley",
	"End",

	-- Overworld regular:

	"Mesa",
	"FlowerForest",
	"Swampland",
	"Taiga",
	"ExtremeHills",
	"ExtremeHillsM",
	"ExtremeHills+_snowtop",
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
	"JungleM",
	"BirchForestM",
	"MesaPlateauF",
	"MesaPlateauFM",
	"MesaPlateauF_grasstop",
	"MesaBryce",
	"JungleEdge",
	"SavannaM",
	"MangroveSwamp",
	"BambooJungle",
	"BambooJungleEdge",
	"BambooJungleEdgeM",
	"BambooJungleM",
}

-- count how many mobs are in an area
local function count_mobs(pos,r,mob_type)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
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
	for _,l in pairs(minetest.luaentities) do
		if l.is_mob then
			if mob_type == nil or l.type == mob_type then
				num = num + 1
			end
		end
	end
	return num
end

local function count_mobs_all(categorise_by, pos, max_distance)
	local mobs_found = {}
	local num = 0
	for _,entity in pairs(minetest.luaentities) do
		if entity and entity.is_mob then

			local add_entry = false

			if pos and max_distance then
				local mob_pos = entity.object:get_pos()
				if mob_pos then
					local distance = vector.distance(pos, mob_pos)

					if distance <= max_distance then
						--mcl_log("distance is good")
						add_entry = true
					else
						mcl_log("mob_pos: " .. minetest.pos_to_string(mob_pos))
						mcl_log("distance: ".. distance)
					end
				end

			else
				add_entry = true
			end

			--local mob_type = entity.type -- animal / monster / npc
			if add_entry then
				local mob_cat = entity[categorise_by]
				if mobs_found[mob_cat] then
					mobs_found[mob_cat] = mobs_found[mob_cat] + 1
				else
					mobs_found[mob_cat] = 1
				end
				num = num + 1
			end
		end
	end
	mcl_log("num: ".. num)
	return mobs_found, num
end

local function count_mobs_total_cap(mob_type)
	local num = 0
	for _,l in pairs(minetest.luaentities) do
		if l.is_mob then
			if ( mob_type == nil or l.type == mob_type ) and l.can_despawn and not l.nametag then
				num = num + 1
			end
		end
	end
	return num
end

local function output_mob_stats(mob_counts, total_mobs)
	if (total_mobs) then
		minetest.log("action", "Total mobs found: " .. total_mobs)
	end
	if mob_counts then
		for k, v1 in pairs(mob_counts) do
			minetest.log("action", "k: " .. tostring(k))
			minetest.log("action", "v1: " .. tostring(v1))
		end
	end
end


-- global functions

function mcl_mobs:spawn_abm_check(pos, node, name)
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

function mcl_mobs:spawn_setup(def)
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
			minetest.log("warning", string.format("[mcl_mobs] %s has spawning disabled", name))
			return
		end
		minetest.log("action", string.format("[mcl_mobs] Chance setting for %s changed to %s (total: %s)", name, chance, aoc))
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

function mcl_mobs:spawn_specific(name, dimension, type_of_spawning, biomes, min_light, max_light, interval, chance, aoc, min_height, max_height, day_toggle, on_spawn)

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
			minetest.log("warning", string.format("[mcl_mobs] %s has spawning disabled", name))
			return
		end

		minetest.log("action", string.format("[mcl_mobs] Chance setting for %s changed to %s (total: %s)", name, chance, aoc))
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
	local distance = math_random(MOB_SPAWN_ZONE_INNER + 1, MOB_SPAWN_ZONE_MIDDLE)
	local angle = math_random() * two_pi
	local xoff = math_round(distance * math_cos(angle))
	local yoff = math_round(distance * math_sin(angle))
	return vector.offset(pos, xoff, 0, yoff)
end

local function decypher_limits(posy)
	posy = math_floor(posy)
	return posy - MOB_SPAWN_ZONE_MIDDLE, posy + MOB_SPAWN_ZONE_MIDDLE
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

local function is_farm_animal(n)
	return n == "mobs_mc:pig" or n == "mobs_mc:cow" or n == "mobs_mc:sheep" or n == "mobs_mc:chicken" or n == "mobs_mc:horse" or n == "mobs_mc:donkey"
end

local function get_water_spawn(p)
		local nn = minetest.find_nodes_in_area(vector.offset(p,-2,-1,-2),vector.offset(p,2,-15,2),{"group:water"})
		if nn and #nn > 0 then
			return nn[math.random(#nn)]
		end
end

local function has_room(self,pos)
	local cb = self.collisionbox
	local nodes = {}
	if self.fly_in then
		local t = type(self.fly_in)
		if t == "table" then
			nodes = table.copy(self.fly_in)
		elseif t == "string" then
			table.insert(nodes,self.fly_in)
		end
	end
	table.insert(nodes,"air")
	local x = cb[4] - cb[1]
	local y = cb[5] - cb[2]
	local z = cb[6] - cb[3]
	local r = math.ceil(x * y * z)
	local p1 = vector.offset(pos,cb[1],cb[2],cb[3])
	local p2 = vector.offset(pos,cb[4],cb[5],cb[6])
	local n = #minetest.find_nodes_in_area(p1,p2,nodes) or 0
	if r > n then
		minetest.log("warning","[mcl_mobs] No room for mob "..self.name.." at "..minetest.pos_to_string(vector.round(pos)))
		return false
	end
	return true
end



local function spawn_check(pos,spawn_def,ignore_caps)
	if not spawn_def then return end
	dbg_spawn_attempts = dbg_spawn_attempts + 1
	local dimension = mcl_worlds.pos_to_dimension(pos)
	local mob_def = minetest.registered_entities[spawn_def.name]
	local mob_type = mob_def.type
	local gotten_node = get_node(pos).name
	local gotten_biome = minetest.get_biome_data(pos)
	if not gotten_node or not gotten_biome then return end
	gotten_biome = get_biome_name(gotten_biome.biome) --makes it easier to work with

	local is_ground = minetest.get_item_group(gotten_node,"solid") ~= 0
	if not is_ground then
		pos.y = pos.y - 1
		gotten_node = get_node(pos).name
		is_ground = minetest.get_item_group(gotten_node,"solid") ~= 0
	end
	pos.y = pos.y + 1
	local is_water = get_item_group(gotten_node, "water") ~= 0
	local is_lava  = get_item_group(gotten_node, "lava") ~= 0
	local is_leaf  = get_item_group(gotten_node, "leaves") ~= 0
	local is_bedrock  = gotten_node == "mcl_core:bedrock"
	local is_grass = minetest.get_item_group(gotten_node,"grass_block") ~= 0
	local mob_count_wide = 0
	local mob_count = 0
	if not ignore_caps then
		mob_count = count_mobs(pos,MOB_CAP_INNER_RADIUS,mob_type)
		mob_count_wide = count_mobs(pos,aoc_range,mob_type)
	end

	if pos and spawn_def
	and ( mob_count_wide < (mob_cap[mob_type] or 15) )
	and ( mob_count < 5 )
	and pos.y >= spawn_def.min_height
	and pos.y <= spawn_def.max_height
	and spawn_def.dimension == dimension
	and biome_check(spawn_def.biomes, gotten_biome)
	and (is_ground or spawn_def.type_of_spawning ~= "ground")
	and (spawn_def.type_of_spawning ~= "ground" or not is_leaf)
	and has_room(mob_def,pos)
	and (spawn_def.check_position and spawn_def.check_position(pos) or true)
	and (not is_farm_animal(spawn_def.name) or is_grass)
	and (spawn_def.type_of_spawning ~= "water" or is_water)
	and ( not spawn_protected or not minetest.is_protected(pos, "") )
	and not is_bedrock then
		--only need to poll for node light if everything else worked
		local gotten_light = get_node_light(pos)
		if gotten_light >= spawn_def.min_light and gotten_light <= spawn_def.max_light then
			return true
		end
	end
	return false
end

function mcl_mobs.spawn(pos,id)
	local def = minetest.registered_entities[id] or minetest.registered_entities["mobs_mc:"..id] or minetest.registered_entities["extra_mobs:"..id]
	if not def or (def.can_spawn and not def.can_spawn(pos)) or not def.is_mob then
		return false
	end
	if not dbg_spawn_counts[def.name] then
		dbg_spawn_counts[def.name] = 1
	else
		dbg_spawn_counts[def.name] = dbg_spawn_counts[def.name] + 1
	end
	return minetest.add_entity(pos, def.name)
end


local function spawn_group(p,mob,spawn_on,amount_to_spawn)
	local nn= minetest.find_nodes_in_area_under_air(vector.offset(p,-5,-3,-5),vector.offset(p,5,3,5),spawn_on)
	local o
	table.shuffle(nn)
	if not nn or #nn < 1 then
		nn = {}
		table.insert(nn,p)
	end

	for i = 1, amount_to_spawn do
		local sp = vector.offset(nn[math.random(#nn)],0,1,0)
		if spawn_check(nn[math.random(#nn)],mob,true) then
			if mob.type_of_spawning == "water" then
				sp = get_water_spawn(sp)
			end
			o =  mcl_mobs.spawn(sp,mob.name)
			if o then dbg_spawn_succ = dbg_spawn_succ + 1 end
		end
	end
	return o
end

mcl_mobs.spawn_group = spawn_group

local S = minetest.get_translator("mcl_mobs")

minetest.register_chatcommand("spawn_mob",{
	privs = { debug = true },
	description=S("spawn_mob is a chatcommand that allows you to type in the name of a mob without 'typing mobs_mc:' all the time like so; 'spawn_mob spider'. however, there is more you can do with this special command, currently you can edit any number, boolean, and string variable you choose with this format: spawn_mob 'any_mob:var<mobs_variable=variable_value>:'. any_mob being your mob of choice, mobs_variable being the variable, and variable value being the value of the chosen variable. and example of this format: \n spawn_mob skeleton:var<passive=true>:\n this would spawn a skeleton that wouldn't attack you. REMEMBER-THIS> when changing a number value always prefix it with 'NUM', example: \n spawn_mob skeleton:var<jump_height=NUM10>:\n this setting the skelly's jump height to 10. if you want to make multiple changes to a mob, you can, example: \n spawn_mob skeleton:var<passive=true>::var<jump_height=NUM10>::var<fly_in=air>::var<fly=true>:\n etc."),
	func = function(n,param)
		local pos = minetest.get_player_by_name(n):get_pos()

		local modifiers = {}
		for capture in string.gmatch(param, "%:(.-)%:") do
			table.insert(modifiers, ":"..capture)
		end

		local mod1 = string.find(param, ":")



		local mobname = param
		if mod1 then
			mobname = string.sub(param, 1, mod1-1)
		end

		local mob = mcl_mobs.spawn(pos,mobname)

		if mob then
			for c=1, #modifiers do
				modifs = modifiers[c]

				local mod1 = string.find(modifs, ":")
				local mod_start = string.find(modifs, "<")
				local mod_vals = string.find(modifs, "=")
				local mod_end = string.find(modifs, ">")
				local mob_entity = mob:get_luaentity()
				if string.sub(modifs, mod1+1, mod1+3) == "var" then
					if mod1 and mod_start and mod_vals and mod_end then
						local variable = string.sub(modifs, mod_start+1, mod_vals-1)
						local value = string.sub(modifs, mod_vals+1, mod_end-1)

						number_tag = string.find(value, "NUM")
						if number_tag then
							value = tonumber(string.sub(value, 4, -1))
						end

						if value == "true" then
							value = true
						elseif value == "false" then
							value = false
						end

						if not mob_entity[variable] then
							minetest.log("warning", n.." mob variable "..variable.." previously unset")
						end

						mob_entity[variable] = value

					else
						minetest.log("warning", n.." couldn't modify "..mobname.." at "..minetest.pos_to_string(pos).. ", missing paramaters")
					end
				else
					minetest.log("warning", n.." couldn't modify "..mobname.." at "..minetest.pos_to_string(pos).. ", missing modification type")
				end
			end

			minetest.log("action", n.." spawned "..mobname.." at "..minetest.pos_to_string(pos))
			return true, mobname.." spawned at "..minetest.pos_to_string(pos)
		else
			return false, "Couldn't spawn "..mobname
		end
	end
})

if mobs_spawn then

	local perlin_noise

	-- Get pos to spawn, x and z are randomised, y is range

	local function mob_cap_space (pos, mob_type, mob_counts)
		local type_cap = mob_cap[mob_type] or 15


		local mob_count_from_total = mob_counts[mob_type]
		if not mob_count_from_total then
			mcl_log("none of type found. set as 0")
			mob_count_from_total = 0
		end

		local cap_space = type_cap - mob_count_from_total
		if cap_space < 1 then
			cap_space = 0
		end


		--type = "monster",
		--spawn_class = "hostile",
		--type = "animal",
		--spawn_class = "passive",
		--local cod = {
		--	type = "animal",
		--	spawn_class = "water",


		--mcl_log("spawn_class: " .. spawn_class)
		mcl_log("mob_type: " .. mob_type)
		mcl_log("type_cap: " .. type_cap)
		--if mob_type == "animal" then

		mcl_log("mob_count_from_total: " .. mob_count_from_total)

		--local mob_count = count_mobs(pos,MOB_CAP_INNER_RADIUS,mob_type)
		local mob_count_wide = count_mobs(pos,aoc_range,mob_type)

		mcl_log("mob_count_wide: " .. mob_count_wide)
		if mob_count_from_total ~= mob_count_wide then
			mcl_log("A difference in mob count")
		else
			mcl_log("No difference in mob count")
		end


		--mcl_log("mob_count: " .. mob_count)

		mcl_log("Cap space available: " .. cap_space)
		--end


		--and ( mob_count_wide < (mob_cap[mob_type] or 15) )
		--and ( mob_count < 5 )
		return cap_space
	end

	local function spawn_a_mob(pos, dimension, y_min, y_max)
		--create a disconnected clone of the spawn dictionary
		--prevents memory leak
		local mob_library_worker_table = table_copy(spawn_dictionary)
		local goal_pos = get_next_mob_spawn_pos(pos)
		--grab mob that fits into the spawning location
		--randomly grab a mob, don't exclude any possibilities
		local spawning_position_list = find_nodes_in_area_under_air(
			{x = goal_pos.x, y = y_min, z = goal_pos.z},
			{x = goal_pos.x, y = y_max, z = goal_pos.z},
			{"group:solid", "group:water", "group:lava"}
		)
		if #spawning_position_list <= 0 then return end
		local spawning_position = spawning_position_list[math_random(1, #spawning_position_list)]

		perlin_noise = perlin_noise or minetest_get_perlin(noise_params)
		local noise = perlin_noise:get_3d(spawning_position)
		local current_summary_chance = summary_chance
		table.shuffle(mob_library_worker_table)

		--
		local mob_counts, total_mobs = count_mobs_all("type", pos, aoc_range)
		output_mob_stats(mob_counts, total_mobs)

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
			--minetest.log(mob_def.name.." "..step_chance.. " "..mob_chance)
			if mob_def and mob_def.name and minetest.registered_entities[mob_def.name] then
				local spawn_in_group = minetest.registered_entities[mob_def.name].spawn_in_group or 4
				local spawn_in_group_min = minetest.registered_entities[mob_def.name].spawn_in_group_min or 1
				local mob_type = minetest.registered_entities[mob_def.name].type

				-- TODO use spawn class for caps
				--local spawn_class = minetest.registered_entities[mob_def.name].spawn_class
				--spawn_class = "water"

				local cap_space = mob_cap_space (pos, mob_type, mob_counts)

				--TODO cap check before or after spawn check - cap_space > 0 and
				if spawn_check(spawning_position,mob_def) then
					if mob_def.type_of_spawning == "water" then
						spawning_position = get_water_spawn(spawning_position)
						if not spawning_position then
							minetest.log("warning","[mcl_mobs] no water spawn for mob "..mob_def.name.." found at "..minetest.pos_to_string(vector.round(pos)))
							return
						end
					end
					if minetest.registered_entities[mob_def.name].can_spawn and not minetest.registered_entities[mob_def.name].can_spawn(spawning_position) then
						minetest.log("warning","[mcl_mobs] mob "..mob_def.name.." refused to spawn at "..minetest.pos_to_string(vector.round(spawning_position)))
						return
					end

					--everything is correct, spawn mob
					--TODO If spawning, need to recheck total, or add to total mobs...
					local object --TODO is not used. remove or use?
					--TODO ensure animal spawns are more gradual, remove mob_type ~= "monster" or
					if spawn_in_group and (mob_type ~= "monster" or math.random(5) == 1) then

						local group_min = spawn_in_group_min
						if not group_min then group_min = 1 end

						local amount_to_spawn = math.random(group_min,spawn_in_group)
						mcl_log("action", "Spawning quantity: " .. amount_to_spawn)

						if amount_to_spawn > cap_space then
							mcl_log("Throttle amount to cap space: " .. cap_space)
							amount_to_spawn = cap_space
						end

						if logging then
							minetest.log("action", "[mcl_mobs] A group of " ..amount_to_spawn .. " " .. mob_def.name .. " mob spawns on " ..minetest.get_node(vector.offset(spawning_position,0,-1,0)).name .." at " .. minetest.pos_to_string(spawning_position, 1))
						end

						object = spawn_group(spawning_position,mob_def,{minetest.get_node(vector.offset(spawning_position,0,-1,0)).name}, amount_to_spawn)
					else
						if logging then
							minetest.log("action", "[mcl_mobs] Mob " .. mob_def.name .. " spawns on " ..minetest.get_node(vector.offset(spawning_position,0,-1,0)).name .." at ".. minetest.pos_to_string(spawning_position, 1))
						end
						object = mcl_mobs.spawn(spawning_position, mob_def.name)
					end
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
		if timer < WAIT_FOR_SPAWN_ATTEMPT then return end
		timer = 0
		local players = get_connected_players()
		local total_mobs = count_mobs_total_cap()
		if total_mobs > mob_cap.total or total_mobs > #players * mob_cap.player then
			minetest.log("action","[mcl_mobs] global mob cap reached. no cycle spawning.")
			return
		end --mob cap per player
		for _, player in pairs(players) do
			local pos = player:get_pos()
			local dimension = mcl_worlds.pos_to_dimension(pos)
			-- ignore void and unloaded area
			if dimension ~= "void" and dimension ~= "default" then
				local y_min, y_max = decypher_limits(pos.y)
				spawn_a_mob(pos, dimension, y_min, y_max)
			end
		end
	end)
end

function mob_class:check_despawn(pos, dtime)
	self.lifetimer = self.lifetimer - dtime

	-- Despawning: when lifetimer expires, remove mob
	if remove_far
	and self.can_despawn == true
	and ((not self.nametag) or (self.nametag == ""))
	and self.state ~= "attack"
	and self.following == nil then
		if self.despawn_immediately or self.lifetimer <= 0 then
			if logging then
				minetest.log("action", "[mcl_mobs] Mob "..self.name.." despawns at "..minetest.pos_to_string(pos, 1) .. " lifetimer ran out")
			end
			mcl_burning.extinguish(self.object)
			self.object:remove()
			return true
		elseif self.lifetimer <= 10 then
			if math.random(10) < 4 then
				self.despawn_immediately = true
			else
				self.lifetimer = 20
			end
		end
	end
end


minetest.register_chatcommand("mobstats",{
	privs = { debug = true },
	func = function(n,param)
		minetest.chat_send_player(n,dump(dbg_spawn_counts))
		local pos = minetest.get_player_by_name(n):get_pos()
		minetest.chat_send_player(n,"mobs within 32 radius of player:"..count_mobs(pos,MOB_CAP_INNER_RADIUS))
		minetest.chat_send_player(n,"total mobs:"..count_mobs_total())
		minetest.chat_send_player(n,"spawning attempts since server start:"..dbg_spawn_attempts)
		minetest.chat_send_player(n,"successful spawns since server start:"..dbg_spawn_succ)


		--local mob_counts, total_mobs = count_mobs_all("name") -- name
		local mob_counts, total_mobs = count_mobs_all("type")
		output_mob_stats(mob_counts, total_mobs)

	end
})
