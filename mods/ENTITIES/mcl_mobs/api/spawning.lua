--lua locals
local get_node                     = minetest.get_node
local get_item_group               = minetest.get_item_group
local get_node_light               = minetest.get_node_light
local find_nodes_in_area_under_air = minetest.find_nodes_in_area_under_air
local get_biome_name               = minetest.get_biome_name
local get_objects_inside_radius    = minetest.get_objects_inside_radius


local math_random    = math.random
local math_floor     = math.floor
local max            = math.max

local vector_distance = vector.distance
local vector_new      = vector.new
local vector_floor    = vector.floor

local table_copy     = table.copy
local table_remove   = table.remove


-- range for mob count
local aoc_range = 48

--do mobs spawn?
local mobs_spawn = minetest.settings:get_bool("mobs_spawn", true) ~= false

--[[

THIS IS THE BIG LIST OF ALL BIOMES - used for programming/updating mobs

underground:
"FlowerForest_underground",
"JungleEdge_underground",local spawning_position = spawning_position_list[math.random(1,#spawning_position_list)]
"ColdTaiga_underground",
"IcePlains_underground",
"IcePlainsSpikes_underground",
"MegaTaiga_underground",
"Taiga_underground",
"ExtremeHills+_underground",
"JungleM_underground",
"ExtremeHillsM_underground",
"JungleEdgeM_underground",

ocean:
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

water or beach?
"MesaPlateauFM_sandlevel",
"MesaPlateauF_sandlevel",
"MesaBryce_sandlevel",
"Mesa_sandlevel",

beach:
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

dimension biome:
"Nether",
"End",

Overworld regular:
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
]]--



-- count how many mobs are in an area
local count_mobs = function(pos)
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

function mobs:spawn_specific(name, dimension, type_of_spawning, biomes, min_light, max_light, interval, chance, aoc, min_height, max_height, day_toggle, on_spawn)

	--print(dump(biomes))

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

		minetest.log("action",
			string.format("[mobs] Chance setting for %s changed to %s (total: %s)", name, chance, aoc))
	end

	--[[
	local spawn_action
	spawn_action = function(pos, node, active_object_count, active_object_count_wider, name)

			local orig_pos = table.copy(pos)
			-- is mob actually registered?
			if not mobs.spawning_mobs[name]
			or not minetest.registered_entities[name] then
				minetest.log("warning", "Mob spawn of "..name.." failed, unknown entity or mob is not registered for spawning!")
				return
			end

			-- additional custom checks for spawning mob
			if mobs:spawn_abm_check(pos, node, name) == true then
				minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, ABM check rejected!")
				return
			end

			-- count nearby mobs in same spawn class
			local entdef = minetest.registered_entities[name]
			local spawn_class = entdef and entdef.spawn_class
			if not spawn_class then
				if entdef.type == "monster" then
					spawn_class = "hostile"
				else
					spawn_class = "passive"
				end
			end
			local in_class_cap = count_mobs(pos, "!"..spawn_class) < MOB_CAP[spawn_class]
			-- do not spawn if too many of same mob in area
			if active_object_count_wider >= max_per_block -- large-range mob cap
			or (not in_class_cap) -- spawn class mob cap
			or count_mobs(pos, name) >= aoc then -- per-mob mob cap
				-- too many entities
				minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, too crowded!")
				return
			end

			-- if toggle set to nil then ignore day/night check
			if day_toggle ~= nil then

				local tod = (minetest.get_timeofday() or 0) * 24000

				if tod > 4500 and tod < 19500 then
					-- daylight, but mob wants night
					if day_toggle == false then
						-- mob needs night
						minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, mob needs light!")
						return
					end
				else
					-- night time but mob wants day
					if day_toggle == true then
						-- mob needs day
						minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, mob needs daylight!")
						return
					end
				end
			end

			-- spawn above node
			pos.y = pos.y + 1

			-- only spawn away from player
			local objs = minetest.get_objects_inside_radius(pos, 24)

			for n = 1, #objs do

				if objs[n]:is_player() then
					-- player too close
					minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, player too close!")
					return
				end
			end

			-- mobs cannot spawn in protected areas when enabled
			if not spawn_protected
			and minetest.is_protected(pos, "") then
				minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, position is protected!")
				return
			end

			-- are we spawning within height limits?
			if pos.y > max_height
			or pos.y < min_height then
				minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, out of height limit!")
				return
			end

			-- are light levels ok?
			local light = minetest.get_node_light(pos)
			if not light
			or light > max_light
			or light < min_light then
				minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, bad light!")
				return
			end

			-- do we have enough space to spawn mob?
			local ent = minetest.registered_entities[name]
			local width_x = max(1, math.ceil(ent.collisionbox[4] - ent.collisionbox[1]))
			local min_x, max_x
			if width_x % 2 == 0 then
				max_x = math.floor(width_x/2)
				min_x = -(max_x-1)
			else
				max_x = math.floor(width_x/2)
				min_x = -max_x
			end

			local width_z = max(1, math.ceil(ent.collisionbox[6] - ent.collisionbox[3]))
			local min_z, max_z
			if width_z % 2 == 0 then
				max_z = math.floor(width_z/2)
				min_z = -(max_z-1)
			else
				max_z = math.floor(width_z/2)
				min_z = -max_z
			end

			local max_y = max(0, math.ceil(ent.collisionbox[5] - ent.collisionbox[2]) - 1)

			for y = 0, max_y do
				for x = min_x, max_x do
					for z = min_z, max_z do
						local pos2 = {x = pos.x+x, y = pos.y+y, z = pos.z+z}
						if minetest.registered_nodes[node_ok(pos2).name].walkable == true then
							-- inside block
							minetest.log("info", "Mob spawn of "..name.." at "..minetest.pos_to_string(pos).." failed, too little space!")
							if ent.spawn_small_alternative ~= nil and (not minetest.registered_nodes[node_ok(pos).name].walkable) then
								minetest.log("info", "Trying to spawn smaller alternative mob: "..ent.spawn_small_alternative)
								spawn_action(orig_pos, node, active_object_count, active_object_count_wider, ent.spawn_small_alternative)
							end
							return
						end
					end
				end
			end

			-- tweak X/Y/Z spawn pos
			if width_x % 2 == 0 then
				pos.x = pos.x + 0.5
			end
			if width_z % 2 == 0 then
				pos.z = pos.z + 0.5
			end
			pos.y = pos.y - 0.5

			local mob = minetest.add_entity(pos, name)
			minetest.log("action", "Mob spawned: "..name.." at "..minetest.pos_to_string(pos))

			if on_spawn then

				local ent = mob:get_luaentity()

				on_spawn(ent, pos)
			end
	end

	local function spawn_abm_action(pos, node, active_object_count, active_object_count_wider)
		spawn_action(pos, node, active_object_count, active_object_count_wider, name)
	end
	]]--

	local entdef = minetest.registered_entities[name]
	local spawn_class
	if entdef.type == "monster" then
		spawn_class = "hostile"
	else
		spawn_class = "passive"
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
	spawn_dictionary[key]["interval"]   = interval
	spawn_dictionary[key]["chance"]     = chance
	spawn_dictionary[key]["aoc"]        = aoc
	spawn_dictionary[key]["min_height"] = min_height
	spawn_dictionary[key]["max_height"] = max_height
	spawn_dictionary[key]["day_toggle"] = day_toggle
	--spawn_dictionary[key]["on_spawn"]   = spawn_abm_action
	spawn_dictionary[key]["spawn_class"] = spawn_class

	--[[
	minetest.register_abm({
		label = name .. " spawning",
		nodenames = nodes,
		neighbors = neighbors,
		interval = interval,
		chance = floor(max(1, chance * mobs_spawn_chance)),
		catch_up = false,
		action = spawn_abm_action,
	})
	]]--
end

-- compatibility with older mob registration
-- we're going to forget about this for now -j4i
--[[
function mobs:register_spawn(name, nodes, max_light, min_light, chance, active_object_count, max_height, day_toggle)

	mobs:spawn_specific(name, nodes, {"air"}, min_light, max_light, 30,
		chance, active_object_count, -31000, max_height, day_toggle)
end
]]--


--Don't disable this yet-j4i
-- MarkBu's spawn function

function mobs:spawn(def)
	--does nothing for now
	--[[
	local name = def.name
	local nodes = def.nodes or {"group:soil", "group:stone"}
	local neighbors = def.neighbors or {"air"}
	local min_light = def.min_light or 0
	local max_light = def.max_light or 15
	local interval = def.interval or 30
	local chance = def.chance or 5000
	local active_object_count = def.active_object_count or 1
	local min_height = def.min_height or -31000
	local max_height = def.max_height or 31000
	local day_toggle = def.day_toggle
	local on_spawn = def.on_spawn

	mobs:spawn_specific(name, nodes, neighbors, min_light, max_light, interval,
		chance, active_object_count, min_height, max_height, day_toggle, on_spawn)
		]]--
end



local axis
--inner and outer part of square donut radius
local inner = 15
local outer = 64
local int = {-1,1}
local position_calculation = function(pos)

	pos = vector_floor(pos)

	--this is used to determine the axis buffer from the player
	axis = math_random(0,1)

	--cast towards the direction
	if axis == 0 then --x
		pos.x = pos.x + math_random(inner,outer)*int[math_random(1,2)]
		pos.z = pos.z + math_random(-outer,outer)
	else --z
		pos.z = pos.z + math_random(inner,outer)*int[math_random(1,2)]
		pos.x = pos.x + math_random(-outer,outer)
	end
	return(pos)
end

--[[
local decypher_limits_dictionary = {
	["overworld"] = {mcl_vars.mg_overworld_min,mcl_vars.mg_overworld_max},
	["nether"]    = {mcl_vars.mg_nether_min,   mcl_vars.mg_nether_max},
	["end"]       = {mcl_vars.mg_end_min,      mcl_vars.mg_end_max}
}
]]--

local function decypher_limits(posy)
	--local min_max_table = decypher_limits_dictionary[dimension]
	--return min_max_table[1],min_max_table[2]
	posy = math_floor(posy)
	return posy - 32, posy + 32
end

--a simple helper function for mob_spawn
local function biome_check(biome_list, biome_goal)
	for _,data in ipairs(biome_list) do
		if data == biome_goal then
			return true
		end
	end

	return false
end


--todo mob limiting
--MAIN LOOP

if mobs_spawn then
	local timer = 0
	minetest.register_globalstep(function(dtime)
		timer = timer + dtime
		if timer >= 10 then
			timer = 0
			for _,player in pairs(minetest.get_connected_players()) do
				-- after this line each "break" means "continue"
				local do_mob_spawning = true
				repeat
					--don't need to get these variables more than once
					--they happen in a single server step

					local player_pos = player:get_pos()
					local _,dimension = mcl_worlds.y_to_layer(player_pos.y)

					if dimension == "void" or dimension == "default" then
						break -- ignore void and unloaded area
					end

					local min,max = decypher_limits(player_pos.y)

					for i = 1,math_random(1,4) do
						-- after this line each "break" means "continue"
						local do_mob_algorithm = true
						repeat

							local goal_pos = position_calculation(player_pos)

							local spawning_position_list = find_nodes_in_area_under_air(vector_new(goal_pos.x,min,goal_pos.z), vector_new(goal_pos.x,max,goal_pos.z), {"group:solid", "group:water", "group:lava"})

							--couldn't find node
							if #spawning_position_list <= 0 then
								break
							end

							local spawning_position = spawning_position_list[math_random(1,#spawning_position_list)]

							--Prevent strange behavior   --- this is commented out: /too close to player --fixed with inner circle
							if not spawning_position then --  or vector_distance(player_pos, spawning_position) < 15 
								break
							end
							
							--hard code mob limit in area to 5 for now
							if count_mobs(spawning_position) >= 5 then
								break
							end

							local gotten_node = get_node(spawning_position).name

							if not gotten_node or gotten_node == "air" then --skip air nodes
								break
							end

							local gotten_biome = minetest.get_biome_data(spawning_position)

							if not gotten_biome then
								break --skip if in unloaded area
							end

							gotten_biome = get_biome_name(gotten_biome.biome) --makes it easier to work with

							--add this so mobs don't spawn inside nodes
							spawning_position.y = spawning_position.y + 1

							--only need to poll for node light if everything else worked
							local gotten_light = get_node_light(spawning_position)

							local is_water = get_item_group(gotten_node, "water") ~= 0
							local is_lava  = get_item_group(gotten_node, "lava") ~= 0

							local mob_def = nil
							
							--create a disconnected clone of the spawn dictionary
							--prevents memory leak
							local mob_library_worker_table = table_copy(spawn_dictionary)

							--grab mob that fits into the spawning location
							--randomly grab a mob, don't exclude any possibilities
							local repeat_mob_search = true
							repeat

								--do not infinite loop
								if #mob_library_worker_table <= 0 then
									--print("breaking infinite loop")
									break
								end

								local skip = false

								--use this for removing table elements of mobs that do not match
								local temp_index = math_random(1,#mob_library_worker_table)

								local temp_def = mob_library_worker_table[temp_index]

								--skip if something ridiculous happens (nil mob def)
								--something truly horrible has happened if skip gets
								--activated at this point
								if not temp_def then
									skip = true
								end

								if not skip and (spawning_position.y < temp_def.min_height or spawning_position.y > temp_def.max_height) then
									skip = true
								end

								--skip if not correct dimension
								if not skip and (temp_def.dimension ~= dimension) then
									skip = true
								end

								--skip if not in correct biome
								if not skip and (not biome_check(temp_def.biomes, gotten_biome)) then
									skip = true
								end

								--don't spawn if not in light limits
								if not skip and (gotten_light < temp_def.min_light or gotten_light > temp_def.max_light) then
									skip = true
								end

								--skip if not in correct spawning type
								if not skip and (temp_def.type_of_spawning == "ground" and is_water) then
									skip = true
								end

								if not skip and (temp_def.type_of_spawning == "ground" and is_lava) then
									skip = true
								end

								--found a mob, exit out of loop
								if not skip then
									--minetest.log("warning", "found mob:"..temp_def.name)
									--print("found mob:"..temp_def.name)
									mob_def = table_copy(temp_def)
									break
								else
									--minetest.log("warning", "deleting temp index "..temp_index)
									--print("deleting temp index")
									table_remove(mob_library_worker_table, temp_index)
								end

							until repeat_mob_search == false --this is needed to sort through mobs randomly


							--catch if went through all mobs and something went horribly wrong
							--could not find a valid mob to spawn that fits the environment
							if not mob_def then
								break
							end

							--adjust the position for water and lava mobs
							if mob_def.type_of_spawning == "water"  or mob_def.type_of_spawning == "lava" then
								spawning_position.y = spawning_position.y - 1
							end

							--print("spawning: " .. mob_def.name)

							--everything is correct, spawn mob
							minetest.add_entity(spawning_position, mob_def.name)

							break
						until do_mob_algorithm == false --this is a safety catch
					end

					break
				until do_mob_spawning == false --this is a performance catch
			end
		end
	end)
end
