--[[ 

THIS IS THE BIG LIST OF ALL BIOMES - used for programming/updating mobs

underground:
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




local mobs_spawn = minetest.settings:get_bool("mobs_spawn", true) ~= false
-- count how many mobs of one type are inside an area
--[[
local count_mobs = function(pos, mobtype)

	local num = 0
	local objs = minetest.get_objects_inside_radius(pos, aoc_range)

	for n = 1, #objs do

		local obj = objs[n]:get_luaentity()

		if obj and obj.name and obj._cmi_is_mob then

			-- count passive mobs only
			if mobtype == "!passive" then
				if obj.spawn_class == "passive" then
					num = num + 1
				end
			-- count hostile mobs only
			elseif mobtype == "!hostile" then
				if obj.spawn_class == "hostile" then
					num = num + 1
				end
			-- count ambient mobs only
			elseif mobtype == "!ambient" then
				if obj.spawn_class == "ambient" then
					num = num + 1
				end
			-- count water mobs only
			elseif mobtype == "!water" then
				if obj.spawn_class == "water" then
					num = num + 1
				end
			-- count mob type
			elseif mobtype and obj.name == mobtype then
				num = num + 1
			-- count total mobs
			elseif not mobtype then
				num = num + 1
			end
		end
	end

	return num
end
]]--

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


	--load information into the spawn dictionary

	--allow for new dimensions to be auto added
	--this will take extra time, a whole few nanoseconds
	--but will allow modularity

	--build dimensions modularly
	if not spawn_dictionary[dimension] then
		spawn_dictionary[dimension] = {}
	end

	--build biome list modularly
	for _,added_biome in pairs(biomes) do
		if not spawn_dictionary[dimension][added_biome] then
			spawn_dictionary[dimension][added_biome] = {}
		end

		--build type of spawning per biome modularly
		if not spawn_dictionary[dimension][added_biome][type_of_spawning] then
			spawn_dictionary[dimension][added_biome][type_of_spawning] = {}
		end

		--build light levels to spawn mob
		for i = min_light,max_light do
			if not spawn_dictionary[dimension][added_biome][type_of_spawning][i] then
				spawn_dictionary[dimension][added_biome][type_of_spawning][i] = {}
			end

			for y = min_height, max_height do
				--print(y)
			end
		end
	end

	

	--[[
	local key = #spawn_dictionary[dimension] + 1

	spawn_dictionary[dimension][key] = {}
	spawn_dictionary[dimension][key]["name"]       = name
	spawn_dictionary[dimension][key]["type"]       = type_of_spawning
	spawn_dictionary[dimension][key]["min_light"]  = min_light
	spawn_dictionary[dimension][key]["max_light"]  = max_light
	spawn_dictionary[dimension][key]["interval"]   = interval
	spawn_dictionary[dimension][key]["chance"]     = chance
	spawn_dictionary[dimension][key]["aoc"]        = aoc
	spawn_dictionary[dimension][key]["min_height"] = min_height
	spawn_dictionary[dimension][key]["max_height"] = max_height
	spawn_dictionary[dimension][key]["day_toggle"] = day_toggle
	spawn_dictionary[dimension][key]["on_spawn"]   = spawn_abm_action
	]]--
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
local inner = 1
local outer = 70
local int = {-1,1}
local position_calculation = function(pos)

	pos = vector.floor(pos)

	--this is used to determine the axis buffer from the player
	axis = math.random(0,1)

	--cast towards the direction
	if axis == 0 then --x
		pos.x = pos.x + math.random(inner,outer)*int[math.random(1,2)]
		pos.z = pos.z + math.random(-outer,outer)
	else --z
		pos.z = pos.z + math.random(inner,outer)*int[math.random(1,2)]
		pos.x = pos.x + math.random(-outer,outer)
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
	posy = math.floor(posy)
	return posy - 32, posy + 32
end
--[[
minetest.register_on_mods_loaded(function()
	for _,data in pairs(minetest.registered_biomes) do
		print(data.name)
	end

    print(dump(spawn_dictionary))
end)
]]--

--todo mob limiting
--MAIN LOOP
--[[
if mobs_spawn then
    local timer = 15 --0
    minetest.register_globalstep(function(dtime)
        timer = timer + dtime
        if timer >= 15 then
            timer = 15--0
            for _,player in ipairs(minetest.get_connected_players()) do
                for i = 1,math.random(5) do
                    local player_pos = player:get_pos()
                    local _,dimension = mcl_worlds.y_to_layer(player_pos.y)

				    if dimension == "void" or dimension == "default" then
                        goto continue -- ignore void and unloaded area
				    end
					

                    local min,max = decypher_limits(player_pos.y)

                    local goal_pos = position_calculation(player_pos)
                    
                    local gotten_biome = minetest.get_biome_data(goal_pos)

                    if not gotten_biome then
                        goto continue --skip if in unloaded area
                    end

                    print(minetest.get_biome_name(gotten_biome.biome))

                    local mob_def = spawn_dictionary[dimension][math.random(1,#spawn_dictionary[dimension])]

                    if not mob_def then --to catch a crazy error if it ever happens
                        minetest.log("error", "WARNING!! Attempted to spawn a mob that doesn't exist! Please notify developers!\nThe game will continue to run though.")
                        goto continue
                    end

                    if mob_def.type == "ground" then

                        local spawning_position_list = minetest.find_nodes_in_area_under_air(vector.new(goal_pos.x,min,goal_pos.z), vector.new(goal_pos.x,max,goal_pos.z), {"group:solid"})

                        if #spawning_position_list <= 0 then
                            goto continue
                        end
                        
                        local spawning_position = spawning_position_list[math.random(1,#spawning_position_list)]

                        spawning_position.y = spawning_position.y + 1

                        local gotten_light = minetest.get_node_light(spawning_position)

                        if gotten_light and gotten_light >= mob_def.min_light and gotten_light <= mob_def.max_light then
                            minetest.add_entity(spawning_position, mob_def.name)
                        end
                    elseif mob_def.type == "air" then
                        local spawning_position_list = minetest.find_nodes_in_area(vector.new(goal_pos.x,min,goal_pos.z), vector.new(goal_pos.x,max,goal_pos.z), {"air"})

                        if #spawning_position_list <= 0 then
                            goto continue
                        end
                        
                        local spawning_position = spawning_position_list[math.random(1,#spawning_position_list)]

                        local gotten_light = minetest.get_node_light(spawning_position)

                        if gotten_light and gotten_light >= mob_def.min_light and gotten_light <= mob_def.max_light then
                            minetest.add_entity(spawning_position, mob_def.name)
                        end
                    elseif mob_def.type == "water" then
                        local spawning_position_list = minetest.find_nodes_in_area(vector.new(goal_pos.x,min,goal_pos.z), vector.new(goal_pos.x,max,goal_pos.z), {"group:water"})

                        if #spawning_position_list <= 0 then
                            goto continue
                        end
                        
                        local spawning_position = spawning_position_list[math.random(1,#spawning_position_list)]

                        local gotten_light = minetest.get_node_light(spawning_position)

                        if gotten_light and gotten_light >= mob_def.min_light and gotten_light <= mob_def.max_light then
                            minetest.add_entity(spawning_position, mob_def.name)
                        end
                    --elseif mob_def.type == "lava" then
                        --implement later
                    end
                    --local spawn minetest.find_nodes_in_area_under_air(vector.new(pos.x,pos.y-find_node_height,pos.z), vector.new(pos.x,pos.y+find_node_height,pos.z), {"group:solid"})

                    ::continue:: --this is a safety catch
                end
            end
        end
    end)
end
]]--